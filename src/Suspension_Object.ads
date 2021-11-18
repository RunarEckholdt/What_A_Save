package Ada.Synchronous_Task_Control is

   type Suspension_Object is limited private;

   procedure Set_True (S : in out Suspension_Object);

   procedure Suspend_Until_True (S : in out Suspension_Object);

   ...
private
   ...
end Ada.Synchronous_Task_Control;
