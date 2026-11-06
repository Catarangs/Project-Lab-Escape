var bw = 28;
draw_set_color(make_color_rgb(60, 20, 20));
draw_rectangle(x - bw/2, y - 30, x + bw/2, y - 26, false);
draw_set_color(make_color_rgb(255, 150, 40));
draw_rectangle(x - bw/2, y - 30, x - bw/2 + (hp/max_hp)*bw, y - 26, false);

var armed = (fuse >= 0);
var blink = armed && ((floor(fuse / 4) mod 2) == 0);
if (armed) {
    draw_set_alpha(0.25 + 0.25 * (1 - fuse / fuse_max));
    draw_set_color(make_color_rgb(255, 80, 40));
    draw_circle(x, y, 80, false);
    draw_set_alpha(0.8);
    draw_circle(x, y, 80, true);
    draw_set_alpha(1);
}
draw_humanoid(x, y, face_dir, moving, anim, set, hit_flash > 0 || blink, 1);

draw_set_color(make_color_rgb(255, 120, 40));
draw_circle(x, y - 38, 4 + (armed ? 2 : 0), false);
draw_set_color(c_white);
