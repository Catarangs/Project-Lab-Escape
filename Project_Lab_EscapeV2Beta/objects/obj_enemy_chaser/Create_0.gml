hp      = 2 + global.floor_num;
max_hp  = hp;
spd     = STEP_PX * (0.5 + 0.15 * global.floor_num);   // about 2 to 2.6 tiles per player step
dying   = false;
depth   = -100;

// pathfinding state
repath_timer = irandom(15);
has_wp       = false;
wp_x         = 0;
wp_y         = 0;

// look
set       = global.set_guard;
face_dir  = 2;
anim      = random(4);
hit_flash = 0;
