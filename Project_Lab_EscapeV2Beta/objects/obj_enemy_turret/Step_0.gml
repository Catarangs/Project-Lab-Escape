if (hit_flash > 0) hit_flash--;
if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;

var ts = global.time_scale;
spin += 1.2 * ts;

if (laser_live > 0) {
    // the beam passes through walls and cover
    laser_live -= ts;
    var ddx = obj_player.x - x;
    var ddy = obj_player.y - y;
    var hit = false;
    switch (laser_dir) {
        case 0:   hit = (ddx > 0 && ddx < laser_len && abs(ddy) < 26); break;
        case 180: hit = (ddx < 0 && -ddx < laser_len && abs(ddy) < 26); break;
        case 270: hit = (ddy > 0 && ddy < laser_len && abs(ddx) < 26); break;
        default:  hit = (ddy < 0 && -ddy < laser_len && abs(ddx) < 26); break;
    }
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
        var wide = (global.floor_num >= 3 && volley_n mod 2 == 0);       // every other volley fires three lanes per side
        var spd_b = STEP_PX * 2 + global.floor_num * 0.4;
        for (var d = 0; d < 4; d++) {
            var ang = d * 90;
            for (var o = (wide ? -1 : 0); o <= (wide ? 1 : 0); o++) {
                var bx = x + lengthdir_x(20, ang) + lengthdir_x(o * TILE, ang + 90);
                var by = y + lengthdir_y(20, ang) + lengthdir_y(o * TILE, ang + 90);
                if (wall_at(bx, by)) continue;
                var b = instance_create_layer(bx, by, "Bullets", obj_bullet_enemy);
                b.bdir  = ang;
                b.bspd  = spd_b;
                b.bcol  = make_color_rgb(255, 170, 50);
                b.depth = -120;
            }
        }
    }
} else if (in_view(x, y, 0)) {
    vol_t -= ts;
    if (vol_t <= 0) {
        vol_t = vol_rate;
        cycle_n++;
        if (global.floor_num >= 2 && random(1) < 0.25) {      // random, so there is no rhythm to learn
            laser_dir = snap_dir(point_direction(x, y, obj_player.x, obj_player.y));    // lane locked now: move out of it
            laser_t   = 60;
        } else {
            charge_t = 30;
        }
    }
}
