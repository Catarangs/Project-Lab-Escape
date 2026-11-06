hp      = 2 + global.floor_num;
max_hp  = hp;
spd     = 1.0 + 0.05 * global.floor_num;
dying   = false;
depth   = -100;

mode     = "seek";
mode_t   = 0;
aim_dir  = 0;
laser_len = 0;
cool     = 60 + irandom(60);

set       = global.set_sniper;
face_dir  = 2;
anim      = random(4);
hit_flash = 0;

mob_init(14);
