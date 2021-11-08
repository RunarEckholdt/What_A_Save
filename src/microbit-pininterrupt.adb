
package body Microbit.PinInterrupt is


      procedure AttachPinToChannel(pin : in nRF.GPIO.GPIO_Pin_Index;
                                     channel : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel;
                                     polarity : in nRF.GPIO.Tasks_And_Events.Event_Polarity;
                                     evtType : out nRF.Event_Type ) is

      begin
         nRF.GPIO.Tasks_And_Events.Enable_Event(channel, pin, polarity);
         nRF.Interrupts.Enable(nRF.Interrupts.GPIOTE_Interrupt);

         case channel is
            when 0 => evtType := eventChannel0;
            when 1 => evtType := eventChannel1;
            when 2 => evtType := eventChannel2;
            when 3 => evtType := eventChannel3;
         end case;
         nRF.Events.Enable_Interrupt(evtType);

      end AttachPinToChannel;


end Microbit.PinInterrupt;
