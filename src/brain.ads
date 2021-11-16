with ADA.Real_Time; use ADA.Real_Time;
with ADA.Interrupts;
with nRF.GPIO;
with MicroBit;
with MicroBit.IOsForTasking; use MicroBit.IOsForTasking;
with MicroBit.Console;
with nRF.GPIO.Tasks_And_Events;


--with Microbit.PinInterrupt; --our interrupt package
With HCSR04;                --our ultra-sonic package
with L298N_MDM;             --our motor controller package

with LSM303AGR; use LSM303AGR;
with MicroBit.Accelerometer;
--  with MicroBit.DisplayRT;
--  with MicroBit.DisplayRT.Symbols;

with MicroBit.Music; use MicroBit.Music; -- for robot sounds


package brain is
   
   ----Configuration Constants-----------
   
   --------------Speed configurations----
   TRACK_MODE_SPEED : constant L298N_MDM.speedControl := 700;
   PROBE_MODE_SPEED : constant L298N_MDM.speedControl := 500;
   NO_SPEED         : constant L298N_MDM.speedControl := 0;
   
   
   --------------Pin configurations------
   
   --------------------Motor Driver------
   MDM_IN1_PIN : constant L298N_MDM.Pin_D := 7;
   MDM_IN2_PIN : constant L298N_MDM.Pin_D := 6;
   MDM_SPD_PIN : constant L298N_MDM.Pin_A := 0;
   
   --------------------Ultra Sonic------
   HC_LEFT_TRIG : constant HCSR04.Pin := 3;
   HC_LEFT_ECHO : constant HCSR04.Pin := 4; --Shared echo
   
   HC_RIGHT_TRIG : constant HCSR04.Pin := 2;
   HC_RIGHT_EHCO : constant HCSR04.Pin := 4; --Shared echo
   
   ECHOHANDLER_GPTIOTE_CHANNEL : constant Integer := 2;
   
   
   --------------Periods----------------
   
   MOVE_PERIOD       : constant Time_Span := Milliseconds(4); --orginal 8
   MEASURE_PERIOD    : constant Time_Span := Milliseconds(16); --orginal 16
   CONTROLLER_PERIOD : constant Time_Span := Milliseconds(8); --orginal 8 but 4 works
   
   
   -------------Move Settings-----------
   
   PROBE_DEBOUNCE : constant Time_Span := Milliseconds(550); --600 is really nice acctually.
   PROBE_START_DELAY : constant Time_Span := Milliseconds(256); 
   PROBE_SWITCH_DIR : constant Time_Span := Milliseconds(450);
   MIN_DIFF : constant Float := 1.85;
   
   
   -------------------------------------
   
   
   
   
   -- Shared data --
   type key_info is record
      distance_left, distance_right, distance_dif, min_dist : float;
      probe_direction: L298N_MDM.dirId;
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
   type dist is (lock_on, adjust, OOB);
   
   -- task set --
   task Move with Priority => 1;
   task Think with Priority => 2;
   task Look with Priority => 3; 
end brain;
