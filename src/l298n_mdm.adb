
package body L298N_MDM is
   
   procedure move(mdm : in L298N; direction : in dirId) is
       
   begin  
      case direction is
         when left =>
            MicroBit.IOsForTasking.Set(mdm.IN_1, true);
            MicroBit.IOsForTasking.Set(mdm.IN_2, false);
         when right =>
            MicroBit.IOsForTasking.Set(mdm.IN_1, false);
            MicroBit.IOsForTasking.Set(mdm.IN_2, true);
         when stop =>
            MicroBit.IOsForTasking.Set(mdm.IN_1, false);
            MicroBit.IOsForTasking.Set(mdm.IN_2, false);
      end case;
      
   end move;

end L298N_MDM;
