With HCSR04;
with L298N_MDM;
with MicroBit.Console;
with Ada.Real_Time; use Ada.Real_Time;

procedure Main is
   --hc : HCSR04.HCSR04;
   --distance : Float;

   with MicroBit.Buttons; use MicroBit.Buttons;

   last : Time := Clock;
   Cycle : constant Time_Span := Milliseconds (1000);
   mdm : L298N_MDM.L298N;

   left : L298N_MDM.dirId := L298N_MDM.left;
   right : L298N_MDM.dirId := L298N_MDM.right;
   stop : L298N_MDM.dirId := L298N_MDM.stop;


begin
   --hc.trig := 1;
   --hc.echo := 2;
   mdm.IN_1 := 1;
   mdm.IN_2 := 2;


   --drive := L298N_MDM.chooseDirection.left;


      --distance := HCSR04.measure(hc);
      --MicroBit.Console.Put_Line(distance'Image);

      ----LEFT----
      L298N_MDM.move(mdm, left);
      last := Clock;
      delay until last + Cycle;

      ----RIGHT----
      L298N_MDM.move(mdm, right);
      last := Clock;
      delay until last + Cycle;

      ----STOP----
      L298N_MDM.move(mdm, stop);
      last := Clock;
      delay until last + Cycle;

   while(true) loop
      null;
   end loop;
end Main;
