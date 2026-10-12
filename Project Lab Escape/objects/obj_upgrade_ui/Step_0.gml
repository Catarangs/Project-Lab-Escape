if (keyboard_check_pressed(ord("1"))) do_select(0);
if (keyboard_check_pressed(ord("2"))) do_select(1);
if (keyboard_check_pressed(ord("3"))) do_select(2);

if (mouse_check_button_pressed(mb_left)) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    for (var i = 0; i < 3; i++) {
        var cx = start_x + i * (card_w + gap);
        if (mx >= cx && mx <= cx + card_w && my >= card_y && my <= card_y + card_h)
            do_select(i);
    }
}