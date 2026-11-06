if (hit_flash > 0) hit_flash--;
if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;
var ts = global.time_scale;
var px = obj_player.x;
var py = obj_player.y;
var dist = point_distance(x, y, px, py);

anim += (moving ? 0.22 : 0.04) * ts;

var los = line_clear(x, y, px, py);
strafe_t -= ts;
if (strafe_t <= 0) { strafe_dir = -strafe_dir; strafe_t = 70 + irandom(90); }

if (!los)                  mob_chase(px, py, spd);
else if (dist > 290)       mob_chase(px, py, spd);
else if (dist < 170)       mob_flee(px, py, spd * 1.1);
else                       mob_strafe(px, py, spd * 0.7);
mob_separate();

var aiming = los && dist < 520 && in_view(x, y, 0);
aim_dir = -1;
if (aiming) {
    aim_dir  = point_direction(x, y, px, py);
    face_dir = dir_from_angle(aim_dir);
    shoot_timer -= ts;
    if (shoot_timer <= 0) {
        shoot_timer = shoot_rate;
        var n = (global.floor_num >= 4) ? 3 : 1;
        for (var i = 0; i < n; i++) {
            var b = instance_create_layer(x, y, "Bullets", obj_bullet_enemy);
            b.bdir  = aim_dir + (i - (n - 1) / 2) * 15;
            b.bspd  = 2.8 + global.floor_num * 0.12;
            b.depth = -120;
        }
    }
}
