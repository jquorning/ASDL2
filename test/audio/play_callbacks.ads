--
--
--

with SDL.Audio.Callbacks;

package Play_Callbacks is
   use SDL.Audio;

   type User_Data is null record;

   procedure Player (Userdata  : in out User_Data;
                     Audio_Buf : in     SDL.Audio.Buffer_Type);

   package CB_Instance is new SDL.Audio.Callbacks (User_Data => User_Data,
                                                   Callback  => Player);

end Play_Callbacks;
