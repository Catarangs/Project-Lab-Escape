if (hit_flash > 0) hit_flash--;
if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;
var ts = global.time_scale;
var px = obj_player.x;
var py = obj_player.y;
var dist = point_distance(x, y, px, py);

anim += (moving ? 0.2 : 0.04) * ts;

var los = line_clear(x, y, px, py);
strafe_t -= ts;
if (strafe_t <= 0) { strafe_dir = -strafe_dir; strafe_t = 80 + irandom(100); }

switch (mode) {
    case "seek":
        cool -= ts;
        if (!los)              mob_chase(px, py, spd);
        else if (dist < 260)   mob_flee(px, py, spd * 1.15);
        else if (dist > 440)   mob_chase(px, py, spd);
        else                   mob_strafe(px, py, spd * 0.6);
        mob_separate();
        if (los && cool <= 0 && dist < 640 && in_view(x, y, 0)) {
            aim_dir   = point_direction(x, y, px, py);
            laser_len = ray_length(x, y, aim_dir, 900);
            mode      = "charge";
            mode_t    = 70;
        }
        break;

    case "charge":
        mode_t -= ts;
        if (mode_t > 24) aim_dir = point_direction(x, y, px, py);
        face_dir  = dir_from_angle(aim_dir);
        laser_len = ray_length(x, y, aim_dir, 900);
        if (mode_t <= 0) {
            var b = instance_create_layer(x, y, "Bullets", obj_bullet_enemy);
            b.bdir  = aim_dir;
            b.bspd  = 6.2 + global.floor_num * 0.3;
            b.bcol  = make_color_rgb(120, 255, 150);
            b.brad  = 5;
            b.ramp  = false;
            b.depth = -120;
            mode   = "cool";
            mode_t = 80;
        }
        break;

    case "cool":
        mode_t -= ts;
        mob_separate();
        if (mode_t <= 0) { mode = "seek"; cool = 70 + irandom(60); }
        break;
}
