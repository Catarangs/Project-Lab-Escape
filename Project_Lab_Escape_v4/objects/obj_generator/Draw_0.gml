var pulse = 0.5 + 0.5 * sin(glow_t * 0.09);

draw_set_color(C_INK);
draw_rectangle(x - 22, y - 24, x + 22, y + 22, false);
draw_set_color(make_color_rgb(104, 116, 140));
draw_rectangle(x - 20, y - 22, x + 20, y + 20, false);
draw_set_color(make_color_rgb(150, 164, 188));
draw_rectangle(x - 20, y - 22, x + 20, y - 18, false);

draw_set_color(C_ORANGE);
for (var i = 0; i < 5; i++) draw_rectangle(x - 18 + i * 8, y + 13, x - 14 + i * 8, y + 18, false);

var core = (hit_flash > 0) ? c_white : merge_colour(C_BLUE, make_color_rgb(150, 220, 255), pulse);
draw_set_color(C_INK);  draw_circle(x, y - 3, 12, false);
draw_set_color(core);   draw_circle(x, y - 3, 9 + pulse * 2, false);
draw_set_alpha(0.2);    draw_circle(x, y - 3, 20 + pulse * 4, false);
draw_set_alpha(1);

var bw = 40;
draw_set_color(C_INK);
draw_rectangle(x - bw/2 - 1, y - 36, x + bw/2 + 1, y - 29, false);
draw_set_color(C_MIST);
draw_rectangle(x - bw/2, y - 35, x + bw/2, y - 30, false);
draw_set_color(C_ORANGE);
draw_rectangle(x - bw/2, y - 35, x - bw/2 + (hp / max_hp) * bw, y - 30, false);
draw_set_color(c_white);
