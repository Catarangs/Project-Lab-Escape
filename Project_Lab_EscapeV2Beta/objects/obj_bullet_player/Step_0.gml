var ts = global.time_scale;
if (!snapped) { bdir = snap_dir(bdir); snapped = true; }

x += lengthdir_x(bspd * ts, bdir);
y += lengthdir_y(bspd * ts, bdir);

var target = instance_nearest(x, y, obj_enemy_parent);
if (target != noone && !target.dying && point_distance(x, y, target.x, target.y) < 22) {
    target.hp -= bdmg;
    if (variable_instance_exists(target, "hit_flash")) target.hit_flash = 4;
    if (target.hp <= 0 && !target.dying) {
        target.dying = true;
        fx_explode(target.x, target.y, (target.object_index == obj_power_node || target.object_index == obj_generator) ? 0.9 : 0.55);
        global.total_kills++;
        global.score += 10 * global.floor_num;
        var gen_x = target.x, gen_y = target.y;
        var was_gen = (target.object_index == obj_generator);
        with (target) instance_destroy();
        if (was_gen) spawn_scrap(gen_x, gen_y);
    }
    if (pierce <= 0) { instance_destroy(); exit; }
    pierce--;
    x += lengthdir_x(30, bdir);
    y += lengthdir_y(30, bdir);
}

if (wall_at(x, y)) instance_destroy();
