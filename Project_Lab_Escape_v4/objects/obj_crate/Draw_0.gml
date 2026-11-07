if (hit_flash > 0) hit_flash--;
draw_sprite_ext(spr_shadow, 0, x, y + 12, 2, 2, 0, c_white, 0.5);
if (hit_flash > 0) gpu_set_fog(true, c_white, 0, 1);
draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_white, 1);
if (hit_flash > 0) gpu_set_fog(false, c_white, 0, 1);
draw_set_color(c_white);
