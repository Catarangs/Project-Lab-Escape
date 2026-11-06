hp        = 5 + global.floor_num;
max_hp    = hp;
dying     = false;
depth     = -100;
hit_flash = 0;
vol_rate  = max(100, 190 - global.floor_num * 15);
vol_t     = vol_rate * 0.4 + irandom(30);
charge_t  = 0;
cycle_n   = 0;
volley_n  = 0;
spin      = random(360);
rot       = random(90);

laser_t    = 0;
laser_live = 0;
laser_dir  = 0;
laser_len  = 720;
