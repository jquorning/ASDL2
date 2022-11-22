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
--  SDL.Audio
--------------------------------------------------------------------------------------------------------------------

with Interfaces;
with System;

with SDL.RWops;

package SDL.Audio is

   use Interfaces;

   ------------------
   --  Audio_Spec  --
   ------------------

   type Audio_Format is
      record
         Bits       : Unsigned_8;
         Float      : Boolean;
         X_Zero_1   : Boolean := False;
         X_Zero_2   : Boolean := False;
         X_Zero_3   : Boolean := False;
         Big_Endian : Boolean;
         X_Zero_4   : Boolean := False;
         X_Zero_5   : Boolean := False;
         Signed     : Boolean;
      end record with Size => 16, Convention => C_Pass_By_Copy;

   for Audio_Format use
      record
         Bits       at 0 range 0 .. 7;
         Float      at 0 range 8 .. 8;
         X_Zero_1   at 0 range 9 .. 9;
         X_Zero_2   at 0 range 10 .. 10;
         X_Zero_3   at 0 range 11 .. 11;
         Big_Endian at 0 range 12 .. 12;
         X_Zero_4   at 0 range 13 .. 13;
         X_Zero_5   at 0 range 14 .. 14;
         Signed     at 0 range 15 .. 15;
      end record;

   Audio_U8      : constant Audio_Format := (Bits =>  8, Signed => False, others => False);
   Audio_S8      : constant Audio_Format := (Bits =>  8, Signed =>  True, others => False);
   Audio_U16_LSB : constant Audio_Format := (Bits => 16, Signed => False, others => False);
   Audio_S16_LSB : constant Audio_Format := (Bits => 16, Signed =>  True, others => False);
   Audio_U16_MSB : constant Audio_Format := (Bits => 16, Signed => False, Big_Endian => True, others => False);
   Audio_S16_MSB : constant Audio_Format := (Bits => 16, Signed =>  True, Big_Endian => True, others => False);
   Audio_U16     : constant Audio_Format := Audio_U16_LSB;
   Audio_S16     : constant Audio_Format := Audio_S16_LSB;

   Audio_S32_LSB : constant Audio_Format := (Bits => 32, Signed => True, others => False);
   Audio_S32_MSB : constant Audio_Format := (Bits => 32, Signed => True, Big_Endian => True, others => False);
   Audio_S32     : constant Audio_Format := Audio_S32_LSB;

   Audio_F32_LSB : constant Audio_Format := (Bits => 32, Float => True, others => False);
   Audio_F32_MSB : constant Audio_Format := (Bits => 32, Float => True, Big_Endian => True, others => False);
   Audio_F32     : constant Audio_Format := Audio_F32_LSB;

   Sys_Is_Big_Endian : constant Boolean := System."=" (System.Default_Bit_Order, System.High_Order_First);
   Audio_U16_Sys : constant Audio_Format := (Bits => 16, Signed => False, Big_Endian => Sys_Is_Big_Endian,
                                             others => False);
   Audio_S16_Sys : constant Audio_Format := (Bits => 16, Signed =>  True, Big_Endian => Sys_Is_Big_Endian,
                                             others => False);
   Audio_U32_Sys : constant Audio_Format := (Bits => 32, Signed => False, Big_Endian => Sys_Is_Big_Endian,
                                             others => False);
   Audio_S32_Sys : constant Audio_Format := (Bits => 32, Signed =>  True, Big_Endian => Sys_Is_Big_Endian,
                                             others => False);

   ---------------------------------
   --  SDL_AUDIO_ALLOW_... flags  --
   ---------------------------------
   --  Map the C int for allowed changes onto a proper (record) type.
   type Allowed_Changes_Flags is
      record
         Allow_Frequency_Change : Boolean;
         Allow_Format_Change    : Boolean;
         Allow_Channels_Change  : Boolean;
         Allow_Samples_Change   : Boolean;
      end record
     with
       Bit_Order => System.Low_Order_First, --  force LE bit counts
       Size      => Interfaces.C.int'Size;
   --  The explicit bit order should be safe also on Big Endian machines,
   --  albeit on those the compiler may give some diagnostics.
   for Allowed_Changes_Flags use
      record
         Allow_Frequency_Change at 0 range 0 .. 0; -- 16#0000_0001#
         Allow_Format_Change    at 0 range 1 .. 1; -- 16#0000_0002#
         Allow_Channels_Change  at 0 range 2 .. 2; -- 16#0000_0004#
         Allow_Samples_Change   at 0 range 3 .. 3; -- 16#0000_0008#
      end record;

   Allow_No_Change  : constant Allowed_Changes_Flags :=
     Allowed_Changes_Flags'(others => False);
   Allow_Any_Change : constant Allowed_Changes_Flags :=
     Allowed_Changes_Flags'(others => True);

   type Byte_Count  is new Unsigned_32;
   type Buffer_Base is new System.Address;

   --  Define a convenience constant for when we don't pass userdata through the
   --  callbacks.
   No_User_Data : constant System.Address := System.Null_Address;

   package Internal is
      --  This callback should never be directly used by the user of the
      --  library.  Instead, an instance of SDL.Audio.Callbacks should be
      --  created.
      type Callback_Access is
        access procedure  (Userdata  : in System.Address;
                           Audio_Buf : in Buffer_Base;
                           Audio_Len : in Interfaces.C.int)
        with Convention => C;
   end Internal;

   type Sample_Rate   is new Integer_32;
   type Channel_Count is new Unsigned_8;

   type Audio_Spec is
      record
         Frequency : Sample_Rate;     -- 4
         Format    : Audio_Format;    -- 2
         Channels  : Channel_Count;   -- 1
         Silence   : Unsigned_8;      -- 1
         Samples   : Unsigned_16;     -- 2
         Padding   : Unsigned_16;     -- 2
         Size      : Unsigned_32;     -- 4
         Callback  : Internal.Callback_Access; -- 8
         Userdata  : System.Address;  -- 8
      end record
     with Convention => C;
   --  Size => 8 * 32; --  This is correct only for 64 bit machines.

   type Buffer_Type is private;
   Null_Buffer : constant Buffer_Type;
   function Length (Buffer : in Buffer_Type) return Byte_Count;
   function Base (Buffer : in Buffer_Type) return Buffer_Base;

   type Device_Id is new Unsigned_32;

   Audio_Error : exception;

   function Get_Number_Of_Drivers return Natural;
   function Get_Driver_Name (Index : in Positive) return String;

   procedure Initialize (Driver : in String);
   procedure Quit;

   function Current_Driver return String;

   procedure Open (Desired  : in     Audio_Spec;
                   Obtained :    out Audio_Spec);
   pragma Obsolescent (Entity  => Open,
                       Message => "Consider using Open (Device => ...) instead.");
   procedure Open (Required : in out Audio_Spec);
   pragma Obsolescent (Entity  => Open,
                       Message => "Consider using Open (Device => ...) instead.");

   function Get_Number_Of_Devices (Is_Capture : in Boolean) return Natural;
   function Get_Device_Name (Index      : in Positive;
                             Is_Capture : in Boolean) return String;

   procedure Open (Device          :    out Device_Id;
                   Device_Name     : in     String;
                   Is_Capture      : in     Boolean;
                   Desired         : in     Audio_Spec;
                   Obtained        :    out Audio_Spec;
                   Allowed_Changes : in     Allowed_Changes_Flags);

   type Status_Type is (Stopped, Playing, Paused);
   function Status return Status_Type;
   pragma Obsolescent (Entity  => Status,
                       Message => "Consider using Status (Device => ...) instead.");
   function Status (Device : in Device_Id)
                   return Status_Type;

   procedure Pause (Pause_On : in Boolean);
   pragma Obsolescent (Entity  => Pause,
                       Message => "Consider using Pause (Device => ...) instead.");
   procedure Pause (Device   : in Device_Id;
                    Pause_On : in Boolean);

   ----------------
   --  Load_WAV  --
   ----------------

   procedure Load_WAV_RW (Source   : in out SDL.RWops.RWops;
                          Free_Src : in     Boolean;
                          Spec     :    out Audio_Spec;
                          Buffer   :    out Buffer_Type);
   procedure Load_WAV (Filename : in     String;
                       Spec     :    out Audio_Spec;
                       Buffer   :    out Buffer_Type);
   procedure Free_WAV (Buffer : in out Buffer_Type);

   -----------
   --  Mix  --
   -----------

   subtype Audio_Volume is Integer range 0 .. 128;

   procedure Mix (Target : in Buffer_Type;
                  Source : in Buffer_Type;
                  Volume : in Audio_Volume);
   pragma Obsolescent (Entity  => Mix,
                       Message => "Consider using Mix_Format (...) instead.");

   procedure Mix_Format (Target : in Buffer_Type;
                         Source : in Buffer_Type;
                         Format : in Audio_Format;
                         Volume : in Audio_Volume);

   ----------------
   --  Queueing  --
   ----------------

   procedure Queue (Device : in Device_Id;
                    Buffer : in Buffer_Type);

   procedure Dequeue (Device : in     Device_Id;
                      Buffer : in     Buffer_Type;
                      Read   :    out Byte_Count);

   function Queued_Size (Device : in Device_Id)
                        return Byte_Count;

   procedure Clear_Queued (Device : in Device_Id);

   ---------------
   --  Locking  --
   ---------------

   procedure Lock;
   pragma Obsolescent (Entity  => Lock,
                       Message => "Consider using Lock (Device => ...) instead.");
   procedure Lock (Device : in Device_Id);

   procedure Unlock;
   pragma Obsolescent (Entity  => Unlock,
                       Message => "Consider using Unlock (Device => ...) instead.");
   procedure Unlock (Device : in Device_Id);

   ---------------
   --  Close  --
   ---------------

   procedure Close;
   pragma Obsolescent (Entity  => Close,
                       Message => "Consider using Close (Device => ...) instead.");
   procedure Close (Device : in Device_Id);

private

   type Buffer_Type is
      record
         Base   : Buffer_Base;
         Length : Byte_Count;
      end record;

   Null_Buffer : constant Buffer_Type := (Base   => Buffer_Base (System.Null_Address),
                                          Length => 0);

   function Length (Buffer : in Buffer_Type) return Byte_Count
   is (Buffer.Length);

   function Base (Buffer : in Buffer_Type) return Buffer_Base
   is (Buffer.Base);

end SDL.Audio;
