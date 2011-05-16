/*
  LogicAnalyser.cpp
  
  Class to capture the state of the digital pins on the Arudino like a logic analyser.
  
  Written by Andrew Lin, May, 2011.
  
  This code is released under the Creative Commons Attribution 3.0 license
  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/us/ 
  or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
*/
#include <WProgram.h>
#include "LogicAnalyser.h"

LogicAnalyser::LogicAnalyser() :
  samplePeriod( 0 ),
  state( DONE ),
  isFirstSample( false ),
  activeTraceCount( 0 ),
  traceInsertPos( 0 )
{
  reset();
}

bool LogicAnalyser::addTrace( const int pin )
{
  // NOTE: We do not do duplicate detection on pins. This is deliberate because it allows us
  // to test for jitter between samples in the same interrupt if we so desire.
  
  // Sanity check the pin number and number of traces.
  if ( pin >= 0 and pin <= 13 and activeTraceCount < 8 )
  {
    activeTrace[ activeTraceCount++ ] = pin;
    
    return true;
  }
  
  // Something is rotten in the state of Denmark.
  return false;
}

bool LogicAnalyser::addTrigger( const int pin, const TriggerType trigger )
{
  for ( unsigned int idx = 0; idx < activeTraceCount; ++idx )
  {
    if ( activeTrace[ idx ] == pin )
    {
      // Requested pin found. Turn on trigger.
      triggerSetting[ 0 ] |= ( 1 << idx );
      
      switch ( trigger )
      {
        case TRIGGER_RISING_EDGE:
          // Look for first sample LOW, second sample HIGH.
          triggerSetting[ 1 ] &= ~( 1 << idx );
          triggerSetting[ 2 ] |= ( 1 << idx );
          break;
        case TRIGGER_FALLING_EDGE:
          // Look for first sample HIGH, second sample LOW.
          triggerSetting[ 1 ] |= ( 1 << idx );
          triggerSetting[ 2 ] &= ~( 1 << idx );
          break;
        case TRIGGER_HIGH:
          // Look for both samples HIGH.
          triggerSetting[ 1 ] |= ( 1 << idx );
          triggerSetting[ 2 ] |= ( 1 << idx );
          break;
        case TRIGGER_LOW:
          // Look for both samples LOW.
          triggerSetting[ 1 ] &= ~( 1 << idx );
          triggerSetting[ 2 ] &= ~( 1 << idx );
          break;
        default:
          // Unknown trigger.
          return false;
      }
      
      return true;
    }
  }
  
  // Requested pin not found.
  return false;
}

void LogicAnalyser::dump()
{
  // "Sample Period: N microseconds"
  Serial.print( "Sample Period:, " );
  Serial.print( samplePeriod );
  Serial.println( ", microseconds" );
  
  // ", 0, 1, 2, ... traceSize - 1"
  Serial.print( ", " );
  for ( unsigned int idx = 0; idx < traceSize - 1; ++idx )
  {
    Serial.print( idx );
    Serial.print( ", " );
  }
  Serial.println( traceSize - 1 );
  
  // "Pin N, 0, 1, 1, 0, 0, ..."
  for ( unsigned int traceIdx = 0; traceIdx < activeTraceCount; ++traceIdx )
  {
    Serial.print( "Pin " );
    Serial.print( activeTrace[ traceIdx ] );
    Serial.print( ", " );
    
    for ( unsigned int idx = 0; idx < traceSize - 1; ++idx )
    {
      Serial.print( ( trace[ idx ] & ( 1 << traceIdx ) ) == 0 ? 0 : 1 );
      Serial.print( ", " );
    }
    Serial.println( ( trace[ traceSize - 1 ] & ( 1 << traceIdx ) ) == 0 ? 0 : 1 );
  }
}

bool LogicAnalyser::isActive()
{
  return ( state == TRACING );
}

bool LogicAnalyser::isDone()
{
  return ( state == DONE );
}

void LogicAnalyser::setSamplePeriod( const long & period )
{
  samplePeriod = period;
}

void LogicAnalyser::reset()
{
  noInterrupts();
  state = DONE;
  interrupts();
  
  samplePeriod = 0;
  isFirstSample = false;
  activeTraceCount = 0;
  traceInsertPos = 0;
  triggerSetting[ 0 ] = triggerSetting[ 1 ] = triggerSetting[ 2 ] = 0;
}

void LogicAnalyser::start()
{
  // Reset some variables in case this is not our first time running.
  noInterrupts();
  traceInsertPos = 2;
  memset( trace, 0, traceSize );
  isFirstSample = true;
  state = WAITING_FOR_TRIGGER;
  interrupts();
}

void LogicAnalyser::timerEvent()
{
  switch ( state )
  {
    case WAITING_FOR_TRIGGER:
      // Sample the lines.
      trace[ 0 ] = trace[ 1 ]; // Remember last read.
      trace[ 1 ] = 0;          // Clear trace[ 1 ] to get an accurate read.
      for ( unsigned int idx = 0; idx < activeTraceCount; ++idx )
      {
        trace[ 1 ] |= ( digitalRead( activeTrace[ idx ] ) == HIGH ? 1 : 0 ) << idx;
      }
      
      if ( isFirstSample )
      {
        // First time through, we do nothing else.
        isFirstSample = false;
      }
      else
      {
        // Subsequent times through, we check for the trigger condition.
        if ( ( triggerSetting[ 1 ] == ( triggerSetting[ 0 ] & trace[ 0 ] ) ) and
             ( triggerSetting[ 2 ] == ( triggerSetting[ 0 ] & trace[ 1 ] ) ) )
        {
          // Trigger condition(s) met.
          state = TRACING;
        }
      }
      break;
    case TRACING:
      // Sample the lines and store.
      for ( unsigned int idx = 0; idx < activeTraceCount; ++idx )
      {
        trace[ traceInsertPos ] |= ( digitalRead( activeTrace[ idx ] ) == HIGH ? 1 : 0 ) << idx;
      }
      
      if ( ++traceInsertPos >= traceSize )
      {
        state = DONE;
      }
      break;
    case DONE:
      // Do nothing. Yes, really.
      break;
  }
}

