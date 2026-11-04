hp            = 3 + global.floor_num;
max_hp        = hp;
spd           = STEP_PX * (1.0 + global.floor_num * 0.08);
shoot_timer   = 14 + irandom(16);
shoot_rate    = max(24, 58 - global.floor_num * 5);
dying         = false;
depth         = -100;
aim_dir       = -1;     // set while lined up with the player, drives the warning line

// pathfinding state
repath_timer = irandom(15);
has_wp       = false;
wp_x         = 0;
wp_y         = 0;

// look
set       = global.set_tech;
face_dir  = 2;
anim      = random(4);
hit_flash = 0;
