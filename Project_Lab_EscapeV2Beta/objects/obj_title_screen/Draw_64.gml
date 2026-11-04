var gw = display_get_gui_width();
var gh = display_get_gui_height();
ui_init();

// lab room backdrop: tiled floor with a wall strip along the top
for (var cx = 0; cx < gw / TILE; cx++) {
    for (var cy = 0; cy < gh / TILE; cy++) {
        if (cy < 2) draw_sprite(spr_wall, 3, cx * TILE, cy * TILE);
        else        draw_sprite_ext(spr_floor, 1, cx * TILE, cy * TILE, 1, 1, 0, ((cx + cy) mod 2 == 0) ? c_white : make_color_rgb(228, 228, 236), 1);
    }
}
draw_set_alpha(0.5);
draw_set_color(C_INK);
draw_rectangle(0, 96, gw, 100, false);
draw_set_alpha(1);

// containment cell with the rabbit
var cell_x = 56;
var cell_y = 150;
var cell_w = 340;
var cell_h = 440;
ui_panel(cell_x, cell_y, cell_w, cell_h, 1);
for (var cx = 0; cx < 6; cx++) {
    for (var cy = 0; cy < 8; cy++) {
        draw_sprite_ext(spr_floor, 0, cell_x + 28 + cx * 48 / 1.0 * 1, cell_y + 28 + cy * 48, 1, 1, 0, ((cx + cy) mod 2 == 0) ? make_color_rgb(235, 240, 255) : make_color_rgb(205, 218, 245), 0.55);
    }
}
var rx = cell_x + cell_w / 2;
var ry = cell_y + cell_h / 2 + 20;
var ta = current_time / 260;
draw_sprite_ext(spr_shadow, 0, rx, ry + 36, 7, 7, 0, c_white, 0.5);
draw_sprite_ext(spr_player_idle_d, floor(ta) mod 2, rx, ry, 7, 7, 0, c_white, 1);
draw_bunny_ears(rx, ry, 2, (floor(ta) mod 2 == 0) ? 9 : 10, 1, 7);
ui_text(cell_x + cell_w / 2, cell_y + cell_h - 36, "SUBJECT 07", F_TINY, C_INK, 2, fa_center, 1);

if (show_help) {
    var hx = 440;
    ui_panel(hx, 140, 470, 530, 0);
    ui_text(hx + 32, 168, "CONTROLS", F_TITLE, C_INK, 1, fa_left, 1);
    var rows = [
        ["WASD / ARROWS", "Step one tile"],
        ["SPACE / J", "Shoot the way you face"],
        ["LEFT CLICK", "Shoot toward the mouse"],
        ["", ""],
        ["Bullets only fly up, down, left or right.", ""],
        ["Time only moves when you step or shoot.", ""],
        ["", ""],
        ["Finish each floor's objectives to open the exit.", ""],
        ["Cut the mecha's power lines to shut it down.", ""],
        ["Blue force fields block your way.", ""],
        ["Green sludge slows your steps.", ""],
        ["Purple pads hold you in place.", ""],
        ["Red laser gates switch on and off.", ""]
    ];
    var yy = 220;
    for (var i = 0; i < array_length(rows); i++) {
        if (rows[i][1] != "") {
            ui_text(hx + 32, yy, rows[i][0], F_TINY, C_BLUE, 2, fa_left, 1);
            ui_text(hx + 32, yy + 24, rows[i][1], F_BODY, C_INK, 1, fa_left, 1);
            yy += 50;
        } else if (rows[i][0] != "") {
            ui_text(hx + 32, yy, rows[i][0], F_BODY, C_INK, 1, fa_left, 1);
            yy += 28;
        } else yy += 12;
    }
    ui_text(hx + 235, 640, "Press any key to go back", F_TINY, C_GREY, 1, fa_center, 1);
} else {
    // title block
    ui_nine(spr_ui_banner, 1, 462, 126, 190, 44, 6, 2, c_white, 1);
    ui_text(557, 138, "PROJECT", F_TINY, C_INK, 2, fa_center, 1);
    ui_text_shadow(466, 174, "LAB", F_TITLE, c_white, C_INK, 2, fa_left, 1);
    ui_text_shadow(466, 258, "ESCAPE", F_TITLE, C_ORANGE, C_INK, 2, fa_left, 1);

    for (var i = 0; i < array_length(menu_items); i++) {
        ui_menu_button(btn_x, btn_y + i * btn_gap, btn_w, btn_h, menu_items[i], i == menu_sel);
    }
}

ui_text(gw - 16, gh - 22, "UI Crusenho (CC BY 4.0)   Characters Snoblin   Tiles LandOfPixels   Fonts Pixelify Sans, Silkscreen (OFL)", F_TINY, C_INK, 1, fa_right, 1);
