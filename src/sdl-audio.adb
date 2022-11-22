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

with SDL.Error;

with Interfaces.C.Strings;

package body SDL.Audio is

   function Get_Number_Of_Drivers return Natural
   is
      function SDL_Get_Number_Of_Drivers return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetNumAudioDrivers";
   begin
      return Natural (SDL_Get_Number_Of_Drivers);
   end Get_Number_Of_Drivers;

   function Get_Driver_Name (Index : Positive) return String
   is
      use Interfaces.C.Strings;
      function SDL_Get_Driver_Name (Index : in Integer)
                                   return chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetAudioDriver";
   begin
      return Value (SDL_Get_Driver_Name (Index - 1));
   end Get_Driver_Name;

   procedure Initialize (Driver : in String) is
      use Interfaces.C.Strings;

      function SDL_Audio_Init (Driver_Name : in chars_ptr)
                              return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_AudioInit";

      --  We assume that we will not be called with an empty string
      --  here, so no special handling required. Also, I am not certain
      --  if SDL_Audio_Init is supposed to handle NULL pointers.
      C_Driver_Name : chars_ptr := New_String (Driver);

      Result : constant C.int := SDL_Audio_Init (C_Driver_Name);
   begin
      Free (C_Driver_Name); --  deallocate the C string

      if Result = 0 then
         raise Audio_Error with SDL.Error.Get;
      end if;
   end Initialize;

   procedure Quit is
      procedure SDL_Audio_Quit with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_AudioQuit";
   begin
      SDL_Audio_Quit;
   end Quit;

   function Current_Driver return String is
      use Interfaces.C.Strings;
      function SDL_Get_Current_Audio_Driver return chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetCurrentAudioDriver";
   begin
      return Value (SDL_Get_Current_Audio_Driver);
   end Current_Driver;

   procedure Open (Desired  : in     Audio_Spec;
                   Obtained :    out Audio_Spec)
   is
      function SDL_Open_Audio (Desired  : in     Audio_Spec;
                               Obtained :    out Audio_Spec)
                              return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_OpenAudio";

      Result : constant C.int := SDL_Open_Audio (Desired, Obtained);
   begin
      if Result /= SDL.Success then
         raise Audio_Error with SDL.Error.Get;
      end if;
   end Open;

   procedure Open (Required : in out Audio_Spec)
   is
      function SDL_Open_Audio (Desired  : in     Audio_Spec;
                               Obtained : access Audio_Spec)
                              return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_OpenAudio";
      --  Alternative interface. If "Obtained" is NULL, Desired will only be
      --  updated with the respective size and silence values.
      Result : constant C.int := SDL_Open_Audio (Desired  => Required,
                                                 Obtained => null);
   begin
      if Result /= SDL.Success then
         raise Audio_Error with SDL.Error.Get;
      end if;
   end Open;

   function Get_Number_Of_Devices (Is_Capture : in Boolean) return Natural
   is
      function SDL_Get_Number_Of_Devices (Capture : in C.int)
                                         return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetNumAudioDevices";
   begin
      return Natural (SDL_Get_Number_Of_Devices
                        ((if Is_Capture then 1 else 0)));
   end Get_Number_Of_Devices;

   function Get_Device_Name (Index      : in Positive;
                             Is_Capture : in Boolean) return String
   is
      use Interfaces.C.Strings;
      function SDL_Get_Device_Name (Index      : in C.int;
                                    Is_Capture : in C.int)
                                   return chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetAudioDeviceName";
   begin
      return Value (SDL_Get_Device_Name (C.int (Index - 1),
                                         (if Is_Capture then 1 else 0)));
   end Get_Device_Name;

   procedure Open (Device          :    out Device_Id;
                   Device_Name     : in     String;
                   Is_Capture      : in     Boolean;
                   Desired         : in     Audio_Spec;
                   Obtained        :    out Audio_Spec;
                   Allowed_Changes : in     Allowed_Changes_Flags)
   is
      use Interfaces.C.Strings;
      function SDL_Open_Audio_Device
        (Device_Name     : in     chars_ptr;
         Is_Capture      : in     C.int;
         Desired         : in     Audio_Spec;
         Obtained        :    out Audio_Spec;
         Allowed_Changes : in     Allowed_Changes_Flags)
        return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_OpenAudioDevice";

      --  In Ada we can't easily distinguish between an empty string
      --  and a null pointer. For the sake of simplicity we assume that
      --  an empty string never denotes a valid device name and should
      --  be used as the place-holder for "use whatever device you think
      --  is fine", which in C translates to NULL.
      C_Device_Name : chars_ptr := (if Device_Name = ""
                                    then Null_Ptr
                                    else New_String (Device_Name));

      Result : constant C.int := SDL_Open_Audio_Device
        (Device_Name     => C_Device_Name,
         Is_Capture      => (if Is_Capture then 1 else 0),
         Desired         => Desired,
         Obtained        => Obtained,
         Allowed_Changes => Allowed_Changes);
   begin
      Free (C_Device_Name); --  deallocate the C string

      if Result <= 0 then
         raise Audio_Error with SDL.Error.Get;
      end if;
      Device := Device_Id (Result);
   end Open;

   function Status return Status_Type is
      function SDL_Get_Status return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetAudioStatus";
   begin
      return Status_Type'Val (SDL_Get_Status);
   end Status;

   function Status (Device : in Device_Id) return Status_Type is
      function SDL_Get_Audio_Device_Status
        (Dev : in Device_Id)
        return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetAudioDeviceStatus";
   begin
      return Status_Type'Val (SDL_Get_Audio_Device_Status (Device));
   end Status;

   procedure Pause (Pause_On : in Boolean) is
      procedure SDL_Pause (Pause_On : in C.int) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_PauseAudio";
   begin
      SDL_Pause ((if Pause_On then 1 else 0));
   end Pause;

   procedure Pause (Device   : in Device_Id;
                    Pause_On : in Boolean)
   is
      procedure SDL_Pause_Audio_Device (Dev      : in Device_Id;
                                        Pause_On : in C.int) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_PauseAudioDevice";
   begin
      SDL_Pause_Audio_Device (Device, (if Pause_On then 1 else 0));
   end Pause;

   procedure Load_WAV_RW (Source   : in out SDL.RWops.RWops;
                          Free_Src : in     Boolean;
                          Spec     :    out Audio_Spec;
                          Buffer   :    out Buffer_Type)
   is
      type Audio_Spec_Access is access all Audio_Spec;
      function SDL_Load_WAV_RW (Src       : in  SDL.RWops.RWops;
                                Freesrc   : in     Integer;
                                Spec      :    out Audio_Spec;
                                Audio_Buf :    out Buffer_Base;
                                Audio_Len :    out Byte_Count)
                               return Audio_Spec_Access with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_LoadWAV_RW";

      Result : Audio_Spec_Access;
   begin
      Result := SDL_Load_WAV_RW (Source,
                                 (if Free_Src then 1 else 0),
                                   Spec, Buffer.Base, Buffer.Length);
      if Result = null then
         raise Audio_Error with SDL.Error.Get;
      end if;
   end Load_WAV_RW;

   procedure Load_WAV (Filename : in     String;
                       Spec     :    out Audio_Spec;
                       Buffer   :    out Buffer_Type)
   is
      use SDL.RWops;
      Ops : RWops.RWops := From_File (Filename, Read_Binary);
   begin
      Load_WAV_RW (Ops, True, Spec, Buffer);
   end Load_WAV;

   procedure Free_WAV (Buffer : in out Buffer_Type) is
      procedure SDL_Free_WAV (Audio_Buf : in Buffer_Base) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_FreeWAV";
   begin
      SDL_Free_WAV (Buffer.Base);
      Buffer.Length := 0;
   end Free_WAV;

   -----------
   --  Mix  --
   -----------

   procedure Mix (Target : in Buffer_Type;
                  Source : in Buffer_Type;
                  Volume : in Audio_Volume)
   is
      procedure SDL_Mix_Audio (Dst    : in Buffer_Base;
                               Src    : in Buffer_Base;
                               Len    : in Byte_Count;
                               Volume : in Integer)
        with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_MixAudio";
   begin
      SDL_Mix_Audio (Target.Base, Source.Base, Target.Length, Volume);
   end Mix;

   procedure Mix_Format (Target : in Buffer_Type;
                         Source : in Buffer_Type;
                         Format : in Audio_Format;
                         Volume : in Audio_Volume)
   is
      procedure SDL_Mix_Audio_Format (Dst    : in Buffer_Base;
                                      Src    : in Buffer_Base;
                                      Format : in Audio_Format;
                                      Len    : in Byte_Count;
                                      Volume : in Integer)
        with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_MixAudioFormat";
   begin
      SDL_Mix_Audio_Format (Target.Base, Source.Base, Format, Target.Length, Volume);
   end Mix_Format;

   ----------------
   --  Queueing  --
   ----------------

   procedure Queue (Device : in Device_Id;
                    Buffer : in Buffer_Type)
   is
      function SDL_Queue_Audio (Dev  : in Device_Id;
                                Data : in Buffer_Base;
                                Len  : in Byte_Count)
                               return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_QueueAudio";
      Result  : constant C.int
        := SDL_Queue_Audio (Device, Buffer.Base, Buffer.Length);
   begin
      if Result /= SDL.Success then
         raise Audio_Error with SDL.Error.Get;
      end if;
   end Queue;

   procedure Dequeue (Device : in     Device_Id;
                      Buffer : in     Buffer_Type;
                      Read   :    out Byte_Count)
   is
      function SDL_Dequeue_Audio (Dev  : in Device_Id;
                                  Data : in Buffer_Base;
                                  Len  : in Byte_Count)
                                 return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_DequeueAudio";

      Result : constant C.int
        := SDL_Dequeue_Audio (Device, Buffer.Base, Buffer.Length);
   begin
      Read := Byte_Count (Result);
   end Dequeue;

   function Queued_Size (Device : in Device_Id)
                        return Byte_Count
   is
      function SDL_Get_Queued_Audio_Size (Dev : in Device_Id)
                                         return Unsigned_32 with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetQueuedAudioSize";
   begin
      return Byte_Count (SDL_Get_Queued_Audio_Size (Device));
   end Queued_Size;

   procedure Clear_Queued (Device : in Device_Id)
   is
      procedure SDL_Clear_Queued_Audio (Dev : in Device_Id) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_ClearQueuedAudio";
   begin
      SDL_Clear_Queued_Audio (Device);
   end Clear_Queued;

   procedure Lock is
      procedure SDL_Lock with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_LockAudio";
   begin
      SDL_Lock;
   end Lock;

   procedure Lock (Device : in Device_Id) is
      procedure SDL_Lock_Audio_Device (Dev : in Device_Id) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_LockAudioDevice";
   begin
      SDL_Lock_Audio_Device (Device);
   end Lock;

   procedure Unlock is
      procedure SDL_Unlock with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_UnlockAudio";
   begin
      SDL_Unlock;
   end Unlock;

   procedure Unlock (Device : in Device_Id) is
      procedure SDL_Unlock_Audio_Device (Dev : in Device_Id) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_UnlockAudioDevice";
   begin
      SDL_Unlock_Audio_Device (Device);
   end Unlock;

   procedure Close is
      procedure SDL_Close_Audio with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_CloseAudio";
   begin
      SDL_Close_Audio;
   end Close;

   procedure Close (Device : in Device_Id) is
      procedure SDL_Close_Audio_Device (Dev : in Device_Id) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_CloseAudioDevice";
   begin
      SDL_Close_Audio_Device (Device);
   end Close;

end SDL.Audio;
