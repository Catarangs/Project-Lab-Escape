// =============================================================================
//  obj_cheat_menu - Step
// =============================================================================

// Open / close: ~ key (virtual key 192). F1 also works for other keyboard layouts.
if (keyboard_check_pressed(192) || keyboard_check_pressed(vk_f1)) {
    global.cheat_open = !global.cheat_open;
    sel = 0;
}
if (!global.cheat_open) exit;

if (keyboard_check_pressed(vk_escape)) {
    global.cheat_open = false;
    exit;
}

var n = array_length(items);

// ---- keyboard: W/S or Up/Down to move, Enter or Space to use ----
if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) sel = (sel + 1) mod n;
if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) sel = (sel - 1 + n) mod n;

if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    message   = items[sel].run();
    msg_timer = 150;
}

// ---- mouse: hover highlights, left click uses ----
var mx    = device_mouse_x_to_gui(0);
var my    = device_mouse_y_to_gui(0);
var moved = (mx != last_mx || my != last_my);
last_mx = mx;
last_my = my;

for (var i = 0; i < n; i++) {
    var ry   = row_y0 + i * row_h;
    var over = (mx >= row_x && mx <= row_x + row_w && my >= ry && my <= ry + row_h - 8);
    if (over) {
        if (moved) sel = i;
        if (mouse_check_button_pressed(mb_left)) {
            sel       = i;
            message   = items[i].run();
            msg_timer = 150;
        }
    }
}

if (msg_timer > 0) msg_timer--;
