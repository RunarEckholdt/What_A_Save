

package body HCSR04 is

   --Measures the distance in meters
   procedure measure(hc : in HCSR04 ; distance : out Float; result : out Boolean) is
      timeS : Time_Span;
      timeSFl : Float;
      speedOfSound : constant Float := 343.0;
   begin
      trig(hc);
      pulseIn(hc,timeS, result);
      if(result) then
         timeSFl := Float(To_Duration(timeS));
         distance := (timeSFl/2.0) * speedOfSound;
      else
         distance := -1.0;
      end if;

   end measure;

   --Sends a trigger pulse of 10 us on the trig pin
   procedure trig(hc : in HCSR04) is
    trigStart : Time;
   begin
      MicroBit.IOsForTasking.Set(hc.trig,True);
      trigStart := Clock;
      delay until trigStart + Microseconds(10); --Fetched from the timing diagram
      MicroBit.IOsForTasking.Set(hc.trig,False);
   end trig;



   --Measures the time lenght of a high pulse
   procedure pulseIn(hc : in HCSR04; pulseTime : out Time_Span; result : out Boolean) is
      startT : Time;
      endT : Time;
      --afterTrig : Time;
      --sendPulseTime : Time_Span;
      --timeOutSend : constant Time_Span := Milliseconds(10);
      --timeOutPulse : constant Time_Span := Milliseconds(50);

   begin
      --afterTrig := Clock;
      while(MicroBit.IOsForTasking.Set(hc.echo) = False) loop
         --asm(wfi ) --TODO change to wait for interupt
         --  if((Clock - afterTrig) > timeOutSend) then
         --     MicroBit.Console.Put_Line("HCSR04 did not trigger");
         --     result := False;
         --     return;
         --  end if;
         null;
      end loop;
      --sendPulseTime := Clock - afterTrig;
      --MicroBit.Console.Put_Line("Send Timing: " & To_Duration(sendPulseTime)'Image & "s"); --Logs time for the send pulses.
      startT := Clock;

      while(MicroBit.IOsForTasking.Set(hc.echo) = True) loop
         --asm(wfi ) --TODO change to wait for interupt
         --  if((Clock - startT) > timeOutPulse) then
         --     MicroBit.Console.Put_Line("HCSR04 timed out");
         --     result := False;
         --     return;

         --end if;
         null;
      end loop;
      endT := Clock;
      pulseTime := endT - startT;
      --MicroBit.Console.Put_Line(pulseTime'Image);
      result := True;
   end pulseIn;





end HCSR04;
