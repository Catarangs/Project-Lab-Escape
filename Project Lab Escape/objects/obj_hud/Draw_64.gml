var gw = display_get_gui_width();
var gh = display_get_gui_height();

if (global.time_scale < 0.5) {
    var vi = (0.5 - global.time_scale) / 0.5;
    draw_set_alpha(vi * 0.35);
    draw_set_color(make_color_rgb(20, 40, 140));
    var vs = 70;
    draw_rectangle(0,       0,       gw,    vs,      false);
    draw_rectangle(0,       gh - vs, gw,    gh,      false);
    draw_rectangle(0,       0,       vs,    gh,      false);
    draw_rectangle(gw - vs, 0,       gw,    gh,      false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(100, 140, 255));
    draw_set_halign(fa_center);
    draw_text(gw/2, 12, "SLOW MOTION");
    draw_set_halign(fa_left);
}

if (flash_timer > 0) {
    draw_set_alpha((flash_timer / 22) * 0.45);
    draw_set_color(c_red);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1);
}


draw_set_color(make_color_rgb(160, 160, 160));
draw_text(18, 18, "HP");
for (var i = 0; i < global.player_max_hp; i++) {
    if (i < global.player_hp) draw_set_color(make_color_rgb(220, 50, 50));
    else                       draw_set_color(make_color_rgb(40, 40, 40));
    draw_circle(62 + i * 26, 27, 9, false);
}


draw_set_halign(fa_right);
draw_set_color(make_color_rgb(180, 200, 180));
draw_text(gw - 18, 14, "FLOOR  " + string(global.floor_num) + " / " + string(global.max_floors));
draw_text(gw - 18, 34, "WAVE   " + string(global.wave_num)  + " / " + string(global.waves_per_floor));
draw_set_color(make_color_rgb(140, 160, 140));
draw_text(gw - 18, 56, "SCORE  " + string(global.score));
draw_set_halign(fa_left);

draw_set_halign(fa_center);
if (instance_exists(obj_wave_manager)) {
    var wm = obj_wave_manager;
    if (wm.state == "countdown") {
        draw_set_color(c_yellow);
        draw_text_transformed(gw/2, 82, "WAVE " + string(wm.current_wave) + " INCOMING", 1.4, 1.4, 0);
    } else if (wm.state == "spawning" || wm.state == "waiting") {
        draw_set_color(make_color_rgb(80, 180, 100));
        draw_text(gw/2, 82, "WAVE " + string(wm.current_wave)
                  + "  —  " + string(instance_number(obj_enemy_parent)) + " enemies remaining");
    } else if (wm.state == "wave_done") {
        draw_set_color(make_color_rgb(80, 220, 100));
        draw_text_transformed(gw/2, 82, "WAVE CLEARED", 1.4, 1.4, 0);
    } else if (wm.state == "floor_done") {
        draw_set_color(make_color_rgb(60, 255, 120));
        draw_text_transformed(gw/2, 82, "FLOOR CLEARED  —  reach the EXIT DOOR", 1.2, 1.2, 0);
    }
}
draw_set_halign(fa_left);

draw_set_color(make_color_rgb(80, 100, 80));
draw_text(18, gh - 24, "Kills: " + string(global.total_kills));

if (global.floor_num == 1 && global.wave_num <= 1) {
    draw_set_color(make_color_rgb(70, 90, 70));
    draw_text(18, gh - 42, "WASD: move  |  Stop: slow-motion  |  Auto-fires at nearest enemy");
}
