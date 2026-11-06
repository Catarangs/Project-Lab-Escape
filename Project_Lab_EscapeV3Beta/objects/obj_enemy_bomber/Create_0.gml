hp      = 2 + global.floor_num div 2;
max_hp  = hp;
spd     = 1.7 + 0.08 * global.floor_num;
dying   = false;
depth   = -100;
fuse    = -1;
fuse_max = 46;

set       = global.set_dash;
face_dir  = 2;
anim      = random(4);
hit_flash = 0;

mob_init(14);
