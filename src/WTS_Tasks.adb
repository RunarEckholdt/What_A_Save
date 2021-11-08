



package body WTS_Tasks is



   protected body SharedData is
      procedure getDistance(lr : out LRData) is
      begin
         hasNewLR := False;
         lr := lrDist;
      end getDistance;

      procedure checkForNewDistData(hasNewData : out Boolean) is
      begin
         hasNewData := hasNewLR;
      end checkForNewDistData;

      procedure setDistData(lr : in LRData) is
      begin
         lrDist := lr;
         hasNewLR := True;
      end setDistData;

      procedure getDirection(dir : out L298N_MDM.dirId) is
      begin
         dir := direction;
      end getDirection;

      procedure setDirection(dir : in L298N_MDM.dirId) is
      begin
         direction := direction;
      end setDirection;

      procedure getMode (m : out BehaviourMode) is
      begin
         m := mode;
      end getMode;


      procedure setMode(m : in BehaviourMode) is
      begin
         mode := m;
      end setMode;
   end SharedData;


   task body MotorControll is
      cyclePeriod : constant Time_Span := Milliseconds(8);
      nextCycle : Time := Clock;
      direction : L298N_MDM.dirId := L298N_MDM.stop;
      mode : BehaviourMode := defaultmode;
      lr : LRData;
      mdm : L298N_MDM.L298N;
      newDist : Boolean;
      procedure Track is
         diffDist : CM;
      begin
         SharedData.checkForNewDistData(newDist);
         if(newDist)then
            SharedData.getDistance(lr);
            diffDist := abs(lr.left-lr.right);
            if(diffDist < 1) then
               direction := L298N_MDM.stop;
            elsif(lr.left > lr.right) then
               direction := L298N_MDM.right;
            else
               direction := L298N_MDM.left;
            end if;
            L298N_MDM.move(mdm,direction,defaultSpeed);
            SharedData.setDirection(direction);

         end if;
      end Track;

      procedure Probe is
      begin
         null;
      end Probe;

   begin
      mdm.IN_1 := mdmEN1;
      mdm.IN_2 := mdmEN2;
      mdm.SPD_1 := mdmSpeed;
      MicroBit.IOsForTasking.Set_Analog_Period_Us(16);
      loop
         nextCycle := Clock + cyclePeriod;
         case mode is
            when PROBE =>
               Probe;
            when TRACK =>
               Track;
            when others =>
               null; --implement idle later

         end case;
         delay until nextCycle;
      end loop;


   end MotorControll;

   task body MainControll is
      cyclePeriod : constant Time_Span := Milliseconds(16);
      nextCycle : Time := Clock;
      mode : BehaviourMode := defaultmode;
   begin

      loop
         nextCycle := Clock + cyclePeriod;
         SharedData.setMode(TRACK);
         delay until nextCycle;
      end loop;

   end MainControll;



   task body DistanceMeasure is
      cyclePeriod : constant Time_Span := Milliseconds(16);
      nextCycle : Time := Clock;
      lr : LRData;
      hc1, hc2 : HCSR04.HCSR04;
      procedure measure(hc : HCSR04.HCSR04; side : HCToUse) is
         distance : Float;
         result : Boolean;
         distanceCM : CM;
      begin
         HCSR04.measure(hc,distance,result);
         if(distance < 0.60 or not result) then
            case side is
            when left =>
               lr.left := OUT_OF_BOUNDS;
               lr.failCountLeft := lr.failCountLeft + 1;
            when right =>
               lr.right := OUT_OF_BOUNDS;
               lr.failCountRight := lr.failCountRight + 1;
            end case;
         else
            distanceCM := CM(Float'Rounding(distance* 100.0));
            case side is
            when left =>
               lr.left := distanceCM;
               lr.failCountLeft := 0;
            when right =>
               lr.right := distanceCM;
               lr.failCountRight := 0;
            end case;
         end if;

      end measure;

   begin
      hc1.trig := hc1Trig;
      hc1.echo := hc1Echo;
      hc2.trig := hc2Trig;
      hc2.echo := hc2Echo;
      loop
         nextCycle := Clock + cyclePeriod;
         measure(hc1,left);
         measure(hc2,right);
         SharedData.setDistData(lr);
         delay until nextCycle;
      end loop;

   end DistanceMeasure;






end WTS_Tasks;
