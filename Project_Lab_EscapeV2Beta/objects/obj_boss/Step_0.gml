var ts = global.time_scale;
if (shake > 0) shake--;
if (flash > 0) flash--;

var alive_nodes = instance_number(obj_power_node);

if (state == "intro") {
    intro_timer--;
    if (intro_timer <= 0) state = "fight";
    exit;
}

if (state == "fight") {
    // a power line was cut
    if (alive_nodes < prev_alive) {
        prev_alive = alive_nodes;
        phase      = nodes_total - alive_nodes;
        shake      = 24;
        flash      = 14;
        global.score += 100 * tier;
        with (obj_bullet_enemy) instance_destroy();   // the surge wipes the screen
        pattern     = "";
        ghosts      = [];
        beams       = [];
        wind_t      = 0;
        stream_t    = 0;
        attack_cd   = 100;
        mode        = "hunt";
        goto_x      = x;
        goto_y      = y;
        stride_t    = 0;
        fx_explode(x + random_range(-90, 90), y + random_range(-40, 40), 1.2);
    }
    if (alive_nodes <= 0) {
        state  = "down";
        down_t = 0;
        shake  = 40;
        ghosts = [];
        beams  = [];
        with (obj_bullet_enemy) instance_destroy();
        // the minions lose power with it
        with (obj_enemy_parent) {
            if (object_index != obj_power_node && object_index != obj_generator) { fx_explode(x, y, 0.5); instance_destroy(); }
        }
        exit;
    }

    rage = (alive_nodes == 1 && nodes_total >= 2);
    var have_player = (instance_exists(obj_player) && obj_player.alive);

    // ---- glide toward the current target point, wrecking any cover underneath ----
    if (ts > 0 && point_distance(x, y, goto_x, goto_y) > 0.5) {
        var gd  = point_distance(x, y, goto_x, goto_y);
        var gs  = min(gd, goto_spd * ts);
        var ga  = point_direction(x, y, goto_x, goto_y);
        x += lengthdir_x(gs, ga);
        y += lengthdir_y(gs, ga);
        smash_cover(x - hit_w, y - hit_h, x + hit_w, y + hit_h);
    }
    var arrived = (point_distance(x, y, goto_x, goto_y) <= 0.5);

    // being touched by the armour hurts
    if (have_player && obj_player.invincible_timer <= 0
        && abs(obj_player.x - x) < hit_w + 10 && abs(obj_player.y - y) < hit_h + 10) hurt_player(1);

    // ---- hunting: every 3 player steps it strides 3 tiles toward the rabbit ----
    switch (mode) {

        case "hunt":
            if (have_player) {
                stride_t += ts;
                if (stride_t >= (rage ? 15 : 21) && arrived) {
                    stride_t = 0;
                    var sdx  = obj_player.x - x;
                    var sdy  = obj_player.y - y;
                    var horiz = (abs(sdx) >= abs(sdy));
                    var gap  = (horiz ? hit_w : hit_h) + 40;
                    var slen = min(3 * TILE, abs(horiz ? sdx : sdy) - gap);
                    if (slen > 8) {
                        if (horiz) goto_x = clamp(x + sign(sdx) * slen, hit_w + TILE, global.arena_w - hit_w - TILE);
                        else       goto_y = clamp(y + sign(sdy) * slen, hit_h + TILE, global.arena_h - hit_h - TILE);
                        goto_spd = 3 * TILE / 10;
                    }
                }
            }
            break;

        case "claw_wind":
            mode_t -= ts;
            if (mode_t <= 0) {
                mode   = "claw_hit";
                mode_t = 14;
                shake  = 10;
                smash_cover(claw_r[0], claw_r[1], claw_r[2], claw_r[3]);
            }
            break;

        case "claw_hit":
            mode_t -= ts;
            if (have_player && obj_player.invincible_timer <= 0
                && obj_player.x > claw_r[0] - 12 && obj_player.x < claw_r[2] + 12
                && obj_player.y > claw_r[1] - 12 && obj_player.y < claw_r[3] + 12) hurt_player(1);
            if (mode_t <= 0) {
                claw_n--;
                if (claw_n > 0 && have_player) aim_claw(rage ? 28 : 36);       // a second swipe, re-aimed
                else { mode = "hunt"; stride_t = 0; end_pattern(rage ? 40 : 70); }
            }
            break;

        case "charge_align":                 // slide onto the rabbit's row or column
            if (arrived && have_player) {
                if (charge_h) {
                    charge_dir = (obj_player.x > x) ? 0 : 180;
                    charge_tx  = (charge_dir == 0) ? global.arena_w - hit_w - TILE : hit_w + TILE;
                    charge_ty  = y;
                } else {
                    charge_dir = (obj_player.y > y) ? 270 : 90;
                    charge_tx  = x;
                    charge_ty  = (charge_dir == 270) ? global.arena_h - hit_h - TILE : hit_h + TILE;
                }
                mode     = "charge_wind";
                mode_t   = rage ? 40 : 55;
                mode_max = mode_t;
            } else if (!have_player) { mode = "hunt"; end_pattern(60); }
            break;

        case "charge_wind":
            mode_t -= ts;
            if (mode_t <= 0) { mode = "charge_dash"; goto_x = charge_tx; goto_y = charge_ty; goto_spd = 22; }
            break;

        case "charge_dash":
            if (arrived) { mode = "charge_rest"; mode_t = 55; shake = 24; }
            break;

        case "charge_rest":
            mode_t -= ts;
            if (mode_t <= 0) { mode = "hunt"; stride_t = 0; end_pattern(rage ? 40 : 70); }
            break;
    }

    // ---- laser beams tick and burn (they pass through walls) ----
    for (var i = array_length(beams) - 1; i >= 0; i--) {
        var bm = beams[i];
        bm.t += ts;
        if (bm.t >= bm.warn && bm.t < bm.warn + bm.live && have_player && obj_player.invincible_timer <= 0) {
            var hit = false;
            if (bm.v) hit = (abs(obj_player.x - bm.px) < bm.w / 2 + 4 && obj_player.y > bm.py && obj_player.y < bm.py + bm.len);
            else      hit = (abs(obj_player.y - bm.py) < bm.w / 2 + 4 && obj_player.x > bm.px && obj_player.x < bm.px + bm.len);
            if (hit) hurt_player(1);
        }
        if (bm.t >= bm.warn + bm.live) array_delete(beams, i, 1);
    }

    // ---- attack flow (claw and charge run their own state machine above) ----
    attack_cd -= ts;
    var cd = max(26, 80 - 8 * phase - 10 * (tier - 1)) * (rage ? 0.7 : 1);
    var special = (pattern == "claw" || pattern == "charge");

    if (pattern == "") {
        if (attack_cd <= 0 && mode == "hunt" && have_player) choose_pattern();
    }
    else if (special) {
        // nothing here: see the mode states
    }
    else if (stream_t > 0) {
        stream_t    -= ts;
        stream_next -= ts;
        if (stream_next <= 0) {
            stream_next = 8;
            var gw  = GRID_W;
            var col = clamp(round(gw / 2 + sin((200 - stream_t) * 0.045) * (gw / 2 - 4)), 2, gw - 3);
            fire(cell_to_px(col), cell_to_px(1), 270, 2.4, make_color_rgb(110, 255, 130));
            if (tier >= 2) fire(cell_to_px(clamp(gw - 1 - col, 2, gw - 3)), cell_to_px(1), 270, 2.4, make_color_rgb(110, 255, 130));
        }
        if (stream_t <= 0) volley_wait = 20;
    }
    else if (wind_t > 0) {
        wind_t -= ts;                    // the ghost shapes are showing: bullets appear when this runs out
        if (wind_t <= 0) { release_ghosts(); volley_wait = 38; }
    }
    else {
        volley_wait -= ts;
        if (volley_wait <= 0) {
            if (volleys_left <= 0) end_pattern(cd);
            else { volleys_left--; do_volley(); }
        }
    }
}
else if (state == "down") {
    // powered down: chain explosions, then the way out opens
    down_t++;
    if (down_t mod 10 == 0) fx_explode(x + random_range(-130, 130), y + random_range(-55, 55), random_range(0.7, 1.5));
    if (down_t >= 190) {
        fx_explode(x, y, 3);
        global.score += 500 * tier;
        state = "dead";
    }
}
