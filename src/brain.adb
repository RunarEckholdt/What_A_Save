

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
      result  : boolean;
      bd : key_info;
      
      -- scheduling management --
      last     : Time := Clock;
      T_period : constant Time_Span := Milliseconds (16); --orginal 16
      next_eye : eye := Left;
      

      
   begin
      -- port mapping --
      right_eye.trig := 2; 
      left_eye.trig  := 3; 
      
      left_eye.echo  := 4;  --shared echo pin
      right_eye.echo := 4;  --shared echo pin
      
      loop
         last := Clock;
         
         case next_eye is        
         when left => 
            HCSR04.measure(left_eye, dis_left, result);
            bd.distance_left := integer(float'rounding(dis_left*100.0));
            
         when right =>
            HCSR04.measure(right_eye, dis_right, result);
            bd.distance_right := integer(float'rounding(dis_right*100.0)); 
        
         end case;  
         
         
         brain_sync.set_brain_data(bd); -- update data --
         delay until last + T_period;
      end loop;
   end Look;
   
   
   -- calculate next move --
   task body Think is --worst computation time: 0.000030518
      bd : key_info;
      -- scheduling management --
      last     : Time := Clock;
      T_period : constant Time_Span := Milliseconds (4); --orginal 8
           
   begin
      loop  
         last := Clock;
         brain_sync.get_brain_data(bd); -- fetch data --         
                  
         if bd.distance_left > bd.distance_right then         
            bd.min_dist := bd.distance_right;                
            bd.distance_dif := bd.distance_left - bd.distance_right;            
            bd.next_direction := L298N_MDM.right;        
         else         
            bd.min_dist := bd.distance_left;        
            bd.distance_dif := bd.distance_right - bd.distance_left;           
            bd.next_direction := L298N_MDM.left;  
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

   begin 
      
      wheels.IN_1 := 7;  
      wheels.IN_2 := 6;  
      wheels.SPD_1 := 0; --analog pwm
      MicroBit.IOsForTasking.Set_Analog_Period_Us(16); --16 works best
      
      loop      
         last := Clock;     
         brain_sync.get_brain_data(bd); -- fetch data --
         
         if (bd.min_dist < 70 and bd.distance_dif > 2) then  --If object is closer than 70 cm and difference between sensors are more than 2 cm; drive.
            L298N_MDM.move(wheels, bd.next_direction, L298N_MDM.speedControl(850));
            MicroBit.Music.Play (27, MicroBit.Music.Pitch(bd.min_dist*100));
         else
            L298N_MDM.move(wheels, L298N_MDM.stop, L298N_MDM.speedControl(0));  
            MicroBit.Music.Play (27, rest);
         end if;

         delay until last + T_period;
      end loop;
   end Move;

end brain;
