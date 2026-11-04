var gw = display_get_gui_width();
var gh = display_get_gui_height();
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

draw_set_alpha(0.62);
draw_set_color(C_INK);
draw_rectangle(0, 0, gw, gh, false);
draw_set_alpha(1);

ui_text_shadow(gw / 2, card_y - 92, "FLOOR " + string(global.floor_num) + " CLEARED", F_TITLE, c_white, C_INK, 1, fa_center, 1);
ui_text(gw / 2, card_y - 44, "Pick one upgrade", F_BODY, C_MIST, 1, fa_center, 1);

for (var i = 0; i < 3; i++) {
    var cx      = start_x + i * (card_w + gap);
    var utype   = choices[i];
    var hovered = (mx >= cx && mx <= cx + card_w && my >= card_y && my <= card_y + card_h);

    ui_panel(cx, hovered ? card_y - 6 : card_y, card_w, card_h, hovered ? 1 : 0);
    var top = hovered ? card_y - 6 : card_y;
    var ink = hovered ? c_white : C_INK;

    ui_text(cx + 22, top + 20, "[" + string(i + 1) + "]", F_TINY, hovered ? C_ORANGE : C_GREY, 2, fa_left, 1);
    ui_text(cx + card_w / 2, top + 84, upgrade_name(utype), F_BODY, ink, 2, fa_center, 1);
    draw_set_color(hovered ? c_white : C_GREY);
    draw_rectangle(cx + 34, top + 138, cx + card_w - 35, top + 139, false);
    ui_text_wrapped(cx + card_w / 2, top + 160, upgrade_desc(utype), F_BODY, ink, 1, card_w - 56, fa_center, 1);
}
draw_set_color(c_white);
ui_text(gw / 2, card_y + card_h + 30, "Press 1, 2 or 3, or click a card", F_TINY, C_MIST, 2, fa_center, 1);
