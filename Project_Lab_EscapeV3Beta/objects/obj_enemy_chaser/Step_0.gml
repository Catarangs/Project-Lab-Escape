if (hit_flash > 0) hit_flash--;
if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;
var ts = global.time_scale;
var px = obj_player.x;
var py = obj_player.y;
var dist = point_distance(x, y, px, py);

anim += (moving ? 0.25 : 0.04) * ts;

if (recoil_t > 0) {
    recoil_t -= ts;
    mob_flee(px, py, spd * 1.2);
}
else if (dist < 34) {
    face_dir = dir_from_angle(point_direction(x, y, px, py));
    if (obj_player.invincible_timer <= 0) {
        hurt_player(1);
        recoil_t = 36;
    }
}
else {
    mob_chase(px, py, spd);
}
mob_separate();
