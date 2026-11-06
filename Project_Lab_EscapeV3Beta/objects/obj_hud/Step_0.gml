if (tip_t > 0) tip_t--;
if (flash_timer > 0) flash_timer--;
if (heal_flash > 0) heal_flash--;
if (keyboard_check_pressed(vk_f3)) show_coords = !show_coords;
if (keyboard_check_pressed(vk_f10)) global.dev = !global.dev;
dev_update();
global.gate_t += global.time_scale;
window_set_cursor(global.is_upgrade_phase ? cr_default : cr_none);
update_camera(false);
