var gw = display_get_gui_width();
var gh = display_get_gui_height();
ui_init();

for (var cx = 0; cx < gw / TILE; cx++) {
    for (var cy = 0; cy < gh / TILE; cy++) {
        draw_sprite_ext(spr_floor, 1, cx * TILE, cy * TILE, 1, 1, 0, make_color_rgb(200, 255, 225), 1);
    }
}

var pw = 560;
var ph = 440;
var px = (gw - pw) / 2;
var py = (gh - ph) / 2;
ui_panel(px, py, pw, ph, 1);
ui_text_shadow(gw / 2, py + 34, "ESCAPED", F_TITLE, c_white, C_INK, 2, fa_center, 1);
ui_text(gw / 2, py + 140, "Mecha down, doors open. The rabbit is free.", F_BODY, c_white, 1, fa_center, 1);

var rows = [["FLOORS CLEARED", string(global.max_floors)], ["ENEMIES DOWN", string(global.total_kills)], ["FINAL SCORE", string(global.score)]];
for (var i = 0; i < 3; i++) {
    var ry = py + 202 + i * 44;
    ui_text(px + 64, ry, rows[i][0], F_TINY, c_white, 2, fa_left, 1);
    ui_text(px + pw - 64, ry - 4, rows[i][1], F_BODY, c_white, 2, fa_right, 1);
    draw_set_color(c_white);
    draw_set_alpha(0.4);
    draw_rectangle(px + 64, ry + 30, px + pw - 64, ry + 31, false);
    draw_set_alpha(1);
}
ui_menu_button(gw / 2 - 150, py + ph - 100, 300, 56, "PLAY AGAIN", true);
draw_set_color(c_white);
