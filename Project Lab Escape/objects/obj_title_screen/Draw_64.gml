var gw = display_get_gui_width();
var gh = display_get_gui_height();

draw_set_color(make_color_rgb(6, 10, 14));
draw_rectangle(0, 0, gw, gh, false);

draw_set_halign(fa_center);
draw_set_color(make_color_rgb(40, 210, 100));
draw_text_transformed(gw/2, gh * 0.22, "PROJECT", 3.2, 3.2, 0);
draw_set_color(make_color_rgb(200, 240, 210));
draw_text_transformed(gw/2, gh * 0.34, "LAB ESCAPE", 3.2, 3.2, 0);

var rx = gw / 2;
var ry = gh * 0.53;
draw_set_color(make_color_rgb(230, 230, 230));
draw_circle(rx, ry, 26, false);
draw_circle(rx - 12, ry - 32, 10, false);
draw_circle(rx + 12, ry - 32, 10, false);
draw_set_color(make_color_rgb(200, 60, 60));
draw_circle(rx - 7, ry - 6, 5, false);
draw_circle(rx + 7, ry - 6, 5, false);

draw_set_color(make_color_rgb(100, 140, 110));
draw_text(gw/2, gh * 0.67, "WASD  — move        Stop moving  — slow time");
draw_text(gw/2, gh * 0.73, "Auto-fire targets nearest enemy while you move");
draw_text(gw/2, gh * 0.79, "Clear waves, collect upgrades, escape the facility");

if ((current_time mod 1000) < 580) {
    draw_set_color(c_yellow);
    draw_text_transformed(gw/2, gh * 0.89, "PRESS SPACE TO START", 1.3, 1.3, 0);
}
draw_set_halign(fa_left);