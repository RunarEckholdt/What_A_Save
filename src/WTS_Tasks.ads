
with L298N_MDM;
with HCSR04;
with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.IOsForTasking;

package WTS_Tasks is

   type CM is range-1..60;

   OUT_OF_BOUNDS : constant CM := -1;

   hc1Trig : Constant HCSR04.Pin := 3;
   hc1Echo : Constant HCSR04.Pin := 4;
   hc2Trig : Constant HCSR04.Pin := 2;
   hc2Echo : Constant HCSR04.Pin := 4;

   mdmEN1 : Constant L298N_MDM.Pin_D := 7;
   mdmEN2 : Constant L298N_MDM.Pin_D := 6;
   mdmSpeed : Constant L298N_MDM.Pin_A := 0;


   defaultSpeed : Constant L298N_MDM.speedControl := 400;

   type LRData is record
      left,right : CM := 0;
      failCountLeft, failCountRight : Natural := 0;
   end record;

   type BehaviourMode is (PROBE,TRACK,IDLE);

   type HCToUse is (LEFT,RIGHT);

   defaultmode : constant BehaviourMode := PROBE;



   protected SharedData is
      procedure getDistance(lr : out LRData);
      procedure checkForNewDistData(hasNewData : out Boolean);
      procedure setDistData(lr : in LRData);
      procedure getDirection(dir : out L298N_MDM.dirId);
      procedure setDirection(dir : in L298N_MDM.dirId);
      procedure getMode (m : out BehaviourMode);
      procedure setMode(m : in BehaviourMode);

   private
      lrDist : LRData;
      hasNewLR : Boolean := False;
      direction : L298N_MDM.dirId := L298N_MDM.stop;
      mode : BehaviourMode := TRACK;

   end SharedData;


   task MotorControll with Priority => 3;
   task MainControll with Priority => 1;
   task DistanceMeasure with Priority => 2;

end WTS_Tasks;
