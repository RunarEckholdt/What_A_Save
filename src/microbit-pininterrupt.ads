with nRF.GPIO.Tasks_And_Events;
with nRF.Interrupts;
with nRF.GPIO;
with Ada.Interrupts.Names;
with System;
with nRF.Events;
with MicroBit.Console;

package Microbit.PinInterrupt is




   protected PinInterrupt is

      --Can be called by a task, will sleep until it is released by the interrupthandler.
      entry Wait;

      procedure PinInterruptHandler;

      --Used to attach a pin to an interrupt event on specified GPIOTE channel
      procedure AttachPinToChannel(  pin      : in nRF.GPIO.GPIO_Pin_Index;
                                     channel  : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel; -- 0..3
                                     polarity : in nRF.GPIO.Tasks_And_Events.Event_Polarity);



      pragma Attach_Handler(PinInterruptHandler, Ada.Interrupts.Names.GPIOTE_Interrupt);
      pragma Interrupt_Priority (System.Interrupt_Priority'First);
   private
      released : Boolean := False;
      evtType : nRF.Event_Type;


   end PinInterrupt;

end Microbit.PinInterrupt;
