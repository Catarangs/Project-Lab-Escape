if (tip_t > 0) tip_t--;
if (flash_timer > 0) flash_timer--;
if (heal_flash > 0) heal_flash--;
if (keyboard_check_pressed(vk_f3)) show_coords = !show_coords;
if (keyboard_check_pressed(vk_f10) || keyboard_check_pressed(vk_f9) || keyboard_check_pressed(192)) global.dev = !global.dev;
var tgw = display_get_gui_width();
var tgh = display_get_gui_height();
var tmx = device_mouse_x_to_gui(0);
var tmy = device_mouse_y_to_gui(0);
var hit_l = (tmx < 26 && abs(tmy - tgh / 2) < 50);
var hit_r = (tmx > tgw - 26 && abs(tmy - tgh / 2) < 50);
var hit_t = (tmy < 26 && abs(tmx - tgw / 2) < 50);
var hit_f = fs_update(tgw, tgh, false);
global.ui_block = (hit_l || hit_r || hit_t || hit_f);
if (mouse_check_button_pressed(mb_left) && !global.is_upgrade_phase) {
    if (hit_l) pin_l = !pin_l;
    if (hit_r) pin_r = !pin_r;
    if (hit_t) pin_t = !pin_t;
}
dev_update();
global.gate_t += global.time_scale;
window_set_cursor(global.is_upgrade_phase ? cr_default : cr_none);
update_camera(false);
