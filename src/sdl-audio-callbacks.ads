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
--  SDL.Audio.Callbacks
--------------------------------------------------------------------------------------------------------------------

generic
   type User_Data is private; --  type of data being passed in the callback
   with procedure Callback (Data   : in out User_Data;
                            Stream : in     Buffer_Type);
   --  Your actual callback function being called by the wrapper declared in
   --  the package which takes care of the conversion of User_Data.
   --  For simplicity, audio data is handled as if it were just a bunch of
   --  bytes. This should be sufficient for most purposes of such a callback.
package SDL.Audio.Callbacks is

   procedure C_Callback (Data   : in System.Address;
                         Stream : in Buffer_Base;
                         Length : in Interfaces.C.int) with
     Convention => C;

end SDL.Audio.Callbacks;
