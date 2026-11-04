// a short dash along the flight line, so the cardinal direction reads at a glance
var horizontal = (bdir == 0 || bdir == 180);
var hw = horizontal ? 10 : 4;
var hh = horizontal ? 4 : 10;
draw_set_color(C_INK);
draw_rectangle(x - hw - 2, y - hh - 2, x + hw + 1, y + hh + 1, false);
draw_set_color(make_color_rgb(255, 214, 70));
draw_rectangle(x - hw, y - hh, x + hw - 1, y + hh - 1, false);
draw_set_color(c_white);
