if (hit_flash > 0) hit_flash--;
if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;

var ts    = global.time_scale;
var zm    = (zone_at(x, y) == ZONE_SLOW) ? 0.45 : 1;
var total = spd * ts * zm;
var n     = ceil(total / 8);          // move in small sub-steps so it can still turn corners at speed

for (var s = 0; s < n; s++) {
    var dir = point_direction(x, y, obj_player.x, obj_player.y);
    // Line of sight -> chase directly; otherwise follow an A* route around walls
    if (!line_clear(x, y, obj_player.x, obj_player.y)) {
        repath_timer -= ts / n;
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
    }
    move_solid(lengthdir_x(total / n, dir), lengthdir_y(total / n, dir));
}
face_dir = dir_from_angle(point_direction(x, y, obj_player.x, obj_player.y));
anim    += 0.2 * ts;

if (point_distance(x, y, obj_player.x, obj_player.y) < 24 && obj_player.invincible_timer <= 0) hurt_player(1);
