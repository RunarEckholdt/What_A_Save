

package body brain is
   
   protected body brain_sync is 
      procedure get_brain_data(bd : out key_info) is
      begin
         bd := brain_data;
      end get_brain_data;
      
      
      procedure set_brain_data(bd : in key_info) is
      begin
         brain_data := bd;
      end set_brain_data;
   end brain_sync;
   
   

   -- look for target --
   task body Measure is  -- 0.007 worst?
      ----- HCSR-04 SENSORS -------
      leftEye       : HCSR04.HCSR04;
      RightEye      : HCSR04.HCSR04;
      -----------------------------
      
      sharedData    : key_info;   
      periodStart   : Time := Clock; 
      periodLength  : constant Time_Span := MEASURE_PERIOD; 
      
      procedure measureDistance(eye : in HCSR04.HCSR04; sd : in out DistanceData) is
         result   : boolean;
      begin
         HCSR04.measure(eye, sd.distance, result);
         if (result and sd.distance < MAX_VIEW_DISTANCE) then
            sd.distance := sd.distance * 100;
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
         
         measureDistance(leftEye,  sharedData.distanceLeft);
         measureDistance(rightEye, sharedData.distanceRight);
 
         brain_sync.set_brain_data(sharedData);
               
         delay until periodStart + periodLength;
      end loop;
   end Measure;
   
  
   -- calculate next move --
   task body Controller is --worst computation time: 0.000030518
      bd : key_info;
      -- scheduling management --
      last     : Time := Clock;
      T_period : constant Time_Span := CONTROLLER_PERIOD;
      
      
      
      procedure DetermineMode is
         minOutOfBoundsCount : Natural;
      begin
         if(bd.distance_left.outOfBoundsCount < bd.distance_right.outOfBoundsCount) then
            minOutOfBoundsCount := bd.distance_left.outOfBoundsCount;
         else
            minOutOfBoundsCount := bd.distance_right.outOfBoundsCount;
         end if;   
         
         case bd.opMode is
            when PROBE =>
               if(minOutOfBoundsCount = 0)then
                  bd.opMode := TRACK;
               end if;
            when TRACK =>
               if(minOutOfBoundsCount >= OOB_TO_PROBE)then
                  bd.opMode := PROBE;
               end if;
         end case;
      end DetermineMode;
      
      procedure Calcualte is
      begin
         if(bd.opMode = TRACK) then
            if bd.distance_left > bd.distance_right then         
               bd.min_dist := bd.distance_right;                
               bd.distance_dif := bd.distance_left - bd.distance_right;            
               bd.next_direction := L298N_MDM.left;        
            else         
               bd.min_dist := bd.distance_left;        
               bd.distance_dif := bd.distance_right - bd.distance_left;           
               bd.next_direction := L298N_MDM.right;  
            end if;
         end if;
      end Calcualte;

   begin
      loop  
         last := Clock;    
         brain_sync.get_brain_data(bd); -- fetch data --   
         
         DetermineMode;
         Calcualte;
         

         brain_sync.set_brain_data(bd); -- update data --
         delay until last + T_period;
      end loop;
   end Controller;
   
   
   -- move the keeper --
   task body Move is             --worst computation time: 0.000030518
      wheels : L298N_MDM.L298N;
      bd : key_info;   
      -- scheduling management --
      last     : Time := Clock;
      T_period : constant Time_Span := MOVE_PERIOD; 
      
      difLim : constant float := MIN_DIFF;
      
      switchProbe    : constant Time_Span := PROBE_SWITCH_DIR;
      startProbe : constant Time_Span := PROBE_START_DELAY;
      
      nextProbe : Time := Clock;
      probeDir : L298N_MDM.dirId := L298N_MDM.left;
      probeBool : Boolean := true;
      
      nextDirSwitch : time := clock;
      probeDebounce : constant Time_Span := PROBE_DEBOUNCE; 
   
      

   begin 
      
      wheels.IN_1 := MDM_IN1_PIN;  
      wheels.IN_2 := MDM_IN2_PIN;  
      wheels.SPD_1 := MDM_SPD_PIN; --analog pwm
      Set_Analog_Period_Us(ANALOG_PERIOD_US); 

      
      loop      
         last := Clock;     
         brain_sync.get_brain_data(bd); -- fetch data --
         
         if (bd.min_dist < 60.0 and bd.distance_dif > difLim) then  --If object is closer than 70 cm and difference between sensors are more than 1.5 cm; drive.
            L298N_MDM.move(wheels, bd.next_direction, L298N_MDM.speedControl(TRACK_MODE_SPEED));
            --MicroBit.Music.Play (27, MicroBit.Music.Pitch(bd.min_dist*100));
            nextProbe := Clock + startProbe;


         elsif (bd.min_dist > 60.0 and Clock > nextProbe) then
            if (abs(MicroBit.Accelerometer.Data.x) > 250 and clock > nextDirSwitch) then
               
               if (probeBool) then
                  MicroBit.Music.Play (27, MicroBit.Music.Pitch(700));
                  probeDir := L298N_MDM.right;
                  probeBool := false;
                  nextDirSwitch := clock + probeDebounce;
               elsif(probeBool = false) then
                  MicroBit.Music.Play (27, MicroBit.Music.Pitch(500));
                  probeDir := L298N_MDM.left;
                  probeBool := true;
                  nextDirSwitch := clock + probeDebounce;
               end if;
               
            else
               MicroBit.Music.Play (27, rest);
            end if;
            
           
            L298N_MDM.move(wheels, probeDir, L298N_MDM.speedControl(PROBE_MODE_SPEED));
            
            
         elsif bd.distance_dif < difLim then
            L298N_MDM.move(wheels, L298N_MDM.stop, L298N_MDM.speedControl(NO_SPEED)); 
            --  nextProbe := Clock + startProbe;
         end if;

         delay until last + T_period;
      end loop;
   end Move;

end brain;
