
if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;

var dir = point_direction(x, y, obj_player.x, obj_player.y);
x += lengthdir_x(spd * global.time_scale, dir);
y += lengthdir_y(spd * global.time_scale, dir);

if (point_distance(x, y, obj_player.x, obj_player.y) < 24
    && obj_player.invincible_timer <= 0 && obj_player.alive) {
    global.player_hp--;
    obj_player.invincible_timer = obj_player.invincible_max;
    if (instance_exists(obj_hud)) obj_hud.flash_timer = 22;
    if (global.player_hp <= 0) { obj_player.alive = false; }
}
