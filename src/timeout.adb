package body timeout is


protected body PO is
   procedure TooLate is
   begin
      if Call'Count = 1 then
         Timed_Out := true;
         Release := true;
      end if;
   end TooLate;

   procedure UsedToReleaseCall is
   begin
      Timed_Out := False;
      Release := True;
   end UsedToReleaseCall;

   entry Call(Timeout1: out Boolean) when Release is
   begin
       Timeout1:= Timed_Out;
      Release := False;
   end Call;
end PO;

--page 34 of http://www.open-std.org/jtc1/sc22/wg9/n424.pdf

protected body TimerControl is
   entry Wait(WaitTime: out Ada.Real_Time.Time) when Realeased is
   begin
      WaitTime:= Timeout;
      Realeased := False;
   end Wait;
   procedure SetTime(WaitTime: Ada.Real_Time.Time) is
   begin
      Timeout := WaitTime;
      Realeased := True;
   end SetTime;
end TimerControl;

task Timer with Priority=>3;
task body Timer is
   T:Ada.Real_Time.Time;
begin
   loop
      TimerControl.Wait(T);
      delay until T;
      PO.TooLate;
   end loop;
end Timer;

end timeout;
