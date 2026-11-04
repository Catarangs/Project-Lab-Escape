if (tip_t > 0) tip_t--;
if (flash_timer > 0) flash_timer--;
if (keyboard_check_pressed(vk_f3)) show_coords = !show_coords;
global.gate_t += global.time_scale;
update_camera(false);
