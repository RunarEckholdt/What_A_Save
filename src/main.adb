With HCSR04;
with MicroBit.Console;
with Ada.Real_Time; use Ada.Real_Time;

procedure Main is
   hc : HCSR04.HCSR04;
   distance : Float;
   last : Time := Clock;
   Cycle : constant Time_Span := Milliseconds (1000);
begin
   hc.trig := 1;
   hc.echo := 2;
   while(True) loop
      distance := HCSR04.measure(hc);
      MicroBit.Console.Put_Line(distance'Image);
      last := Clock;
      delay until last + Cycle;

   end loop;
end Main;
