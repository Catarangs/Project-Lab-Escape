var bw = 28;
draw_set_color(make_color_rgb(30, 20, 50));
draw_rectangle(x - bw/2, y - 30, x + bw/2, y - 26, false);
draw_set_color(make_color_rgb(160, 40, 220));
draw_rectangle(x - bw/2, y - 30, x - bw/2 + (hp/max_hp)*bw, y - 26, false);

draw_humanoid(x, y, face_dir, moving, anim, set, hit_flash > 0, 1);

if (aim_dir != -1 && shoot_timer < 30) {
    draw_set_alpha(0.35 + 0.35 * ((current_time mod 200) < 100));
    draw_set_color(make_color_rgb(255, 70, 60));
    draw_line_width(x, y, x + lengthdir_x(120, aim_dir), y + lengthdir_y(120, aim_dir), 3);
    draw_set_alpha(1);
}
draw_set_color(c_white);
