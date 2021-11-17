package body HCSR04 is

--     protected PO is
--     entry Call(Timeout_en: out Boolean);
--     procedure UsedToReleaseCall;
--     procedure TooLate;
--  private
--     TimeOut_T:Boolean :=False;
--        Release:Boolean :=False;
--        const_period:Ada.Real_Time.Time;
--        Timeout: Ada.Real_Time.Time;
--
--     end PO;



--  protected body PO is
--     procedure TooLate is
--     begin
--        if Call'Count = 1 then
--           TimeOut_T := true;
--           Release := true;
--        end if;
--     end TooLate;
--
--     procedure UsedToReleaseCall is
--     begin
--        TimeOut_T := False;
--        Release := True;
--     end UsedToReleaseCall;
--
--     entry Call(Timeout_en: out Boolean) when Release is
--     begin
--        Timeout_en := TimeOut_T;
--        Release := False;
--     end Call;
--     end PO;


   protected body EchoHandlerInterface is

      entry Wait when released is
      begin
         --WaitTime := Timeout;
         released := False;
         --timeout := Ada.Real_Time.Time;
      end Wait;

      procedure SetMaxTime(WaitTime: Ada.Real_Time.Time) is
      begin
         Timeout:= WaitTime;
         Released := False;
      end SetMaxTime;




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

      --  task Timer;
      --     task body Timer is
      --        T: Ada.Real_Time.Time;
      --     begin
      --        loop
      --           EchoHandlerInterface.Wait;
      --           delay until T;
      --           PO.TooLate;
      --        end loop;
      --
      --     end Timer;
   procedure initializeInterrupt(hc : in HCSR04;channel : in nRF.GPIO.Tasks_And_Events.GPIOTE_Channel) is
   evtType : nRF.Event_Type;
   begin
      --MicroBit.PinInterrupt.AttachPinToChannel(MicroBit.PinInterrupt.Pin_Id(hc.echo),channel,MicroBit.PinInterrupt.falling,evtType);
      MicroBit.PinInterrupt.AttachPinToChannel(28,channel,MicroBit.PinInterrupt.falling,evtType);
      EchoHandlerInterface.setEventType(evtType);
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

   --time controll--------------------------
   protected TimerControl is
   entry Wait(WaitTime:  out Ada.Real_Time.Time);
   procedure SetTime(WaitTime: Ada.Real_Time.Time);
private
      Timeout:Ada.Real_Time.Time;
      outOfBoundsPeriod:Ada.Real_Time.Time_Span:=Microseconds(40);
      Release: Boolean := False;
   end TimerControl;

protected body TimerControl is
   entry Wait(WaitTime: out Ada.Real_Time.Time) when Release is
      begin
         --if(WaitTime - Ada.Real_Time.Time>outOfBoundsPeriod) then

      WaitTime:= Timeout;
      Release := False;
        -- end if;
      end Wait;

   procedure SetTime(WaitTime: Ada.Real_Time.Time) is
   begin
      Timeout := WaitTime;
      Release := True;
      end SetTime;
   end TimerControl;


   --Measures the time lenght of a high pulse
   procedure pulseIn(hc : in HCSR04; pulseTime : out Time_Span; result : out Boolean) is
      startT : Time;
      endT : Time;
      lastEvent : InterruptEvent := falling;
      outOfBoundsPeriod: Ada.Real_Time.Time_Span:=Microseconds(40);
      --const_T : ada.Real_Time.Time_Span:= 40;
      test_var:Boolean:= false;

   begin

      --wait until the HCSR04 is done sending signal
      while(MicroBit.IOsForTasking.Set(hc.echo) = False) loop
         null;
      end loop;


      startT := Clock;
      --TimerControl.SetTime(WaitTime => outOfBoundsPeriod );
      --  if(startT - Clock >= outOfBoundsPeriod) then
      --     result := True;
       --EchoHandlerInterface.Wait(startT);

      --  end if;
      --timeout.TimerControl.Wait(WaitTime => startT);
      --timeout.PO.Call(test_var);
      --Wait signal is recieved back or module timeout
      --EchoHandlerInterface.timeout;


      endT := Clock;
      pulseTime := endT - startT;
      result := True;
      --timeout.TimerControl.SetTime(Clock);

   end pulseIn;



end HCSR04;
