

package body HCSR04 is


   --  procedure Wait is
   --  begin
   --     Ada.Synchronous_Task_Control.Suspend_Until_True(released);
   --     --Ada.Synchronous_Task_Control.Set_False(released);
   --     --released := False;
   --  end Wait;

   protected body EchoHandlerInterface is

      --  entry Signal(intrEvent : in InterruptEvent) when True is
      --  begin
      --     null;
      --  end Signal;
      --
      --  procedure AcceptSignal(evt : out InterruptEvent) is
      --  begin
      --     Accept Signal(intrEvent : in InterruptEvent) do
      --        evt := intrEvent;
      --     end Signal;
      --  end AcceptSignal;

      entry Wait when released is
      begin
         released := False;
      end Wait;

      --  entry Signal(intrEvent : in InterruptEvent) is
      --  begin
      --
      --  end Signal;


      procedure EchoHandler is

      begin
         if(nRF.Events.Triggered(nRF.Events.GPIOTE_IN_0))then
            nRF.Events.Clear(nRF.Events.GPIOTE_IN_0);
            --lastEvent := rising;
            --Signal(rising);
            --MicroBit.Console.Put_Line("Falling");
            released := True;
         end if;

         --  if(nRF.Events.Triggered(nRF.Events.GPIOTE_IN_1))then
         --     nRF.Events.Clear(nRF.Events.GPIOTE_IN_1);
         --     lastEvent := falling;
         --     --Signal(falling);
         --     MicroBit.Console.Put_Line("Falling");
         --     released := True;
         --  end if;






         --Ada.Synchronous_Task_Control.Set_True(released);
         --MicroBit.Console.Put("Interrupted: ");
         --MicroBit.Console.Put_Line(MicroBit.IOsForTasking.Set(28)'Image);


      end EchoHandler;

      procedure setEventType(et : nRF.Event_Type) is
      begin
         evtType := et;
      end setEventType;

      --  procedure getLastEvent(lEvent : out InterruptEvent) is
      --  begin
      --     lEvent := lastEvent;
      --  end getLastEvent;

  end EchoHandlerInterface;


   procedure initializeInterrupt(hc : in HCSR04;channel : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel) is
   evtType : nRF.Event_Type;
   begin
      MicroBit.PinInterrupt.AttachPinToChannel(28,channel,MicroBit.PinInterrupt.falling,evtType);
      --MicroBit.PinInterrupt.AttachPinToChannel(28,1,MicroBit.PinInterrupt.falling, evtType);
      EchoHandlerInterface.setEventType(nRF.Events.GPIOTE_IN_0);
   end initializeInterrupt;


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
      delay until trigStart + Microseconds(100); --Fetched from the timing diagram
      MicroBit.IOsForTasking.Set(hc.trig,False);
   end trig;



   --Measures the time lenght of a high pulse
   procedure pulseIn(hc : in HCSR04; pulseTime : out Time_Span; result : out Boolean) is
      startT : Time;
      endT : Time;
      lastEvent : InterruptEvent := falling;

   begin

      while(MicroBit.IOsForTasking.Set(hc.echo) = False) loop
         null;
      end loop;



      --  while(lastEvent /= rising) loop
      --     EchoHandlerInterface.getLastEvent(lastEvent);
      --  end loop;




      startT := Clock;

      --  while(MicroBit.IOsForTasking.Set(hc.echo) = True) loop
      --     null;
      --
      --  end loop;

      --EchoHandlerInterface.Wait;
      --  if(MicroBit.IOsForTasking.Set(hc.echo) = True) then
      --     --null;
      --
      --  end if;


      EchoHandlerInterface.Wait;

      --while(lastEvent /= falling) loop
      --EchoHandlerInterface.getLastEvent(lastEvent);
      --end loop;
      endT := Clock;
      pulseTime := endT - startT;
      result := True;
   end pulseIn;





end HCSR04;
