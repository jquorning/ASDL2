with SDL.Audio,
     SDL.Error,
     SDL.Log;

with System;

procedure Audio is

   procedure List_Drivers is
   begin
      SDL.Log.Put_Debug (Message => "Checking for available audio drivers...");

      for i in 1 .. SDL.Audio.Get_Number_Of_Drivers loop
         SDL.Log.Put_Debug
           (Message => "  Found: """ & SDL.Audio.Get_Driver_Name (Index => i) & """");
      end loop;

      SDL.Log.Put_Debug
        (Message =>
           "  Current audio driver is """ & SDL.Audio.Current_Driver & """");
   end List_Drivers;

   procedure List_Devices is
   begin
      SDL.Log.Put_Debug (Message => "Checking for audio devices...");

      for i in 1 .. SDL.Audio.Get_Number_Of_Devices (Is_Capture => False) loop
         SDL.Log.Put_Debug
           (Message => "  Found """ & SDL.Audio.Get_Device_Name (Index      => i,
                                                                 Is_Capture => False) & """");
      end loop;

      SDL.Log.Put_Debug (Message => "Checking for recording devices...");

      for i in 1 .. SDL.Audio.Get_Number_Of_Devices (Is_Capture => True) loop
         SDL.Log.Put_Debug
           (Message =>
              "  Found """ &
              SDL.Audio.Get_Device_Name (Index      => i,
                                         Is_Capture => True) & """");
      end loop;
   end List_Devices;

   procedure Open_Device (Frequency : in SDL.Audio.Sample_Rate;
                          Format    : in SDL.Audio.Audio_Format;
                          Channels  : in SDL.Audio.Channel_Count)
   is
      function Format_Image (Value : in SDL.Audio.Audio_Format) return String is
        (Value.Bits'Image & " bits/sample, " &
         (if Value.Signed then "" else "un") & "signed " &
         (if Value.Float then "float" else "integer") & ", " &
         (if Value.Big_Endian then "big" else "little") & " endian");

      Obtained : SDL.Audio.Audio_Spec;
      Device   : SDL.Audio.Device_Id;
   begin
      SDL.Log.Put_Debug
        (Message =>
           "Trying to open default audio device, requesting" &
           Frequency'Image & " Hz," &
           Format_Image (Value => Format) & "," &
           Channels'Image & " channels.");

      begin
         SDL.Audio.Open
           (Desired         => SDL.Audio.Audio_Spec'(Frequency => Frequency,
                                                     Format    => Format,
                                                     Channels  => Channels,
                                                     Silence   => 123,
                                                     Samples   => 512,
                                                     Padding   => <>,
                                                     Size      => <>,
                                                     Callback  => null,
                                                     Userdata  => System.Null_Address),
            Obtained        => Obtained,
            Device_Name     => "",
            Is_Capture      => False,
            Allowed_Changes => SDL.Audio.Allow_Any_Change,
            Device          => Device);

         SDL.Log.Put_Debug (Message => "Obtained audio data:");
         SDL.Log.Put_Debug (Message => "Frequency:" & Obtained.Frequency'Image);
         SDL.Log.Put_Debug
           (Message => "Format   :" & Format_Image (Value => Obtained.Format));
         SDL.Log.Put_Debug (Message => "Channels :" & Obtained.Channels'Image);
         SDL.Log.Put_Debug (Message => "Silence  :" & Obtained.Silence'Image);
         SDL.Log.Put_Debug (Message => "Samples  :" & Obtained.Samples'Image);
         SDL.Log.Put_Debug (Message => "Size     :" & Obtained.Size'Image);

         SDL.Audio.Close (Device => Device);
      exception
         when SDL.Audio.Audio_Error =>
            SDL.Log.Put_Error (Message => SDL.Error.Get);
            SDL.Log.Put_Debug (Message => "Call failed, did not get a device id!");
      end;
   end Open_Device;

begin
   SDL.Log.Set (Category => SDL.Log.Application, Priority => SDL.Log.Debug);

   if SDL.Initialise (Flags => SDL.Enable_Audio) then
      List_Drivers;
      List_Devices;
      Open_Device (Frequency => 22_500,
                   Format    => SDL.Audio.Audio_U8,
                   Channels  => 1);
      Open_Device (Frequency => 48_000,
                   Format    => SDL.Audio.Audio_U16_LSB,
                   Channels  => 6);
      Open_Device (Frequency => 48_000,
                   Format    => SDL.Audio.Audio_S16_LSB,
                   Channels  => 2);
   end if;

   SDL.Finalise;
end Audio;
