bob += 4;
if (!ready) {
    respawn_t -= global.time_scale;
    if (respawn_t <= 0) { ready = true; fx_explode(x, y, 0.25); }
    exit;
}
if (instance_exists(obj_player) && obj_player.alive
    && point_distance(x, y, obj_player.x, obj_player.y) < 30 && global.player_hp < global.player_max_hp) {
    global.player_hp = min(global.player_max_hp, global.player_hp + 1 + aug_n("s_medic"));
    if (one_shot) { instance_destroy(); exit; }
    ready     = false;
    respawn_t = respawn_time * (1 - 0.3 * aug_n("s_medic"));
    if (instance_exists(obj_hud)) obj_hud.heal_flash = 20;
}
