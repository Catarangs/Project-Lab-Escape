var gw = display_get_gui_width();
var gh = display_get_gui_height();

draw_set_alpha(0.75);
draw_set_color(make_color_rgb(5, 8, 12));
draw_rectangle(0, 0, gw, gh, false);
draw_set_alpha(1);

draw_set_halign(fa_center);
draw_set_color(make_color_rgb(80, 220, 120));
draw_text_transformed(gw/2, card_y - 56, "UPGRADE AVAILABLE", 1.8, 1.8, 0);
draw_set_color(make_color_rgb(140, 160, 140));
draw_text(gw/2, card_y - 22, "Floor " + string(global.floor_num) + " cleared  —  choose one upgrade");

for (var i = 0; i < 3; i++) {
    var cx      = start_x + i * (card_w + gap);
    var utype   = choices[i];
    var mx      = device_mouse_x_to_gui(0);
    var my      = device_mouse_y_to_gui(0);
    var hovered = (mx >= cx && mx <= cx + card_w && my >= card_y && my <= card_y + card_h);

    draw_set_color(hovered ? make_color_rgb(20,44,30) : make_color_rgb(12,22,18));
    draw_rectangle(cx, card_y, cx + card_w, card_y + card_h, false);
    draw_set_color(hovered ? make_color_rgb(60,200,100) : make_color_rgb(30,70,45));
    draw_rectangle(cx, card_y, cx + card_w, card_y + card_h, true);

    draw_set_color(hovered ? make_color_rgb(120,240,160) : make_color_rgb(60,120,80));
    draw_text_transformed(cx + card_w/2, card_y + 26, "[" + string(i+1) + "]", 1.4, 1.4, 0);

    draw_set_color(make_color_rgb(200, 240, 210));
    draw_text(cx + card_w/2, card_y + 70, upgrade_name(utype));

    draw_set_color(make_color_rgb(120, 160, 130));
    draw_text_ext(cx + card_w/2, card_y + 140, upgrade_desc(utype), 22, card_w - 24);

    draw_set_color(hovered ? make_color_rgb(80,200,120) : make_color_rgb(40,80,55));
    draw_text(cx + card_w/2, card_y + card_h - 26, "Click or press " + string(i+1));
}
draw_set_halign(fa_left);
