hp      = 2 + global.floor_num;
max_hp  = hp;
spd     = 1.45 + 0.1 * global.floor_num;
dying   = false;
depth   = -100;
recoil_t = 0;

set       = global.set_guard;
face_dir  = 2;
anim      = random(4);
hit_flash = 0;

mob_init(14);
