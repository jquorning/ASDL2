--
--
--

with SDL.Audio.Frames;

package body Audiostream_Callbacks is

   procedure Clear (Buffer : in Buffer_Type);
   --  Clear Buffer.

   type Sample_Type is range -2**15 .. 2**15 - 1;

   package Stereo_Buffers is
      new SDL.Audio.Frames.Buffer_Overlays (Sample_Type  => Sample_Type,
                                            Frame_Config => Frames.Config_Stereo);

   procedure Clear (Buffer : in Buffer_Type) is
      use Stereo_Buffers;
      subtype Frame_Range is Frame_Index
        range First_Index (Buffer) .. Last_Index (Buffer);
   begin
      for Index in Frame_Range loop
         Update (Buffer, Index, Value => (0, 0));
      end loop;
   end Clear;

   procedure Callback (Userdata  : in out User_Data;
                       Audio_Buf : in     Buffer_Type)
   is
      Got : Byte_Count;
      pragma Unreferenced (Userdata, Got);
   begin
      Clear (Audio_Buf);
      Streams.Stream_Get (Stream, Audio_Buf, Got);
   end Callback;

end Audiostream_Callbacks;
