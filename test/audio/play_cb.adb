--
--
--
--  Play UFO sound by direct manipulation of callback buffer.
--

with Ada.Text_IO;

with SDL.Audio;

with Play_Callbacks;

procedure Play_CB is
   use SDL.Audio;
   use Ada.Text_IO;

   Desired  : constant Audio_Spec :=
     (Frequency => 24_000,
      Format    => Audio_S16_Sys,
      Channels  => 2,
      Samples   => 512,
      Silence   => 0,
      Callback  => Play_Callbacks.CB_Instance.C_Callback'Access,
      Userdata  => SDL.Audio.No_User_Data,
      Padding   => 0,
      Size      => 0);
   Obtained : Audio_Spec;
begin
   if not SDL.Initialise (SDL.Enable_Audio) then
      Put_Line ("Could not initialise SDL audio.");
      return;
   end if;

   Open (Desired  => Desired,
         Obtained => Obtained);
   if
     Obtained.Frequency /= Desired.Frequency or
     Obtained.Format    /= Desired.Format    or
     Obtained.Channels  /= Desired.Channels
   then
      Put_Line ("Could not obtain audio quality.");
      return;
   end if;

   Pause (False);
   delay 5.000;
   Pause (True);

   delay 0.100;
   Close;
   Quit;
end Play_CB;
