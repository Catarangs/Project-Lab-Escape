if (hit_flash > 0) hit_flash--;
if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;

var ts = global.time_scale;
spin += 1.2 * ts;

if (laser_live > 0) {
    laser_live -= ts;
    var lx = lengthdir_x(laser_len, laser_dir);
    var ly = lengthdir_y(laser_len, laser_dir);
    var tt = clamp(((obj_player.x - x) * lx + (obj_player.y - y) * ly) / (laser_len * laser_len), 0, 1);
    var hit = point_distance(obj_player.x, obj_player.y, x + lx * tt, y + ly * tt) < 24;
    if (hit && obj_player.invincible_timer <= 0) hurt_player(1);
}
else if (laser_t > 0) {
    laser_t -= ts;
    if (laser_t <= 0) laser_live = 30;
}
else if (charge_t > 0) {
    charge_t -= ts;
    if (charge_t <= 0) {
        volley_n++;
        var wide  = (global.floor_num >= 3 && volley_n mod 2 == 0);
        var n     = wide ? 8 : 4;
        var spd_b = 2.5 + global.floor_num * 0.12;
        for (var d = 0; d < n; d++) {
            var ang = rot + d * 360 / n;
            var bx = x + lengthdir_x(20, ang);
            var by = y + lengthdir_y(20, ang);
            if (wall_at(bx, by)) continue;
            var b = instance_create_layer(bx, by, "Bullets", obj_bullet_enemy);
            b.bdir  = ang;
            b.bspd  = spd_b;
            b.bcol  = make_color_rgb(255, 170, 50);
            b.depth = -120;
        }
        rot += 19;
    }
} else if (in_view(x, y, 0)) {
    vol_t -= ts;
    if (vol_t <= 0) {
        vol_t = vol_rate;
        cycle_n++;
        if (global.floor_num >= 2 && random(1) < 0.25) {
            laser_dir = point_direction(x, y, obj_player.x, obj_player.y);
            laser_t   = 60;
        } else {
            charge_t = 30;
        }
    }
}
