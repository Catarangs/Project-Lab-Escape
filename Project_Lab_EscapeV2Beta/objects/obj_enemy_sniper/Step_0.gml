if (hit_flash > 0) hit_flash--;
if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;

var ts = global.time_scale;
var zm = (zone_at(x, y) == ZONE_SLOW) ? 0.45 : 1;
var dx = obj_player.x - x;
var dy = obj_player.y - y;
var los  = line_clear(x, y, obj_player.x, obj_player.y);
var dist = point_distance(x, y, obj_player.x, obj_player.y);
var aligned = los && (abs(dx) < 20 || abs(dy) < 20);
var mdir = -1;

switch (mode) {
    case "seek":
        cool -= ts;
        if (!los) {
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
            if (aligned) {
                if (dist < 230) mdir = point_direction(obj_player.x, obj_player.y, x, y);     // too close: back off along the lane
                else if (cool <= 0 && in_view(x, y, 0)) {
                    aim_dir   = (abs(dy) < 20) ? ((dx > 0) ? 0 : 180) : ((dy > 0) ? 270 : 90);
                    laser_len = ray_length(x, y, aim_dir, 900);
                    mode   = "charge";
                    mode_t = 60;
                }
            } else if (dist < 230) {
                mdir = point_direction(obj_player.x, obj_player.y, x, y);
            } else {
                mdir = (abs(dx) < abs(dy)) ? ((dx > 0) ? 0 : 180) : ((dy > 0) ? 270 : 90);   // get onto the player's row or column
            }
        }
        break;

    case "charge":                      // the lane is locked: step aside before it fires
        mode_t -= ts;
        if (mode_t <= 0) {
            var b = instance_create_layer(x, y, "Bullets", obj_bullet_enemy);
            b.bdir  = aim_dir;
            b.bspd  = 19 + global.floor_num * 0.6;     // three tiles per step
            b.bcol  = make_color_rgb(120, 255, 150);
            b.brad  = 5;
            b.depth = -120;
            mode = "cool";
            mode_t = 80;
        }
        break;

    case "cool":
        mode_t -= ts;
        if (mode_t <= 0) { mode = "seek"; cool = 55 + irandom(40); }
        break;
}

if (mdir != -1) {
    move_solid(lengthdir_x(spd * ts * zm, mdir), lengthdir_y(spd * ts * zm, mdir));
    anim += 0.12 * ts;
}
face_dir = (mode == "charge") ? dir_from_angle(aim_dir) : dir_from_angle(point_direction(x, y, obj_player.x, obj_player.y));
x = clamp(x, 50, global.arena_w - 50);
y = clamp(y, 50, global.arena_h - 50);
