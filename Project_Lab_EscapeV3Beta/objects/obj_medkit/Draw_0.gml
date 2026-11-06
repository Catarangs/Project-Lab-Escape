var by = y + 2 * sin(degtorad(bob));
if (ready) {
    draw_sprite_ext(spr_shadow, 0, x, y + 12, 1.5, 1.5, 0, c_white, 0.5);
    draw_set_color(C_INK);
    draw_rectangle(x - 13, by - 13, x + 13, by + 13, false);
    draw_set_color(make_color_rgb(245, 245, 250));
    draw_rectangle(x - 11, by - 11, x + 11, by + 11, false);
    draw_set_color(make_color_rgb(230, 60, 80));
    draw_rectangle(x - 3, by - 8, x + 3, by + 8, false);
    draw_rectangle(x - 8, by - 3, x + 8, by + 3, false);
    draw_set_alpha(0.25 + 0.15 * sin(degtorad(bob * 2)));
    draw_set_color(make_color_rgb(120, 255, 170));
    draw_circle(x, by, 20, true);
    draw_set_alpha(1);
} else {

    draw_set_alpha(0.3);
    draw_set_color(C_INK);
    draw_rectangle(x - 11, y - 11, x + 11, y + 11, true);
    var f = 1 - respawn_t / respawn_time;
    draw_rectangle(x - 11, y + 11 - 22 * f, x + 11, y + 11, false);
    draw_set_alpha(1);
}
draw_set_color(c_white);
