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
with timeout;
with Timed_Conditions;  use Timed_Conditions;

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

   private
      Sendt : Timed_Condition;
      released : Boolean := False;
      evtType : nRF.Event_Type;
      Timeout_en : Boolean := False;
      Timeout: Ada.Real_Time.Time;

   end EchoHandlerInterface;


   type HCSR04 is record
      echo, trig : Pin;
   end record;


   procedure initializeInterrupt(hc : in HCSR04; channel : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel);
   procedure measure(hc : in HCSR04; distance : out Float; result : out Boolean);
   procedure trig(hc : in HCSR04);
   procedure pulseIn(hc : in HCSR04; pulseTime : out Time_Span; result : out Boolean);





end HCSR04;
