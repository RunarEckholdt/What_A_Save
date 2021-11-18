with Ada.Real_Time;
with HCSR04;
with Timed_Conditions; use Timed_Conditions;

package body HCSR04_timeout_Controller is
   Time_Expired:Boolean;
   timeout : constant Time_Span:= Milliseconds(2_000);
   T:ada.Real_Time.Time;

   task body Control is
   begin
      loop
         Wait(This      => HCSR04.sendt,
              Deadline  => Timeout,
              Timed_Out => Time_Expired)
         if Time_Expired then
            delay until T;
         end if;

 end loop;


end Control;

end HCSR04_timeout_Controller;
