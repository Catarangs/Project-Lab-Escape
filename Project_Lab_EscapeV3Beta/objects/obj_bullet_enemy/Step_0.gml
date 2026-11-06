var ts = global.time_scale;

age  += ts;
life += 1;
var m = (ramp && age < 7) ? 0.5 : 1;
x += lengthdir_x(bspd * ts * m, bdir);
y += lengthdir_y(bspd * ts * m, bdir);

if (instance_exists(obj_player) && obj_player.alive
    && obj_player.invincible_timer <= 0
    && point_distance(x, y, obj_player.x, obj_player.y) < 12 + brad * 0.5) {
    hurt_player(1);
    instance_destroy();
    exit;
}

if (wall_at(x, y)) {
    damage_cover(px_to_cell(x), px_to_cell(y), 1);
    instance_destroy();
    exit;
}
if (life > 2400) instance_destroy();
