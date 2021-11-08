

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
   task body Look is
      -- task components --
      left_eye  : HCSR04.HCSR04;
      right_eye : HCSR04.HCSR04;

      result  : boolean;
      bd : key_info;
      
      -- scheduling management --
      last     : Time := Clock;
      T_period : constant Time_Span := Milliseconds (16);
      next_eye : eye := Left;
      
      dis_left : float;
      dis_right : float;
         
   begin
      -- port mapping --
      right_eye.trig := 2; 
      left_eye.trig  := 3; 
      
      left_eye.echo  := 4;  --shared echo pin
      right_eye.echo := 4;  --shared echo pin
      
      loop
         case next_eye is
         when left =>
            HCSR04.measure(left_eye, dis_left, result);
            bd.distance_left := integer(float'rounding(dis_left*100.0));
            last := Clock;
            delay until last + T_period;
            brain_sync.set_brain_data(bd);
            next_eye := right;
            
         when right =>
            HCSR04.measure(right_eye, dis_right, result);
            bd.distance_right := integer(float'rounding(dis_right*100.0));
            last := Clock;
            delay until last + T_period;
            brain_sync.set_brain_data(bd);
            next_eye := left;    
         end case;      
      end loop;
   end Look;
   
   
   -- set think --
   task body Think is --worst computation time: 0.000030518
      bd : key_info;
      -- scheduling management --
      last     : Time := Clock;
      T_period : constant Time_Span := Milliseconds (8);
      
      
      
   begin
      loop
         
         brain_sync.get_brain_data(bd); -- fetch data --
         bd.distance_dif := abs(bd.distance_left - bd.distance_right);
         
         
         if (bd.distance_dif < 15) then
            bd.next_speed := 1;
            bd.next_direction := L298N_MDM.stop;
         elsif (bd.distance_left < bd.distance_right) then
            if (bd.distance_left > 80) then
               bd.next_speed := 1;
            elsif(bd.distance_left > 60) then
               bd.next_speed := 1020;
            elsif(bd.distance_left <= 3) then
               bd.next_speed := 1;
            else
               bd.next_speed := L298N_MDM.speedControl(bd.distance_left*100.0);
            end if;
            bd.next_direction := L298N_MDM.left;
         elsif (bd.distance_right < bd.distance_left) then
            if (bd.distance_right > 80) then
               bd.next_speed := 1;
            elsif(bd.distance_right > 60) then
               bd.next_speed := 1020;
            elsif(bd.distance_right <= 3) then
               bd.next_speed := 1;
            else
               bd.next_speed := L298N_MDM.speedControl(bd.distance_left*100.0);
            end if;
            bd.next_direction := L298N_MDM.right;
         end if;
         brain_sync.set_brain_data(bd);
         last := Clock;
         delay until last + T_period;
      end loop;
   end think;
   
   
   -- move the keeper --
   task body Move is             --worst computation time: 0.000030518
      wheels : L298N_MDM.L298N;
      bd : key_info;   
      -- scheduling management --
      last     : Time := Clock;
      T_period : constant Time_Span := Milliseconds (8);
      
      -- testing variables --
      comp_test_pre, comp_test_post    : Time := Clock;
      comp_span :  Time_Span;
      comp_sleep : constant  Time_Span := Milliseconds(100);
      
   begin 
      
      wheels.IN_1 := 7;  
      wheels.IN_2 := 6;  
      wheels.SPD_1 := 0; --analog pwm
      MicroBit.IOsForTasking.Set_Analog_Period_Us(16); --16 works best
      
      loop
         --comp_test_pre := clock; --for testing computation time
         
         brain_sync.get_brain_data(bd); -- fetch data --
         L298N_MDM.move(wheels, bd.next_direction, bd.next_speed);   
         ------------------
         --TESTING BLOCK--
         ------------------
         --comp_test_post := clock; --for testing computation time
         --comp_span := comp_test_post - comp_test_pre;
         --MicroBit.Console.Put_Line(bd.distance_left'Image);
         --delay until comp_test_post + comp_sleep;
         ------------------ 
         
         last := Clock;
         delay until last + T_period;
      end loop;
   end Move;

end brain;
