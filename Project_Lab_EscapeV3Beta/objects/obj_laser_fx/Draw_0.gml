var f = life / life_max;
for (var i = 0; i < array_length(segs); i++) {
    var s = segs[i];
    draw_set_alpha(0.55 * f);
    draw_set_color(make_color_rgb(60, 220, 255));
    draw_line_width(s[0], s[1], s[2], s[3], s[4] * 2.2);
    draw_set_alpha(0.95 * f);
    draw_set_color(make_color_rgb(190, 250, 255));
    draw_line_width(s[0], s[1], s[2], s[3], s[4]);
    draw_set_color(c_white);
    draw_line_width(s[0], s[1], s[2], s[3], max(2, s[4] * 0.4));
}
draw_set_alpha(1);
draw_set_color(c_white);
