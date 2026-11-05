// =============================================================================
//  obj_cheat_menu - Create
//  Press ~ (or F1) in-game to open. The game is paused while the menu is open.
//  Spawned by obj_game_manager, so it only exists in room_game.
// =============================================================================
depth = -2000;          // draw above everything, including the upgrade screen

sel       = 0;          // highlighted row
message   = "";         // feedback line shown at the bottom of the panel
msg_timer = 0;          // frames left to show the message
last_mx   = 0;          // previous mouse position (hover only moves the highlight
last_my   = 0;          //  when the mouse actually moves, so W/S still work)

// ---------------------------------------------------------------------------
//  THE CHEAT LIST - to add a cheat, add one more { ... } entry below.
//    label : name shown in the menu
//    desc  : one-line explanation
//    get   : returns true/false to show ON/OFF for a toggle, or undefined for
//            a one-shot action (shown as [ RUN ])
//    run   : performs the cheat and returns a message to show the player
// ---------------------------------------------------------------------------
items = [
    {
        label : "God Mode",
        desc  : "Take no damage from enemies or bullets",
        get   : function() { return global.god_mode; },
        run   : function() {
            global.god_mode = !global.god_mode;
            return global.god_mode ? "God Mode ON" : "God Mode OFF";
        }
    },
    {
        label : "Complete Current Wave",
        desc  : "Instantly clears the wave in progress",
        get   : undefined,
        run   : function() {
            if (!instance_exists(obj_wave_manager)) return "No wave manager found";
            if (obj_wave_manager.complete_wave()) return "Wave completed";
            return "No wave in progress";
        }
    }
];

// ---- panel layout (GUI coordinates) ----
gui_w   = display_get_gui_width();
gui_h   = display_get_gui_height();
row_h   = 56;
panel_w = 540;
panel_h = 100 + array_length(items) * row_h + 70;
panel_x = (gui_w - panel_w) / 2;
panel_y = (gui_h - panel_h) / 2;
row_x   = panel_x + 20;
row_w   = panel_w - 40;
row_y0  = panel_y + 90;
