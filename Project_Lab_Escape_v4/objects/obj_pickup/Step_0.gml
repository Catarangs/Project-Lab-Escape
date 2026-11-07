glow_t++;

if (instance_exists(obj_player) && obj_player.alive && point_distance(x, y, obj_player.x, obj_player.y) < 26) {
    global.score += 50;
    fx_explode(x, y, 0.45);
    instance_destroy();
}
