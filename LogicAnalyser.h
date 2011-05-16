/*
  LogicAnalyser.h
  
  Class to capture the state of the digital pins on the Arudino like a logic analyser.
  
  Written by Andrew Lin, May, 2011.
  
  This code is released under the Creative Commons Attribution 3.0 license
  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/us/ 
  or send a letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
*/
#ifndef LOGICANALYSER_H
#define LOGICANALYSER_H

class LogicAnalyser
{
  public:
  enum TriggerType { TRIGGER_RISING_EDGE, TRIGGER_FALLING_EDGE, TRIGGER_HIGH, TRIGGER_LOW };
  
  // LogicAnalyser()
  //
  // Constructor
  LogicAnalyser();
  
  // addTrace()
  //
  // Add a pin to trace.
  bool addTrace( const int pin );
  
  // addTrigger()
  //
  // Add a trigger condition to the trace.
  bool addTrigger( const int pin, const TriggerType trigger );
  
  // dump()
  //
  // Dump the collected data over the serial connection.
  void dump();
  
  // isActive()
  // Returns:
  //   true - Logic Analyser is actively collecting data.
  //   false - Logic Analyser is not actively collecting data.
  //
  // Query the LogicAnalyser to see if it's busy or not.
  bool isActive();
  
  // isDone()
  // Returns:
  //   true - Logic Analyser has finished collecting data.
  //   false - Logic Analyser has not finished collecting data.
  bool isDone();
  
  // reset()
  //
  // Clear all logic analyser settings.
  void reset();
  
  // setSamplePeriod()
  // Arguments:
  //   period - Sample period in microseconds.
  //
  // Informs the logic analyser what the sample period is. Outputs this value in the dump.
  void setSamplePeriod( const long & period );
  
  // start()
  //
  // Start the trace.
  void start();
  
  // timerEvent()
  //
  // A timer ISR should call this event.
  void timerEvent();
  
  private:
  enum State { WAITING_FOR_TRIGGER, TRACING, DONE };
  
  // NOTE: OpenOffice can't handle more than 1012 columns, so you might want to keep the
  // sample size under that.
  static const unsigned int traceSize = 500;

  long         samplePeriod;
  State        state;
  bool         isFirstSample;
  unsigned int activeTraceCount;
  unsigned int traceInsertPos;
  
  int           activeTrace[ 8 ];  
  unsigned char triggerSetting[ 3 ];
  unsigned char trace[ traceSize ];
};

#endif
