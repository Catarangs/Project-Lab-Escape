if (hit_flash > 0) hit_flash--;
if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;

var ts = global.time_scale;
var zm = (zone_at(x, y) == ZONE_SLOW) ? 0.45 : 1;
var dx = obj_player.x - x;
var dy = obj_player.y - y;
var los = line_clear(x, y, obj_player.x, obj_player.y);
var dist = point_distance(x, y, obj_player.x, obj_player.y);
var moving = false;

switch (mode) {

    case "stalk":
        cool -= ts;
        var dir = point_direction(x, y, obj_player.x, obj_player.y);
        var aligned = los && (abs(dx) < 20 || abs(dy) < 20);
        if (aligned && cool <= 0 && dist > 90 && dist < 460 && in_view(x, y, 0)) {
            dash_dir = (abs(dy) < 20) ? ((dx > 0) ? 0 : 180) : ((dy > 0) ? 270 : 90);
            warn_len = ray_length(x, y, dash_dir, 520);
            mode = "windup";
            mode_t = 36;
            face_dir = dir_from_angle(dash_dir);
            break;
        }
        if (!los) {
            repath_timer -= ts;
            if (repath_timer <= 0 || !has_wp) {
                repath_timer = 20;
                var wp = nav_next_point(obj_player.x, obj_player.y);
                has_wp = is_array(wp);
                if (has_wp) { wp_x = wp[0]; wp_y = wp[1]; }
            }
            if (has_wp) {
                if (point_distance(x, y, wp_x, wp_y) < 6) { has_wp = false; repath_timer = 0; }
                else dir = point_direction(x, y, wp_x, wp_y);
            }
        } else {
            has_wp = false;
            // slide toward a shared row or column so it can line up a dash
            if (!aligned) dir = (abs(dx) < abs(dy)) ? ((dx > 0) ? 0 : 180) : ((dy > 0) ? 270 : 90);
        }
        move_solid(lengthdir_x(spd * ts * zm, dir), lengthdir_y(spd * ts * zm, dir));
        face_dir = dir_from_angle(dir);
        moving = true;
        break;

    case "windup":
        mode_t -= ts;
        if (mode_t <= 0) { mode = "dash"; dash_left = warn_len + 30; }
        break;

    case "dash":
        if (ts > 0) {
            var ox = x, oy = y;
            var sp = 20 * ts * zm;                  // about 3 tiles per player step
            move_solid(lengthdir_x(sp, dash_dir), lengthdir_y(sp, dash_dir));
            dash_left -= sp;
            if (point_distance(ox, oy, x, y) < sp * 0.5 || dash_left <= 0) { mode = "recover"; mode_t = 55; }
        }
        moving = true;
        face_dir = dir_from_angle(dash_dir);
        break;

    case "recover":                 // winded: the moment to shoot it
        mode_t -= ts;
        if (mode_t <= 0) { mode = "stalk"; cool = 50 + irandom(30); }
        break;
}

anim += ((mode == "dash") ? 0.3 : 0.14) * ts * (moving ? 1 : 0);
x = clamp(x, 50, global.arena_w - 50);
y = clamp(y, 50, global.arena_h - 50);

// touching it hurts, at any time except while it winds up
if (mode != "windup" && dist < 26 && obj_player.invincible_timer <= 0) hurt_player(1);
