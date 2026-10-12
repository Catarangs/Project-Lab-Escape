x += lengthdir_x(bspd, bdir);
y += lengthdir_y(bspd, bdir);

var hit = instance_nearest(x, y, obj_enemy_parent);
if (hit != noone && !hit.dying && point_distance(x, y, hit.x, hit.y) < 13) {
    hit.hp -= bdmg;
    if (hit.hp <= 0 && !hit.dying) {
        hit.dying = true;
        global.total_kills++;
        global.score += 10 * global.floor_num;
        with (hit) instance_destroy();
    }
    if (pierce <= 0) { instance_destroy(); exit; }
    pierce--;
    x += lengthdir_x(22, bdir);
    y += lengthdir_y(22, bdir);
}

if (x < -20 || x > room_width + 20 || y < -20 || y > room_height + 20)
    instance_destroy();
