x += lengthdir_x(bspd * global.time_scale, bdir);
y += lengthdir_y(bspd * global.time_scale, bdir);

if (instance_exists(obj_player) && obj_player.alive
    && obj_player.invincible_timer <= 0
    && point_distance(x, y, obj_player.x, obj_player.y) < 14) {
    global.player_hp--;
    obj_player.invincible_timer = obj_player.invincible_max;
    if (instance_exists(obj_hud)) obj_hud.flash_timer = 22;
    if (global.player_hp <= 0) obj_player.alive = false;
    instance_destroy();
    exit;
}

if (x < -20 || x > room_width + 20 || y < -20 || y > room_height + 20)
    instance_destroy();
