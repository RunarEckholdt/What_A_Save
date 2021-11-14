with ADA.Real_Time; use ADA.Real_Time;
with nRF.GPIO;
with MicroBit;
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
   --  Procedure Wait;
   --  released : Ada.Synchronous_Task_Control.Suspension_Object;
   type InterruptEvent is (rising,falling,change);

   protected EchoHandlerInterface is

      entry Wait;
      --  entry Signal(intrEvent : in InterruptEvent);
      --
      --  procedure AcceptSignal(intrEvent : out InterruptEvent);

      procedure EchoHandler with Attach_Handler => Ada.Interrupts.Names.GPIOTE_Interrupt;
      pragma Interrupt_Priority (253);
      procedure setEventType(et : in nRF.Event_Type);
      --pragma Attach_Handler(EchoHandler,Ada.Interrupts.Names.GPIOTE_Interrupt);
      --procedure getLastEvent(lEvent : out InterruptEvent);

   private
      released : Boolean := False;
      --lastEvent : InterruptEvent;

      evtType : nRF.Event_Type;
   end EchoHandlerInterface;


   subtype Pin is MicroBit.IOsForTasking.Pin_Id
   		with Predicate => Supports(Pin, Analog);

   type HCSR04 is record
      echo, trig : Pin;
   end record;


   procedure initializeInterrupt(hc : in HCSR04; channel : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel);
   procedure measure(hc : in HCSR04; distance : out Float; result : out Boolean);
   procedure trig(hc : in HCSR04);
   procedure pulseIn(hc : in HCSR04; pulseTime : out Time_Span; result : out Boolean);





end HCSR04;
