var pulse = 0.7 + sin(glow_t * 0.08) * 0.3;

draw_set_alpha(pulse * 0.25);
draw_set_color(make_color_rgb(30, 255, 100));
draw_circle(x, y, 48, false);
draw_set_alpha(1);

draw_set_color(make_color_rgb(0, 200, 80));
draw_set_alpha(pulse);
draw_rectangle(x - 22, y - 34, x + 22, y + 34, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(0, 255, 100));
draw_rectangle(x - 22, y - 34, x + 22, y + 34, true);

draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, y - 6, "EXIT");
draw_text(x, y + 10, "^");
draw_set_halign(fa_left);
draw_set_valign(fa_top);
