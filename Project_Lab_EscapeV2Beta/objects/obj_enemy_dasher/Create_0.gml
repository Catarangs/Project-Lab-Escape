// melee: stalks you, lines up, winds up, then dashes down a row or column
hp      = 3 + global.floor_num;
max_hp  = hp;
spd     = STEP_PX * (0.75 + global.floor_num * 0.1);
dying   = false;
depth   = -100;

mode      = "stalk";     // stalk -> windup -> dash -> recover
mode_t    = 0;
dash_dir  = 0;
dash_left = 0;
cool      = 40 + irandom(30);
warn_len  = 0;

repath_timer = irandom(15);
has_wp       = false;
wp_x         = 0;
wp_y         = 0;

set       = global.set_dash;
face_dir  = 2;
anim      = random(4);
hit_flash = 0;
