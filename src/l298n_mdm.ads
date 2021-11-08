
with ADA.Real_Time; use ADA.Real_Time;
with ADA.Interrupts;
with nRF.GPIO;
with MicroBit;
with MicroBit.IOsForTasking; use MicroBit.IOsForTasking;


package L298N_MDM is

   
   subtype Pin_D is MicroBit.IOsForTasking.Pin_Id
     with Predicate => Supports(Pin_D, Digital);
   subtype Pin_A is MicroBit.IOsForTasking.Pin_Id
     with Predicate => Supports(Pin_A, Analog);
   
   subtype speedControl is MicroBit.IOsForTasking.Analog_Value range 0..1023;
   
     
   type dirId is (left, right, stop);
           
   type L298N is record
      IN_1, IN_2   : Pin_D;
      SPD_1, SPD_2 : Pin_A;
   end record;
   
   
   
   
   procedure move(mdm : in L298N; direction : in dirId; spd : in speedControl); --dir is left, right, stop.
     
   

end L298N_MDM;
