x += lengthdir_x(bspd, bdir);
y += lengthdir_y(bspd, bdir);
travelled += bspd;
if (travelled > maxdist) { instance_destroy(); exit; }

var ov = instance_nearest(x, y, obj_overload);
if (ov != noone && ov.state == "ready" && point_distance(x, y, ov.x, ov.y) < 34) {
    ov.arm();
    fx_hit(x, y, spr_fx_hit_a, 1.2);
    instance_destroy();
    exit;
}

if (instance_exists(obj_boss) && obj_boss.state == "fight"
    && abs(x - obj_boss.x) < obj_boss.hit_w && abs(y - obj_boss.y) < obj_boss.hit_h) {
    obj_boss.hurt(bdmg);
    fx_hit(x, y, obj_boss.stun_t > 0 ? spr_fx_hit_b : spr_fx_hit_c, obj_boss.stun_t > 0 ? 1.1 : 1.4);
    if (pierce <= 0) { instance_destroy(); exit; }
    pierce--;
    x += lengthdir_x(40, bdir);
    y += lengthdir_y(40, bdir);
}

var target = instance_nearest(x, y, obj_enemy_parent);
if (target != noone && !target.dying) {
    var is_node = (target.object_index == obj_power_node);
    var rad = is_node ? 38 : 22;
    if (point_distance(x, y, target.x, target.y) < rad) {
        var tx0 = target.x;
        var ty0 = target.y;
        if (is_node) {
            var open_gap = node_shield_open(target, x, y);
            damage_enemy(target, bdmg, x, y);
            if (!open_gap) { fx_hit(x, y, spr_fx_hit_c, 1.2); instance_destroy(); exit; }
        } else {
            damage_enemy(target, bdmg);
        }
        fx_hit(x, y, spr_fx_hit_a, 1);
        chain_hit(tx0, ty0, target, bdmg);
        bullet_blast(tx0, ty0, bdmg);
        if (pierce <= 0) { instance_destroy(); exit; }
        pierce--;
        x += lengthdir_x(30, bdir);
        y += lengthdir_y(30, bdir);
    }
}

if (wall_at(x, y)) {
    if (bounces > 0) {
        bounces--;
        x -= lengthdir_x(bspd, bdir);
        y -= lengthdir_y(bspd, bdir);
        bdir = reflect_dir(x, y, bdir, bspd + 4);
        x += lengthdir_x(bspd, bdir);
        y += lengthdir_y(bspd, bdir);
        if (wall_at(x, y)) { instance_destroy(); exit; }
        travelled = max(0, travelled - 300);
    } else {
        fx_hit(x, y, spr_fx_hit_a, 0.9);
        instance_destroy();
    }
}
