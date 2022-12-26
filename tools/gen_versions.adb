--------------------------------------------------------------------------------------------------------------------
--  Copyright (c) 2013-2020,  Luke A. Guest
--  Copyright (c) 2022,       Jesper Quorning
--
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
--  Gen_Versions
--------------------------------------------------------------------------------------------------------------------
--  Generates the SDL.Events.Keyboards.ads file.
--  Makefile should call this and redirect the output to the correct file in $TOP/gen_src/sdl-events-keyboards.ads.
--------------------------------------------------------------------------------------------------------------------
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Command_Line;
with Interfaces;

with Utils; use Utils;

procedure Gen_Versions is

   type    t_version       is new Interfaces.Unsigned_8;
   subtype t_version_major is t_version;
   subtype t_version_minor is t_version;
   subtype t_version_patch is t_version;

   major : t_version_major with export; --convention => c, import;
   minor : t_version_minor with export; -- convention => c, import;
   patch : t_version_patch with export; -- convention => c, import;
--   pragma import (c, major);
   
   procedure get_version_root  with import;
   procedure get_version_image with import;
   procedure get_version_ttf   with import;
   
   type t_mode is (root, image, ttf);
   mode : t_mode;

   procedure Command_Line is
      use Ada.Command_Line;
   begin
      if    argument_Count /= 1    then raise constraint_error;
      elsif argument (1) = "root"  then mode := root;
      elsif argument (1) = "image" then mode := image;
      elsif argument (1) = "ttf"   then mode := ttf;
      end if;
   end Command_Line;

begin
   Command_Line;

   case mode is
      when root   =>  get_version_root;
      when image  =>  get_version_image;
      when ttf    =>  get_version_ttf;
   end case;

   put ("package ");
   case mode is
      when root   => put ("SDL.Versions.Constants");
      when image  => put ("SDL.Image.Versions.Constants");
      when ttf    => put ("SDL.TTF.Versions.Constants");
   end case;
   put (" is");
   new_line;

   put (" version : constant := (");
   put (major'image); put (",");
   put (minor'image); put (",");
   put (patch'image);
   put (")");
   new_line;

   put ("end nn;");
   new_line;

exception when others =>
     put_line ("usage: gen_versions ( root | image | ttf )");
end Gen_Versions;
