var pulse = 0.5 + 0.5 * sin(glow_t * 0.1);
var bob   = sin(glow_t * 0.07) * 3;

var col = C_TEAL;
if (item == "chip") col = C_BLUE;
if (item == "cell") col = C_ORANGE;

// floor glow so it can be spotted from a distance, and a soft shadow
draw_set_alpha(0.22 + 0.14 * pulse);
draw_set_color(col);
draw_circle(x, y + 4, 24 + pulse * 5, false);
draw_set_alpha(0.3);
draw_set_color(c_black);
draw_ellipse(x - 11, y + 12, x + 11, y + 19, false);
draw_set_alpha(1);

var py = y + bob - 4;
switch (item) {
    case "keycard":
        draw_set_color(C_INK);   draw_rectangle(x - 13, py - 9, x + 12, py + 9, false);
        draw_set_color(col);     draw_rectangle(x - 11, py - 7, x + 10, py + 7, false);
        draw_set_color(C_PAPER); draw_rectangle(x - 11, py - 7, x + 10, py - 5, false);
        draw_set_color(C_INK);   draw_rectangle(x - 8,  py - 1, x - 3,  py + 4, false);
        draw_rectangle(x + 1, py + 1, x + 8, py + 2, false);
        break;
    case "chip":
        draw_set_color(C_INK);
        for (var i = -2; i <= 2; i++) {
            draw_rectangle(x + i * 5 - 1, py - 14, x + i * 5 + 1, py - 9, false);
            draw_rectangle(x + i * 5 - 1, py + 9,  x + i * 5 + 1, py + 14, false);
        }
        draw_rectangle(x - 12, py - 11, x + 11, py + 11, false);
        draw_set_color(col);     draw_rectangle(x - 10, py - 9, x + 9, py + 9, false);
        draw_set_color(C_PAPER); draw_rectangle(x - 5,  py - 4, x + 4, py + 4, false);
        break;
    default: // cell
        draw_set_color(C_INK);   draw_rectangle(x - 8, py - 13, x + 7, py + 13, false);
        draw_rectangle(x - 4, py - 16, x + 3, py - 13, false);
        draw_set_color(col);     draw_rectangle(x - 6, py - 11, x + 5, py + 11, false);
        draw_set_color(C_PAPER); draw_rectangle(x - 6, py - 11, x - 3, py + 11, false);
        draw_set_color(C_INK);   draw_rectangle(x - 6, py - 1, x + 5, py + 1, false);
        break;
}
draw_set_color(c_white);
