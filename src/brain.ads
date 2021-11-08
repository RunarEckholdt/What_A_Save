with ADA.Real_Time; use ADA.Real_Time;
with ADA.Interrupts;
with nRF.GPIO;
with MicroBit;
with MicroBit.IOsForTasking; use MicroBit.IOsForTasking;
with MicroBit.Console;
with nRF.GPIO.Tasks_And_Events;

with Microbit.PinInterrupt; --our interrupt package
With HCSR04;                --our ultra-sonic package
with L298N_MDM;             --our motor controller package

package brain is
   -- Shared data --
   type key_info is record
      distance_left, distance_right, distance_dif : integer;
      next_direction : L298N_MDM.dirId;
      next_speed     : L298N_MDM.speedControl;     
   end record;
   type viewRange is new Integer range 0 .. 63;
     
   protected brain_sync is 
      procedure set_brain_data(bd : in key_info);
      procedure get_brain_data(bd : out key_info);
   private
      brain_data : key_info;
   end brain_sync;
   
   -- QOL-eyes --
   type eye is (left, right);
   
   -- task set --
   task Move with Priority => 3;
   task Think with Priority => 2;
   task Look with Priority => 1;
end brain;
