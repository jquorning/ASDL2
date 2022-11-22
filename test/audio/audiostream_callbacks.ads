--
--
--

with SDL.Audio.Callbacks,
     SDL.Audio.Streams;

package Audiostream_Callbacks is
   use SDL.Audio;

   Stream : Streams.Audio_Stream;

   type User_Data is null record; -- No user data here.

   procedure Callback (Userdata  : in out User_Data;
                       Audio_Buf : in     SDL.Audio.Buffer_Type);

   package Callback_Instance is new SDL.Audio.Callbacks (User_Data => User_Data,
                                                         Callback  => Callback);

end Audiostream_Callbacks;
