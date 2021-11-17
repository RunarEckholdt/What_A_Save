

package body brain is
   
   protected body SharedData is 
      procedure GetSharedData(sd : out KeyInfo) is
      begin
         sd := data;
      end GetSharedData;
      
      
      --  procedure set_brain_data(sd : in keyInfo) is
      --  begin
      --     data := sd;
      --  end set_brain_data;
      
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
   
   

   -- look for target --
   task body Measure is  -- 0.007 worst?
      ----- HCSR-04 SENSORS -------
      leftEye       : HCSR04.HCSR04;
      RightEye      : HCSR04.HCSR04;
      -----------------------------
      
      sd    : keyInfo;   
      periodStart   : Time := Clock; 
      periodLength  : constant Time_Span := MEASURE_PERIOD; 
      
      procedure measureDistance(eye : in HCSR04.HCSR04; sd : in out DistanceData) is
         result   : boolean;
      begin
         HCSR04.measure(eye, sd.distance, result);
         if (result and sd.distance < MAX_VIEW_DISTANCE) then
            sd.distance := sd.distance * 100.0;
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
               
         delay until periodStart + periodLength;
      end loop;
   end Measure;
   
  
   -- calculate next move --
   task body Controller is --worst computation time: 0.000030518
      sd : KeyInfo;
      -- scheduling management --
      last     : Time := Clock;
      T_period : constant Time_Span := CONTROLLER_PERIOD;
      
      
      
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
               if(minOutOfBoundsCount = 0)then
                  sd.opMode := TRACK;
               end if;
            when TRACK =>
               if(minOutOfBoundsCount >= OOB_TO_PROBE)then
                  sd.opMode := PROBE;
               end if;
         end case;
      end DetermineMode;
      
      procedure Calculate is
      begin
         if(sd.opMode = TRACK) then
            if sd.distanceLeft.distance > sd.distanceRight.distance then         
               sd.minDist := sd.distanceRight.distance;                
               sd.distanceDif := sd.distanceLeft.distance - sd.distanceRight.distance;            
               sd.nextDirection := L298N_MDM.left;        
            else         
               sd.minDist := sd.distanceLeft.distance;        
               sd.distanceDif := sd.distanceRight.distance - sd.distanceLeft.distance;           
               sd.nextDirection := L298N_MDM.right;  
            end if;
         end if;
      end Calculate;

   begin
      loop  
         last := Clock;    
         SharedData.GetSharedData(sd); -- fetch data --   
         
         DetermineMode;
         Calculate;
         

         SharedData.SetControllData(sd); -- update data --
         delay until last + T_period;
      end loop;
   end Controller;
   
   
   -- move the keeper --
   task body Move is             --worst computation time: 0.000030518
      wheels : L298N_MDM.L298N;
      sd : KeyInfo;   
      -- scheduling management --
      last     : Time := Clock;
      T_period : constant Time_Span := MOVE_PERIOD; 
      trackDir : L298N_MDM.dirId := L298N_MDM.stop;
      
      
      difLim : constant float := MIN_DIFF;
      
      switchProbe    : constant Time_Span := PROBE_SWITCH_DIR;
      --startProbe : constant Time_Span := PROBE_START_DELAY;
      nextProbe : Time := Clock;
      probeDir : L298N_MDM.dirId := L298N_MDM.left;
      
      
      probeBool : Boolean := true;
      
      nextDirSwitch : time := clock;
      --dirSwitchCycle : constant Time_Span := PROBE_DIR_SWITCH_CYCLE;
      --probeDebounce : constant Time_Span := PROBE_DEBOUNCE; 
      
      opMove : OperationMode := PROBE;
      
      soundOn : Boolean := False;
      
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
            nextProbe := Clock + PROBE_DIR_SWITCH_CYCLE;
         elsif(abs(MicroBit.Accelerometer.Data.x) > ACCELEROMETER_SENSITIVITY and Clock > nextDirSwitch) then
            probeDir := (if probeDir = L298N_MDM.left then L298N_MDM.right else L298N_MDM.left);
            L298N_MDM.move(wheels, probeDir, L298N_MDM.speedControl(PROBE_MODE_SPEED));
            nextDirSwitch := Clock + PROBE_DEBOUNCE;
            nextProbe := Clock + PROBE_DIR_SWITCH_CYCLE;
            MicroBit.Music.Play (27, MicroBit.Music.Pitch(700));
            soundOn := True;
         elsif(soundOn)then
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
         
         
         last := Clock;     
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
         
         
         
         --  if (bd.min_dist < 60.0 and bd.distance_dif > difLim) then  --If object is closer than 70 cm and difference between sensors are more than 1.5 cm; drive.
         --     L298N_MDM.move(wheels, bd.next_direction, L298N_MDM.speedControl(TRACK_MODE_SPEED));
         --     --MicroBit.Music.Play (27, MicroBit.Music.Pitch(bd.min_dist*100));
         --     nextProbe := Clock + startProbe;
         --  
         --  
         --  elsif (bd.min_dist > 60.0 and Clock > nextProbe) then
         --     if (abs(MicroBit.Accelerometer.Data.x) > ACCELEROMETER_SENSITIVITY and clock > nextDirSwitch) then
         --  
         --        if (probeBool) then
         --           MicroBit.Music.Play (27, MicroBit.Music.Pitch(700));
         --           probeDir := L298N_MDM.right;
         --           probeBool := false;
         --           nextDirSwitch := clock + probeDebounce;
         --        elsif(probeBool = false) then
         --           MicroBit.Music.Play (27, MicroBit.Music.Pitch(500));
         --           probeDir := L298N_MDM.left;
         --           probeBool := true;
         --           nextDirSwitch := clock + probeDebounce;
         --        end if;
         --  
         --     else
         --        MicroBit.Music.Play (27, rest);
         --     end if;
         --  
         --  
         --     L298N_MDM.move(wheels, probeDir, L298N_MDM.speedControl(PROBE_MODE_SPEED));
         --  
         --  
         --  elsif bd.distance_dif < difLim then
         --     L298N_MDM.move(wheels, L298N_MDM.stop, L298N_MDM.speedControl(NO_SPEED));
         --     --  nextProbe := Clock + startProbe;
         --  end if;

         delay until last + T_period;
      end loop;
   end Move;

end brain;
