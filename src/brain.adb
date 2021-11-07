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
         
   begin
      -- port mapping --
      right_eye.trig := 2; 
      left_eye.trig  := 3; 
      
      left_eye.echo  := 4;  --shared echo pin
      right_eye.echo := 4;  --shared echo pin
      
      loop
         case next_eye is
         when left =>
            HCSR04.measure(left_eye, bd.distance_left, result);
            last := Clock;
            delay until last + T_period;
            brain_sync.set_brain_data(bd);
            next_eye := right;
            
         when right =>
            HCSR04.measure(right_eye, bd.distance_right, result);
            last := Clock;
            delay until last + T_period;
            brain_sync.set_brain_data(bd);
            next_eye := left;    
         end case;      
      end loop;
   end Look;
   
   
   -- set think --
   task body Think is
      bd : key_info;
   begin
      loop
         brain_sync.get_brain_data(bd); -- fetch data --
         bd.distance_dif := abs(bd.distance_left - bd.distance_right);
         if (bd.distance_dif < 0.05) then
            bd.next_direction := L298N_MDM.stop;
         elsif (bd.distance_left < bd.distance_right) then
            bd.next_direction := L298N_MDM.left;
         elsif (bd.distance_right < bd.distance_left) then
            bd.next_direction := L298N_MDM.right;
         end if;
         brain_sync.set_brain_data(bd);
      end loop;
   end think;
   
   
   -- move the keeper --
   task body Move is
      wheels : L298N_MDM.L298N;
      bd : key_info;   
      -- scheduling management --
      --last     : Time := Clock;
      --T_period : constant Time_Span := Milliseconds (8);
      
   begin
      wheels.IN_1 := 7;  
      wheels.IN_2 := 6;  
      
      loop
         brain_sync.get_brain_data(bd); -- fetch data --
         L298N_MDM.move(wheels, bd.next_direction);    
      end loop;
   end Move;

end brain;
