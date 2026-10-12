if (!alive) {
    var r = death_timer * 0.6;
    draw_set_alpha(max(0, 1 - death_timer / 80));
    draw_set_color(c_red);
    draw_circle(x, y, r, true);
    draw_set_color(c_white);
    draw_circle(x, y, r * 0.5, true);
    draw_set_alpha(1);
    exit;
}

if (invincible_timer > 0 && (invincible_timer mod 8) < 4) {
    draw_set_alpha(0.25);
}

draw_set_color(make_color_rgb(240, 240, 240));
draw_circle(x, y, 13, false);

var ex = lengthdir_x(16, angle_face);
var ey = lengthdir_y(16, angle_face);
var sx = lengthdir_x(7, angle_face + 90);
var sy = lengthdir_y(7, angle_face + 90);
draw_circle(x + ex + sx, y + ey + sy, 5, false);
draw_circle(x + ex - sx, y + ey - sy, 5, false);

draw_set_color(make_color_rgb(220, 50, 50));
var fx = lengthdir_x(9, angle_face);
var fy = lengthdir_y(9, angle_face);
var ox = lengthdir_x(4, angle_face + 90);
var oy = lengthdir_y(4, angle_face + 90);
draw_circle(x + fx + ox, y + fy + oy, 3, false);
draw_circle(x + fx - ox, y + fy - oy, 3, false);

draw_set_alpha(1);