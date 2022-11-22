--------------------------------------------------------------------------------------------------------------------
--  This software is provided 'as-is', without any express or implied
--  warranty. In no event will the authors be held liable for any damages
--  arising from the use of this software.
--
--  Permission is granted to anyone to use this software for any purpose,
--  including commercial applications, and to alter it and redistribute it
--  freely, subject to the following restrictions:
--
--     1. The origin of this software must not be misrepresented; you must not
--     claim that you wrote the original software. If you use this software
--     in a product, an acknowledgment in the product documentation would be
--     appreciated but is not required.
--
--     2. Altered source versions must be plainly marked as such, and must not be
--     misrepresented as being the original software.
--
--     3. This notice may not be removed or altered from any source
--     distribution.
--------------------------------------------------------------------------------------------------------------------
--  SDL.Audio.Frames
--------------------------------------------------------------------------------------------------------------------

package SDL.Audio.Frames is

   ------------------------------
   --  Channel configurations  --
   ------------------------------

   type Config_Mono         is (Common);
   type Config_Stereo       is (Front_Left, Front_Right);
   type Config_Surround_2_1 is (Front_Left, Front_Right, LFE);
   type Config_Quad         is (Front_Left, Front_Right,
                                Back_Left, Back_Right);
   type Config_Quad_Center  is (Front_Left, Front_Right,
                                Front_Center,
                                Back_Left, Back_Right);
   type Config_Surround_5_1 is (Front_Left, Front_Right,
                                Front_Center, LFE,
                                S_Left, S_Right);
   type Config_Surround_6_1 is (Front_Left, Front_Right,
                                Front_Center, LFE,
                                Back_Center,
                                S_Left, S_Right);
   type Config_Surround_7_1 is (Front_Left, Front_Right,
                                Front_Center, LFE,
                                Back_Left, Back_Right,
                                S_Left, S_Right);

   generic
      type Sample_Type  is private;
      type Frame_Config is (<>);  --  See enumerations above (Config_*)
   package Buffer_Overlays is

      subtype Frame_Index is Natural;
      type Frame_Type is array (Frame_Config) of Sample_Type;

      function First_Index (Buffer : Buffer_Type) return Frame_Index;
      function Last_Index  (Buffer : Buffer_Type) return Frame_Index;
      --  TODO: function Length (Buffer : Buffer_Type) return Frame_Index;

      function Value (Buffer  : in Buffer_Type;
                      Frame   : in Frame_Index;
                      Channel : in Frame_Config)
                     return Sample_Type;

      function Value (Buffer : in Buffer_Type;
                      Frame  : in Frame_Index)
                     return Frame_Type;

      --  Please not that conceptually the buffer changes, but due to the fact
      --  that behind the scenes these are raw pointers to the data, we can
      --  get away with using "in" parameter mode. The added value is that
      --  a buffer's contents can be changed directly via a To_Buffer call.
      procedure Update (Buffer  : in Buffer_Type;
                        Frame   : in Frame_Index;
                        Channel : in Frame_Config;
                        Value   : in Sample_Type);

      procedure Update (Buffer  : in Buffer_Type;
                        Frame   : in Frame_Index;
                        Value   : in Frame_Type);
   end Buffer_Overlays;

end SDL.Audio.Frames;

