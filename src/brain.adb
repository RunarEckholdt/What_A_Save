

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
   task body Look is  -- 0.007 worst?
      -- task components --
      -- left eye --
      left_eye  : HCSR04.HCSR04;
      dis_left : float;  
      -- right eye --
      right_eye : HCSR04.HCSR04;
      dis_right : float;
      --
      
      
        
      -- other --
      result : boolean;
      bd : key_info;
      
      -- scheduling management --
      last     : Time := Clock;
      T_period : constant Time_Span := Milliseconds (16); --orginal 16
      next_eye : eye := left;
      

      
   begin
      -- port mapping --
      right_eye.trig := 2; 
      left_eye.trig  := 3; 
      
      left_eye.echo  := 4;  --shared echo pin
      right_eye.echo := 4;  --shared echo pin
      
      loop
         last := Clock;
         
         HCSR04.measure(left_eye, dis_left, result);
         if (result) then
            bd.distance_left := dis_left*100.0;
         else
            bd.distance_left := 100.0;
         end if;
            --  bd.distance_left := integer(float'rounding(dis_left*100.0));
         
         HCSR04.measure(right_eye, dis_right, result);
         if (result) then
            bd.distance_right := dis_right*100.0; 
         else
            bd.distance_right := 100.0;
         end if; 
         --  bd.distance_right := integer(float'rounding(dis_right*100.0));
            
         
         brain_sync.set_brain_data(bd); -- update data --
         
         
         delay until last + T_period;
      end loop;
   end Look;
   
   
   -- calculate next move --
   task body Think is --worst computation time: 0.000030518
      bd : key_info;
      -- scheduling management --
      last     : Time := Clock;
      T_period : constant Time_Span := Milliseconds (4); --orginal 8 but 4 works
      
       
   begin
      loop  
         last := Clock;    
         brain_sync.get_brain_data(bd); -- fetch data --   
         
       
         if bd.distance_left > bd.distance_right then         
            bd.min_dist := bd.distance_right;                
            bd.distance_dif := bd.distance_left - bd.distance_right;            
            bd.next_direction := L298N_MDM.left;        
         else         
            bd.min_dist := bd.distance_left;        
            bd.distance_dif := bd.distance_right - bd.distance_left;           
            bd.next_direction := L298N_MDM.right;  
         end if;
         

         brain_sync.set_brain_data(bd); -- update data --
         delay until last + T_period;
      end loop;
   end think;
   
   
   -- move the keeper --
   task body Move is             --worst computation time: 0.000030518
      wheels : L298N_MDM.L298N;
      bd : key_info;   
      -- scheduling management --
      last     : Time := Clock;
      T_period : constant Time_Span := Milliseconds (8); --orginal 8
      
      difLim : constant float := 1.85;
      
      switchProbe    : constant Time_Span := Milliseconds (450);
      startProbe : constant Time_Span := Milliseconds(256);
      
      nextProbe : Time := Clock;
      probeDir : L298N_MDM.dirId := L298N_MDM.left;
      probeBool : Boolean := true;
      
      nextDirSwitch : time := clock;
      probeDebounce : Time_Span := Milliseconds(550); --600 is really nice acctually.
   
      

   begin 
      
      wheels.IN_1 := 7;  
      wheels.IN_2 := 6;  
      wheels.SPD_1 := 0; --analog pwm
      MicroBit.IOsForTasking.Set_Analog_Period_Us(20_000); --20kHZ from data sheet
      
      loop      
         last := Clock;     
         brain_sync.get_brain_data(bd); -- fetch data --
       
         
         if (bd.min_dist < 60.0 and bd.distance_dif > difLim) then  --If object is closer than 70 cm and difference between sensors are more than 1.5 cm; drive.
            L298N_MDM.move(wheels, bd.next_direction, L298N_MDM.speedControl(700));
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
            
           
            L298N_MDM.move(wheels, probeDir, L298N_MDM.speedControl(900));
            
            
         elsif bd.distance_dif < difLim then
            L298N_MDM.move(wheels, L298N_MDM.stop, L298N_MDM.speedControl(0)); 
            --  nextProbe := Clock + startProbe;
         end if;

         delay until last + T_period;
      end loop;
   end Move;

end brain;
