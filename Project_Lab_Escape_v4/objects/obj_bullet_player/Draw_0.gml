var fr = floor(current_time / 60 + real(id)) mod sprite_get_number(spr_fx_pulse);
draw_sprite_ext(spr_fx_pulse, fr, x, y, 0.8, 0.8, bdir, c_white, 1);
