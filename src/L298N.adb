procedure MapPin(pinNum:Integer,MicrobitPin:Integer);
is
begin
   case MapPins is
      when 1 => L298N.InputPin1:=MicrobitPin;
      when 2 => L298N.InputPin2:=MicrobitPin;
      when others => raise Error;
   end case;
--   if(pinNum = 1)then
--      L298N.InputPin1:=MicrobitPin;
--   elsif(pinNum=2) then
--      L298N.InputPin2:=MicrobitPin;
--   end if;
end SetPin;

procedure SetPinValue(pinNum:Integer, state:Boolean);
is
begin
   case pinNum is
      when 1 => MicroBit.IOS.Set(L298N.InputPin1,state);
      when 2 => MicroBit.IOS.Set(L298N.InputPin2, state);
      when others => MicroBit.IOS.Set(L298N.InputPin1, low) and MicroBit.IOS.Set(L298N.InputPin2, low);
   end case;

  --if(pinNum=1) then
  --   MicroBit.IOS.Set(L298N.InputPin1,state);
  -- elsif(pinNum=2) then
  --  MicroBit.IOS.Set(L298N.InputPin2, state);
  --elsif(pinNum!= (1 | 2)) then
  -- return 1;
  --end if;
end SetPinValue;

procedure moveLeft
is
begin
      SetPinValue(1,state); -- set the pins depending on your setup.
      SetPinValue(2,!state);  -- MicroBit.IOs.Set(L298N.InputPin2,False);The L298N movement: 00/11-No movement. 10/01=drive/reverse

end moveLeft;

procedure moveRight
is
begin
   SetPinValue(1,!state);  -- MicroBit.IOS.Set(L298N.InputPin1,False);
   SetPinValue(2,state); -- MicroBit.IOs.Set(L298N.InputPin2,True);

end moveRight;

procedure moveKeeper (BallEndpoint:Integer;
                      Poss:Integer)
is
   begin
if BallEndpoint>Poss then
      moveLeft;
      Put_Line ("left");

elsif BallEndpoint<Poss then
      moveRight;
      Put_Line ("right");

      else
         Put_Line ("Neither left or right");
      MicroBit.IOS.Set(1,False);
      MicroBit.IOs.Set(0,False);
 end if;
end moveKeeper;
