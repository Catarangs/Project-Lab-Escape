state     = "ready";
arm_t     = 0;
cool_t    = 0;
cool_max  = 840;
blast_r   = 210;
glow_t    = random(100);
depth     = -90;

arm = function() {
    if (state != "ready") return;
    state = "armed";
    arm_t = 32;
    fx_hit(x, y, spr_fx_hit_c, 2.2);
};

detonate = function() {
    state  = "cooling";
    cool_t = cool_max;
    fx_hit(x, y, spr_fx_hit_b, 7);
    fx_explode(x, y, 1.8);
    if (instance_exists(obj_boss)) obj_boss.overload_blast(x, y, blast_r);
    var bx = x;
    var by = y;
    var rr = blast_r;
    var victims = [];
    with (obj_enemy_parent) {
        if (!dying && !is_machine(object_index) && point_distance(x, y, bx, by) < rr) array_push(victims, id);
    }
    for (var i = 0; i < array_length(victims); i++) {
        if (instance_exists(victims[i])) damage_enemy(victims[i], 6);
    }
};
