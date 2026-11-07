vx             = 0;
vy             = 0;
aim_ang        = 0;
is_moving      = false;
fire_timer     = 0;
invincible_timer = 0;
invincible_max   = 80;
alive          = true;
death_timer    = 0;
depth          = -200;

face_dir = 2;
anim_t   = 0;
stuck_t  = 0;
stasis_cd = 0;
echo_t   = 0;
echo_ang = 0;

snap_to_cell = function(cx, cy) {
    x  = cell_to_px(cx);
    y  = cell_to_px(cy);
    vx = 0;
    vy = 0;
};
snap_to_cell(global.spawn_cx, global.spawn_cy);
