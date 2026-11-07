draw_sprite_ext(spr_shadow, 0, x, y + 14, 2, 2, 0, c_white, 0.5);
var hot = (charge_t > 0);
var fl  = (hit_flash > 0);

for (var d = 0; d < 4; d++) {
    var a = rot + d * 90;
    var bx = x + lengthdir_x(20, a);
    var by = y + lengthdir_y(20, a);
    draw_set_color(C_INK);
    draw_circle(bx, by, 9, false);
    draw_set_color(hot ? make_color_rgb(255, 170, 50) : make_color_rgb(110, 115, 135));
    draw_circle(bx, by, 6, false);
    if (hot) {
        draw_set_alpha(0.3 + 0.3 * ((current_time mod 140) < 70));
        draw_set_color(make_color_rgb(255, 170, 50));
        draw_line_width(x, y, x + lengthdir_x(110, a), y + lengthdir_y(110, a), 3);
        draw_set_alpha(1);
    }
}

draw_set_color(C_INK);
draw_rectangle(x - 17, y - 17, x + 17, y + 17, false);
draw_set_color(fl ? c_white : make_color_rgb(88, 94, 118));
draw_rectangle(x - 14, y - 14, x + 14, y + 14, false);
draw_set_color(fl ? c_white : make_color_rgb(60, 64, 84));
draw_rectangle(x - 14, y + 6, x + 14, y + 14, false);

draw_set_color(C_INK);
draw_circle(x, y, 9, false);
draw_set_color(hot ? make_color_rgb(255, 120, 50) : make_color_rgb(120, 230, 255));
draw_circle(x, y, 6, false);
draw_set_color(c_white);
draw_circle(x + lengthdir_x(3, spin), y + lengthdir_y(3, spin), 2, false);

if (laser_t > 0) {
    draw_set_alpha(0.35 + 0.3 * ((current_time mod 160) < 80));
    draw_set_color(make_color_rgb(255, 70, 60));
    for (var l = 24; l < laser_len; l += 32) {
        draw_line_width(x + lengthdir_x(l, laser_dir), y + lengthdir_y(l, laser_dir),
                        x + lengthdir_x(l + 16, laser_dir), y + lengthdir_y(l + 16, laser_dir), 3);
    }
    draw_set_alpha(1);
}
if (laser_live > 0) {
    draw_set_alpha(0.85);
    draw_set_color(make_color_rgb(255, 60, 60));
    draw_line_width(x, y, x + lengthdir_x(laser_len, laser_dir), y + lengthdir_y(laser_len, laser_dir), TILE);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(255, 240, 225));
    draw_line_width(x, y, x + lengthdir_x(laser_len, laser_dir), y + lengthdir_y(laser_len, laser_dir), TILE * 0.4);
}
draw_set_alpha(1);

var bw = 28;
draw_set_color(make_color_rgb(50, 30, 10));
draw_rectangle(x - bw/2, y - 32, x + bw/2, y - 28, false);
draw_set_color(make_color_rgb(255, 170, 50));
draw_rectangle(x - bw/2, y - 32, x - bw/2 + (hp/max_hp)*bw, y - 28, false);
draw_set_color(c_white);
