move_dir_x     = 0;
move_dir_y     = 0;
fire_timer     = 0;
act_timer      = 0;    // frames of time still running after a shot
invincible_timer = 0;
invincible_max   = 90;
alive          = true;
angle_face     = 0;
death_timer    = 0;
depth          = -200;

face_dir = 2;   // 0 right, 1 left, 2 down, 3 up (sprite direction)
anim_t   = 0;

// ---- Grid movement ----
grid_x      = 0;               // current tile
grid_y      = 0;
sliding     = false;           // true while gliding to the next tile
slide_t     = 0;               // 0..1 progress of the slide
slide_from_x = 0;
slide_from_y = 0;
slide_to_x   = 0;
slide_to_y   = 0;
last_dir_key = -1;
cur_frames   = 8;              // frames the current step takes (sludge makes it longer)
stuck_t      = 0;              // frames left held by a stasis pad (time keeps running)             // most recently pressed direction (for held keys)

snap_to_cell = function(cx, cy) {
    grid_x = cx;
    grid_y = cy;
    x = cell_to_px(cx);
    y = cell_to_px(cy);
    sliding = false;
    slide_t = 0;
    move_dir_x = 0;
    move_dir_y = 0;
};
snap_to_cell(global.spawn_cx, global.spawn_cy);
