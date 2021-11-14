with nRF.GPIO.Tasks_And_Events;
with nRF.Interrupts;
with nRF.GPIO;
with Ada.Interrupts.Names;
with nRF.Events;
with MicroBit; use MicroBit;
with MicroBit.IOsForTasking; use MicroBit.IOsForTasking;

package Microbit.PinInterrupt is

   eventChannel0 : nRF.Event_Type renames nRF.Events.GPIOTE_IN_0;
   eventChannel1 : nRF.Event_Type renames nRF.Events.GPIOTE_IN_1;
   eventChannel2 : nRF.Event_Type renames nRF.Events.GPIOTE_IN_2;
   eventChannel3 : nRF.Event_Type renames nRF.Events.GPIOTE_IN_3;

   rising : nRF.GPIO.Tasks_And_Events.Event_Polarity renames nRF.GPIO.Tasks_And_Events.Rising_Edge;
   falling : nRF.GPIO.Tasks_And_Events.Event_Polarity renames nRF.GPIO.Tasks_And_Events.Falling_Edge;
   change : nRF.GPIO.Tasks_And_Events.Event_Polarity renames nRF.GPIO.Tasks_And_Events.Any_Change;


   type Pin_Id is range 0..34;



   --Attaches a pin to an GPIOTE channel and enables the event and interrupt
   procedure AttachPinToChannel(pin      : in Pin_Id;
                                channel  : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel;
                                polarity : in nRF.GPIO.Tasks_And_Events.Event_Polarity;
                                evtType  : out nRF.Event_Type );




private
   --Mapping between pin id and GPIO_Points

   PinIDToGPIOMap : array (Pin_Id) of nRF.GPIO.GPIO_Point :=
     (0  => MB_P0,
      1  => MB_P1,
      2  => MB_P2,
      3  => MB_P3,
      4  => MB_P4,
      5  => MB_P5,
      6  => MB_P6,
      7  => MB_P7,
      8  => MB_P8,
      9  => MB_P9,
      10 => MB_P10,
      11 => MB_P11,
      12 => MB_P12,
      13 => MB_P13,
      14 => MB_P14,
      15 => MB_P15,
      16 => MB_P16,
      17 => MB_P0,  --  There's no pin17, using P0 to fill in...
      18 => MB_P0,  --  There's no pin18, using P0 to fill in...
      19 => MB_P19,
      20 => MB_P20,
      21 => MB_P21,
      22 => MB_P22,
      23 => MB_P23,
      24 => MB_P24,
      25 => MB_P25,
      26 => MB_P26,
      27 => MB_P27,
      28 => MB_P28,
      29 => MB_P29,
      30 => MB_P30,
      31 => MB_P31,
      32 => MB_P32,
      33 => MB_P33,
      34 => MB_P34
     );




end Microbit.PinInterrupt;
