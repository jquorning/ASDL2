--
--
--

with Ada.Text_IO;

with SDL.Audio.Buffers;

with Audio_IO;

procedure Capture is
   use Ada.Text_IO;
   use SDL.Audio;

   Desired : constant Audio_Spec :=
     (Frequency => 12_000,
      Format    => Audio_S16,
      Channels  => 2,
      Samples   => 512,
      Silence   => 0,
      Size      => 0,
      Callback  => null,
      Userdata  => SDL.Audio.No_User_Data,
      Padding   => 0);

   Device_Capture    : Device_Id;
   Device_Playback   : Device_Id;
   Obtained_Capture  : Audio_Spec;
   Obtained_Playback : Audio_Spec;

   Buffer : Buffer_Type := Null_Buffer;
   Got    : Byte_Count;
begin
   if SDL.Initialise then
      null;
   end if;

   --
   --  Open capture and playback devices
   --
   declare
      Name_Capture  : constant String := Get_Device_Name (Is_Capture => True,  Index => 1);
      Name_Playback : constant String := Get_Device_Name (Is_Capture => False, Index => 1);
   begin
      Open (Device_Playback, Name_Playback,
            False, Desired, Obtained_Playback, Allow_No_Change);
      Open (Device_Capture,  Name_Capture,
            True,  Desired, Obtained_Capture,  Allow_No_Change);

      Put_Line ("Obtained playback:");
      Put_Line ("Device name   : " & Name_Playback);
      Put_Line ("Device_Id     :"  & Device_Playback'Image);
      Audio_IO.Dump (Obtained_Playback);
      New_Line;

      Put_Line ("Obtained capture:");
      Put_Line ("Device name   : " & Name_Capture);
      Put_Line ("Device_Id     :"  & Device_Capture'Image);
      Audio_IO.Dump (Obtained_Capture);
      New_Line;
   end;

   Buffer := Buffers.Allocate (Length => 12_000 * 2 * 2 * 4);
   --  12_000 frames/s
   --  2 samples/frame
   --  2 bytes/sample
   --  4 seconds

   --
   --  Capture
   --
   Put_Line ("Capture sound for 3 seconds...");
   Pause (Device_Capture,  False);
   delay 3.000;
   Dequeue (Device_Capture, Buffer, Got);
   Pause (Device_Capture,  True);

   Put_Line ("Capture sound for 3 seconds done.");
   Put_Line ("Got bytes: " & Got'Image & " of " & Length (Buffer)'Image);
   New_Line;

   --
   --  Play Buffer two times
   --
   Put_Line ("Sound is played back 2 times.");
   Pause (Device_Playback, False);
   Queue (Device_Playback, Buffer);
   Queue (Device_Playback, Buffer);

   while Queued_Size (Device_Playback) /= 0 loop
      delay 0.100;
   end loop;

   Buffers.Release (Buffer);
   Close (Device_Playback);
   Close (Device_Capture);
   Quit;
end Capture;
