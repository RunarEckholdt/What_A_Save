
package body Microbit.PinInterrupt is


   protected body PinInterrupt is


      entry Wait when released is
         begin
         released := False;
      end Wait;



      procedure PinInterruptHandler is
      begin

         nRF.Events.Clear(nRF.Events.GPIOTE_IN_0);
         released := True;
      end PinInterruptHandler;

      procedure AttachToPinToChannel(pin : in nRF.GPIO.GPIO_Pin_Index;
                                     channel : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel;
                                     polarity : in nRF.GPIO.Tasks_And_Events.Event_Polarity) is
      begin

         nRF.GPIO.Tasks_And_Events.Enable_Event(channel, pin, polarity);
         nRF.Interrupts.Enable(nRF.Interrupts.GPIOTE_Interrupt);
         nRF.Events.Enable_Interrupt(nRF.Events.GPIOTE_IN_0);

      end AttachToPinToChannel;



   end PinInterrupt;
end Microbit.PinInterrupt;
