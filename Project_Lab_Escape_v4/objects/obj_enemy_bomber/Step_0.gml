if (hit_flash > 0) hit_flash--;
if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;
var ts = global.time_scale;
var px = obj_player.x;
var py = obj_player.y;
var dist = point_distance(x, y, px, py);

anim += (moving ? 0.3 : 0.05) * ts;

if (fuse >= 0) {
    fuse -= ts;
    if (fuse < 0) {
        damage_enemy(id, 9999);
        exit;
    }
}

if (fuse < 0 && dist < 100) fuse = fuse_max;
mob_chase(px, py, (fuse >= 0) ? spd * 0.6 : spd);
mob_separate();
