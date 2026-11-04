// stationary: fires volleys down all four lanes while you are on screen.
// Now and then (randomly) it fires a laser that ignores walls, so hiding behind cover will not save you from it.
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

laser_t    = 0;      // warning time
laser_live = 0;      // frames the beam burns
laser_dir  = 0;
laser_len  = 720;
