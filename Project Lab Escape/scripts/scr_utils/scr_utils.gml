function get_wave_enemies(fl, wv) {
    var total    = 3 + fl * 2 + wv;
    var shooters = clamp(fl + wv - 2, 0, floor(total * 0.45));
    return { total: total, chasers: total - shooters, shooters: shooters };
}

function pick_upgrades() {
    var pool = ["speed","fire_rate","damage","max_hp","bullet_speed","pierce"];
    if (global.player_hp < global.player_max_hp) array_push(pool, "heal");
    for (var i = array_length(pool) - 1; i > 0; i--) {
        var j   = irandom(i);
        var tmp = pool[i]; pool[i] = pool[j]; pool[j] = tmp;
    }
    return [pool[0], pool[1], pool[2]];
}

function apply_upgrade(type) {
    switch (type) {
        case "speed":        global.player_speed       += 0.5; break;
        case "fire_rate":    global.player_fire_rate    = max(6, global.player_fire_rate - 4); break;
        case "damage":       global.player_damage++;            break;
        case "max_hp":       global.player_max_hp++;
                             global.player_hp = min(global.player_hp + 1, global.player_max_hp); break;
        case "heal":         global.player_hp = min(global.player_hp + 2, global.player_max_hp); break;
        case "bullet_speed": global.player_bullet_speed += 2;  break;
        case "pierce":       global.player_pierce++;            break;
    }
}

function upgrade_name(type) {
    switch (type) {
        case "speed":        return "SPEED BOOST";
        case "fire_rate":    return "RAPID FIRE";
        case "damage":       return "POWER UP";
        case "max_hp":       return "HP UP";
        case "heal":         return "EMERGENCY HEAL";
        case "bullet_speed": return "SWIFT BULLETS";
        case "pierce":       return "PIERCING SHOT";
        default:             return string(type);
    }
}

function upgrade_desc(type) {
    switch (type) {
        case "speed":        return "+0.5 movement speed";
        case "fire_rate":    return "Shoot 4 frames faster per shot";
        case "damage":       return "+1 damage per bullet";
        case "max_hp":       return "+1 Max HP  +  restore 1 HP";
        case "heal":         return "Restore 2 HP immediately";
        case "bullet_speed": return "+2 bullet travel speed";
        case "pierce":       return "Bullets pierce 1 extra enemy";
        default:             return "";
    }
}
