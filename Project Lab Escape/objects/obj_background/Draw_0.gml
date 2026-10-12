draw_set_color(make_color_rgb(10, 16, 20));
draw_rectangle(0, 0, room_width, room_height, false);

draw_set_color(make_color_rgb(18, 28, 34));
var gs = 64;
for (var gx = gs; gx < room_width;  gx += gs) draw_line(gx, 0, gx, room_height);
for (var gy = gs; gy < room_height; gy += gs) draw_line(0, gy, room_width, gy);

var w = 36;
draw_set_color(make_color_rgb(22, 36, 42));
draw_rectangle(0,                  0,                   room_width, w,                  false);
draw_rectangle(0,                  room_height - w,     room_width, room_height,        false);
draw_rectangle(0,                  0,                   w,          room_height,        false);
draw_rectangle(room_width - w,     0,                   room_width, room_height,        false);

draw_set_color(make_color_rgb(40, 68, 80));
draw_rectangle(w - 1, w - 1, room_width - w + 1, room_height - w + 1, true);
