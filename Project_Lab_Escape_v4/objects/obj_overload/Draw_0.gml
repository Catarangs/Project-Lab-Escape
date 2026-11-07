var pulse = 0.5 + 0.5 * sin(glow_t * 0.12);
var ready = (state == "ready");
var armed = (state == "armed");

if (ready || armed) {
    draw_set_alpha(0.10 + 0.07 * pulse + (armed ? 0.2 : 0));
    draw_set_color(armed ? make_color_rgb(255, 90, 70) : make_color_rgb(90, 200, 255));
    draw_circle(x, y, blast_r, false);
    draw_set_alpha(0.35 + 0.3 * pulse);
    draw_circle(x, y, blast_r, true);
    draw_set_alpha(1);
}

draw_set_color(C_INK);
draw_rectangle(x - 26, y - 20, x + 26, y + 26, false);
draw_set_color(make_color_rgb(98, 110, 134));
draw_rectangle(x - 24, y - 18, x + 24, y + 24, false);
draw_set_color(make_color_rgb(140, 154, 180));
draw_rectangle(x - 24, y - 18, x + 24, y - 12, false);
draw_set_color(ready ? C_ORANGE : make_color_rgb(70, 74, 90));
for (var i = 0; i < 5; i++) draw_rectangle(x - 20 + i * 9, y + 14, x - 15 + i * 9, y + 20, false);

if (ready || armed) {
    var col = armed ? ((current_time mod 120) < 60 ? c_white : make_color_rgb(255, 90, 70)) : merge_colour(C_BLUE, make_color_rgb(150, 230, 255), pulse);
    draw_sprite_ext(spr_fx_charge, floor(glow_t * 0.2) mod sprite_get_number(spr_fx_charge), x, y - 4, 0.9, 0.9, 0, col, 1);
} else {
    draw_set_color(make_color_rgb(40, 44, 58));
    draw_circle(x, y - 3, 10, false);
    var k = 1 - cool_t / cool_max;
    draw_set_color(C_INK);
    draw_rectangle(x - 22, y - 34, x + 22, y - 28, false);
    draw_set_color(C_BLUE);
    draw_rectangle(x - 21, y - 33, x - 21 + 42 * k, y - 29, false);
}
draw_set_color(c_white);
