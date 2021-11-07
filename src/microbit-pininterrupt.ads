with nRF.GPIO.Tasks_And_Events;
with nRF.Interrupts;
with nRF.GPIO;
with Ada.Interrupts.Names;
with nRF.Events;

package Microbit.PinInterrupt is

   eventChannel0 : nRF.Event_Type renames nRF.Events.GPIOTE_IN_0;
   eventChannel1 : nRF.Event_Type renames nRF.Events.GPIOTE_IN_1;
   eventChannel2 : nRF.Event_Type renames nRF.Events.GPIOTE_IN_2;
   eventChannel3 : nRF.Event_Type renames nRF.Events.GPIOTE_IN_3;



   --Attaches a pin to an GPIOTE channel and enables the event and interrupt
   procedure AttachToPinToChannel(pin : in nRF.GPIO.GPIO_Pin_Index;
                                  channel : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel;
                                  polarity : in nRF.GPIO.Tasks_And_Events.Event_Polarity;
                                  evtType : out nRF.Event_Type );








end Microbit.PinInterrupt;
