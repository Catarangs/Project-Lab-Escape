hp            = 3 + global.floor_num;
max_hp        = hp;
spd           = 0.9 + global.floor_num * 0.1;
shoot_timer   = 60 + irandom(40);
shoot_rate    = max(55, 130 - global.floor_num * 12);
pref_dist     = 200 + irandom(80);
dying         = false;
depth         = -100;
