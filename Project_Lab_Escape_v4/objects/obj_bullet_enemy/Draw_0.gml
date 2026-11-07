var spr_b = bolt_sprite(bcol);
var fr = floor(current_time / 70 + real(id)) mod sprite_get_number(spr_b);
var tint = (global.time_scale > 0.6) ? c_white : make_color_rgb(190, 215, 255);
var s_k = clamp(brad / 8, 0.7, 1.4) * 0.85;
draw_sprite_ext(spr_b, fr, x, y, s_k, s_k, bdir, tint, 1);
