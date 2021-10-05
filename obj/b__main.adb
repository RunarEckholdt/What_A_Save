pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__main.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__main.adb");
pragma Suppress (Overflow_Check);

package body ada_main is

   E94 : Short_Integer; pragma Import (Ada, E94, "bit_fields_E");
   E83 : Short_Integer; pragma Import (Ada, E83, "memory_barriers_E");
   E81 : Short_Integer; pragma Import (Ada, E81, "cortex_m__nvic_E");
   E73 : Short_Integer; pragma Import (Ada, E73, "nrf__events_E");
   E29 : Short_Integer; pragma Import (Ada, E29, "nrf__gpio_E");
   E75 : Short_Integer; pragma Import (Ada, E75, "nrf__gpio__tasks_and_events_E");
   E77 : Short_Integer; pragma Import (Ada, E77, "nrf__interrupts_E");
   E37 : Short_Integer; pragma Import (Ada, E37, "nrf__rtc_E");
   E40 : Short_Integer; pragma Import (Ada, E40, "nrf__spi_master_E");
   E61 : Short_Integer; pragma Import (Ada, E61, "nrf__tasks_E");
   E59 : Short_Integer; pragma Import (Ada, E59, "nrf__adc_E");
   E89 : Short_Integer; pragma Import (Ada, E89, "nrf__clock_E");
   E85 : Short_Integer; pragma Import (Ada, E85, "nrf__ppi_E");
   E44 : Short_Integer; pragma Import (Ada, E44, "nrf__timers_E");
   E47 : Short_Integer; pragma Import (Ada, E47, "nrf__twi_E");
   E51 : Short_Integer; pragma Import (Ada, E51, "nrf__uart_E");
   E06 : Short_Integer; pragma Import (Ada, E06, "nrf__device_E");
   E55 : Short_Integer; pragma Import (Ada, E55, "microbit__i2c_E");
   E57 : Short_Integer; pragma Import (Ada, E57, "microbit__ios_E");
   E87 : Short_Integer; pragma Import (Ada, E87, "microbit__time_E");
   E92 : Short_Integer; pragma Import (Ada, E92, "ov2640_E");

   Sec_Default_Sized_Stacks : array (1 .. 1) of aliased System.Secondary_Stack.SS_Stack (System.Parameters.Runtime_Default_Sec_Stack_Size);


   procedure adainit is
      Binder_Sec_Stacks_Count : Natural;
      pragma Import (Ada, Binder_Sec_Stacks_Count, "__gnat_binder_ss_count");

      Default_Secondary_Stack_Size : System.Parameters.Size_Type;
      pragma Import (C, Default_Secondary_Stack_Size, "__gnat_default_ss_size");
      Default_Sized_SS_Pool : System.Address;
      pragma Import (Ada, Default_Sized_SS_Pool, "__gnat_default_ss_pool");

   begin
      null;

      ada_main'Elab_Body;
      Default_Secondary_Stack_Size := System.Parameters.Runtime_Default_Sec_Stack_Size;
      Binder_Sec_Stacks_Count := 1;
      Default_Sized_SS_Pool := Sec_Default_Sized_Stacks'Address;


      E94 := E94 + 1;
      E83 := E83 + 1;
      E81 := E81 + 1;
      E73 := E73 + 1;
      E29 := E29 + 1;
      E75 := E75 + 1;
      E77 := E77 + 1;
      E37 := E37 + 1;
      E40 := E40 + 1;
      E61 := E61 + 1;
      E59 := E59 + 1;
      E89 := E89 + 1;
      E85 := E85 + 1;
      E44 := E44 + 1;
      E47 := E47 + 1;
      E51 := E51 + 1;
      Nrf.Device'Elab_Spec;
      Nrf.Device'Elab_Body;
      E06 := E06 + 1;
      E55 := E55 + 1;
      Microbit.Ios'Elab_Spec;
      Microbit.Ios'Elab_Body;
      E57 := E57 + 1;
      Microbit.Time'Elab_Body;
      E87 := E87 + 1;
      E92 := E92 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_main");

   procedure main is
      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      adainit;
      Ada_Main_Program;
   end;

--  BEGIN Object file/option list
   --   C:\Programmering\ADA\What_A_Save\obj\main.o
   --   -LC:\Programmering\ADA\What_A_Save\obj\
   --   -LC:\Programmering\ADA\What_A_Save\obj\
   --   -LC:\Programmering\ADA\Ada_Drivers_Library\boards\MicroBit_v2\obj\sfp_lib_Debug\
   --   -LC:\gnat\2021-arm-elf\arm-eabi\lib\gnat\ravenscar-sfp-nrf52833\adalib\
   --   -static
   --   -lgnat
--  END Object file/option list   

end ada_main;
