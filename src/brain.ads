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
   TRACK_MODE_SPEED : constant L298N_MDM.speedControl := 1023; --Default 700
   PROBE_MODE_SPEED : constant L298N_MDM.speedControl := 1023; --Default 500
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
   
   ECHOHANDLER_GPTIOTE_CHANNEL : constant nRF.GPIO.Tasks_And_Events.GPIOTE_Channel := 2;
   
   
   --------------Periods----------------
   
   MOVE_PERIOD       : constant Time_Span := Milliseconds(4); --orginal 8
   MEASURE_PERIOD    : constant Time_Span := Milliseconds(16); --orginal 16
   CONTROLLER_PERIOD : constant Time_Span := Milliseconds(8); --orginal 8 but 4 works
   
   -------------Controller settings-----
   
   OOB_TO_PROBE : constant Natural := 16; -- Amount of Out of bounds values until entering probe mode
   
   
   -------------Move Settings-----------
   
   PROBE_DEBOUNCE : constant Time_Span := Milliseconds(550); --600 is really nice acctually.
   PROBE_SWITCH_DIR : constant Time_Span := Milliseconds(450);
   MIN_DIFF : constant Float := 1.85;
   L298N_OPERATION_FREQ : constant Natural := 20_000; --20kHZ from data sheet
   MICROSECONDS_IN_A_SECOND : constant Natural := 10**6;
   --ANALOG_PERIOD_US : constant Natural := MICROSECONDS_IN_A_SECOND/L298N_OPERATION_FREQ; 
   ACCELEROMETER_SENSITIVITY : constant LSM303AGR.Axis_Data := 250;
   ANALOG_PERIOD_US : constant Natural := 20_000; 
   PROBE_DIR_SWITCH_CYCLE : constant Time_Span := Milliseconds(256);
   
   -------------Other constants-----------
   OUT_OF_BOUNDS : constant Float := 100.0;
   MAX_VIEW_DISTANCE : constant Float := 60.0;
   
   
   
   --------------------------------------
  
   type OperationMode is (TRACK, PROBE);
   
   
   type DistanceData is record
      distance : Float := 0;
      outOfBoundsCount : Natural := 0;
   end record;
   
  
    
   
   
   -- Shared data --
   type key_info is record
      distance_left, distance_right : DistanceData; 
      distance_dif, min_dist        : float;
      probe_direction               : L298N_MDM.dirId;
      next_direction                : L298N_MDM.dirId;
      next_speed                    : L298N_MDM.speedControl;     
      opMode                        : OperationMode := PROBE;
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
   
   
   --Task Responsibility
   --     Probe:
   --           Change probe direction based on time or acelerometer data
   --     Track:
   --           If new direction is applied, change to it
   task Move with Priority => 1;
   
   
   
   --Task Responsibility--
   --     Determine mode:
   --                    Track
   --                    Probe
   --     Calculate:
   --               Track:
   --                     Direction
   --                     Speed?
   --                     Distance diff
   --                     Min distance
   --               Probe:
   --                     None
   task Controller with Priority => 2;
   
   
   --Task responibility
   --     Measure distance with both ultrasonics
   task Look with Priority => 3; 
end brain;
