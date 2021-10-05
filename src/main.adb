
with OV2640;

procedure Main is
   cam : OV2640_Camera;
begin

   OV2640.Initialize(cam,16#7D);
   OV2640.Set_Frame_Size(cam,OV2640.CIF);
   OV2640.Pixel_Format(cam,OV2640.Pix_RGB565);
   OV2640.Set_Frame_Rate(cam,FR_60FPS);



   null;
end Main;
