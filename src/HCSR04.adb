

package body HCSR04 is

   protected body EchoHandlerInterface is

      entry Wait when released is
      begin
          released := False;
      end Wait;

      procedure EchoHandler is
      begin
         released := True;
      end EchoHandler;
  end EchoHandlerInterface;


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

   begin
      while(MicroBit.IOsForTasking.Set(hc.echo) = False) loop
         EchoHandlerInterface.Wait;
      end loop;
      startT := Clock;

      while(MicroBit.IOsForTasking.Set(hc.echo) = True) loop
         EchoHandlerInterface.Wait;
      end loop;
      endT := Clock;
      pulseTime := endT - startT;
      result := True;
   end pulseIn;





end HCSR04;
