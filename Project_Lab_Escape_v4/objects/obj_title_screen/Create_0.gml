window_set_cursor(cr_default);
prev_mx = -1;
prev_my = -1;
ui_init();
if (!variable_global_exists("dev")) { global.dev = false; global.dev_god = false; }
menu_items = ["START", "CONTROLS", "QUIT"];
menu_sel   = 0;
show_help  = false;
btn_x = 470;
btn_y = 372;
btn_w = 330;
btn_h = 60;
btn_gap = 80;
