
with MicroBit.IOs;
with MicroBit.I2C;
with MicroBit.Time;
with OV2640;


procedure Main is
   cam : OV2640.OV2640_Camera(MicroBit.I2C.Controller);
begin

   --TODO Inizialize I2C first
   OV2640.Initialize(cam, 16#26#);
   OV2640.Set_Frame_Size(cam,OV2640.CIF);
   OV2640.Set_Pixel_Format(cam,OV2640.Pix_RGB565);
   OV2640.Set_Frame_Rate(cam,OV2640.FR_60FPS);


   loop

      MicroBit.IOs.Set(12,True);
      MicroBit.Time.Delay_Ms(500);
      MicroBit.IOs.Set(12,False);
      MicroBit.Time.Delay_Ms(500);

   end loop;

end Main;
