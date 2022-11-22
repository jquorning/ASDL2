--
--
--

with Ada.Text_IO;
with Ada.Command_Line;

with SDL.Audio.Streams;

with Audiostream_Callbacks;
with Audio_IO;

procedure Audiostream is
   use Ada.Text_IO;
   use SDL.Audio;
   use SDL.Audio.Streams;

   Desired : constant Audio_Spec :=
     (Frequency => 48_000,
      Channels  => 2,
      Format    => Audio_S16,
      Callback  => Audiostream_Callbacks.Callback_Instance.C_Callback'Access,
      Samples   => 512,
      Silence   => 0,
      Userdata  => SDL.Audio.No_User_Data,
      Padding   => 0,
      Size      => 0);

   Obtained  : Audio_Spec;
   WAV_Spec  : Audio_Spec;
   Buffer_In : Buffer_Type;
   Stream    : Audio_Stream renames Audiostream_Callbacks.Stream;
begin
   if Ada.Command_Line.Argument_Count = 0 then
      Ada.Text_IO.Put_Line ("Usage: audiostream file.wav");
      return;
   end if;

   if SDL.Initialise (SDL.Enable_Audio) then
      null;
   end if;
   Open (Desired, Obtained);

   for File in 1 .. Ada.Command_Line.Argument_Count loop
      declare
         Filename : String renames Ada.Command_Line.Argument (File);
      begin
         Load_WAV (Filename, WAV_Spec, Buffer_In);

         Put ("Rate: ");       Put (WAV_Spec.Frequency'Image);
         Put (" Channels: ");  Put (WAV_Spec.Channels'Image);
         Put (" ");
         Audio_IO.Dump (WAV_Spec.Format, Compact => True);
         Put (" File: ");  Put (Filename);
         New_Line;

         Stream :=
           New_Stream (Source_Format   => WAV_Spec.Format,
                       Source_Channels => WAV_Spec.Channels,
                       Source_Rate     => WAV_Spec.Frequency,
                       Dest_Format     => Obtained.Format,
                       Dest_Channels   => Obtained.Channels,
                       Dest_Rate       => Obtained.Frequency);
         Pause (False);

         Stream_Put (Stream, Buffer_In);
         Free_WAV (Buffer_In);
         Stream_Flush (Stream);

         while Stream_Available (Stream) /= 0 loop
            delay 0.100;
         end loop;

         --  Clean up
         Pause (True);
         Free_Stream (Stream);

      exception when Audio_Error =>
         Put ("Could not load file: ");
         Put (Filename);
         New_Line;
      end;
   end loop;
   Quit;
end Audiostream;
