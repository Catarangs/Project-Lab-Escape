choices  = pick_upgrades();
selected = -1;
depth    = -1000;

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
card_w    = 210;
card_h    = 270;
gap       = 28;
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
    with (obj_enemy_parent)  instance_destroy();
    with (obj_bullet_player) instance_destroy();
    with (obj_bullet_enemy)  instance_destroy();
    with (obj_exit_door)     instance_destroy();
    with (obj_wave_manager)  instance_destroy();

    if (instance_exists(obj_player)) {
        obj_player.x = room_width  / 2;
        obj_player.y = room_height / 2;
        obj_player.move_dir_x = 0;
        obj_player.move_dir_y = 0;
    }

    instance_create_layer(0, 0, "Instances", obj_wave_manager);
    instance_destroy();
};