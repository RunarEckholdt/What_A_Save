
with ADA.Real_Time; use ADA.Real_Time;
with ADA.Interrupts;
with nRF.GPIO;
with MicroBit;
with MicroBit.IOsForTasking; use MicroBit.IOsForTasking;


package L298N_MDM is

   
   subtype Pin_D is MicroBit.IOsForTasking.Pin_Id
     with Predicate => Supports(Pin, Digital);
   
   type dirId is (left, right, stop);
           
   type L298N is record
      IN_1, IN_2  : Pin_D;
   end record;
   
   
   
   
   procedure move(mdm : in L298N; direction : in dirId); --dir is left, right, stop.
     
   

end L298N_MDM;
