
package body Microbit.PinInterrupt is


   protected body PinInterrupt is


      entry Wait when released is
      begin
         released := False;
      end Wait;



      procedure PinInterruptHandler is

      begin


         if(nRF.Events.Triggered(evtType)) then
            nRF.Events.Clear(evtType);
            released := True;
         end if;

      end PinInterruptHandler;

      procedure AttachToPinToChannel(pin : in nRF.GPIO.GPIO_Pin_Index;
                                     channel : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel;
                                     polarity : in nRF.GPIO.Tasks_And_Events.Event_Polarity) is
      begin
         nRF.GPIO.Tasks_And_Events.Enable_Event(channel, pin, polarity);
         nRF.Interrupts.Enable(nRF.Interrupts.GPIOTE_Interrupt);

         case channel is
            when 0 =>
               evtType := nRF.Events.GPIOTE_IN_0;
            when 1 =>
               evtType := nRF.Events.GPIOTE_IN_1;
            when 2 =>
               evtType := nRF.Events.GPIOTE_IN_2;
            when 3 =>
               evtType := nRF.Events.GPIOTE_IN_3;
         end case;
         nRF.Events.Enable_Interrupt(evtType);

      end AttachToPinToChannel;



   end PinInterrupt;
end Microbit.PinInterrupt;
