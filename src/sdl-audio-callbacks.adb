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

with SDL.Audio.Buffers;

package body SDL.Audio.Callbacks is

   procedure C_Callback (Data   : in System.Address;
                         Stream : in Buffer_Base;
                         Length : in Interfaces.C.int) is
      Ada_User_Data : User_Data with
        Import     => True,
        Convention => Ada;
      for Ada_User_Data'Address use Data;
   begin
      Callback (Data   => Ada_User_Data,
                Stream => Buffers.To_Buffer (Audio_Buf => Stream,
                                             Audio_Len => Byte_Count (Length)));
   end C_Callback;

end SDL.Audio.Callbacks;
