With HCSR04;
with MicroBit.Console;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;

procedure Main is
   hc : HCSR04.HCSR04;
   distance : Float;
   last : Time := Clock;
   --Cycle : constant Time_Span := Microseconds(5500);
   Cycle : constant Time_Span := Milliseconds(1000);
   result : Boolean;
begin
   hc.trig := 1;
   hc.echo := 2;
   while(True) loop
      last := Clock;
      HCSR04.measure(hc,distance, result);
      if(not result) then
        MicroBit.Console.Put_Line("Failed to measure distance");
      else
         MicroBit.Console.Put("Distance: ");
         MicroBit.Console.Put(distance'Image);
         MicroBit.Console.Put_Line("m");
      end if;

      --  HCSR04.trig(hc);


      delay until last + Cycle;

   end loop;
end Main;
