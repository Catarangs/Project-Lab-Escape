var lx = lengthdir_x(8, bdir);
var ly = lengthdir_y(8, bdir);
draw_set_color(C_INK);
draw_line_width(x - lx, y - ly, x + lx, y + ly, 9);
draw_set_color(make_color_rgb(255, 214, 70));
draw_line_width(x - lx, y - ly, x + lx, y + ly, 5);
draw_set_color(c_white);
