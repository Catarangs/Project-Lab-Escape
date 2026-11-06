mode       = "floor";
picks_left = 2;
selected   = -1;
depth      = -1000;
aug_build();
choices    = aug_offer();

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
card_w    = 252;
card_h    = 300;
gap       = 24;
total_w   = card_w * 3 + gap * 2;
start_x   = (gui_w - total_w) / 2;
card_y    = (gui_h - card_h) / 2 + 20;
reroll_x  = gui_w / 2 - 110;
reroll_y  = card_y + card_h + 56;
reroll_w  = 220;
reroll_h  = 40;

finish = function() {
    global.is_upgrade_phase = false;
    if (mode != "floor") {
        instance_destroy();
        return;
    }
    global.door_open = false;
    if (global.floor_num >= global.max_floors) {
        room_goto(room_win);
        return;
    }
    global.floor_num++;
    global.wave_num = 0;
    room_goto(floor_room(global.floor_num));
};

do_reroll = function() {
    if (global.rerolls <= 0 || selected != -1) return;
    global.rerolls--;
    choices = aug_offer();
};

do_select = function(idx) {
    if (selected != -1 || idx >= array_length(choices)) return;
    aug_apply(choices[idx]);
    global.aug_round++;
    picks_left--;
    if (picks_left > 0) {
        choices = aug_offer();
        return;
    }
    selected = idx;
    finish();
};
