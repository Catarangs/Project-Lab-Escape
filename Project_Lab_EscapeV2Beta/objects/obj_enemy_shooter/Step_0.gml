if (hit_flash > 0) hit_flash--;

if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;

var ts = global.time_scale;
var dx = obj_player.x - x;
var dy = obj_player.y - y;
var los = line_clear(x, y, obj_player.x, obj_player.y);
var aligned  = los && (abs(dx) < 20 || abs(dy) < 20) && point_distance(x, y, obj_player.x, obj_player.y) < 700;
var lined_up = aligned && in_view(x, y, 0);      // never fires from off screen
var mdir = -1;

aim_dir = -1;
if (!los) {
    // no line of sight: route around walls toward the player
    repath_timer -= ts;
    if (repath_timer <= 0 || !has_wp) {
        repath_timer = 20;
        var wp = nav_next_point(obj_player.x, obj_player.y);
        has_wp = is_array(wp);
        if (has_wp) { wp_x = wp[0]; wp_y = wp[1]; }
    }
    if (has_wp && point_distance(x, y, wp_x, wp_y) < 6) { has_wp = false; repath_timer = 0; }
    mdir = has_wp ? point_direction(x, y, wp_x, wp_y) : point_direction(x, y, obj_player.x, obj_player.y);
} else {
    has_wp = false;
    if (lined_up) {
        // bullets only fly along rows and columns, so it holds still and shoots down the lane
        aim_dir = (abs(dy) < 20) ? ((dx > 0) ? 0 : 180) : ((dy > 0) ? 270 : 90);
    } else if (aligned) {
        mdir = point_direction(x, y, obj_player.x, obj_player.y);   // lined up but off screen: close in
    } else if (abs(dx) < abs(dy)) {
        mdir = (dx > 0) ? 0 : 180;    // slide sideways until it shares a column
    } else {
        mdir = (dy > 0) ? 270 : 90;   // slide up or down until it shares a row
    }
}

var zm = (zone_at(x, y) == ZONE_SLOW) ? 0.45 : 1;
if (mdir != -1) move_solid(lengthdir_x(spd * ts * zm, mdir), lengthdir_y(spd * ts * zm, mdir));
face_dir = dir_from_angle(point_direction(x, y, obj_player.x, obj_player.y));
anim    += 0.12 * ts;
x = clamp(x, 50, global.arena_w - 50);
y = clamp(y, 50, global.arena_h - 50);

// the reload only ticks while it is lined up and time is running
if (aim_dir != -1) shoot_timer -= ts;
if (aim_dir != -1 && shoot_timer <= 0) {
    shoot_timer = shoot_rate;
    var b = instance_create_layer(x, y, "Bullets", obj_bullet_enemy);
    b.bdir  = aim_dir;
    b.bspd  = STEP_PX * 2 + global.floor_num * 0.4;     // two tiles per step (the first step is half, see obj_bullet_enemy)
    b.depth = -120;
}
