// =============================================================================
//  obj_cheat_menu - Draw GUI
// =============================================================================
if (!global.cheat_open) exit;

var n = array_length(items);

// dim the paused game
draw_set_alpha(0.72);
draw_set_color(make_color_rgb(4, 6, 10));
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(1);

// panel
draw_set_color(make_color_rgb(14, 22, 18));
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
draw_set_color(make_color_rgb(60, 200, 100));
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);

// title
draw_set_halign(fa_center);
draw_set_color(make_color_rgb(80, 220, 120));
draw_text_transformed(panel_x + panel_w / 2, panel_y + 18, "CHEAT MENU", 1.8, 1.8, 0);
draw_set_color(make_color_rgb(120, 150, 130));
draw_text(panel_x + panel_w / 2, panel_y + 58, "Game paused");

// rows
for (var i = 0; i < n; i++) {
    var item = items[i];
    var ry   = row_y0 + i * row_h;
    var isel = (i == sel);

    draw_set_color(isel ? make_color_rgb(24, 52, 36) : make_color_rgb(18, 30, 24));
    draw_rectangle(row_x, ry, row_x + row_w, ry + row_h - 8, false);
    draw_set_color(isel ? make_color_rgb(60, 200, 100) : make_color_rgb(34, 70, 48));
    draw_rectangle(row_x, ry, row_x + row_w, ry + row_h - 8, true);

    draw_set_halign(fa_left);
    draw_set_color(isel ? make_color_rgb(220, 250, 228) : make_color_rgb(180, 210, 188));
    draw_text(row_x + 16, ry + 6, item.label);
    draw_set_color(make_color_rgb(110, 140, 120));
    draw_text(row_x + 16, ry + 26, item.desc);

    draw_set_halign(fa_right);
    if (is_undefined(item.get)) {
        draw_set_color(make_color_rgb(255, 210, 60));
        draw_text(row_x + row_w - 16, ry + 15, "[ RUN ]");
    } else if (item.get()) {
        draw_set_color(make_color_rgb(80, 230, 120));
        draw_text(row_x + row_w - 16, ry + 15, "ON");
    } else {
        draw_set_color(make_color_rgb(150, 150, 150));
        draw_text(row_x + row_w - 16, ry + 15, "OFF");
    }
}

// feedback message + controls hint
draw_set_halign(fa_center);
if (msg_timer > 0) {
    draw_set_color(make_color_rgb(255, 210, 60));
    draw_text(panel_x + panel_w / 2, panel_y + panel_h - 52, message);
}
draw_set_color(make_color_rgb(110, 140, 120));
draw_text(panel_x + panel_w / 2, panel_y + panel_h - 28, "W/S or Up/Down + Enter, or click   |   ~ / F1 / Esc to close");

// restore draw state for other objects
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
