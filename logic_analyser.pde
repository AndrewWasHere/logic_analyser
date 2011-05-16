/*
  LogicAnalyser
  
  Unit Test for LogicAnalyser class.
  If you're trying to use LogicAnalyser in your code, you do not need this sketch! Copy LogicAnalyser.cpp
  and .h into a directory called "LogicAnalyser" in your libraries directory, and include <LogicAnalyser.h>
  into your own sketch, or add them directly to your sketch.
  
  Written by Andrew Lin, May, 2011.
  
  This code is released under the Creative Commons Attribution 3.0 license
  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/us/ 
  or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
*/
#include <TimerOne.h>
#include "LogicAnalyser.h"

enum TestType { TEST_1, TEST_2, TEST_3, TEST_4, TEST_5, FINISHED };
const long samplePeriod = 5000; // Timer period in microseconds between interrupts.
const long togglePeriod = 250;  // Digital pin output toggle time in milliseconds.
const char * triggeredString = "Triggered."; // Inline string constants stored in RAM. Consolodating to conserve space...

TestType test;
LogicAnalyser la;

// timerISR()
// Interrupt service routine for the Timer1 interrupt.
void timerISR()
{
  la.timerEvent();
}

// addTrace_test()
// Test the addTrace() interface.
bool addTrace_test()
{
  Serial.println( "Testing addTrace()..." );
  la.reset();
  if ( la.addTrace( -1 ) )
  {
    Serial.println( "FAIL: Out of range pin ( value < 0 ) not caught." );
    return false;
  }
  
  if ( la.addTrace( 14 ) )
  {
    Serial.println( "FAIL: Out of range pin ( value > 13 ) not caught." );
    return false;
  }
  
  // These should work.
  for ( int idx = 1; idx <= 8; ++idx )
  {
    if ( !la.addTrace( idx ) )
    {
      Serial.print( "FAIL: #" );
      Serial.print( idx );
      Serial.println( " trace add was rejected." );
      return false;
    }
  }
  
  // This should not (already maxed out the traces).
  if ( la.addTrace( 9 ) )
  {
    Serial.println( "FAIL: 9th trace add not caught." );
    return false;
  }
  
  // Test passed. Hooray!
  return true;
}

// addTrigger_test()
// Test the addTrigger() interface.
bool addTrigger_test()
{
  Serial.println( "Testing addTrigger()..." );
  la.reset();
  
  if ( la.addTrigger( 1, LogicAnalyser::TRIGGER_HIGH ) )
  {
    Serial.println( "FAIL: added trigger for untraced pin." );
    return false;
  }
  
  la.addTrace( 2 );
  if ( !la.addTrigger( 2, LogicAnalyser::TRIGGER_LOW ) )
  {
    Serial.println( "FAIL: unable to add trigger for traced pin." );
    return false;
  }
  
  // Booya! Test passed.
  return true;
}

// TEST 1:
// Single line, trigger HIGH.
void test_1_setup()
{
  Serial.println( "Test 1: Trigger on HIGH" );
  test = TEST_1;

  // Configure digital pins.
  pinMode( 2, OUTPUT );
  digitalWrite( 2, LOW );

  // Configure the logic analyser.
  la.reset();
  la.setSamplePeriod( samplePeriod );
  la.addTrace( 2 );
  la.addTrigger( 2, LogicAnalyser::TRIGGER_HIGH );
  la.start();
}

void test_1_execute()
{
  static bool msgSent = false;
  
  digitalWrite( 2, digitalRead( 2 ) == HIGH ? LOW : HIGH );
  delay( togglePeriod );
  
  if ( !msgSent and la.isActive() )
  {
    msgSent = true;
    Serial.println( triggeredString );
  }
  
  if ( la.isDone() )
  {
    la.dump();
    Serial.println( "Test 1 complete." );
    test_2_setup();
  }
}

// TEST 2:
// Single line, trigger LOW.
void test_2_setup()
{
  Serial.println( "Test 2: Trigger on LOW" );
  test = TEST_2;

  // Configure digital pins.
  pinMode( 2, OUTPUT );
  digitalWrite( 2, HIGH );

  // Configure the logic analyser.
  la.reset();
  la.setSamplePeriod( samplePeriod );
  la.addTrace( 2 );
  la.addTrigger( 2, LogicAnalyser::TRIGGER_LOW );
  la.start();
}

void test_2_execute()
{
  static bool msgSent = false;

  digitalWrite( 2, digitalRead( 2 ) == HIGH ? LOW : HIGH );
  delay( togglePeriod );
  
  if ( !msgSent and la.isActive() )
  {
    msgSent = true;
    Serial.println( triggeredString );
  }
  
  if ( la.isDone() )
  {
    la.dump();
    Serial.println( "Test 2 complete." );
    test_3_setup();
  }
}

// TEST 3:
// Single line, trigger RISING EDGE.
void test_3_setup()
{
  Serial.println( "Test 3: Trigger on RISING EDGE" );
  test = TEST_3;

  // Configure digital pins.
  pinMode( 2, OUTPUT );
  digitalWrite( 2, LOW );

  // Configure the logic analyser.
  la.reset();
  la.setSamplePeriod( samplePeriod );
  la.addTrace( 2 );
  la.addTrigger( 2, LogicAnalyser::TRIGGER_RISING_EDGE );
  la.start();
}

void test_3_execute()
{
  static bool msgSent = false;

  digitalWrite( 2, digitalRead( 2 ) == HIGH ? LOW : HIGH );
  delay( togglePeriod );
  
  if ( !msgSent and la.isActive() )
  {
    msgSent = true;
    Serial.println( triggeredString );
  }
  
  if ( la.isDone() )
  {
    la.dump();
    Serial.println( "Test 3 complete." );
    test_4_setup();
  }
}

// Test 4:
// Single line, trigger FALLING EDGE.
void test_4_setup()
{
  Serial.println( "Test 4: Trigger on FALLING EDGE" );
  test = TEST_4;

  // Configure digital pins.
  pinMode( 2, OUTPUT );
  digitalWrite( 2, HIGH );

  // Configure the logic analyser.
  la.reset();
  la.setSamplePeriod( samplePeriod );
  la.addTrace( 2 );
  la.addTrigger( 2, LogicAnalyser::TRIGGER_FALLING_EDGE );
  la.start();
}

void test_4_execute()
{
  static bool msgSent = false;

  digitalWrite( 2, digitalRead( 2 ) == HIGH ? LOW : HIGH );
  delay( togglePeriod );
  
  if ( !msgSent and la.isActive() )
  {
    msgSent = true;
    Serial.println( triggeredString );
  }
  
  if ( la.isDone() )
  {
    la.dump();
    Serial.println( "Test 4 complete." );
    test_5_setup();
  }
}

// Test 5:
// Multi-line trigger FALLING and RISING EDGE.
void test_5_setup()
{
  Serial.println( "Test 5: Multi-line Trigger on FALLING and RISING EDGE" );
  test = TEST_5;

  // Configure digital pins.
  pinMode( 2, OUTPUT );
  digitalWrite( 2, HIGH );
  pinMode( 3, OUTPUT );
  digitalWrite( 3, LOW );

  // Configure the logic analyser.
  la.reset();
  la.setSamplePeriod( samplePeriod );
  la.addTrace( 2 );
  la.addTrigger( 2, LogicAnalyser::TRIGGER_FALLING_EDGE );
  la.addTrace( 3 );
  la.addTrigger( 3, LogicAnalyser::TRIGGER_RISING_EDGE );
  la.start();
}

void test_5_execute()
{
  static bool msgSent = false;

  digitalWrite( 2, digitalRead( 2 ) == HIGH ? LOW : HIGH );
  digitalWrite( 3, digitalRead( 3 ) == HIGH ? LOW : HIGH );
  delay( togglePeriod );
  
  if ( !msgSent and la.isActive() )
  {
    msgSent = true;
    Serial.println( triggeredString );
  }
  
  if ( la.isDone() )
  {
    la.dump();
    Serial.println( "Test 5 complete." );
    test = FINISHED;
  }
}

// setup()
// Get the Arduino house in order.
void setup()
{
  // Initialize serial communications.
  Serial.begin( 9600 );
  
  // Automated tests.
  if ( !addTrace_test() or !addTrigger_test() )
  {
    // Test failed. We can't exit, so we'll sit and spin instead.
    for ( ;; );
  }
  
  // Start the trigger tests (NOTE: These aren't automated!)
  test_1_setup();
  
  // Initialize Timer1 interrupt.
  Timer1.initialize( samplePeriod );
  Timer1.attachInterrupt( timerISR );
}

// loop()
// Watch Arduino chase its tail.
void loop()
{
  switch ( test )
  {
    case TEST_1:
      test_1_execute();
      break;
    case TEST_2:
      test_2_execute();
      break;
    case TEST_3:
      test_3_execute();
      break;
    case TEST_4:
      test_4_execute();
      break;
    case TEST_5:
      test_5_execute();
      break;
    case FINISHED:
      Serial.println( "Completed unit tests." );
      for ( ;; );
      break;
    default:
      Serial.println( "ERROR: Unknown test case." );
      for ( ;; );
      break;
  }
}
