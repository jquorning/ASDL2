--
--
--

--  Usage:
---------
--  loop
--    Block;
--    Get (Event);
--    case Evnet.Kind is
--       ...
--    end case;
--  end loop;

package SDL.Events.Streams is

   type Event_Kind is (None, Root, Keyboard, Joystick, Mouse);

   type    Base_Event     is null record;
   subtype Root_Event     is Base_Event;
   subtype Keyboard_Event is Base_Event;
   subtype Joystick_Event is Base_Event;
   subtype Mouse_Event    is Base_Event;

   type Event_Type is record
      Kind     : Event_Kind;
      Root     : Root_Event;
      Keyboard : Keyboard_Event;
      Joystick : Joystick_Event;
      Mouse    : Mouse_Event;
   end record;

   type Endpoint_Type is null record;
--   type Endpoint_Type is interface;

   procedure Block (Endpoint : in out Endpoint_Type) is null;
   --  Block until event available.

   procedure Get (Endpoint : in out Endpoint_Type;
                  Event    :    out Event_Type) is null;

   function Get (Endpoint : in out Endpoint_Type)
      return Event_Type is (Kind => None, others => <>);
   --  Get event. Event.Kind may be None.

end SDL.Events.Streams;
