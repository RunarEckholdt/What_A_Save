

package body HCSR04 is

   function measure(hc : HCSR04) return Float is
      timeUs : Float;
      Distance : Float;
      speedOfSound : constant Float := 342.0;
   begin
      trig(hc);
      timeUs := Float(To_Duration(pulseIn(hc)));
      Distance := (timeUs/2.0) * speedOfSound;
      return Distance;
   end measure;


   procedure trig(hc : in HCSR04) is
      trigStart : Time := Clock;
   begin
      MicroBit.IOsForTasking.Set(hc.trig,True);
      delay until Clock + Microseconds(10); --Fetched from the timing diagram
      MicroBit.IOsForTasking.Set(hc.trig,False);
   end trig;



   function pulseIn(hc : HCSR04) return Time_Span is
      startT : Time;
      endT : Time;
      pulseLength : Time_Span;
   begin
      while(MicroBit.IOsForTasking.Set(hc.echo) = False) loop
         --asm(wfi ) --TODO change to wait for interupt
         null;
      end loop;
      startT := Clock;
      while(MicroBit.IOsForTasking.Set(hc.echo) = True) loop
         --asm(wfi ) --TODO change to wait for interupt
         null;
      end loop;
      endT := Clock;
      pulseLength := endT - startT;
      return pulseLength;
   end pulseIn;





end HCSR04;
