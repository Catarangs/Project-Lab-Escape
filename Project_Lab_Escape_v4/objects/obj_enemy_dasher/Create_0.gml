hp      = 3 + global.floor_num;
max_hp  = hp;
spd     = 1.4 + 0.07 * global.floor_num;
dying   = false;
depth   = -100;

mode      = "stalk";
mode_t    = 0;
dash_dir  = 0;
dash_left = 0;
cool      = 70 + irandom(50);
warn_len  = 0;
retreat_t = 0;

set       = global.set_dash;
face_dir  = 2;
anim      = random(4);
hit_flash = 0;

mob_init(14);
