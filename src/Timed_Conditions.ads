with Ada.Real_Time;                use Ada.Real_Time;
with Ada.Real_Time.Timing_Events;  use Ada.Real_Time.Timing_Events;
with Ada.Synchronous_Task_Control; use Ada.Synchronous_Task_Control;

package Timed_Conditions is

   type Timed_Condition is limited private;

   procedure Wait
     (This      : in out Timed_Condition;
      Deadline  : Time;
      Timed_Out : out Boolean);

   procedure Wait
     (This      : in out Timed_Condition;
      Interval  : Time_Span;
      Timed_Out : out Boolean);

   procedure Signal (This : in out Timed_Condition);

private

   type Timed_Condition is new Timing_Event with record
      Timed_Out        : Boolean := False;
      Caller_Unblocked : Ada.Synchronous_Task_Control.Suspension_Object;
   end record;

   protected Timeout_Handler is
      pragma Interrupt_Priority;
      procedure Signal_Timeout (Event : in out Timing_Event);
   end Timeout_Handler;
   --  A shared, global PO defining the timing event handler procedure. All
   --  objects of type Timed_Condition use this one handler. Each execution of
   --  the procedure will necessarily execute at Interrupt_Priority'Last, so
   --  there's no reason to have a handler per-object.

end Timed_Conditions;
