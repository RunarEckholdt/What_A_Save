

package body HCSR04 is




   protected body EchoHandlerInterface is



      entry Wait when released is
      begin
         released := False;
      end Wait;




      procedure EchoHandler is

      begin
         if(nRF.Events.Triggered(evtType))then
            nRF.Events.Clear(evtType);
            released := True;
         end if;




      end EchoHandler;

      procedure setEventType(et : nRF.Event_Type) is
      begin
         evtType := et;
      end setEventType;



  end EchoHandlerInterface;


   procedure initializeInterrupt(hc : in HCSR04;channel : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel) is
   evtType : nRF.Event_Type;
   begin
      --MicroBit.PinInterrupt.AttachPinToChannel(MicroBit.PinInterrupt.Pin_Id(hc.echo),channel,MicroBit.PinInterrupt.falling,evtType);
      MicroBit.PinInterrupt.AttachPinToChannel(28,channel,MicroBit.PinInterrupt.falling,evtType);
      EchoHandlerInterface.setEventType(evtType);
   end initializeInterrupt;


   --Measures the distance in meters
   procedure measure(hc : in HCSR04; distance : out Float; result : out Boolean; uom : in UnitOfMeasure := METER) is
      timeS : Time_Span;
      timeSFl : Float;
      speedOfSound : constant Float := 343.0;
   begin
      trig(hc);
      pulseIn(hc,timeS, result);
      if(result) then
         timeSFl := Float(To_Duration(timeS));
         distance := (timeSFl/2.0) * speedOfSound;

         case uom is
            when CM =>
               distance := distance * 100.0;
            when MM =>
               distance := distance * 1000.0;
            when METER =>
               null;
         end case;
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
      delay until trigStart + Microseconds(100); --Fetched from the timing diagram
      MicroBit.IOsForTasking.Set(hc.trig,False);
   end trig;



   --Measures the time lenght of a high pulse
   procedure pulseIn(hc : in HCSR04; pulseTime : out Time_Span; result : out Boolean) is
      startT : Time;
      endT : Time;
      lastEvent : InterruptEvent := falling;

   begin

      --wait until the HCSR04 is done sending signal
      while(MicroBit.IOsForTasking.Set(hc.echo) = False) loop
         null;
      end loop;


      startT := Clock;

      --Wait signal is recieved back or module timeout
      EchoHandlerInterface.Wait;

      endT := Clock;
      pulseTime := endT - startT;
      result := True;
   end pulseIn;





end HCSR04;
