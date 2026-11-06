draw_set_color(C_INK);
draw_circle(x, y, brad + 2, false);
draw_set_color(global.time_scale > 0.6 ? bcol : merge_colour(bcol, c_white, 0.35));
draw_circle(x, y, brad, false);
draw_set_color(make_color_rgb(255, 245, 235));
draw_circle(x - 2, y - 2, 2, false);
draw_set_color(c_white);
