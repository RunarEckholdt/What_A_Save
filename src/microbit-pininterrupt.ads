with nRF.GPIO.Tasks_And_Events;
with nRF.Interrupts;
with nRF.GPIO;
with Ada.Interrupts.Names;
with System;
with nRF.Events;

package Microbit.PinInterrupt is




   protected PinInterrupt is

      entry Wait;

      procedure PinInterruptHandler;
      procedure AttachToPinToChannel(pin : in nRF.GPIO.GPIO_Pin_Index;
                                     channel : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel;
                                     polarity : in nRF.GPIO.Tasks_And_Events.Event_Polarity);



      pragma Attach_Handler(PinInterruptHandler, Ada.Interrupts.Names.GPIOTE_Interrupt);
      pragma Interrupt_Priority (System.Interrupt_Priority'First);
   private
      released : Boolean := False;


   end PinInterrupt;

end Microbit.PinInterrupt;
