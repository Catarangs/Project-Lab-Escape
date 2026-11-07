hp            = 3 + global.floor_num;
max_hp        = hp;
spd           = 1.15 + 0.07 * global.floor_num;
shoot_timer   = 30 + irandom(40);
shoot_rate    = max(44, 100 - global.floor_num * 6);
dying         = false;
depth         = -100;
aim_dir       = -1;

set       = global.set_tech;
face_dir  = 2;
anim      = random(4);
hit_flash = 0;

mob_init(14);
