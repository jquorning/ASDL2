with SDL.Inputs.Joysticks.Makers;
with SDL.Inputs.Joysticks.Game_Controllers;

separate (Test)
procedure Test_Joysticks is
--      declare
         Total_Sticks : constant SDL.Inputs.Joysticks.All_Devices := SDL.Inputs.Joysticks.Total;
         Stick        : SDL.Inputs.Joysticks.Joystick;
         GUID_1       : SDL.Inputs.Joysticks.GUIDs;
         GUID_2       : SDL.Inputs.Joysticks.GUIDs;

         use type SDL.Inputs.Joysticks.Devices;
         use type SDL.Inputs.Joysticks.Joystick;
         use type SDL.Inputs.Joysticks.GUIDs;
      begin
         if Total_Sticks = 0 then
            SDL.Log.Put_Debug ("No Joysticks    : ");
         else
            SDL.Log.Put_Debug ("Joystick polling: " & Boolean'Image (SDL.Events.Joysticks.Is_Polling_Enabled));
            SDL.Log.Put_Debug ("Total Joysticks : " & SDL.Inputs.Joysticks.Devices'Image (Total_Sticks));

            for Joystick in SDL.Inputs.Joysticks.Devices'First .. Total_Sticks loop
               GUID_1 := SDL.Inputs.Joysticks.GUID (Joystick);
               GUID_2 := SDL.Inputs.Joysticks.Value (SDL.Inputs.Joysticks.Image (GUID_1));

               if GUID_1 = GUID_2 then
                  SDL.Log.Put_Debug ("GUID Image<->Value works");
               end if;

               SDL.Log.Put_Debug ("Joystick              : (" & SDL.Inputs.Joysticks.Devices'Image (Joystick) & ") - " &
                                    SDL.Inputs.Joysticks.Name (Joystick) & " - " &
                                    Integer'Image (SDL.Inputs.Joysticks.GUIDs'Size) & " - GUID: " & ' ' &
                                    SDL.Inputs.Joysticks.Image (GUID_1));

               SDL.Inputs.Joysticks.Makers.Create (Device => Joystick, Actual_Stick => Stick);

               if Stick /= SDL.Inputs.Joysticks.Null_Joystick then
                  SDL.Log.Put_Debug ("  Name               : " & Stick.Name);
                  SDL.Log.Put_Debug ("  Axes               : " & SDL.Events.Joysticks.Axes'Image (Stick.Axes));
                  SDL.Log.Put_Debug ("  Balls              : " & SDL.Events.Joysticks.Balls'Image (Stick.Balls));
                  SDL.Log.Put_Debug ("  Buttons            : " & SDL.Events.Joysticks.Buttons'Image (Stick.Buttons));
                  SDL.Log.Put_Debug ("  Hats               : " & SDL.Events.Joysticks.Hats'Image (Stick.Hats));
                  SDL.Log.Put_Debug ("  Haptic             : " & Boolean'Image (Stick.Is_Haptic));
                  SDL.Log.Put_Debug ("  Attached           : " & Boolean'Image (Stick.Is_Attached));
                  SDL.Log.Put_Debug ("  GUID               : " & SDL.Inputs.Joysticks.Image (Stick.GUID));
                  SDL.Log.Put_Debug ("  Instance           : " & SDL.Inputs.Joysticks.Instances'Image (Stick.Instance));

                  Stick.Close;
               end if;

               if SDL.Inputs.Joysticks.Game_Controllers.Is_Game_Controller (Joystick) = True then
                  SDL.Log.Put_Debug ("  Is game controller : Yes");
               else
                  SDL.Log.Put_Debug ("  Is game controller : No");
               end if;
            end loop;
         end if;
      end;
