if (keyboard_check_pressed(vk_f10)) global.dev = !global.dev;
var pick = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var clicked = mouse_check_button_pressed(mb_left);

if (show_help) {
    if (pick || clicked || keyboard_check_pressed(vk_escape)) show_help = false;
    exit;
}

var n = array_length(menu_items);
if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) menu_sel = (menu_sel + 1) mod n;
if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) menu_sel = (menu_sel + n - 1) mod n;

var over = -1;
for (var i = 0; i < n; i++) {
    var by = btn_y + i * btn_gap;
    if (mx >= btn_x && mx < btn_x + btn_w && my >= by && my < by + btn_h) over = i;
}
if (mouse_x != prev_mx || mouse_y != prev_my) { if (over != -1) menu_sel = over; }
prev_mx = mouse_x;
prev_my = mouse_y;
if (clicked && over != -1) { menu_sel = over; pick = true; }

if (pick) {
    switch (menu_sel) {
        case 0: global.new_run = true; room_goto(room_floor1); break;
        case 1: show_help = true; break;
        case 2: game_end(); break;
    }
}
