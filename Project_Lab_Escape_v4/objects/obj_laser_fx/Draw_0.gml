var f = life / life_max;
var frm = floor((life_max - life) * 0.8) mod sprite_get_number(spr_fx_spark);
for (var i = 0; i < array_length(segs); i++) {
    var s  = segs[i];
    var a  = point_direction(s[0], s[1], s[2], s[3]);
    var seg_len = point_distance(s[0], s[1], s[2], s[3]);
    var wk = max(1, s[4] / 10);
    draw_set_alpha(0.4 * f);
    draw_set_color(make_color_rgb(60, 180, 255));
    draw_line_width(s[0], s[1], s[2], s[3], s[4] * 1.6);
    draw_set_alpha(0.95 * f);
    draw_set_color(make_color_rgb(200, 250, 255));
    draw_line_width(s[0], s[1], s[2], s[3], max(2, s[4] * 0.45));
    draw_set_alpha(1);
    for (var d = 48; d <= seg_len + 40; d += 48) {
        var dd = min(d, seg_len);
        draw_sprite_ext(spr_fx_spark, (frm + d div 48) mod sprite_get_number(spr_fx_spark),
                        s[0] + lengthdir_x(dd, a), s[1] + lengthdir_y(dd, a), 0.8, 0.8 * wk, a, c_white, f);
    }
}
draw_set_alpha(1);
draw_set_color(c_white);
