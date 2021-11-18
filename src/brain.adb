

package body brain is
   
   protected body SharedData is 
      procedure GetSharedData(sd : out KeyInfo) is
      begin
         sd := data;
      end GetSharedData;
      
      procedure SetMeasureData(sd : in KeyInfo) is
      begin
         data.distanceLeft := sd.distanceLeft;
         data.distanceRight := sd.distanceRight;
      end SetMeasureData;
      
      procedure SetControllData(sd : in KeyInfo) is
      begin
         data.distanceDif := sd.distanceDif;
         data.minDist := sd.minDist;
         data.nextDirection := sd.nextDirection;
         data.opMode := sd.opMode;
      end SetControllData;
      
   end SharedData;
   
   
   protected body MeasuredSignal is
      entry WaitForNewData when newData is
      begin
         newData := False;
      end WaitForNewData;
      
      procedure Signal is
      begin
         newData := True;
      end Signal;
      
   end MeasuredSignal;
   
   

   -- look for target --
   task body Measure is  -- 0.007 worst?
      ----- HCSR-04 SENSORS -------
      leftEye       : HCSR04.HCSR04;
      RightEye      : HCSR04.HCSR04;
      -----------------------------
      
      sd            : keyInfo;   
      periodStart   : Time := Clock; 
      periodLength  : constant Time_Span := MEASURE_PERIOD; 
      
      procedure measureDistance(eye : in HCSR04.HCSR04; sd : in out DistanceData) is
         result   : boolean := false;
      begin
         HCSR04.measure(eye, sd.distance, result,HCSR04.CM);
         --sd.distance := sd.distance * 100.0;
         if (result and sd.distance < MAX_VIEW_DISTANCE) then
            sd.outOfBoundsCount := 0;
         else
            sd.distance := OUT_OF_BOUNDS;
            sd.outOfBoundsCount := sd.outOfBoundsCount + 1;
         end if;
      end measureDistance;

   begin
     
      -- TRIGGER PINS --
      rightEye.trig := HC_RIGHT_TRIG; 
      leftEye.trig  := HC_LEFT_TRIG; 
      
      -- ECHO PINS --
      leftEye.echo  := HC_LEFT_ECHO; 
      rightEye.echo := HC_RIGHT_EHCO; 
      
      -- INITIALIZE INTERRUPT --
      HCSR04.initializeInterrupt(leftEye, ECHOHANDLER_GPTIOTE_CHANNEL); -- both sensors share the same ECHO pin --
      
      loop
         periodStart := Clock;
         
         measureDistance(leftEye,  sd.distanceLeft);
         measureDistance(rightEye, sd.distanceRight);
         
         SharedData.SetMeasureData(sd);
         MeasuredSignal.Signal;
               
         delay until periodStart + periodLength;
      end loop;
   end Measure;
   
  
   -- calculate next move --
   task body Controller is --worst computation time: 0.000030518
      sd : KeyInfo;
      periodStart   : Time := Clock; 
      periodLength  : constant Time_Span := CONTROLLER_PERIOD;


      procedure DetermineMode is
         minOutOfBoundsCount : Natural;
         
      begin
         if(sd.distanceLeft.outOfBoundsCount < sd.distanceRight.outOfBoundsCount) then
            minOutOfBoundsCount := sd.distanceLeft.outOfBoundsCount;
         else
            minOutOfBoundsCount := sd.distanceRight.outOfBoundsCount;
         end if;  
         
         case sd.opMode is
            when PROBE =>
               if (minOutOfBoundsCount = 0) then
                  sd.opMode := TRACK;
               end if;
            when TRACK =>
               if (minOutOfBoundsCount >= OOB_TO_PROBE) then
                  sd.opMode := PROBE;
               end if;
         end case;
      end DetermineMode;
      
      procedure Calculate is
      begin
         if(sd.opMode = TRACK) then
            sd.distanceDif := abs(sd.distanceLeft.distance - sd.distanceRight.distance);  
            if sd.distanceDif < MIN_DIFF then
               sd.nextDirection := L298N_MDM.stop;
            elsif sd.distanceLeft.distance > sd.distanceRight.distance then      -- Bot is hanging upside down, thats why it seems inverted.    
               sd.minDist := sd.distanceRight.distance;                        
               sd.nextDirection := L298N_MDM.left;        
            else         
               sd.minDist := sd.distanceLeft.distance;               
               sd.nextDirection := L298N_MDM.right;  
            end if;
         end if;
      end Calculate;

   begin
      loop  
         periodStart := Clock;    
         MeasuredSignal.WaitForNewData;
         SharedData.GetSharedData(sd); -- fetch data --   
         
         DetermineMode;
         Calculate;
  
         SharedData.SetControllData(sd); -- update data --
         delay until periodStart + periodLength;
      end loop;
   end Controller;
   
   
   -- move the keeper --
   task body Move is             --worst computation time: 0.000030518
      wheels : L298N_MDM.L298N;
      sd : KeyInfo;   
      -- scheduling management --
      periodStart     : Time := Clock;
      periodLength: constant Time_Span := MOVE_PERIOD; 
      trackDir : L298N_MDM.dirId := L298N_MDM.stop;
      
      
      difLim : constant float := MIN_DIFF;
      
      switchProbe    : constant Time_Span := PROBE_DIR_SWITCH_CYCLE;
      nextProbe : Time := Clock;
      probeDir : L298N_MDM.dirId := L298N_MDM.left;

      nextDirSwitch : time := clock;
      --dirSwitchCycle : constant Time_Span := PROBE_DIR_SWITCH_CYCLE;
      --probeDebounce : constant Time_Span := PROBE_DEBOUNCE; 
      
      opMove : OperationMode := PROBE;
      
      soundOn   : Boolean := False;
      soundTime : Time    := clock;
      
      procedure Tracking is
      begin
         if(sd.nextDirection /= trackDir)then
            trackDir := sd.nextDirection;
            L298N_MDM.move(wheels, trackDir, L298N_MDM.speedControl(TRACK_MODE_SPEED));
         end if;
      end Tracking;
      
      procedure Probing is
      begin
         if(Clock >= nextProbe)then
            probeDir := (if probeDir = L298N_MDM.left then L298N_MDM.right else L298N_MDM.left);
            L298N_MDM.move(wheels, probeDir, L298N_MDM.speedControl(PROBE_MODE_SPEED));
            
            
            nextProbe     := Clock + PROBE_DIR_SWITCH_CYCLE;
            nextDirSwitch := Clock + PROBE_DEBOUNCE;
            soundTime     := Clock + SWITCH_DIRECTION_BEEP_DURATION;
            
            MicroBit.Music.Play (27, MicroBit.Music.Pitch(600));
            soundOn := True;
         elsif(abs(MicroBit.Accelerometer.Data.x) > ACCELEROMETER_SENSITIVITY and Clock > nextDirSwitch) then
            probeDir := (if probeDir = L298N_MDM.left then L298N_MDM.right else L298N_MDM.left);
            L298N_MDM.move(wheels, probeDir, L298N_MDM.speedControl(PROBE_MODE_SPEED));
            
            nextDirSwitch := Clock + PROBE_DEBOUNCE;
            nextProbe     := Clock + PROBE_DIR_SWITCH_CYCLE;
            soundTime     := Clock + SWITCH_DIRECTION_BEEP_DURATION;
            
            MicroBit.Music.Play (27, MicroBit.Music.Pitch(900));
            soundOn := True;
         end if;
         if(soundOn and clock > soundTime) then
            MicroBit.Music.Play (27, rest);
            soundOn := False;
         end if;
      end Probing;
      
   begin 
      
      wheels.IN_1 := MDM_IN1_PIN;  
      wheels.IN_2 := MDM_IN2_PIN;  
      wheels.SPD_1 := MDM_SPD_PIN; --analog pwm
      Set_Analog_Period_Us(ANALOG_PERIOD_US); 


      loop      
         
         periodStart := Clock;     
         SharedData.GetSharedData(sd); -- fetch data --
         
         --If we are entering Probe mode
         if(sd.opMode /= opMove and sd.opMode = PROBE)then
            opMove := sd.opMode;
            nextDirSwitch := Clock + PROBE_DIR_SWITCH_CYCLE;
         end if;
      
         case sd.opMode is
            when PROBE =>
               Probing;
            when TRACK =>
               Tracking;
         end case;

         delay until periodStart + periodLength;
      end loop;
   end Move;

end brain;
