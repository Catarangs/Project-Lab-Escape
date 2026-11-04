var bw = 28;
draw_set_color(make_color_rgb(60, 50, 10));
draw_rectangle(x - bw/2, y - 30, x + bw/2, y - 26, false);
draw_set_color(make_color_rgb(250, 200, 40));
draw_rectangle(x - bw/2, y - 30, x - bw/2 + (hp/max_hp)*bw, y - 26, false);

// warning lane while it winds up
if (mode == "windup") {
    draw_set_alpha(0.3 + 0.35 * ((current_time mod 160) < 80));
    draw_set_color(make_color_rgb(255, 210, 50));
    draw_line_width(x, y, x + lengthdir_x(warn_len, dash_dir), y + lengthdir_y(warn_len, dash_dir), 6);
    draw_set_alpha(1);
}
var shake = (mode == "windup") ? irandom_range(-1, 1) : 0;
var flash = (hit_flash > 0) || (mode == "windup" && (mode_t mod 8) < 3);
draw_humanoid(x + shake, y, face_dir, (mode == "stalk" || mode == "dash"), anim, set, flash, (mode == "recover") ? 0.7 : 1);
if (mode == "recover") {
    draw_set_color(C_INK);
    draw_text(x - 8, y - 46, "...");
}
draw_set_color(c_white);
