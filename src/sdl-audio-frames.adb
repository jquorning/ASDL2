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

package body SDL.Audio.Frames is

   package body Buffer_Overlays is

      function First_Index (Buffer : Buffer_Type) return Frame_Index
      is (1);

      function Last_Index  (Buffer : Buffer_Type) return Frame_Index
      is (Natural (8 * Buffer.Length / Sample_Type'Size) / Frame_Type'Length);

      function Value (Buffer  : in Buffer_Type;
                      Frame   : in Frame_Index;
                      Channel : in Frame_Config)
                     return Sample_Type
      is (Value (Buffer, Frame) (Channel));

      function Value (Buffer  : in Buffer_Type;
                      Frame   : in Frame_Index)
                     return Frame_Type
      is
         subtype Array_Range is Frame_Index
           range First_Index (Buffer) .. Last_Index  (Buffer);
         type Array_Type is array (Array_Range) of Frame_Type;
         Buf : Array_Type with Address => System.Address (Buffer.Base);
      begin
         return Buf (Frame);
      end Value;

      procedure Update (Buffer  : in Buffer_Type;
                        Frame   : in Frame_Index;
                        Channel : in Frame_Config;
                        Value   : in Sample_Type)
      is
         subtype Array_Range is Frame_Index
           range First_Index (Buffer) .. Last_Index  (Buffer);
         type Array_Type is array (Array_Range) of Frame_Type;
         Buf : Array_Type with Address => System.Address (Buffer.Base);
      begin
         Buf (Frame) (Channel) := Value;
      end Update;

      procedure Update (Buffer  : in Buffer_Type;
                        Frame   : in Frame_Index;
                        Value   : in Frame_Type)
      is
         subtype Array_Range is Frame_Index
           range First_Index (Buffer) ..  Last_Index  (Buffer);
         type Array_Type is array (Array_Range) of Frame_Type;
         Buf : Array_Type with Address => System.Address (Buffer.Base);
      begin
         Buf (Frame) := Value;
      end Update;

   end Buffer_Overlays;

end SDL.Audio.Frames;

