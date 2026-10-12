var gw = display_get_gui_width();
var gh = display_get_gui_height();

draw_set_color(make_color_rgb(4, 12, 6));
draw_rectangle(0, 0, gw, gh, false);
draw_set_halign(fa_center);

draw_set_color(make_color_rgb(40, 220, 90));
draw_text_transformed(gw/2, gh * 0.22, "ESCAPED!", 3.5, 3.5, 0);

draw_set_color(make_color_rgb(160, 240, 180));
draw_text(gw/2, gh * 0.42, "The experiment is free. The lab burns behind you.");

draw_set_color(make_color_rgb(120, 180, 130));
draw_text(gw/2, gh * 0.54, "Floors cleared :  " + string(global.max_floors));
draw_text(gw/2, gh * 0.61, "Enemies eliminated :  " + string(global.total_kills));
draw_text(gw/2, gh * 0.68, "Final score :  " + string(global.score));

if ((current_time mod 1000) < 580) {
    draw_set_color(c_yellow);
    draw_text_transformed(gw/2, gh * 0.83, "PRESS SPACE TO PLAY AGAIN", 1.25, 1.25, 0);
}
draw_set_halign(fa_left);