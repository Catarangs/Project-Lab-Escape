var gw = display_get_gui_width();
var gh = display_get_gui_height();
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

draw_set_alpha(0.66);
draw_set_color(C_INK);
draw_rectangle(0, 0, gw, gh, false);
draw_set_alpha(1);

var head = "FLOOR " + string(global.floor_num) + " CLEARED";
var sub  = "Augment " + string(3 - picks_left) + " of 2";
if (mode == "start") { head = "CHOOSE YOUR STARTING AUGMENT"; sub = "Pick one to begin"; }
if (mode == "dev")   { head = "DEV: AUGMENT"; sub = "Pick one"; }
ui_text_shadow(gw / 2, card_y - 92, head, F_TITLE, c_white, C_INK, 1, fa_center, 1);
ui_text(gw / 2, card_y - 44, sub, F_BODY, C_MIST, 1, fa_center, 1);

for (var i = 0; i < array_length(choices); i++) {
    var cx      = start_x + i * (card_w + gap);
    var aid     = choices[i];
    var tier    = aug_tier(aid);
    var tcol    = aug_tier_color(tier);
    var hovered = (mx >= cx && mx <= cx + card_w && my >= card_y && my <= card_y + card_h);

    ui_panel(cx, hovered ? card_y - 6 : card_y, card_w, card_h, hovered ? 1 : 0);
    var top = hovered ? card_y - 6 : card_y;
    var ink = hovered ? c_white : C_INK;

    draw_set_color(tcol);
    draw_rectangle(cx + 10, top + 10, cx + card_w - 10, top + 14, false);
    ui_text(cx + 22, top + 24, "[" + string(i + 1) + "]", F_TINY, hovered ? C_ORANGE : C_GREY, 2, fa_left, 1);
    ui_text(cx + card_w - 22, top + 24, aug_tier_name(tier), F_TINY, tcol, 2, fa_right, 1);
    ui_text(cx + card_w / 2, top + 84, aug_name(aid), F_BODY, ink, 2, fa_center, 1);
    draw_set_color(tcol);
    draw_rectangle(cx + 34, top + 138, cx + card_w - 35, top + 139, false);
    ui_text_wrapped(cx + card_w / 2, top + 160, aug_desc(aid), F_BODY, ink, 1, card_w - 56, fa_center, 1);
    var have = aug_n(aid);
    if (have > 0) ui_text(cx + card_w / 2, top + card_h - 30, "OWNED x" + string(have), F_TINY, C_GREY, 2, fa_center, 1);
}

var rr = (global.rerolls > 0);
var rh = (mx >= reroll_x && mx <= reroll_x + reroll_w && my >= reroll_y && my <= reroll_y + reroll_h);
draw_set_alpha(rr ? (rh ? 0.95 : 0.8) : 0.35);
draw_set_color(rr ? C_ORANGE : C_GREY);
draw_rectangle(reroll_x, reroll_y, reroll_x + reroll_w, reroll_y + reroll_h, false);
draw_set_alpha(1);
ui_text(reroll_x + reroll_w / 2, reroll_y + 10, "REROLL [R]   " + string(global.rerolls) + " LEFT", F_TINY, C_INK, 2, fa_center, 1);
draw_set_color(c_white);
ui_text(gw / 2, reroll_y + reroll_h + 24, "Press 1, 2 or 3, or click a card", F_TINY, C_MIST, 2, fa_center, 1);
