choices  = pick_upgrades();
selected = -1;
depth    = -1000;

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
card_w    = 252;
card_h    = 300;
gap       = 24;
total_w   = card_w * 3 + gap * 2;
start_x   = (gui_w - total_w) / 2;
card_y    = (gui_h - card_h) / 2 + 20;

do_select = function(idx) {
    if (selected != -1) return;
    selected = idx;
    apply_upgrade(choices[idx]);
    global.is_upgrade_phase = false;
    global.door_open        = false;

    if (global.floor_num >= global.max_floors) {
        room_goto(room_win);
        return;
    }

    global.floor_num++;
    global.wave_num = 0;
    room_goto(floor_room(global.floor_num));      // each floor is its own room
};