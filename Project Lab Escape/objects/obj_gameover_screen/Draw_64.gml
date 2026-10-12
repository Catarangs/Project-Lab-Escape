var gw = display_get_gui_width();
var gh = display_get_gui_height();

draw_set_color(make_color_rgb(10, 4, 4));
draw_rectangle(0, 0, gw, gh, false);
draw_set_halign(fa_center);

draw_set_color(make_color_rgb(200, 40, 40));
draw_text_transformed(gw/2, gh * 0.24, "EXPERIMENT TERMINATED", 2.0, 2.0, 0);

draw_set_color(make_color_rgb(160, 120, 120));
draw_text(gw/2, gh * 0.40, "The rabbit could not escape...");

var fl = variable_global_exists("floor_num") ? global.floor_num : 1;
draw_set_color(make_color_rgb(140, 140, 140));
draw_text(gw/2, gh * 0.52, "Floor reached :  " + string(fl));
draw_text(gw/2, gh * 0.59, "Enemies eliminated :  " + string(global.total_kills));
draw_text(gw/2, gh * 0.66, "Final score :  " + string(global.score));

if ((current_time mod 1000) < 580) {
    draw_set_color(make_color_rgb(180,180,180));
    draw_text_transformed(gw/2, gh * 0.82, "PRESS SPACE TO TRY AGAIN", 1.2, 1.2, 0);
}
draw_set_halign(fa_left);
