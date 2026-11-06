if (hit_flash > 0) hit_flash--;
if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;
var ts = global.time_scale;
var px = obj_player.x;
var py = obj_player.y;
var dist = point_distance(x, y, px, py);

anim += ((mode == "dash") ? 0.35 : (moving ? 0.25 : 0.04)) * ts;

var los = line_clear(x, y, px, py);

switch (mode) {

    case "stalk":
        cool -= ts;
        if (dist < 34) {
            face_dir = dir_from_angle(point_direction(x, y, px, py));
            if (obj_player.invincible_timer <= 0) { hurt_player(1); mode = "retreat"; retreat_t = 110; }
        }
        else if (los && cool <= 0 && dist > 120 && dist < 460 && in_view(x, y, 0)) {
            dash_dir = point_direction(x, y, px, py);
            warn_len = min(ray_length(x, y, dash_dir, 9 * TILE), dist + 80);
            face_dir = dir_from_angle(dash_dir);
            mode     = "windup";
            mode_t   = 40;
        }
        else if (dist > 200) mob_chase(px, py, spd);
        else                 mob_strafe(px, py, spd * 0.8);
        mob_separate();
        break;

    case "windup":
        mode_t -= ts;
        if (mode_t > 14) {
            dash_dir = point_direction(x, y, px, py);
            warn_len = min(ray_length(x, y, dash_dir, 9 * TILE), dist + 80);
        }
        face_dir = dir_from_angle(dash_dir);
        if (mode_t <= 0) { mode = "dash"; dash_left = warn_len; }
        break;

    case "dash":
        var step = 8 * ts;
        var ox = x;
        var oy = y;
        mob_apply(lengthdir_x(step, dash_dir), lengthdir_y(step, dash_dir));
        dash_left -= step;
        if (dist < 28) {
            if (obj_player.invincible_timer <= 0) hurt_player(1);
            mode = "recover"; mode_t = 34;
        }
        else if (dash_left <= 0 || (abs(x - ox) + abs(y - oy)) < 0.2 * step) { mode = "recover"; mode_t = 34; }
        break;

    case "recover":
        mode_t -= ts;
        if (mode_t <= 0) { mode = "retreat"; retreat_t = 110; }
        break;

    case "retreat":
        retreat_t -= ts;
        mob_flee(px, py, spd * 1.2);
        mob_separate();
        if (dist >= 340 || retreat_t <= 0) { mode = "stalk"; cool = 40 + irandom(30); }
        break;
}
