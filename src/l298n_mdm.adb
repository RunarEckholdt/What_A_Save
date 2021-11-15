
package body L298N_MDM is
   
   procedure move(mdm : in L298N; direction : in dirId; spd : in speedControl) is
       
   begin  
      
      case direction is --if you want more speed modes; you can add new directions and cases.
         
         when left =>
            MicroBit.IOsForTasking.Write(mdm.SPD_1, spd); --Write is for analog
            MicroBit.IOsForTasking.Set(mdm.IN_1, true);
            MicroBit.IOsForTasking.Set(mdm.IN_2, false);
         when right =>
            MicroBit.IOsForTasking.Write(mdm.SPD_1, spd);
            MicroBit.IOsForTasking.Set(mdm.IN_1, false);
            MicroBit.IOsForTasking.Set(mdm.IN_2, true);
         when stop =>
            MicroBit.IOsForTasking.Set(mdm.IN_1, false);
            MicroBit.IOsForTasking.Set(mdm.IN_2, false);
      end case;
      
   end move;

end L298N_MDM;
