var pulse = 0.5 + 0.5 * sin(current_time / 140 + x);

// socket plate
draw_set_color(make_color_rgb(34, 28, 44));
draw_rectangle(x - 20, y - 20, x + 20, y + 20, false);
draw_set_color(make_color_rgb(255, 190, 50));
draw_rectangle(x - 20, y - 20, x + 20, y + 20, true);
draw_rectangle(x - 18, y - 18, x + 18, y + 18, true);

// glowing core (flashes white when hit)
var col = (hit_flash > 0) ? c_white : merge_colour(make_color_rgb(255, 120, 30), make_color_rgb(255, 235, 130), pulse);
draw_set_color(col);
draw_circle(x, y, 9 + pulse * 3, false);
draw_set_alpha(0.25);
draw_circle(x, y, 17 + pulse * 3, false);
draw_set_alpha(1);

// health bar
var bw = 36;
draw_set_color(make_color_rgb(50, 30, 20));
draw_rectangle(x - bw/2, y - 32, x + bw/2, y - 27, false);
draw_set_color(make_color_rgb(255, 200, 60));
draw_rectangle(x - bw/2, y - 32, x - bw/2 + (hp / max_hp) * bw, y - 27, false);
draw_set_color(c_white);
