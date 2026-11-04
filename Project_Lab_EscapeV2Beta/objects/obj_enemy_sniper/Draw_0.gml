var bw = 28;
draw_set_color(make_color_rgb(10, 50, 30));
draw_rectangle(x - bw/2, y - 30, x + bw/2, y - 26, false);
draw_set_color(make_color_rgb(70, 220, 110));
draw_rectangle(x - bw/2, y - 30, x - bw/2 + (hp/max_hp)*bw, y - 26, false);

// the locked lane: thin while charging, flashing just before it fires
if (mode == "charge") {
    var hot = (mode_t < 22);
    draw_set_alpha(hot ? (0.5 + 0.4 * ((current_time mod 120) < 60)) : 0.35);
    draw_set_color(hot ? make_color_rgb(255, 80, 60) : make_color_rgb(120, 255, 150));
    draw_line_width(x, y, x + lengthdir_x(laser_len, aim_dir), y + lengthdir_y(laser_len, aim_dir), hot ? 4 : 2);
    draw_set_alpha(1);
}
draw_humanoid(x, y, face_dir, (mode == "seek"), anim, set, hit_flash > 0, 1);
draw_set_color(c_white);
