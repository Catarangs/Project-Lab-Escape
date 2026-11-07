var pulse = 0.5 + 0.5 * sin(current_time / 140 + x);

draw_set_color(make_color_rgb(34, 28, 44));
draw_rectangle(x - 20, y - 20, x + 20, y + 20, false);
draw_set_color(make_color_rgb(255, 190, 50));
draw_rectangle(x - 20, y - 20, x + 20, y + 20, true);
draw_rectangle(x - 18, y - 18, x + 18, y + 18, true);

var col = (hit_flash > 0) ? c_white : merge_colour(make_color_rgb(255, 120, 30), make_color_rgb(255, 235, 130), pulse);
draw_set_color(col);
draw_circle(x, y, 9 + pulse * 3, false);
draw_set_alpha(0.25);
draw_circle(x, y, 17 + pulse * 3, false);
draw_set_alpha(1);

var sr    = 34;
var arc   = 360 - gap_w;
var start = gap_ang + gap_w / 2;
var steps = 36;
var shield_col = (block_flash > 0) ? c_white : make_color_rgb(90, 190, 255);
for (var i = 0; i < steps; i++) {
    var a1 = start + arc * i / steps;
    var a2 = start + arc * (i + 1) / steps;
    draw_set_color(C_INK);
    draw_line_width(x + lengthdir_x(sr, a1), y + lengthdir_y(sr, a1), x + lengthdir_x(sr, a2), y + lengthdir_y(sr, a2), 9);
    draw_set_color(shield_col);
    draw_line_width(x + lengthdir_x(sr, a1), y + lengthdir_y(sr, a1), x + lengthdir_x(sr, a2), y + lengthdir_y(sr, a2), 5);
}
var ga = gap_ang;
draw_set_color(make_color_rgb(255, 235, 130));
draw_set_alpha(0.5 + 0.4 * pulse);
draw_circle(x + lengthdir_x(sr, ga), y + lengthdir_y(sr, ga), 5, false);
draw_set_alpha(1);

var bw = 36;
draw_set_color(make_color_rgb(50, 30, 20));
draw_rectangle(x - bw/2, y - 50, x + bw/2, y - 45, false);
draw_set_color(make_color_rgb(255, 200, 60));
draw_rectangle(x - bw/2, y - 50, x - bw/2 + (hp / max_hp) * bw, y - 45, false);
draw_set_color(c_white);
