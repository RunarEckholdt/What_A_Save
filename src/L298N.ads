with Ada.Real_Time; use Ada.Real_Time;
with Ada.Execution_Time;
with Ada.Text_IO; use Ada.Text_IO;
with MicroBit.IOs;

package L298N is
   type L298N is
   CourtSize:Integer 42;
   BallEndpoint:Integer range 1 .. CourtSize;
   InputPin1: Integer;
   InputPin2: Integer;


   Current_Poss:Integer is private;
   procedure moveLeft;
   procedure moveRight;
   procedure moveKeeper(BallEndpoint:Integer, Poss:Integer);
   procedure MapPin(pinNum:Integer,MicrobitPin:Integer);
   procedure SetPinValue(pinNum:Integer, state:Boolean);

 end L298N;
