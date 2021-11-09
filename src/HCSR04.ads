with ADA.Real_Time; use ADA.Real_Time;
with nRF.GPIO;
with MicroBit;
with MicroBit.IOsForTasking; use MicroBit.IOsForTasking;
with MicroBit.Console;
with MicroBit.PinInterrupt;
with Ada.Interrupts.Names;
with nRF.Events;
with nRF.GPIO.Tasks_And_Events;

--https://create.arduino.cc/projecthub/abdularbi17/ultrasonic-sensor-hc-sr04-with-arduino-tutorial-327ff6


package HCSR04 is

   protected EchoHandlerInterface is
      entry Wait;
      procedure EchoHandler;
      procedure setEventType(et : in nRF.Event_Type);
      pragma Attach_Handler(EchoHandler,Ada.Interrupts.Names.GPIOTE_Interrupt);

   private
      released : Boolean := False;
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
