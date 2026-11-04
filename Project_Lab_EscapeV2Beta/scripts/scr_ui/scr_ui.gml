// ---- UI toolkit: pixel fonts baked into sprites, 9-slice panels, buttons ----
// Fonts are sprites (one frame per ASCII character from 32 to 126) so the pixels stay
// crisp at any whole-number scale. To swap a font, regenerate its spr_font_* sprite.
#macro F_BODY  0
#macro F_TITLE 1
#macro F_TINY  2

// lab palette
#macro C_INK    make_color_rgb(30, 38, 58)
#macro C_PAPER  make_color_rgb(232, 240, 246)
#macro C_MIST   make_color_rgb(196, 212, 226)
#macro C_GREY   make_color_rgb(120, 134, 152)
#macro C_TEAL   make_color_rgb(38, 176, 132)
#macro C_ORANGE make_color_rgb(255, 150, 40)
#macro C_RED    make_color_rgb(222, 70, 70)
#macro C_BLUE   make_color_rgb(60, 120, 220)

function ui_init() {
    if (variable_global_exists("ui_fonts")) return;
    gpu_set_texfilter(false);
    global.ui_fonts = [
        { spr: spr_font_body, h: 22, adv: [4, 5, 9, 12, 10, 15, 12, 5, 7, 7, 5, 11, 5, 7, 5, 10, 10, 8, 10, 10, 10, 10, 10, 10, 10, 10, 5, 5, 11, 11, 11, 10, 11, 10, 10, 10, 10, 10, 10, 10, 10, 8, 10, 10, 10, 13, 10, 10, 10, 10, 10, 10, 10, 10, 10, 13, 10, 10, 10, 7, 10, 7, 5, 8, 5, 12, 10, 10, 10, 10, 10, 10, 10, 5, 9, 10, 5, 13, 10, 10, 10, 10, 10, 10, 12, 10, 10, 13, 10, 10, 10, 9, 5, 9, 11] },
        { spr: spr_font_title, h: 41, adv: [8, 9, 17, 24, 21, 30, 24, 11, 14, 14, 11, 21, 11, 13, 9, 19, 21, 15, 21, 21, 21, 21, 21, 21, 21, 21, 9, 11, 21, 21, 21, 21, 22, 21, 21, 21, 21, 21, 21, 21, 21, 15, 21, 21, 21, 27, 21, 21, 21, 21, 21, 21, 21, 21, 21, 27, 21, 21, 21, 14, 19, 14, 11, 16, 11, 24, 21, 21, 21, 21, 21, 21, 21, 9, 18, 21, 9, 27, 21, 21, 21, 21, 21, 21, 24, 21, 21, 27, 21, 21, 21, 17, 9, 17, 21] },
        { spr: spr_font_tiny, h: 13, adv: [5, 4, 6, 8, 7, 8, 7, 4, 5, 5, 8, 8, 5, 6, 4, 6, 7, 6, 7, 7, 7, 7, 7, 7, 7, 7, 4, 5, 6, 6, 6, 7, 8, 7, 7, 7, 7, 6, 6, 7, 7, 4, 7, 7, 6, 8, 8, 7, 7, 7, 7, 7, 6, 7, 8, 8, 8, 8, 6, 5, 6, 5, 6, 7, 5, 7, 7, 7, 7, 6, 6, 7, 7, 4, 7, 7, 6, 8, 8, 7, 7, 7, 7, 7, 6, 7, 8, 8, 8, 8, 6, 6, 4, 6, 7] }
    ];
}

function ui_char_index(c) {
    var n = ord(c) - 32;
    if (n < 0 || n > 94) n = 31;
    return n;
}

function ui_text_w(str, f, sc) {
    ui_init();
    var fd = global.ui_fonts[f];
    var w = 0;
    for (var i = 1; i <= string_length(str); i++) w += fd.adv[ui_char_index(string_char_at(str, i))];
    return w * sc;
}

function ui_text_h(f, sc) {
    ui_init();
    return global.ui_fonts[f].h * sc;
}

// align: fa_left, fa_center or fa_right
function ui_text(px, py, str, f, col, sc, align, alpha) {
    ui_init();
    var fd = global.ui_fonts[f];
    var cx = px;
    if (align == fa_center)     cx -= ui_text_w(str, f, sc) / 2;
    else if (align == fa_right) cx -= ui_text_w(str, f, sc);
    cx = floor(cx);
    py = floor(py);
    for (var i = 1; i <= string_length(str); i++) {
        var idx = ui_char_index(string_char_at(str, i));
        draw_sprite_ext(fd.spr, idx, cx, py, sc, sc, 0, col, alpha);
        cx += fd.adv[idx] * sc;
    }
}

// text with a hard offset shadow
function ui_text_shadow(px, py, str, f, col, shadow_col, sc, align, alpha) {
    ui_text(px + sc, py + sc, str, f, shadow_col, sc, align, alpha);
    ui_text(px, py, str, f, col, sc, align, alpha);
}

function ui_wrap_lines(str, f, sc, maxw) {
    var lines = [];
    var line  = "";
    var rest  = str;
    while (string_length(rest) > 0) {
        var p = string_pos(" ", rest);
        var word;
        if (p == 0) { word = rest; rest = ""; }
        else        { word = string_copy(rest, 1, p - 1); rest = string_delete(rest, 1, p); }
        var trial = (line == "") ? word : line + " " + word;
        if (line != "" && ui_text_w(trial, f, sc) > maxw) { array_push(lines, line); line = word; }
        else line = trial;
    }
    if (line != "") array_push(lines, line);
    return lines;
}

// returns the y just below the last line
function ui_text_wrapped(px, py, str, f, col, sc, maxw, align, alpha) {
    var lines  = ui_wrap_lines(str, f, sc, maxw);
    var line_h = ui_text_h(f, sc) + sc * 2;
    for (var i = 0; i < array_length(lines); i++) {
        ui_text(px, py + i * line_h, lines[i], f, col, sc, align, alpha);
    }
    return py + array_length(lines) * line_h;
}

// 9-slice: m = border size in source pixels, sc = pixel scale
function ui_nine(spr, sub, px, py, w, h, m, sc, col, alpha) {
    var sw = sprite_get_width(spr);
    var sh = sprite_get_height(spr);
    var cm = m * sc;
    var iw = sw - 2 * m;
    var ih = sh - 2 * m;
    var mw = w - 2 * cm;
    var mh = h - 2 * cm;
    px = floor(px); py = floor(py);
    draw_sprite_part_ext(spr, sub, 0,      0,      m,  m,  px,          py,          sc,      sc,      col, alpha);
    draw_sprite_part_ext(spr, sub, sw - m, 0,      m,  m,  px + w - cm, py,          sc,      sc,      col, alpha);
    draw_sprite_part_ext(spr, sub, 0,      sh - m, m,  m,  px,          py + h - cm, sc,      sc,      col, alpha);
    draw_sprite_part_ext(spr, sub, sw - m, sh - m, m,  m,  px + w - cm, py + h - cm, sc,      sc,      col, alpha);
    draw_sprite_part_ext(spr, sub, m,      0,      iw, m,  px + cm,     py,          mw / iw, sc,      col, alpha);
    draw_sprite_part_ext(spr, sub, m,      sh - m, iw, m,  px + cm,     py + h - cm, mw / iw, sc,      col, alpha);
    draw_sprite_part_ext(spr, sub, 0,      m,      m,  ih, px,          py + cm,     sc,      mh / ih, col, alpha);
    draw_sprite_part_ext(spr, sub, sw - m, m,      m,  ih, px + w - cm, py + cm,     sc,      mh / ih, col, alpha);
    draw_sprite_part_ext(spr, sub, m,      m,      iw, ih, px + cm,     py + cm,     mw / iw, mh / ih, col, alpha);
}

function ui_panel(px, py, w, h, tone) {
    var spr = spr_ui_panel;
    if (tone == 1) spr = spr_ui_panel_blue;
    if (tone == 2) spr = spr_ui_panel_orange;
    ui_nine(spr, 0, px, py, w, h, 8, 3, c_white, 1);
}

// cream button, frame 1 looks pressed in
function ui_button_box(px, py, w, h, hot) {
    ui_nine(spr_ui_button, hot ? 1 : 0, px, py, w, h, 12, 2, hot ? make_color_rgb(255, 232, 190) : c_white, 1);
}

// the four corner pieces of the selector sprite, placed around a rectangle
function ui_brackets(x1, y1, x2, y2, sc, col) {
    var q = 16 * sc;
    draw_sprite_part_ext(spr_ui_select, 0, 0,  0,  16, 16, x1,     y1,     sc, sc, col, 1);
    draw_sprite_part_ext(spr_ui_select, 0, 16, 0,  16, 16, x2 - q, y1,     sc, sc, col, 1);
    draw_sprite_part_ext(spr_ui_select, 0, 0,  16, 16, 16, x1,     y2 - q, sc, sc, col, 1);
    draw_sprite_part_ext(spr_ui_select, 0, 16, 16, 16, 16, x2 - q, y2 - q, sc, sc, col, 1);
}

// pixel heart, 7 x 6 source pixels
function ui_heart(px, py, sc, full) {
    var rows = [".XX.XX.", "XXXXXXX", "XXXXXXX", ".XXXXX.", "..XXX..", "...X..."];
    var fill = full ? C_RED : make_color_rgb(150, 162, 180);
    var edge = C_INK;
    for (var pass = 0; pass < 2; pass++) {
        for (var r = 0; r < 6; r++) {
            for (var c = 0; c < 7; c++) {
                if (string_char_at(rows[r], c + 1) != "X") continue;
                var qx = px + c * sc;
                var qy = py + r * sc;
                if (pass == 0) {
                    draw_set_color(edge);
                    draw_rectangle(qx - sc, qy, qx + sc * 2 - 1, qy + sc - 1, false);
                    draw_rectangle(qx, qy - sc, qx + sc - 1, qy + sc * 2 - 1, false);
                } else {
                    draw_set_color((full && r == 1 && c == 1) ? make_color_rgb(255, 170, 170) : fill);
                    draw_rectangle(qx, qy, qx + sc - 1, qy + sc - 1, false);
                }
            }
        }
    }
    draw_set_color(c_white);
}

// a menu button: label centred, brackets and an arrow when selected
// returns true when the mouse is over it
function ui_menu_button(px, py, w, h, label, selected) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var over = (mx >= px && mx < px + w && my >= py && my < py + h);
    ui_button_box(px, py, w, h, selected);
    var ty = py + (h - ui_text_h(F_BODY, 2)) / 2 - 3;
    ui_text(px + w / 2, ty, label, F_BODY, C_INK, 2, fa_center, 1);
    if (selected) {
        ui_brackets(px - 10, py - 10, px + w + 10, py + h + 10, 2, c_white);
        var bob = floor(current_time / 200) mod 2;
        draw_sprite_ext(spr_ui_play, 0, px - 34 - bob * 2, py + h / 2 - 14, 2, 2, 0, c_white, 1);
    }
    return over;
}
