// ranged: keeps its distance, locks onto a lane with a long laser, then fires one fast bullet
hp      = 2 + global.floor_num;
max_hp  = hp;
spd     = STEP_PX * (1.0 + global.floor_num * 0.05);
dying   = false;
depth   = -100;

mode     = "seek";      // seek -> charge -> cool
mode_t   = 0;
aim_dir  = 0;
laser_len = 0;
cool     = 40 + irandom(40);

repath_timer = irandom(15);
has_wp       = false;
wp_x         = 0;
wp_y         = 0;

set       = global.set_sniper;
face_dir  = 2;
anim      = random(4);
hit_flash = 0;
