var gw = display_get_gui_width();
var gh = display_get_gui_height();
ui_init();

var slow_k = clamp(1 - global.time_scale / 0.5, 0, 1);
var frozen = (global.time_scale < 0.5 && !global.is_upgrade_phase
              && instance_exists(obj_player) && obj_player.alive);

if (frozen) {
    draw_set_color(make_color_rgb(140, 190, 255));
    draw_set_alpha(0.07 * slow_k);
    draw_rectangle(0, 0, gw, gh, false);
    var edge = 44;
    for (var i = 0; i < 4; i++) {
        draw_set_alpha((0.16 - i * 0.035) * slow_k);
        draw_rectangle(0,              i * 11,        gw,              i * 11 + 11,        false);
        draw_rectangle(0,              gh - i * 11 - 11, gw,           gh - i * 11,        false);
        draw_rectangle(i * 11,         0,             i * 11 + 11,     gh,                 false);
        draw_rectangle(gw - i * 11 - 11, 0,           gw - i * 11,     gh,                 false);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

if (flash_timer > 0) {
    draw_set_alpha((flash_timer / 22) * 0.4);
    draw_set_color(c_red);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

if (heal_flash > 0) {
    draw_set_alpha((heal_flash / 20) * 0.25);
    draw_set_color(make_color_rgb(90, 255, 160));
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

var finfo = floor_info(global.floor_num);

var hp_w = max(180, 36 + global.player_max_hp * 30);
ui_panel(12, 12, hp_w, 66, 0);
for (var i = 0; i < global.player_max_hp; i++) {
    ui_heart(30 + i * 30, 30, 3, i < global.player_hp);
}

var objs  = global.objectives;
var n_obj = array_length(objs);
if (n_obj > 0 && !finfo.boss) {
    var ox = 12;
    var oy = 88;
    var ow = 310;
    var oh = 56 + n_obj * 30;
    ui_panel(ox, oy, ow, oh, 0);
    ui_text(ox + 26, oy + 16, "OBJECTIVES", F_TINY, C_GREY, 1, fa_left, 1);
    for (var i = 0; i < n_obj; i++) {
        var o    = objs[i];
        var ry   = oy + 40 + i * 30;
        var done = (o.done >= o.goal);
        draw_set_color(C_INK);   draw_rectangle(ox + 26, ry + 2, ox + 43, ry + 19, false);
        draw_set_color(C_PAPER); draw_rectangle(ox + 28, ry + 4, ox + 41, ry + 17, false);
        draw_set_color(c_white);
        if (done) draw_sprite(spr_ui_check, 0, ox + 26, ry + 3);
        var txt;
        if (o.kind == "survive") txt = o.label + "  " + string(max(0, ceil((o.goal - o.done) / 60))) + "s";
        else                     txt = o.label + "  " + string(min(o.done, o.goal)) + " / " + string(o.goal);
        ui_text(ox + 54, ry, txt, F_BODY, done ? C_TEAL : C_INK, 1, fa_left, 1);
    }
}

var pw = 244;
ui_panel(gw - pw - 12, 12, pw, 108, 0);
var rx = gw - 12 - 22;
ui_text(rx, 26, "FLOOR " + string(global.floor_num) + " / " + string(global.max_floors), F_BODY, C_INK, 1, fa_right, 1);
ui_text(rx, 50, finfo.name, F_TINY, C_GREY, 1, fa_right, 1);
ui_text(rx, 68, finfo.boss ? "BOSS FIGHT" : "FIND THE WAY OUT", F_TINY, finfo.boss ? C_RED : C_BLUE, 1, fa_right, 1);
ui_text(rx, 86, "SCORE " + string(global.score), F_TINY, C_INK, 1, fa_right, 1);

var msg = "";
var msg_col = C_INK;
var nodes_left = -1;
var nodes_total = 0;
if (instance_exists(obj_wave_manager)) {
    var wm = obj_wave_manager;
    switch (wm.state) {
        case "briefing":   msg = "FLOOR " + string(global.floor_num) + ": " + finfo.name; break;
        case "mission":    msg = "COMPLETE THE OBJECTIVES"; break;
        case "complete":   msg = "OBJECTIVES COMPLETE"; msg_col = C_TEAL; break;
        case "boss_intro":
            msg = "WARNING: MECHA APPROACHING";
            msg_col = ((current_time mod 500) < 280) ? C_RED : make_color_rgb(150, 50, 50);
            break;
        case "boss_fight":
            if (instance_exists(obj_boss) && obj_boss.state == "down") { msg = "MECHA POWERED DOWN"; msg_col = C_BLUE; }
            else {
                msg = "CUT THE POWER LINES";
                nodes_left  = instance_number(obj_power_node);
                nodes_total = instance_exists(obj_boss) ? obj_boss.nodes_total : nodes_left;
            }
            break;
        case "floor_done": msg = "FLOOR CLEARED. REACH THE EXIT"; msg_col = C_TEAL; break;
    }
}
if (msg != "") {
    var mw = max(280, ui_text_w(msg, F_BODY, 1) + 72);
    var bx = gw / 2 - mw / 2;
    ui_nine(spr_ui_banner, 0, bx, 14, mw, 44, 6, 2, c_white, 1);
    ui_text(gw / 2, 24, msg, F_BODY, msg_col, 1, fa_center, 1);
    if (nodes_left >= 0) {
        for (var i = 0; i < nodes_total; i++) {
            var dx = gw / 2 - (nodes_total - 1) * 14 + i * 28;
            draw_set_color(C_INK);
            draw_circle(dx, 78, 9, false);
            draw_set_color(i < nodes_left ? C_ORANGE : C_MIST);
            draw_circle(dx, 78, 7, false);
        }
        draw_set_color(c_white);
    }
}

ui_text(18, gh - 30, "KILLS " + string(global.total_kills), F_TINY, C_INK, 1, fa_left, 1);
ui_text(18, gh - 52, "WEAPON  " + aug_label() + "   AUTO-FIRE " + (global.auto_fire ? "ON" : "OFF") + " [Q]", F_TINY, C_INK, 1, fa_left, 1);
ui_text(18, gh - 74, "AUGMENTS  " + string(array_length(aug_owned_list())) + "   [TAB] LIST", F_TINY, C_INK, 1, fa_left, 1);
if (keyboard_check(vk_tab)) aug_draw_list(gw, gh);

if (frozen) {
    ui_text_shadow(gw / 2, gh - 58, "TIME SLOWED  -  KEEP MOVING TO SPEED IT UP", F_TINY, c_white, C_BLUE, 2, fa_center, 1);
}

if (instance_exists(obj_player) && obj_player.alive && obj_player.stuck_t > 0) {
    ui_text_shadow(gw / 2, gh - 58, "HELD IN STASIS", F_TINY, c_white, make_color_rgb(110, 60, 190), 2, fa_center, 1);
}

if (global.floor_num == 1 && tip_t > 0) {
    var tip_w = 560;
    ui_panel(gw / 2 - tip_w / 2, gh - 168, tip_w, 92, 0);
    ui_text(gw / 2, gh - 154, "WASD or arrows: move freely, mouse: aim", F_BODY, C_INK, 1, fa_center, 1);
    ui_text(gw / 2, gh - 132, "You fire automatically while moving. Click to shoot while still. Q toggles auto-fire.", F_TINY, C_INK, 1, fa_center, 1);
    ui_text(gw / 2, gh - 106, "Time slows down when you stop moving. Finish the objectives to open the exit.", F_TINY, C_BLUE, 1, fa_center, 1);
}

if (global.door_open && instance_exists(obj_exit_door) && instance_exists(obj_player)) {
    var cam = view_camera[0];
    var k   = gw / camera_get_view_width(cam);
    var ddir = point_direction(obj_player.x, obj_player.y, obj_exit_door.x, obj_exit_door.y);
    if (point_distance(obj_player.x, obj_player.y, obj_exit_door.x, obj_exit_door.y) > 110) {
        var ax = (obj_player.x - camera_get_view_x(cam)) * k + lengthdir_x(62, ddir);
        var ay = (obj_player.y - camera_get_view_y(cam)) * k + lengthdir_y(62, ddir);
        draw_set_alpha(0.7 + 0.3 * sin(current_time / 150));
        draw_set_color(C_INK);
        draw_triangle(ax + lengthdir_x(16, ddir), ay + lengthdir_y(16, ddir),
                      ax + lengthdir_x(11, ddir + 140), ay + lengthdir_y(11, ddir + 140),
                      ax + lengthdir_x(11, ddir - 140), ay + lengthdir_y(11, ddir - 140), false);
        draw_set_color(C_TEAL);
        draw_triangle(ax + lengthdir_x(12, ddir), ay + lengthdir_y(12, ddir),
                      ax + lengthdir_x(8, ddir + 140), ay + lengthdir_y(8, ddir + 140),
                      ax + lengthdir_x(8, ddir - 140), ay + lengthdir_y(8, ddir - 140), false);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}

if (instance_exists(obj_player) && !global.door_open) {
    var near_pick = instance_nearest(obj_player.x, obj_player.y, obj_pickup);
    if (near_pick != noone) draw_pointer(near_pick.x, near_pick.y);
    var near_gen = instance_nearest(obj_player.x, obj_player.y, obj_generator);
    if (near_gen != noone) draw_pointer(near_gen.x, near_gen.y);
}

if (!global.is_upgrade_phase && instance_exists(obj_player) && obj_player.alive) {
    var cmx = device_mouse_x_to_gui(0);
    var cmy = device_mouse_y_to_gui(0);
    draw_set_alpha(0.9);
    draw_set_color(C_INK);
    draw_circle(cmx, cmy, 13, true);
    draw_circle(cmx, cmy, 12, true);
    draw_set_color(c_white);
    draw_circle(cmx, cmy, 11, true);
    draw_line(cmx - 20, cmy, cmx - 6, cmy);
    draw_line(cmx + 6, cmy, cmx + 20, cmy);
    draw_line(cmx, cmy - 20, cmx, cmy - 6);
    draw_line(cmx, cmy + 6, cmx, cmy + 20);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

dev_draw(gw, gh);

if (show_coords) {
    var mxw = mouse_x;
    var myw = mouse_y;
    var gx  = device_mouse_x_to_gui(0);
    var gy  = device_mouse_y_to_gui(0);
    var lbl = "x " + string(floor(mxw / TILE) * TILE + TILE / 2) + "  y " + string(floor(myw / TILE) * TILE + TILE / 2)
            + "   tile " + string(px_to_cell(mxw)) + ", " + string(px_to_cell(myw));
    ui_text_shadow(gx + 16, gy + 16, lbl, F_TINY, c_white, C_INK, 2, fa_left, 1);
}
