var gw = display_get_gui_width();
var gh = display_get_gui_height();
ui_init();

draw_set_alpha(0.26);
draw_set_color(make_color_rgb(10, 16, 32));
draw_rectangle(0, 0, gw, gh, false);
draw_set_alpha(1);
draw_set_color(c_white);

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

var msg = "";
var msg_col = C_INK;
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
                msg = (instance_exists(obj_boss) && obj_boss.stun_t > 0) ? "STUNNED! SHOOT THE MECHA!" : "SHOOT A GENERATOR NEXT TO THE MECHA";
            }
            break;
        case "floor_done": msg = "EXIT OPEN ON THE " + edge_name(global.exit_cx, global.exit_cy) + " EDGE"; msg_col = C_TEAL; break;
    }
}
var wmx = instance_exists(obj_wave_manager) ? obj_wave_manager : noone;
var in_brief = (wmx != noone && (wmx.state == "briefing" || wmx.state == "boss_intro"));
var obj_sum = 0;
for (var oi = 0; oi < array_length(global.objectives); oi++) obj_sum += min(global.objectives[oi].done, global.objectives[oi].goal) * ((global.objectives[oi].kind == "survive") ? 0 : 1);
if (obj_sum != obj_prev) { obj_prev = obj_sum; obj_flash = 240; }
if (msg != last_msg) { last_msg = msg; top_flash = 200; }
if (obj_flash > 0) obj_flash--;
if (top_flash > 0) top_flash--;
var melt_low = (wmx != noone && wmx.has_threat && wmx.state == "mission" && wmx.threat_t <= 600);
var surge_on = (wmx != noone && wmx.surge_t > 0);
var want_l = pin_l || in_brief || keyboard_check(ord("I"));
var want_r = pin_r;
var want_t = pin_t || in_brief || melt_low || surge_on;
if (global.is_upgrade_phase) { want_l = false; want_r = false; want_t = false; }
kl = lerp(kl, want_l ? 1 : 0, 0.18);
kr = lerp(kr, want_r ? 1 : 0, 0.18);
kt = lerp(kt, want_t ? 1 : 0, 0.18);
if (abs(kl - (want_l ? 1 : 0)) < 0.01) kl = want_l ? 1 : 0;
if (abs(kr - (want_r ? 1 : 0)) < 0.01) kr = want_r ? 1 : 0;
if (abs(kt - (want_t ? 1 : 0)) < 0.01) kt = want_t ? 1 : 0;

fs_draw(gw, gh, false);

if (kl > 0) {
    matrix_set(matrix_world, matrix_build(-380 * (1 - kl), 0, 0, 0, 0, 0, 1, 1, 1));
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

    if (wmx != noone) {
        var wm2 = wmx;
        var hint = floor_hint(global.floor_num);
        if (hint != "") {
            var hy = (n_obj > 0 && !finfo.boss) ? 88 + 56 + n_obj * 30 + 10 : 88;
            var hw = 330;
            var hl = ui_wrap_lines(hint, F_BODY, 1, hw - 44);
            var hh = 52 + array_length(hl) * 24;
            ui_panel(12, hy, hw, hh, 0);
            ui_text(38, hy + 16, "HOW IT WORKS", F_TINY, C_BLUE, 1, fa_left, 1);
            ui_text_wrapped(38, hy + 42, hint, F_BODY, C_INK, 1, hw - 44, fa_left, 1);
        }
    }
ui_text(18, gh - 30, "KILLS " + string(global.total_kills), F_TINY, C_INK, 1, fa_left, 1);
ui_text(18, gh - 52, "WEAPON  " + aug_label() + "   AUTO-FIRE " + (global.auto_fire ? "ON" : "OFF") + " [Q]", F_TINY, C_INK, 1, fa_left, 1);
ui_text(18, gh - 74, "AUGMENTS  " + string(array_length(aug_owned_list())) + "   [TAB] LIST   [I] HELP", F_TINY, C_INK, 1, fa_left, 1);
    matrix_set(matrix_world, matrix_build_identity());
}

if (kr > 0) {
    matrix_set(matrix_world, matrix_build(280 * (1 - kr), 0, 0, 0, 0, 0, 1, 1, 1));
var pw = 244;
ui_panel(gw - pw - 12, 12, pw, 108, 0);
var rx = gw - 12 - 22;
ui_text(rx, 26, "FLOOR " + string(global.floor_num) + " / " + string(global.max_floors), F_BODY, C_INK, 1, fa_right, 1);
ui_text(rx, 50, finfo.name, F_TINY, C_GREY, 1, fa_right, 1);
ui_text(rx, 68, finfo.boss ? "BOSS FIGHT" : "FIND THE WAY OUT", F_TINY, finfo.boss ? C_RED : C_BLUE, 1, fa_right, 1);
ui_text(rx, 86, "SCORE " + string(global.score), F_TINY, C_INK, 1, fa_right, 1);

    matrix_set(matrix_world, matrix_build_identity());
}

if (kt > 0) {
    matrix_set(matrix_world, matrix_build(0, -170 * (1 - kt), 0, 0, 0, 0, 1, 1, 1));
if (msg != "") {
    var mw = max(280, ui_text_w(msg, F_BODY, 1) + 72);
    var bx = gw / 2 - mw / 2;
    ui_nine(spr_ui_banner, 0, bx, 14, mw, 44, 6, 2, C_DIM, 1);
    ui_text(gw / 2, 24, msg, F_BODY, msg_col, 1, fa_center, 1);
}

    if (wmx != noone) {
        var wm2 = wmx;
    if (wm2.has_threat && wm2.state == "mission") {
        var secs  = max(0, ceil(wm2.threat_t / 60));
        var low   = (secs <= 10);
        var mtxt  = "REACTOR MELTDOWN IN " + string(secs div 60) + ":" + (secs mod 60 < 10 ? "0" : "") + string(secs mod 60);
        var mcol  = (low && ((current_time mod 400) < 220)) ? C_RED : C_INK;
        var mpw   = 440;
        var mpx   = gw / 2 - mpw / 2;
        ui_panel(mpx, 66, mpw, 74, 0);
        ui_text(gw / 2, 78, mtxt, F_BODY, mcol, 1, fa_center, 1);
        var melt_k = clamp(wm2.threat_t / wm2.threat.time, 0, 1);
        draw_set_color(C_INK);
        draw_rectangle(mpx + 26, 104, mpx + mpw - 26, 116, false);
        draw_set_color(low ? C_RED : C_ORANGE);
        draw_rectangle(mpx + 28, 106, mpx + 28 + (mpw - 56) * melt_k, 114, false);
        draw_set_color(c_white);
        ui_text(gw / 2, 120, "Grab coolant cells: +15s.  At 0 = surge!", F_TINY, C_INK, 1, fa_center, 1);
    }
    }
    matrix_set(matrix_world, matrix_build_identity());
}

if (instance_exists(obj_boss) && (obj_boss.state == "fight" || obj_boss.state == "down") && !global.is_upgrade_phase) {
    var bo   = obj_boss;
    var bbw  = 520;
    var bbx  = gw / 2 - bbw / 2;
    var bby  = gh - 124;
    var bfr  = clamp(bo.hp / bo.max_hp, 0, 1);
    var stn  = (bo.stun_t > 0);
    var gen_ready = 0;
    with (obj_overload) { if (state == "ready") gen_ready++; }
    var gen_all = instance_number(obj_overload);
    var blbl = floor_info(global.floor_num).name + (stn ? "   STUNNED - DOUBLE DAMAGE" : "   ARMORED - SHOTS DO LITTLE");
    ui_text(gw / 2, bby - 30, blbl, F_BODY, stn ? C_ORANGE : c_white, 1, fa_center, 1);
    draw_set_color(C_INK);
    draw_rectangle(bbx - 4, bby - 4, bbx + bbw + 4, bby + 22, false);
    draw_set_color(make_color_rgb(70, 40, 44));
    draw_rectangle(bbx, bby, bbx + bbw, bby + 18, false);
    draw_set_color(stn ? make_color_rgb(255, 200, 60) : make_color_rgb(220, 70, 70));
    draw_rectangle(bbx, bby, bbx + bbw * bfr, bby + 18, false);
    if (stn) {
        draw_set_alpha(0.4 + 0.3 * sin(current_time / 90));
        draw_set_color(c_white);
        draw_rectangle(bbx, bby, bbx + bbw * bfr, bby + 18, false);
        draw_set_alpha(1);
    }
    draw_set_color(c_white);
    ui_text(gw / 2, bby + 30, "GENERATORS READY  " + string(gen_ready) + " / " + string(gen_all), F_BODY, C_MIST, 1, fa_center, 1);
}

hud_tab(0, gw, gh, kl);
hud_tab(1, gw, gh, kr);
hud_tab(2, gw, gh, kt);

if (wmx != noone) {
    var wm2 = wmx;
    if (wm2.surge_t > 0) {
        var sa = clamp(wm2.surge_t / 40, 0, 1);
        ui_text_shadow(gw / 2, gh / 2 - 120, "REACTOR SURGE!", F_TITLE, c_white, C_RED, 1, fa_center, sa);
        ui_text_shadow(gw / 2, gh / 2 - 70, "-1 HP  -  HUNTERS INCOMING", F_BODY, c_white, C_RED, 1, fa_center, sa);
    }
}

if (keyboard_check(vk_tab)) aug_draw_list(gw, gh);

if (frozen) {
    ui_text_shadow(gw / 2, gh - 58, "TIME SLOWED  -  KEEP MOVING TO SPEED IT UP", F_TINY, c_white, C_BLUE, 2, fa_center, 1);
}

if (instance_exists(obj_player) && obj_player.alive && obj_player.stuck_t > 0) {
    ui_text_shadow(gw / 2, gh - 58, "HELD IN STASIS", F_TINY, c_white, make_color_rgb(110, 60, 190), 2, fa_center, 1);
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
