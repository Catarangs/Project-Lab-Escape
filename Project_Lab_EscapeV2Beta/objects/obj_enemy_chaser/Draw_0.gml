var bw = 28;
draw_set_color(make_color_rgb(60, 20, 20));
draw_rectangle(x - bw/2, y - 30, x + bw/2, y - 26, false);
draw_set_color(make_color_rgb(220, 50, 50));
draw_rectangle(x - bw/2, y - 30, x - bw/2 + (hp/max_hp)*bw, y - 26, false);

draw_humanoid(x, y, face_dir, true, anim, set, hit_flash > 0, 1);
draw_set_color(c_white);
