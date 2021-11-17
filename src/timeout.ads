with Ada.Real_Time;
package timeout is
   protected PO is
   entry Call(Timeout1: out Boolean);
   procedure TooLate;
   procedure UsedToReleaseCall;
   private
   Timed_Out:Boolean :=False;
   Release:Boolean :=False;

end PO;
protected TimerControl is
      entry Wait(WaitTime: out Ada.Real_Time.Time);
      procedure SetTime(WaitTime: Ada.Real_Time.Time);
   private
      Timeout:Ada.Real_Time.Time;
      Realeased:Boolean:=False;
end TimerControl;




end timeout;
