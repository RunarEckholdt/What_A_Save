with ADA.Real_Time; use ADA.Real_Time;
with nRF.GPIO;
with MicroBit.IOsForTasking; use MicroBit.IOsForTasking;
with MicroBit.Console;
with MicroBit.PinInterrupt;
with Ada.Interrupts.Names;
with nRF.Events;
with nRF.GPIO.Tasks_And_Events;
with Ada.Synchronous_Task_Control;
with System;

--https://create.arduino.cc/projecthub/abdularbi17/ultrasonic-sensor-hc-sr04-with-arduino-tutorial-327ff6


package HCSR04 is
   type InterruptEvent is (rising,falling,change);

   subtype Pin is MicroBit.IOsForTasking.Pin_Id
   		with Predicate => Supports(Pin, Analog);

   protected EchoHandlerInterface is

      entry Wait;

      procedure EchoHandler with Attach_Handler => Ada.Interrupts.Names.GPIOTE_Interrupt;
      pragma Interrupt_Priority (253); --Priority 3
      procedure setEventType(et : in nRF.Event_Type);
      procedure FetchInterruptTimestamp(t : out Time);

   private
      released : Boolean := False;
      evtType : nRF.Event_Type;
      interruptedTime : Time;
   end EchoHandlerInterface;


   type UnitOfMeasure is (METER, CM, MM);

   type HCSR04 is record
      echo, trig : Pin;
   end record;


   procedure initializeInterrupt(hc : in HCSR04; channel : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel);
   procedure measure(hc : in HCSR04; distance : out Float; result : out Boolean; uom : in UnitOfMeasure := METER);
   procedure trig(hc : in HCSR04);
   procedure pulseIn(hc : in HCSR04; pulseTime : out Time_Span; result : out Boolean);





end HCSR04;
