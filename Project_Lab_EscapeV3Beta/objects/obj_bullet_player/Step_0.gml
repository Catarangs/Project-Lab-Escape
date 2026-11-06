x += lengthdir_x(bspd, bdir);
y += lengthdir_y(bspd, bdir);
travelled += bspd;
if (travelled > maxdist) { instance_destroy(); exit; }

var target = instance_nearest(x, y, obj_enemy_parent);
if (target != noone && !target.dying && point_distance(x, y, target.x, target.y) < 22) {
    var tx0 = target.x;
    var ty0 = target.y;
    damage_enemy(target, bdmg);
    chain_hit(tx0, ty0, target, bdmg);
    bullet_blast(tx0, ty0, bdmg);
    if (pierce <= 0) { instance_destroy(); exit; }
    pierce--;
    x += lengthdir_x(30, bdir);
    y += lengthdir_y(30, bdir);
}

if (wall_at(x, y)) {
    if (bounces > 0) {
        bounces--;
        bdir += 180;
        x += lengthdir_x(26, bdir);
        y += lengthdir_y(26, bdir);
        travelled = max(0, travelled - 200);
    } else {
        instance_destroy();
    }
}
