var sc = 2;

if (!alive) {
    var r = death_timer * 0.6;
    draw_sprite_ext(spr_shadow, 0, x, y + 10, sc, sc, 0, c_white, max(0, 1 - death_timer / 60));
    draw_sprite_ext(spr_player_death, min(2, floor(death_timer / 12)), x, y, sc, sc, 0, c_white, max(0, 1 - death_timer / 90));
    draw_set_alpha(max(0, 1 - death_timer / 80));
    draw_set_color(c_red);
    draw_circle(x, y, r, true);
    draw_set_color(c_white);
    draw_circle(x, y, r * 0.5, true);
    draw_set_alpha(1);
    exit;
}

if (stuck_t > 0) {
    var sr = 14 + (stuck_t mod 20);
    draw_set_alpha(0.8);
    draw_set_color(make_color_rgb(225, 190, 255));
    draw_circle(x, y + 8, sr, true);
    draw_circle(x, y + 8, sr * 0.6, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

var blink = (invincible_timer > 0 && (invincible_timer mod 8) < 4);
var a     = blink ? 0.35 : 1;
var hurt  = (invincible_timer > invincible_max - 16);
var idx;

if (hurt) {
    idx = floor(invincible_timer / 4) mod 2;
    draw_sprite_ext(spr_shadow, 0, x, y + 10, sc, sc, 0, c_white, 0.5 * a);
    draw_sprite_ext(spr_player_hurt, idx, x, y, sc, sc, 0, c_white, a);
} else {
    idx = draw_humanoid(x, y, face_dir, is_moving, anim_t, global.set_player, false, a);
}

var top = (is_moving && !hurt) ? ((idx mod 2 == 0) ? 10 : 9) : ((idx == 0) ? 9 : 10);
draw_bunny_ears(x, y, face_dir, top, a, sc);

var fa   = aim_ang;
var cxm  = x + lengthdir_x(34, fa);
var cym  = y + lengthdir_y(34, fa) + 4;
draw_set_alpha(0.85 * a);
draw_set_color(C_INK);
draw_triangle(cxm + lengthdir_x(8, fa), cym + lengthdir_y(8, fa),
              cxm + lengthdir_x(7, fa + 135), cym + lengthdir_y(7, fa + 135),
              cxm + lengthdir_x(7, fa - 135), cym + lengthdir_y(7, fa - 135), false);
draw_set_color(c_white);
draw_triangle(cxm + lengthdir_x(5, fa), cym + lengthdir_y(5, fa),
              cxm + lengthdir_x(4, fa + 135), cym + lengthdir_y(4, fa + 135),
              cxm + lengthdir_x(4, fa - 135), cym + lengthdir_y(4, fa - 135), false);
draw_set_alpha(1);
