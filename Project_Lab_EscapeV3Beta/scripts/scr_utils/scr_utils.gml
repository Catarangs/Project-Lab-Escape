#macro TILE   48
#macro SLOW_TS 0.18
#macro COVER_HP 5
#macro GRID_W global.grid_w
#macro GRID_H global.grid_h

#macro FIXED_LAYOUTS true

function floor_room(f) {
    switch (f) {
        case 1:  return room_floor1;
        case 2:  return room_floor2;
        case 3:  return room_floor3;
        case 4:  return room_floor4;
        case 5:  return room_floor5;
        case 6:  return room_floor6;
        case 7:  return room_floor7;
        case 8:  return room_floor8;
        default: return room_floor9;
    }
}

function cell_to_px(c) { return c * TILE + TILE / 2; }
function px_to_cell(p) { return floor(p / TILE); }

function snap_dir(a) {
    return ((round(a / 90) mod 4) + 4) mod 4 * 90;
}

function floor_info(f) {
    switch (f) {
        case 1: return { name: "CELL BLOCK",    theme: 0, boss: false, tier: 0, layout: 0, w: 36, h: 27, view_w: 640 };
        case 2: return { name: "RESEARCH WING", theme: 1, boss: false, tier: 0, layout: 1, w: 40, h: 30, view_w: 640 };
        case 3: return { name: "SENTINEL BAY",  theme: 2, boss: true,  tier: 1, layout: 3, w: 30, h: 24, view_w: 960 };
        case 4: return { name: "REACTOR CORE",  theme: 3, boss: false, tier: 0, layout: 2, w: 44, h: 32, view_w: 640 };
        case 5: return { name: "SERVER VAULT",  theme: 4, boss: false, tier: 0, layout: 1, w: 48, h: 34, view_w: 640 };
        case 6: return { name: "WARDEN-9",      theme: 5, boss: true,  tier: 2, layout: 4, w: 34, h: 26, view_w: 960 };
        case 7: return { name: "FROZEN ANNEX",  theme: 6, boss: false, tier: 0, layout: 1, w: 42, h: 30, view_w: 640 };
        case 8: return { name: "DEMOLITION YARD", theme: 7, boss: false, tier: 0, layout: 1, w: 46, h: 32, view_w: 640 };
        default: return { name: "OMEGA-0",       theme: 8, boss: true,  tier: 3, layout: 5, w: 38, h: 28, view_w: 960 };
    }
}

function floor_objectives(f) {
    switch (f) {
        case 1: return [ { kind: "collect", label: "KEYCARDS",      goal: 3,    done: 0, item: "keycard" } ];
        case 2: return [ { kind: "destroy", label: "GENERATORS",    goal: 3,    done: 0, item: "" } ];
        case 4: return [ { kind: "survive", label: "MELTDOWN",      goal: 3600, done: 0, item: "" },
                         { kind: "collect", label: "COOLANT CELLS", goal: 2,    done: 0, item: "cell" } ];
        case 5: return [ { kind: "collect", label: "DATA CHIPS",    goal: 4,    done: 0, item: "chip" },
                         { kind: "destroy", label: "SERVERS",       goal: 2,    done: 0, item: "" } ];
        case 7: return [ { kind: "collect", label: "HEAT CELLS",    goal: 4,    done: 0, item: "cell" } ];
        case 8: return [ { kind: "destroy", label: "DETONATORS",    goal: 4,    done: 0, item: "" },
                         { kind: "survive", label: "HOLD THE YARD", goal: 1800, done: 0, item: "" } ];
        default: return [];
    }
}

function theme_info(t) {
    switch (t) {
        case 0: return { ff: 0, wf: 0, fc: c_white, wc: c_white };
        case 1: return { ff: 1, wf: 3, fc: c_white, wc: c_white };
        case 2: return { ff: 2, wf: 1, fc: c_white, wc: c_white };
        case 3: return { ff: 2, wf: 3, fc: make_color_rgb(255,170,150), wc: make_color_rgb(255,150,130) };
        case 4: return { ff: 0, wf: 1, fc: make_color_rgb(150,255,215), wc: make_color_rgb(170,255,225) };
        case 5: return { ff: 1, wf: 3, fc: make_color_rgb(255,190,190), wc: make_color_rgb(255,170,170) };
        case 6: return { ff: 0, wf: 1, fc: make_color_rgb(190,225,255), wc: make_color_rgb(170,210,255) };
        case 7: return { ff: 2, wf: 3, fc: make_color_rgb(255,225,160), wc: make_color_rgb(255,215,150) };
        default: return { ff: 1, wf: 1, fc: make_color_rgb(215,170,255), wc: make_color_rgb(220,150,255) };
    }
}

function boss_node_cells(tier) {
    var w = GRID_W;
    var h = GRID_H;
    if (tier <= 1) return [[1, 13], [w - 2, 13]];
    if (tier == 2) return [[1, 8], [w - 2, 8], [1, 17], [w - 2, 17]];
    return [[1, 7], [w - 2, 7], [1, 13], [w - 2, 13], [1, 19], [w - 2, 19]];
}

function arena_rect(cx, cy, cw, ch) {
    var x1 = clamp(cx, 0, GRID_W - 1);
    var y1 = clamp(cy, 0, GRID_H - 1);
    var x2 = clamp(cx + cw - 1, 0, GRID_W - 1);
    var y2 = clamp(cy + ch - 1, 0, GRID_H - 1);
    ds_grid_set_region(global.wall_grid, x1, y1, x2, y2, 1);
}

function arena_clear(cx, cy, cw, ch) {
    var x1 = clamp(cx, 1, GRID_W - 2);
    var y1 = clamp(cy, 1, GRID_H - 2);
    var x2 = clamp(cx + cw - 1, 1, GRID_W - 2);
    var y2 = clamp(cy + ch - 1, 1, GRID_H - 2);
    ds_grid_set_region(global.wall_grid, x1, y1, x2, y2, 0);
}

function fill_arena(info) {
    var w = GRID_W;
    var h = GRID_H;
    ds_grid_clear(global.wall_grid, 0);

    switch (info.layout) {
        case 0:
            var count = (w * h) div 38;
            for (var i = 0; i < count; i++) {
                var bw = choose(2, 3, 4, 5);
                var bh = choose(1, 2);
                arena_rect(irandom_range(3, w - bw - 3), irandom_range(3, h - bh - 3), bw, bh);
            }
            break;

        case 1:
            for (var px = 4; px < w - 5; px += 6) {
                for (var py = 4; py < h - 5; py += 5) {
                    if (irandom(3) != 0) arena_rect(px, py, 2, 2);
                }
            }
            break;

        case 2:
            var dividers = [w div 3, (w * 2) div 3];
            for (var i = 0; i < 2; i++) {
                arena_rect(dividers[i], 1, 1, h - 2);
                arena_clear(dividers[i], irandom_range(3, 7), 1, 4);
                arena_clear(dividers[i], irandom_range(12, h - 9), 1, 4);
                arena_clear(dividers[i], h - 7, 1, 4);
            }
            arena_rect(1, h div 2, w - 2, 1);
            arena_clear(irandom_range(3, w div 3 - 4), h div 2, 4, 1);
            arena_clear(irandom_range(w div 3 + 3, (w * 2) div 3 - 4), h div 2, 4, 1);
            arena_clear(irandom_range((w * 2) div 3 + 3, w - 8), h div 2, 4, 1);
            for (var i = 0; i < 8; i++) {
                arena_rect(irandom_range(3, w - 7), irandom_range(3, h - 5), choose(2, 3), 1);
            }
            break;

        case 3:
            arena_rect(5, 7, 3, 2);      arena_rect(w - 8, 7, 3, 2);
            arena_rect(w div 2 - 2, 10, 4, 2);
            arena_rect(5, 16, 3, 2);     arena_rect(w - 8, 16, 3, 2);
            arena_rect(w div 2 - 2, 15, 4, 1);
            break;

        default:
            arena_rect(6, 6, 3, 2);      arena_rect(w - 9, 6, 3, 2);
            arena_rect(w div 2 - 6, 12, 3, 2);  arena_rect(w div 2 + 3, 12, 3, 2);
            arena_rect(6, 21, 3, 2);     arena_rect(w - 9, 21, 3, 2);
            break;
    }

    arena_rect(0, 0, w, 1);
    arena_rect(0, h - 1, w, 1);
    arena_rect(0, 0, 1, h);
    arena_rect(w - 1, 0, 1, h);

    var sx = global.spawn_cx;
    var sy = global.spawn_cy;
    arena_clear(sx - 2, sy - 2, 5, 5);
    arena_clear(w div 2 - 1, sy, 3, h - 1 - sy);

    if (info.boss) {
        var nodes = boss_node_cells(info.tier);
        for (var i = 0; i < array_length(nodes); i++) {
            arena_clear(1, nodes[i][1] - 1, 3, 3);
            arena_clear(1, nodes[i][1], w - 2, 1);
        }
    }
}

function arena_flood(sx, sy) {
    var w = GRID_W;
    var h = GRID_H;
    var seen  = ds_grid_create(w, h);
    var queue = ds_queue_create();
    var cells = [];
    var step_x = [1, -1, 0, 0];
    var step_y = [0, 0, 1, -1];
    ds_grid_clear(seen, 0);
    seen[# sx, sy] = 1;
    ds_queue_enqueue(queue, sx + sy * w);
    while (!ds_queue_empty(queue)) {
        var idx = ds_queue_dequeue(queue);
        var cx = idx mod w;
        var cy = idx div w;
        array_push(cells, idx);
        for (var d = 0; d < 4; d++) {
            var nx = cx + step_x[d];
            var ny = cy + step_y[d];
            if (cell_is_wall(nx, ny)) continue;
            if (seen[# nx, ny] == 1) continue;
            seen[# nx, ny] = 1;
            ds_queue_enqueue(queue, nx + ny * w);
        }
    }
    ds_grid_destroy(seen);
    ds_queue_destroy(queue);
    return cells;
}

function build_arena(floor_n) {
    if (variable_global_exists("wall_grid") && ds_exists(global.wall_grid, ds_type_grid))
        ds_grid_destroy(global.wall_grid);
    if (variable_global_exists("cover_hp") && ds_exists(global.cover_hp, ds_type_grid))
        ds_grid_destroy(global.cover_hp);
    if (variable_global_exists("nav_grid") && global.nav_grid != -1)
        mp_grid_destroy(global.nav_grid);
    if (!variable_global_exists("nav_path") || !path_exists(global.nav_path))
        global.nav_path = path_add();

    if (FIXED_LAYOUTS) random_set_seed(7000 + floor_n * 131);
    var info = floor_info(floor_n);
    global.grid_w   = info.w;
    global.grid_h   = info.h;
    global.arena_w  = info.w * TILE;
    global.arena_h  = info.h * TILE;
    global.view_w   = info.view_w;
    global.view_h   = info.view_w * 0.75;
    global.spawn_cx = info.w div 2;
    global.spawn_cy = info.boss ? info.h - 4 : info.h div 2;

    global.wall_grid = ds_grid_create(info.w, info.h);

    global.authored_layout = (instance_number(obj_wall) > 0);
    if (global.authored_layout) load_layout(info);
    else                        fill_arena(info);
    mark_props();

    var reached = arena_flood(global.spawn_cx, global.spawn_cy);
    var keep = ds_grid_create(info.w, info.h);
    ds_grid_clear(keep, 0);
    for (var i = 0; i < array_length(reached); i++) {
        keep[# reached[i] mod info.w, reached[i] div info.w] = 1;
    }
    for (var cx = 0; cx < info.w; cx++) {
        for (var cy = 0; cy < info.h; cy++) {
            if (keep[# cx, cy] == 0) global.wall_grid[# cx, cy] = 1;
        }
    }
    ds_grid_destroy(keep);
    global.open_cells = reached;
    make_cover(info);
    if (global.authored_layout) load_zones(info);
    else                        fill_zones(info, floor_n);

    global.nav_grid = mp_grid_create(0, 0, info.w, info.h, TILE, TILE);
    for (var cx = 0; cx < info.w; cx++) {
        for (var cy = 0; cy < info.h; cy++) {
            if (global.wall_grid[# cx, cy] >= 1) mp_grid_add_cell(global.nav_grid, cx, cy);
        }
    }

    with (obj_wall) instance_destroy();
    with (obj_zone) instance_destroy();
    randomize();
}

function cell_is_wall(cx, cy) {
    if (cx < 0 || cy < 0 || cx >= GRID_W || cy >= GRID_H) return true;
    return global.wall_grid[# cx, cy] >= 1;
}
function wall_at(px, py) { return cell_is_wall(px_to_cell(px), px_to_cell(py)); }

function line_clear(x1, y1, x2, y2) {
    var d  = point_distance(x1, y1, x2, y2);
    var a  = point_direction(x1, y1, x2, y2);
    var steps = max(1, ceil(d / 12));
    for (var o = -10; o <= 10; o += 10) {
        var ox = lengthdir_x(o, a + 90);
        var oy = lengthdir_y(o, a + 90);
        for (var i = 1; i <= steps; i++) {
            var t = i / steps;
            if (wall_at(lerp(x1, x2, t) + ox, lerp(y1, y2, t) + oy)) return false;
        }
    }
    return true;
}

function nav_next_point(tx, ty) {
    if (mp_grid_path(global.nav_grid, global.nav_path, x, y, tx, ty, false)
        && path_get_number(global.nav_path) > 1) {
        return [path_get_point_x(global.nav_path, 1), path_get_point_y(global.nav_path, 1)];
    }
    return undefined;
}

function random_spawn_point(min_dist) {
    var count = array_length(global.open_cells);
    var spot = [cell_to_px(GRID_W div 2), cell_to_px(GRID_H div 2)];
    for (var i = 0; i < 80; i++) {
        var idx = global.open_cells[irandom(count - 1)];
        spot = [cell_to_px(idx mod GRID_W), cell_to_px(idx div GRID_W)];
        if (!instance_exists(obj_player)) break;
        if (point_distance(spot[0], spot[1], obj_player.x, obj_player.y) >= min_dist) break;
    }
    return spot;
}

function pick_enemy_type() {
    var f = global.floor_num;
    var w;
    if (f <= 1)      w = [5, 2, 1, 1, 0];
    else if (f == 2) w = [4, 2, 2, 2, 1];
    else if (f <= 4) w = [4, 1, 2, 2, 2];
    else             w = [3, 1, 2, 2, 3];
    var names = ["shooter", "chaser", "turret", "dasher", "sniper", "bomber"];
    if (f == 7) w = [3, 1, 2, 2, 3];
    if (f == 7) array_push(w, 1);
    else if (f == 8) { w = [3, 2, 1, 2, 2]; array_push(w, 5); }
    else if (f >= 9) { w = [3, 1, 2, 2, 3]; array_push(w, 2); }
    else array_push(w, 0);
    if (instance_number(obj_enemy_turret) >= 2 + f div 2) w[2] = 0;
    var total = 0;
    for (var i = 0; i < 6; i++) total += w[i];
    var r = random(total);
    for (var i = 0; i < 6; i++) {
        if (r < w[i]) return names[i];
        r -= w[i];
    }
    return "shooter";
}

function mob_object(t) {
    switch (t) {
        case "chaser": return obj_enemy_chaser;
        case "turret": return obj_enemy_turret;
        case "dasher": return obj_enemy_dasher;
        case "sniper": return obj_enemy_sniper;
        case "bomber": return obj_enemy_bomber;
        default:       return obj_enemy_shooter;
    }
}

function spawn_mob(t, px, py) {

    for (var tries = 0; tries < 16 && !spot_free(px, py, 16, noone); tries++) {
        var sp = random_spawn_point(300);
        px = sp[0];
        py = sp[1];
    }
    var m = instance_create_layer(px, py, "Instances", mob_object(t));
    fx_explode(px, py, 0.4);
    return m;
}

function mob_count() {
    return instance_number(obj_enemy_parent) - instance_number(obj_generator) - instance_number(obj_power_node)
         - instance_number(obj_barrel) - instance_number(obj_crate);
}

function ray_length(px, py, dir, maxlen) {
    var l = 0;
    while (l < maxlen) {
        if (wall_at(px + lengthdir_x(l, dir), py + lengthdir_y(l, dir))) break;
        l += 12;
    }
    return min(l, maxlen);
}

function hurt_player(n) {
    if (!instance_exists(obj_player) || !obj_player.alive) return;
    if (variable_global_exists("dev_god") && global.dev_god) return;
    if (global.shield_hits > 0) {
        global.shield_hits--;
        obj_player.invincible_timer = obj_player.invincible_max;
        if (instance_exists(obj_hud)) obj_hud.heal_flash = 20;
        fx_explode(obj_player.x, obj_player.y, 0.5);
        return;
    }
    global.player_hp -= n;
    obj_player.invincible_timer = obj_player.invincible_max;
    if (instance_exists(obj_hud)) obj_hud.flash_timer = 22;
    var th = aug_n("g_thorns");
    if (th > 0 && global.player_hp > 0) {
        fx_explode(obj_player.x, obj_player.y, 1.0);
        var victims = [];
        var px0 = obj_player.x;
        var py0 = obj_player.y;
        with (obj_enemy_parent) {
            if (!dying && !is_machine(object_index) && point_distance(x, y, px0, py0) < 3 * TILE) array_push(victims, id);
        }
        for (var i = 0; i < array_length(victims); i++) {
            if (instance_exists(victims[i])) damage_enemy(victims[i], 2 + th);
        }
    }
    if (global.player_hp <= 0) {
        if (aug_has("p_wind") && !global.wind_used) {
            global.wind_used = true;
            global.player_hp = max(1, ceil(global.player_max_hp / 2));
            fx_explode(obj_player.x, obj_player.y, 2.0);
            var px1 = obj_player.x;
            var py1 = obj_player.y;
            var vic2 = [];
            with (obj_enemy_parent) {
                if (!dying && !is_machine(object_index) && point_distance(x, y, px1, py1) < 5 * TILE) array_push(vic2, id);
            }
            for (var i = 0; i < array_length(vic2); i++) {
                if (instance_exists(vic2[i])) damage_enemy(vic2[i], 6);
            }
            obj_player.invincible_timer = 150;
        } else {
            obj_player.alive = false;
        }
    }
}

function in_view(px, py, margin) {
    var cam = view_camera[0];
    var vx  = camera_get_view_x(cam);
    var vy  = camera_get_view_y(cam);
    return (px > vx - margin && px < vx + camera_get_view_width(cam) + margin
         && py > vy - margin && py < vy + camera_get_view_height(cam) + margin);
}

function item_cell_ok(cx, cy) {
    for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) {
            if (cell_is_wall(cx + dx, cy + dy)) return false;
            if (zone_at_cell(cx + dx, cy + dy) != ZONE_NONE) return false;
        }
    }
    return true;
}

function random_item_spot(min_player, used) {
    var count = array_length(global.open_cells);
    var spot  = [cell_to_px(GRID_W div 2), cell_to_px(GRID_H div 2)];
    var found = false;
    for (var i = 0; i < 400 && !found; i++) {
        var idx = global.open_cells[irandom(count - 1)];
        var cx  = idx mod GRID_W;
        var cy  = idx div GRID_W;
        if (!item_cell_ok(cx, cy)) continue;
        var sp = [cell_to_px(cx), cell_to_px(cy)];
        var ok = true;
        if (instance_exists(obj_player) && point_distance(sp[0], sp[1], obj_player.x, obj_player.y) < min_player) ok = false;
        if (cy >= GRID_H - 4 && abs(cx - GRID_W div 2) <= 3) ok = false;
        for (var j = 0; j < array_length(used); j++) {
            if (point_distance(sp[0], sp[1], used[j][0], used[j][1]) < 260) ok = false;
        }
        if (ok) { spot = sp; found = true; }
    }
    return spot;
}

function snap_item_clear() {
    var cx = clamp(px_to_cell(x), 1, GRID_W - 2);
    var cy = clamp(px_to_cell(y), 1, GRID_H - 2);
    if (item_cell_ok(cx, cy)) { x = cell_to_px(cx); y = cell_to_px(cy); return; }
    for (var r = 1; r <= 12; r++) {
        for (var dx = -r; dx <= r; dx++) {
            for (var dy = -r; dy <= r; dy++) {
                if (max(abs(dx), abs(dy)) != r) continue;
                if (item_cell_ok(cx + dx, cy + dy)) { x = cell_to_px(cx + dx); y = cell_to_px(cy + dy); return; }
            }
        }
    }
}

function draw_pointer(wx, wy) {
    if (!instance_exists(obj_player)) return;
    var cam = view_camera[0];
    var vx  = camera_get_view_x(cam);
    var vy  = camera_get_view_y(cam);
    var vw  = camera_get_view_width(cam);
    var vh  = camera_get_view_height(cam);
    if (wx > vx + 24 && wx < vx + vw - 24 && wy > vy + 24 && wy < vy + vh - 24) return;
    var k = display_get_gui_width() / vw;
    var d = point_direction(obj_player.x, obj_player.y, wx, wy);
    var ax = (obj_player.x - vx) * k + lengthdir_x(84, d);
    var ay = (obj_player.y - vy) * k + lengthdir_y(84, d);
    draw_sprite_ext(spr_ui_arrow, 0, ax, ay, 2, 2, d, c_white, 0.8 + 0.2 * sin(current_time / 150));
}

function fx_explode(px, py, sc) {
    var f = instance_create_layer(px, py, "Instances", obj_fx_explosion);
    f.sc = sc;
    return f;
}

function dir_from_angle(a) {
    a = ((a mod 360) + 360) mod 360;
    if (a >= 45  && a < 135) return 3;
    if (a >= 135 && a < 225) return 1;
    if (a >= 225 && a < 315) return 2;
    return 0;
}

function draw_humanoid(px, py, dir, moving, anim, set, flash, alpha) {
    var sc = 2;
    var k  = (dir == 2) ? 0 : ((dir == 3) ? 2 : 1);
    var xs = (dir == 1) ? -sc : sc;
    var spr = set[(moving ? 3 : 0) + k];
    var idx = floor(anim) mod sprite_get_number(spr);
    draw_sprite_ext(spr_shadow, 0, px, py + 10, sc, sc, 0, c_white, 0.5 * alpha);
    if (flash) gpu_set_fog(true, c_white, 0, 1);
    draw_sprite_ext(spr, idx, px, py, xs, sc, 0, c_white, alpha);
    if (flash) gpu_set_fog(false, c_white, 0, 1);
    return idx;
}

function draw_bunny_ears(ox, oy, dir, top, a, sc) {
    var out = make_color_rgb(62, 40, 70);
    var wh  = make_color_rgb(245, 238, 245);
    var pk  = make_color_rgb(235, 150, 175);
    var xs;
    if (dir >= 2)       xs = [11, 18];
    else if (dir == 0)  xs = [11, 14];
    else                xs = [18, 15];
    draw_set_alpha(a);
    for (var i = 0; i < 2; i++) {
        var ex = xs[i];
        draw_set_color(out);
        draw_rectangle(ox + (ex - 1 - 16) * sc, oy + (top - 8 - 16) * sc, ox + (ex + 4 - 16) * sc - 1, oy + (top + 1 - 16) * sc - 1, false);
        draw_set_color(wh);
        draw_rectangle(ox + (ex - 16) * sc,     oy + (top - 7 - 16) * sc, ox + (ex + 3 - 16) * sc - 1, oy + (top + 1 - 16) * sc - 1, false);
        draw_set_color(pk);
        draw_rectangle(ox + (ex + 1 - 16) * sc, oy + (top - 5 - 16) * sc, ox + (ex + 2 - 16) * sc - 1, oy + (top - 1 - 16) * sc - 1, false);
    }
    draw_set_color(c_white);
    draw_set_alpha(1);
}

function draw_cable(x1, y1, x2, y2, t) {
    var n = 18;
    var d = point_direction(x1, y1, x2, y2);
    var lx = x1, ly = y1;
    for (var i = 1; i <= n; i++) {
        var f   = i / n;
        var amp = (i < n) ? 5 * sin(f * pi) : 0;
        var off = amp * sin(t * 0.25 + i * 1.9);
        var nx  = lerp(x1, x2, f) + lengthdir_x(off, d + 90);
        var ny  = lerp(y1, y2, f) + lengthdir_y(off, d + 90);
        draw_set_color(c_black);
        draw_line_width(lx, ly, nx, ny, 7);
        draw_set_color(make_color_rgb(255, 190, 50));
        draw_line_width(lx, ly, nx, ny, 3);

        var pulse = frac(t * 0.02 - f);
        if (pulse < 0.12) {
            draw_set_color(make_color_rgb(255, 255, 200));
            draw_line_width(lx, ly, nx, ny, 3);
        }
        lx = nx; ly = ny;
    }
    draw_set_color(c_white);
}

function update_camera(snap) {
    var cam = view_camera[0];
    var vw  = global.view_w;
    var vh  = global.view_h;
    var tx  = global.arena_w / 2;
    var ty  = global.arena_h / 2;
    if (instance_exists(obj_player)) { tx = obj_player.x; ty = obj_player.y; }

    var cx = tx - vw / 2;
    var cy = ty - vh / 2;
    cx = (global.arena_w <= vw) ? (global.arena_w - vw) / 2 : clamp(cx, 0, global.arena_w - vw);
    cy = (global.arena_h <= vh) ? (global.arena_h - vh) / 2 : clamp(cy, 0, global.arena_h - vh);

    if (!snap) {
        cx = lerp(camera_get_view_x(cam), cx, 0.2);
        cy = lerp(camera_get_view_y(cam), cy, 0.2);
    }
    camera_set_view_size(cam, vw, vh);
    camera_set_view_pos(cam, round(cx), round(cy));
}

#macro ZONE_NONE   0
#macro ZONE_FIELD  1
#macro ZONE_SLOW   2
#macro ZONE_STASIS 3
#macro ZONE_GATE_A 4
#macro ZONE_GATE_B 5
#macro ZONE_ICE    6
#macro GATE_PERIOD 300

function gate_active(z) {
    var t = global.gate_t mod GATE_PERIOD;
    if (z == ZONE_GATE_A) return (t < 130);
    return (t >= 150 && t < 280);
}

function gate_warn(z) {
    var t = global.gate_t mod GATE_PERIOD;
    if (z == ZONE_GATE_A) return (t >= 270);
    return (t >= 120 && t < 150);
}
function is_gate(z) { return (z == ZONE_GATE_A || z == ZONE_GATE_B); }

function zone_at_cell(cx, cy) {
    if (cx < 0 || cy < 0 || cx >= GRID_W || cy >= GRID_H) return ZONE_NONE;
    return global.zone_grid[# cx, cy];
}
function zone_at(px, py) { return zone_at_cell(px_to_cell(px), px_to_cell(py)); }

function zone_cell_ok(cx, cy, info) {
    if (cell_is_wall(cx, cy)) return false;
    if (global.zone_grid[# cx, cy] != ZONE_NONE) return false;
    if (abs(cx - global.spawn_cx) <= 4 && abs(cy - global.spawn_cy) <= 4) return false;
    if (abs(cx - GRID_W div 2) <= 1 && cy >= global.spawn_cy) return false;
    if (info.boss) {
        if (cy < 6) return false;
        var nodes = boss_node_cells(info.tier);
        for (var i = 0; i < array_length(nodes); i++) {
            if (abs(cy - nodes[i][1]) <= 1) return false;
        }
    }
    return true;
}

function place_zone_patch(kind, pw, ph, info) {
    var needs_solid = (kind == ZONE_FIELD || is_gate(kind));
    for (var attempt = 0; attempt < 40; attempt++) {
        var idx = global.open_cells[irandom(array_length(global.open_cells) - 1)];
        var x0  = idx mod GRID_W;
        var y0  = idx div GRID_W;
        var ok  = true;
        for (var i = 0; i < pw && ok; i++) {
            for (var j = 0; j < ph && ok; j++) {
                if (!zone_cell_ok(x0 + i, y0 + j, info)) ok = false;
            }
        }
        if (!ok) continue;

        if (needs_solid) {
            var before = array_length(arena_flood(global.spawn_cx, global.spawn_cy));
            ds_grid_set_region(global.wall_grid, x0, y0, x0 + pw - 1, y0 + ph - 1, 2);
            var after = array_length(arena_flood(global.spawn_cx, global.spawn_cy));
            if (after != before - pw * ph) {
                ds_grid_set_region(global.wall_grid, x0, y0, x0 + pw - 1, y0 + ph - 1, 0);
                continue;
            }
            if (kind != ZONE_FIELD) ds_grid_set_region(global.wall_grid, x0, y0, x0 + pw - 1, y0 + ph - 1, 0);
        }
        ds_grid_set_region(global.zone_grid, x0, y0, x0 + pw - 1, y0 + ph - 1, kind);
        return true;
    }
    return false;
}

function fill_zones(info, floor_n) {
    if (variable_global_exists("zone_grid") && ds_exists(global.zone_grid, ds_type_grid))
        ds_grid_destroy(global.zone_grid);
    global.zone_grid = ds_grid_create(info.w, info.h);
    ds_grid_clear(global.zone_grid, ZONE_NONE);
    global.gate_t = 0;

    var area = array_length(global.open_cells);
    var k    = min(1, 0.6 + 0.1 * floor_n);
    var n_field  = round(area / 95  * k);
    var n_slow   = round(area / 110 * k);
    var n_stasis = round(area / 150 * k);
    var n_gate   = round(area / 190 * k);

    for (var i = 0; i < n_field; i++) {
        if (irandom(1) == 0) place_zone_patch(ZONE_FIELD, irandom_range(2, 4), 1, info);
        else                 place_zone_patch(ZONE_FIELD, 1, irandom_range(2, 4), info);
    }
    for (var i = 0; i < n_slow; i++)   place_zone_patch(ZONE_SLOW, irandom_range(3, 5), irandom_range(2, 4), info);
    for (var i = 0; i < n_stasis; i++) place_zone_patch(ZONE_STASIS, irandom_range(1, 2), irandom_range(1, 2), info);
    for (var i = 0; i < n_gate; i++) {
        var kind = (i mod 2 == 0) ? ZONE_GATE_A : ZONE_GATE_B;
        var len  = irandom_range(3, 5);
        if (irandom(1) == 0) place_zone_patch(kind, len, 1, info);
        else                 place_zone_patch(kind, 1, len, info);
    }

    global.open_cells = arena_flood(global.spawn_cx, global.spawn_cy);
}

function draw_zone_cell(cx, cy, z) {
    var x0 = cx * TILE;
    var y0 = cy * TILE;
    var t  = current_time;
    var x1 = x0 + TILE - 1;
    var y1 = y0 + TILE - 1;
    switch (z) {
        case ZONE_FIELD:
            draw_set_alpha(0.55);
            draw_set_color(make_color_rgb(40, 110, 230));
            draw_rectangle(x0 + 2, y0 + 2, x1 - 2, y1 - 2, false);
            draw_set_alpha(0.55);
            draw_set_color(make_color_rgb(170, 230, 255));
            var f_off = floor(t / 40 + cx * 3) mod 12;
            for (var i = 0; i < 4; i++) {
                var f_y = y0 + ((i * 12 + f_off) mod TILE);
                draw_line(x0 + 3, f_y, x1 - 3, f_y);
            }
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(190, 240, 255));
            draw_rectangle(x0 + 1, y0 + 1, x1 - 1, y1 - 1, true);
            draw_rectangle(x0 + 3, y0 + 3, x1 - 3, y1 - 3, true);
            break;

        case ZONE_SLOW:
            draw_set_alpha(0.62);
            draw_set_color(make_color_rgb(70, 150, 50));
            draw_rectangle(x0, y0, x1, y1, false);
            draw_set_alpha(0.5);
            draw_set_color(make_color_rgb(40, 100, 40));
            draw_circle(x0 + 14 + ((cx * 7) mod 10), y0 + 16 + ((cy * 5) mod 10), 11, false);
            draw_circle(x0 + 32 - ((cy * 3) mod 8), y0 + 30, 8, false);
            draw_set_alpha(0.85);
            draw_set_color(make_color_rgb(190, 255, 150));
            for (var i = 0; i < 3; i++) {
                var s_ph = frac(t / 1400 + i * 0.33 + (cx * 3 + cy * 5) * 0.07);
                var s_x  = x0 + 8 + ((cx * 13 + i * 17) mod 32);
                var s_y  = y0 + TILE - 6 - s_ph * 34;
                draw_circle(s_x, s_y, 1 + s_ph * 3, true);
            }
            draw_set_alpha(1);
            break;

        case ZONE_STASIS:
            draw_set_alpha(0.5);
            draw_set_color(make_color_rgb(110, 60, 190));
            draw_rectangle(x0 + 2, y0 + 2, x1 - 2, y1 - 2, false);
            draw_set_alpha(0.9);
            draw_set_color(make_color_rgb(225, 190, 255));
            draw_circle(x0 + TILE / 2, y0 + TILE / 2, 15 + 3 * sin(t / 220), true);
            draw_circle(x0 + TILE / 2, y0 + TILE / 2, 8 + 2 * sin(t / 220 + 2), true);
            draw_line(x0 + 8, y0 + 8, x1 - 8, y1 - 8);
            draw_line(x1 - 8, y0 + 8, x0 + 8, y1 - 8);
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(70, 30, 130));
            draw_rectangle(x0 + 2, y0 + 2, x1 - 2, y1 - 2, true);
            break;

        case ZONE_ICE:
            draw_set_alpha(0.5);
            draw_set_color(make_color_rgb(150, 215, 255));
            draw_rectangle(x0, y0, x1, y1, false);
            draw_set_alpha(0.7);
            draw_set_color(make_color_rgb(235, 250, 255));
            draw_line(x0 + 6, y0 + 38, x0 + 22, y0 + 8);
            draw_line(x0 + 26, y0 + 40, x0 + 40, y0 + 14);
            var glint = frac(t / 1800 + (cx * 5 + cy * 3) * 0.11);
            draw_circle(x0 + 6 + glint * 36, y0 + 10 + ((cx * 7 + cy * 3) mod 24), 2, false);
            draw_set_alpha(0.9);
            draw_set_color(make_color_rgb(110, 175, 230));
            draw_rectangle(x0 + 1, y0 + 1, x1 - 1, y1 - 1, true);
            draw_set_alpha(1);
            break;

        case ZONE_GATE_A:
        case ZONE_GATE_B:
            var live = gate_active(z);
            var warn = gate_warn(z);
            if (live) {
                draw_set_alpha(0.8);
                draw_set_color(make_color_rgb(255, 50, 50));
                draw_rectangle(x0 + 3, y0 + 3, x1 - 3, y1 - 3, false);
                draw_set_alpha(1);
                draw_set_color(make_color_rgb(255, 235, 220));
                draw_rectangle(x0 + 18, y0 + 3, x1 - 18, y1 - 3, false);
                draw_rectangle(x0 + 3, y0 + 18, x1 - 3, y1 - 18, false);
            } else if (warn && ((t div 90) mod 2 == 0)) {
                draw_set_alpha(0.55);
                draw_set_color(make_color_rgb(255, 170, 60));
                draw_rectangle(x0 + 6, y0 + 6, x1 - 6, y1 - 6, false);
            } else {
                draw_set_alpha(0.28);
                draw_set_color(make_color_rgb(255, 80, 80));
                draw_rectangle(x0 + 4, y0 + 4, x1 - 4, y1 - 4, true);
            }
            draw_set_alpha(1);
            draw_set_color(C_INK);
            draw_rectangle(x0 + TILE / 2 - 5, y0 + TILE / 2 - 5, x0 + TILE / 2 + 4, y0 + TILE / 2 + 4, false);
            draw_set_color(live ? c_white : make_color_rgb(255, 120, 100));
            draw_rectangle(x0 + TILE / 2 - 2, y0 + TILE / 2 - 2, x0 + TILE / 2 + 1, y0 + TILE / 2 + 1, false);
            break;
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

function shape_cells(kind, r) {
    var c = [];
    switch (kind) {
        case "diamond":
            for (var dx = -r; dx <= r; dx++) {
                var dy = r - abs(dx);
                array_push(c, [dx, dy]);
                if (dy != 0) array_push(c, [dx, -dy]);
            }
            break;
        case "triangle":
            for (var dx = -r; dx <= r; dx++) array_push(c, [dx, 0]);
            for (var k = 1; k <= r; k++) {
                array_push(c, [r - k, k]);
                if (r - k != 0) array_push(c, [-(r - k), k]);
            }
            break;
        case "square":
            for (var dx = -r; dx <= r; dx++) {
                for (var dy = -r; dy <= r; dy++) {
                    if (max(abs(dx), abs(dy)) == r) array_push(c, [dx, dy]);
                }
            }
            break;
        case "chevron":
            for (var k = 0; k <= r; k++) {
                array_push(c, [k, r - k]);
                if (k > 0) array_push(c, [-k, r - k]);
            }
            break;
        case "plus":
            array_push(c, [0, 0]);
            for (var k = 1; k <= r; k++) { array_push(c, [k, 0]); array_push(c, [-k, 0]); array_push(c, [0, k]); array_push(c, [0, -k]); }
            break;
        case "x":
            array_push(c, [0, 0]);
            for (var k = 1; k <= r; k++) { array_push(c, [k, k]); array_push(c, [-k, k]); array_push(c, [k, -k]); array_push(c, [-k, -k]); }
            break;
    }
    return c;
}

function rot_offset(o, dir) {
    switch (dir) {
        case 0:   return [o[1], o[0]];
        case 180: return [-o[1], o[0]];
        case 90:  return [o[0], -o[1]];
        default:  return [o[0], o[1]];
    }
}

function shape_color(kind) {
    switch (kind) {
        case "diamond":  return make_color_rgb(70, 220, 255);
        case "triangle": return make_color_rgb(255, 215, 60);
        case "square":   return make_color_rgb(235, 90, 255);
        case "chevron":  return make_color_rgb(255, 150, 50);
        case "plus":     return make_color_rgb(110, 255, 130);
        case "x":        return make_color_rgb(255, 100, 150);
        default:         return make_color_rgb(255, 84, 64);
    }
}

function cover_at(cx, cy) {
    if (cx < 0 || cy < 0 || cx >= GRID_W || cy >= GRID_H) return false;
    return global.wall_grid[# cx, cy] == 3;
}

function make_cover(info) {
    global.cover_hp = ds_grid_create(info.w, info.h);
    ds_grid_clear(global.cover_hp, 0);
    if (!info.boss) return;
    for (var cx = 1; cx < info.w - 1; cx++) {
        for (var cy = 5; cy < info.h - 1; cy++) {
            if (global.wall_grid[# cx, cy] == 1) {
                global.wall_grid[# cx, cy] = 3;
                global.cover_hp[# cx, cy] = COVER_HP;
            }
        }
    }
}

function damage_cover(cx, cy, n) {
    if (!cover_at(cx, cy)) return;
    global.cover_hp[# cx, cy] -= n;
    if (global.cover_hp[# cx, cy] <= 0) {
        global.wall_grid[# cx, cy] = 0;
        mp_grid_clear_cell(global.nav_grid, cx, cy);
        fx_explode(cell_to_px(cx), cell_to_px(cy), 0.45);
    }
}

function smash_cover(x1, y1, x2, y2) {
    var c1 = px_to_cell(x1), c2 = px_to_cell(x2);
    var r1 = px_to_cell(y1), r2 = px_to_cell(y2);
    for (var cx = c1; cx <= c2; cx++) {
        for (var cy = r1; cy <= r2; cy++) damage_cover(cx, cy, 99);
    }
}

function add_cover(cx, cy, hp) {
    if (cx < 1 || cy < 1 || cx >= GRID_W - 1 || cy >= GRID_H - 1) return;
    if (cell_is_wall(cx, cy)) return;
    if (zone_at_cell(cx, cy) != ZONE_NONE) return;
    if (abs(cx - GRID_W div 2) <= 1 && cy >= global.spawn_cy) return;
    var px = cell_to_px(cx), py = cell_to_px(cy);
    if (instance_exists(obj_player) && point_distance(px, py, obj_player.x, obj_player.y) < TILE * 0.9) return;
    var near = instance_nearest(px, py, obj_enemy_parent);
    if (near != noone && point_distance(px, py, near.x, near.y) < 40) return;
    global.wall_grid[# cx, cy] = 3;
    global.cover_hp[# cx, cy]  = hp;
    mp_grid_add_cell(global.nav_grid, cx, cy);
}

function spawn_scrap(px, py) {
    var cx = px_to_cell(px);
    var cy = px_to_cell(py);
    var nb = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    for (var i = 3; i > 0; i--) {
        var j = irandom(i);
        var t = nb[i]; nb[i] = nb[j]; nb[j] = t;
    }
    add_cover(cx, cy, 4);
    add_cover(cx + nb[0][0], cy + nb[0][1], 4);
    add_cover(cx + nb[1][0], cy + nb[1][1], 4);
}

function draw_cover_cell(cx, cy, th) {
    var x0 = cx * TILE;
    var y0 = cy * TILE;
    var ratio = global.cover_hp[# cx, cy] / COVER_HP;
    draw_sprite_ext(spr_wall, th.wf, x0, y0, 1, 1, 0, merge_colour(th.wc, make_color_rgb(255, 190, 120), 0.5), 1);
    draw_set_color(make_color_rgb(255, 200, 40));
    draw_rectangle(x0 + 1, y0 + 1, x0 + TILE - 2, y0 + TILE - 2, true);
    draw_set_color(C_INK);
    if (ratio < 0.85) draw_line_width(x0 + 10, y0 + 8,  x0 + 22, y0 + 26, 2);
    if (ratio < 0.65) draw_line_width(x0 + 22, y0 + 26, x0 + 14, y0 + 40, 2);
    if (ratio < 0.45) draw_line_width(x0 + 32, y0 + 6,  x0 + 36, y0 + 30, 2);
    if (ratio < 0.25) draw_line_width(x0 + 36, y0 + 30, x0 + 26, y0 + 44, 2);
    draw_set_color(c_white);
}

function load_layout(info) {
    var w = info.w;
    var h = info.h;
    ds_grid_clear(global.wall_grid, 0);
    with (obj_wall) {
        var wx = px_to_cell(x);
        var wy = px_to_cell(y);
        if (wx >= 0 && wy >= 0 && wx < GRID_W && wy < GRID_H) global.wall_grid[# wx, wy] = 1;
    }

    arena_rect(0, 0, w, 1);
    arena_rect(0, h - 1, w, 1);
    arena_rect(0, 0, 1, h);
    arena_rect(w - 1, 0, 1, h);
    arena_clear(global.spawn_cx - 2, global.spawn_cy - 2, 5, 5);
    arena_clear(w div 2 - 1, global.spawn_cy, 3, h - 1 - global.spawn_cy);
    if (info.boss) {
        var nodes = boss_node_cells(info.tier);
        for (var i = 0; i < array_length(nodes); i++) {
            arena_clear(1, nodes[i][1] - 1, 3, 3);
            arena_clear(1, nodes[i][1], w - 2, 1);
        }
    }
}

function load_zones(info) {
    if (variable_global_exists("zone_grid") && ds_exists(global.zone_grid, ds_type_grid))
        ds_grid_destroy(global.zone_grid);
    global.zone_grid = ds_grid_create(info.w, info.h);
    ds_grid_clear(global.zone_grid, ZONE_NONE);
    global.gate_t = 0;
    with (obj_zone) {
        var zx = px_to_cell(x);
        var zy = px_to_cell(y);
        var zk = floor(image_index) + 1;
        if (zk >= ZONE_FIELD && zk <= ZONE_ICE && !cell_is_wall(zx, zy)) {
            global.zone_grid[# zx, zy] = zk;
            if (zk == ZONE_FIELD) global.wall_grid[# zx, zy] = 2;
        }
    }
    global.open_cells = arena_flood(global.spawn_cx, global.spawn_cy);
}

function is_machine(o) {
    return (o == obj_generator || o == obj_barrel || o == obj_crate || o == obj_power_node);
}

function damage_enemy(t, n) {
    if (t.dying) return;
    if (aug_has("g_exec") && t.hp <= 2 && !is_machine(t.object_index) && t.object_index != obj_boss) n = max(n, t.hp);
    t.hp -= n;
    if (variable_instance_exists(t, "hit_flash")) t.hit_flash = 4;
    if (t.hp > 0) return;
    t.dying = true;
    var kind = t.object_index;
    var tx = t.x;
    var ty = t.y;
    fx_explode(tx, ty, is_machine(kind) ? 0.9 : 0.55);
    global.total_kills++;
    global.score += 10 * global.floor_num;
    with (t) instance_destroy();

    if (!is_machine(kind) && kind != obj_boss) {
        if (aug_has("s_blood") && instance_exists(obj_player)) obj_player.fire_timer = 0;
        var vn = aug_n("g_vamp");
        if (vn > 0) {
            global.vamp_kills++;
            if (global.vamp_kills >= 12 - 2 * vn) {
                global.vamp_kills = 0;
                global.player_hp = min(global.player_max_hp, global.player_hp + 1);
                if (instance_exists(obj_hud)) obj_hud.heal_flash = 14;
            }
        }
        var sc = aug_n("s_scav");
        if (sc > 0 && random(1) < 0.07 * sc) {
            var mk = instance_create_layer(tx, ty, "Instances", obj_medkit);
            mk.one_shot = true;
        }
    }

    if (kind == obj_generator || kind == obj_barrel || kind == obj_crate) spawn_scrap(tx, ty);
    if (kind == obj_barrel || kind == obj_enemy_bomber) barrel_blast(tx, ty);
}

function barrel_blast(px, py) {
    fx_explode(px, py, 1.7);
    var victims = [];
    with (obj_enemy_parent) {
        if (!dying && object_index != obj_power_node && point_distance(x, y, px, py) < 120) array_push(victims, id);
    }
    for (var i = 0; i < array_length(victims); i++) {
        if (instance_exists(victims[i])) damage_enemy(victims[i], 4);
    }
    if (instance_exists(obj_player) && obj_player.alive && point_distance(px, py, obj_player.x, obj_player.y) < 80
        && obj_player.invincible_timer <= 0) hurt_player(1);

    for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) damage_cover(px_to_cell(px) + dx, px_to_cell(py) + dy, 2);
    }
}

function mark_props() {
    with (obj_prop) {
        var cx1 = floor(x / TILE);
        var cx2 = floor((x + sprite_width - 1) / TILE);
        var cy2 = floor((y + sprite_height - 1) / TILE);
        var cy1 = max(floor(y / TILE), cy2 - 1);
        for (var cx = cx1; cx <= cx2; cx++) {
            for (var cy = cy1; cy <= cy2; cy++) {
                if (cx >= 0 && cy >= 0 && cx < GRID_W && cy < GRID_H && global.wall_grid[# cx, cy] == 0) global.wall_grid[# cx, cy] = 4;
            }
        }
    }
}

function aug_label() {
    var s = "BULLETS";
    switch (global.aug) {
        case "laser":   s = "LASER";   break;
        case "scatter": s = "SCATTER"; break;
    }
    switch (global.aug_spec) {
        case "lbeam": s = "L-BEAM LASER"; break;
        case "wide":  s = "WIDE LASER";   break;
        case "cross": s = "CROSSFIRE";    break;
        case "wall":  s = "BULLET WALL";  break;
    }
    return s;
}

function spawn_player_bullet(bx, by, ang, maxdist) {
    if (wall_at(bx, by)) return;
    var b = instance_create_layer(bx, by, "Bullets", obj_bullet_player);
    b.bdir    = ang;
    b.bspd    = global.player_bullet_speed;
    b.bdmg    = global.shot_dmg;
    b.pierce  = global.player_pierce;
    b.maxdist = maxdist;
    b.depth   = -150;
}

function beam_hit_segments(segs) {
    var hit = [];
    for (var i = 0; i < array_length(segs); i++) {
        var s  = segs[i];
        var x1 = min(s[0], s[2]) - 26;
        var x2 = max(s[0], s[2]) + 26;
        var y1 = min(s[1], s[3]) - 26;
        var y2 = max(s[1], s[3]) + 26;
        with (obj_enemy_parent) {
            if (!dying && x > x1 && x < x2 && y > y1 && y < y2) {
                var seen = false;
                for (var k = 0; k < array_length(hit); k++) { if (hit[k] == id) seen = true; }
                if (!seen) array_push(hit, id);
            }
        }
    }
    for (var k = 0; k < array_length(hit); k++) {
        if (instance_exists(hit[k])) damage_enemy(hit[k], global.shot_dmg);
    }
}

function beam_leg(sx, sy, ang, tiles, wdt) {
    var len = ray_length(sx, sy, ang, tiles * TILE);
    return [sx, sy, sx + lengthdir_x(len, ang), sy + lengthdir_y(len, ang), wdt];
}

function fire_laser(ang) {
    var segs = [];
    var fx   = x;
    var fy   = y;
    switch (global.aug_spec) {
        case "lbeam":
            var leg1 = beam_leg(fx, fy, ang, 4, 8);
            array_push(segs, leg1);

            var side = ang + 90;
            var near = instance_nearest(leg1[2], leg1[3], obj_enemy_parent);
            if (near != noone && !near.dying) {
                var cross_p = lengthdir_x(1, ang) * (near.y - leg1[3]) - lengthdir_y(1, ang) * (near.x - leg1[2]);
                side = (cross_p >= 0) ? ang - 90 : ang + 90;
            } else {
                global.laser_flip = !global.laser_flip;
                side = global.laser_flip ? ang + 90 : ang - 90;
            }
            array_push(segs, beam_leg(leg1[2], leg1[3], side, 3, 8));
            break;
        case "wide":
            for (var o = -1; o <= 1; o++) {
                var ox = fx + lengthdir_x(o * 20, ang + 90);
                var oy = fy + lengthdir_y(o * 20, ang + 90);
                if (!wall_at(ox, oy)) array_push(segs, beam_leg(ox, oy, ang, 4, 8));
            }
            break;
        default:
            array_push(segs, beam_leg(fx, fy, ang, 5, 8));
            break;
    }
    var fxo = instance_create_layer(0, 0, "Bullets", obj_laser_fx);
    fxo.segs = segs;
    beam_hit_segments(segs);
}

function fire_scatter(ang) {
    var fx = x;
    var fy = y;
    switch (global.aug_spec) {
        case "cross":
            for (var d = 0; d < 4; d++) spawn_player_bullet(fx + lengthdir_x(16, ang + d * 90), fy + lengthdir_y(16, ang + d * 90), ang + d * 90, 7 * TILE);
            break;
        case "wall":
            for (var o = -2; o <= 2; o++) {
                spawn_player_bullet(fx + lengthdir_x(16, ang) + lengthdir_x(o * 20, ang + 90),
                                    fy + lengthdir_y(16, ang) + lengthdir_y(o * 20, ang + 90), ang, 5 * TILE);
            }
            break;
        default:
            for (var o = -1; o <= 1; o++) {
                spawn_player_bullet(fx + lengthdir_x(16, ang) + lengthdir_x(o * 20, ang + 90),
                                    fy + lengthdir_y(16, ang) + lengthdir_y(o * 20, ang + 90), ang, 6 * TILE);
            }
            break;
    }
}

function player_damage_now() {
    var d = global.player_damage;
    if (aug_has("g_last") && global.player_hp <= 1) d *= 2;
    return d;
}

function fire_overcharge(ang) {
    var segs = [beam_leg(x, y, ang, 10, 12)];
    var fxo = instance_create_layer(0, 0, "Bullets", obj_laser_fx);
    fxo.segs = segs;
    var keep = global.shot_dmg;
    global.shot_dmg = keep * 3;
    beam_hit_segments(segs);
    global.shot_dmg = keep;
}

function fire_weapon_raw(ang) {
    switch (global.aug) {
        case "laser":   fire_laser(ang);   break;
        case "scatter": fire_scatter(ang); break;
        default:        spawn_player_bullet(x + lengthdir_x(16, ang), y + lengthdir_y(16, ang), ang, 1500); break;
    }
    if (aug_has("p_quad")) {
        for (var d = 1; d < 4; d++) {
            var qa = ang + d * 90;
            spawn_player_bullet(x + lengthdir_x(16, qa), y + lengthdir_y(16, qa), qa, 7 * TILE);
        }
    }
}

function fire_weapon(ang) {
    global.shot_dmg = player_damage_now();
    if (random(1) < 0.15 * aug_n("s_crit")) global.shot_dmg *= 2;
    global.shots++;
    if (aug_has("p_over") && global.shots mod 5 == 0) {
        fire_overcharge(ang);
    } else {
        fire_weapon_raw(ang);
    }
    if (aug_has("g_double") && random(1) < 0.3) {
        echo_t   = 6;
        echo_ang = ang;
    }
}

function chain_hit(ox, oy, from, dmg) {
    var n = aug_n("g_chain");
    if (n <= 0) return;
    var best = noone;
    var bd   = 4 * TILE;
    with (obj_enemy_parent) {
        if (id != from && !dying) {
            var dd = point_distance(x, y, ox, oy);
            if (dd < bd) { bd = dd; best = id; }
        }
    }
    if (best != noone) {
        var fxo = instance_create_layer(0, 0, "Bullets", obj_laser_fx);
        fxo.segs = [[ox, oy, best.x, best.y, 4]];
        fxo.life = 8;
        fxo.life_max = 8;
        damage_enemy(best, max(1, ceil(dmg * 0.5 * n)));
    }
}

function bullet_blast(px, py, dmg) {
    var n = aug_n("g_blast");
    if (n <= 0) return;
    fx_explode(px, py, 0.6 + 0.3 * n);
    var victims = [];
    with (obj_enemy_parent) {
        if (!dying && point_distance(x, y, px, py) < 60 + 24 * n) array_push(victims, id);
    }
    for (var i = 0; i < array_length(victims); i++) {
        if (instance_exists(victims[i])) damage_enemy(victims[i], max(1, ceil(dmg * 0.5 * n)));
    }
}

function aug_def(aid, nm, ds, tier, maxn, req, excl) {
    array_push(global.aug_db, { id: aid, name: nm, desc: ds, tier: tier, maxn: maxn, req: req, excl: excl });
}

function aug_build() {
    if (variable_global_exists("aug_db")) return;
    global.aug_db = [];
    aug_def("s_speed",  "QUICK PAWS",      "Move faster. Stacks 3 times.",                       0, 3, "", []);
    aug_def("s_rate",   "RAPID FIRE",      "Shoot more often. Stacks 3 times.",                  0, 3, "", ["p_over"]);
    aug_def("s_dmg",    "HOLLOW POINTS",   "+1 bullet damage. Stacks 3 times.",                  0, 3, "", []);
    aug_def("s_hp",     "REINFORCED",      "+1 max HP and heal 1. Stacks 3 times.",              0, 3, "", []);
    aug_def("s_bspd",   "SLICK ROUNDS",    "Bullets fly faster. Stacks 3 times.",                0, 3, "", []);
    aug_def("s_pierce", "PIERCING",        "Bullets pass through 1 more enemy. Stacks 3 times.", 0, 3, "", []);
    aug_def("s_heal",   "FIELD DRESSING",  "Heal 2 HP right now.",                               0, 99, "", []);
    aug_def("s_medic",  "MEDIC",           "Medkits heal 1 more and come back 30% sooner.",      0, 2, "", []);
    aug_def("s_crit",   "LUCKY SHOT",      "15% chance to deal double damage. Stacks 3 times.",  0, 3, "", []);
    aug_def("s_scav",   "SCAVENGER",       "Kills have a 7% chance to drop a medkit. Stacks 3 times.", 0, 3, "", []);
    aug_def("s_blood",  "ADRENALINE",      "Killing an enemy reloads your weapon instantly.",    0, 1, "", []);

    aug_def("g_laser",  "LASER CORE",      "Your gun becomes a beam that pierces everything, but only reaches 5 tiles.", 1, 1, "", ["g_scatter"]);
    aug_def("g_scatter","SCATTER ARRAY",   "Fire 3 bullets side by side, but only 6 tiles far.", 1, 1, "", ["g_laser"]);
    aug_def("g_lbeam",  "L-BEAM",          "The laser bends 90 degrees toward the nearest enemy.", 1, 1, "g_laser", ["g_wide"]);
    aug_def("g_wide",   "WIDE BEAM",       "Three laser beams side by side.",                    1, 1, "g_laser", ["g_lbeam"]);
    aug_def("g_cross",  "CROSSFIRE",       "Fire in all four directions at once.",               1, 1, "g_scatter", ["g_wall"]);
    aug_def("g_wall",   "BULLET WALL",     "Five bullets side by side.",                         1, 1, "g_scatter", ["g_cross"]);
    aug_def("g_chain",  "CHAIN LIGHTNING", "Hits arc to the nearest enemy within 4 tiles. Stacks twice.", 1, 2, "", []);
    aug_def("g_blast",  "EXPLOSIVE ROUNDS","Bullets explode where they hit. Stacks twice.",       1, 2, "", []);
    aug_def("g_ricochet","RICOCHET",       "Bullets bounce back off the first wall they hit.",   1, 1, "", []);
    aug_def("g_shield", "AEGIS",           "Block the first hit on every floor. Stacks twice.",  1, 2, "", []);
    aug_def("g_vamp",   "VAMPIRIC",        "Heal 1 HP every 10 kills. Stacks twice.",            1, 2, "", []);
    aug_def("g_exec",   "EXECUTIONER",     "Enemies with 2 HP or less die in one hit.",          1, 1, "", []);
    aug_def("g_double", "DOUBLE TAP",      "30% chance to fire a second shot right after.",      1, 1, "", []);
    aug_def("g_last",   "LAST STAND",      "Double damage while you are on 1 HP.",               1, 1, "", []);
    aug_def("g_thorns", "REACTIVE PLATING","Taking a hit sends out a shockwave. Stacks twice.",  1, 2, "", []);
    aug_def("g_reroll", "REROLL CACHE",    "Gain 2 rerolls.",                                    1, 2, "", []);

    aug_def("p_over",   "OVERCHARGE",      "Every 5th shot is a huge triple damage laser. Rapid Fire is removed from your offers.", 2, 1, "", []);
    aug_def("p_wind",   "SECOND WIND",     "Once per run, a killing blow instead heals you to half and blasts nearby enemies.", 2, 1, "", []);
    aug_def("p_titan",  "TITAN FRAME",     "+3 max HP and a full heal.",                         2, 1, "", ["p_glass"]);
    aug_def("p_glass",  "GLASS CANNON",    "Double your damage, but lose 2 max HP.",             2, 1, "", ["p_titan"]);
    aug_def("p_quad",   "QUAD CORE",       "Every shot also fires in the three other directions.", 2, 1, "", []);
    aug_def("p_drive",  "OVERDRIVE",       "Halve your weapon cooldown: shoot twice as often.", 2, 1, "", []);
}

function aug_n(aid) {
    if (!variable_global_exists("aug_have")) return 0;
    return variable_struct_exists(global.aug_have, aid) ? variable_struct_get(global.aug_have, aid) : 0;
}
function aug_has(aid) { return aug_n(aid) > 0; }

function aug_find(aid) {
    for (var i = 0; i < array_length(global.aug_db); i++) { if (global.aug_db[i].id == aid) return global.aug_db[i]; }
    return noone;
}
function aug_name(aid) { var d = aug_find(aid); return (d == noone) ? aid : d.name; }
function aug_desc(aid) { var d = aug_find(aid); return (d == noone) ? "" : d.desc; }
function aug_tier(aid) { var d = aug_find(aid); return (d == noone) ? 0 : d.tier; }
function aug_tier_name(t) { return (t == 0) ? "SILVER" : ((t == 1) ? "GOLD" : "PRISMATIC"); }
function aug_tier_color(t) {
    if (t == 0) return make_color_rgb(150, 165, 185);
    if (t == 1) return make_color_rgb(240, 180, 50);
    return make_color_rgb(215, 90, 235);
}

function aug_eligible(d) {
    if (aug_n(d.id) >= d.maxn) return false;
    if (d.req != "" && !aug_has(d.req)) return false;
    for (var i = 0; i < array_length(d.excl); i++) { if (aug_has(d.excl[i])) return false; }
    if (d.id == "s_heal" && global.player_hp >= global.player_max_hp) return false;
    if (d.id == "s_rate" && aug_has("p_over")) return false;
    return true;
}

function aug_pick_tier() {
    var p = (global.aug_round <= 0) ? 0 : (global.floor_num / max(1, global.max_floors));
    var ws;
    if (global.aug_round <= 0) ws = [15, 85, 0];
    else if (p < 0.34)         ws = [60, 38, 2];
    else if (p < 0.67)         ws = [28, 52, 20];
    else                       ws = [10, 45, 45];
    var r = random(ws[0] + ws[1] + ws[2]);
    if (r < ws[0]) return 0;
    if (r < ws[0] + ws[1]) return 1;
    return 2;
}

function aug_offer() {
    aug_build();
    var tier = aug_pick_tier();
    var pool = [];
    for (var i = 0; i < array_length(global.aug_db); i++) {
        var d = global.aug_db[i];
        if (d.tier == tier && aug_eligible(d)) array_push(pool, d.id);
    }
    if (array_length(pool) < 3) {
        for (var i = 0; i < array_length(global.aug_db); i++) {
            var d = global.aug_db[i];
            if (d.tier != tier && aug_eligible(d)) array_push(pool, d.id);
        }
    }
    for (var i = array_length(pool) - 1; i > 0; i--) {
        var j = irandom(i);
        var tmp = pool[i]; pool[i] = pool[j]; pool[j] = tmp;
    }
    var out = [];
    for (var i = 0; i < min(3, array_length(pool)); i++) array_push(out, pool[i]);
    return out;
}

function aug_apply(aid) {
    var c = aug_n(aid) + 1;
    variable_struct_set(global.aug_have, aid, c);
    switch (aid) {
        case "s_speed":  global.player_speed += 0.5; break;
        case "s_rate":   global.player_fire_rate = max(6, global.player_fire_rate - 3); break;
        case "s_dmg":    global.player_damage++; break;
        case "s_hp":     global.player_max_hp++; global.player_hp = min(global.player_hp + 1, global.player_max_hp); break;
        case "s_bspd":   global.player_bullet_speed += 2; break;
        case "s_pierce": global.player_pierce++; break;
        case "s_heal":   global.player_hp = min(global.player_hp + 2, global.player_max_hp); break;
        case "g_laser":  global.aug = "laser";   global.aug_spec = ""; break;
        case "g_scatter":global.aug = "scatter"; global.aug_spec = ""; break;
        case "g_lbeam":  global.aug_spec = "lbeam"; break;
        case "g_wide":   global.aug_spec = "wide";  break;
        case "g_cross":  global.aug_spec = "cross"; break;
        case "g_wall":   global.aug_spec = "wall";  break;
        case "g_shield": global.shield_hits++; break;
        case "g_reroll": global.rerolls += 2; break;
        case "p_titan":  global.player_max_hp += 3; global.player_hp = global.player_max_hp; break;
        case "p_glass":  global.player_damage *= 2; global.player_max_hp = max(2, global.player_max_hp - 2);
                         global.player_hp = min(global.player_hp, global.player_max_hp); break;
        case "p_drive":  global.player_fire_rate = max(5, ceil(global.player_fire_rate * 0.5)); break;
    }
}

function aug_owned_list() {
    var out = [];
    for (var i = 0; i < array_length(global.aug_db); i++) {
        var d = global.aug_db[i];
        if (aug_has(d.id)) array_push(out, d);
    }
    return out;
}

function aug_draw_list(gw, gh) {
    var list = aug_owned_list();
    var pw = 360;
    var ph = 40 + max(1, array_length(list)) * 22;
    var px0 = gw / 2 - pw / 2;
    var py0 = 90;
    draw_set_alpha(0.78);
    draw_set_color(C_INK);
    draw_rectangle(px0, py0, px0 + pw, py0 + ph, false);
    draw_set_alpha(1);
    ui_text(px0 + 16, py0 + 10, "YOUR AUGMENTS  (REROLLS " + string(global.rerolls) + ")", F_TINY, c_white, 1, fa_left, 1);
    for (var i = 0; i < array_length(list); i++) {
        var d = list[i];
        var n = aug_n(d.id);
        ui_text(px0 + 16, py0 + 36 + i * 22, d.name + ((n > 1) ? " x" + string(n) : ""), F_TINY, aug_tier_color(d.tier), 1, fa_left, 1);
    }
    if (array_length(list) == 0) ui_text(px0 + 16, py0 + 36, "None yet", F_TINY, C_MIST, 1, fa_left, 1);
    draw_set_color(c_white);
}

function dev_boss_patterns() {
    return ["", "ring", "fan", "spiral", "diamonds", "triangles", "squares", "chevrons", "xcross", "rain", "lance", "beams", "stream", "summon", "claw", "charge"];
}

function dev_spawn(t, mx, my) {
    var cx = px_to_cell(mx);
    var cy = px_to_cell(my);
    if (cell_is_wall(cx, cy)) return;
    var px = cell_to_px(cx);
    var py = cell_to_px(cy);
    if (t == "barrel")      instance_create_layer(px, py, "Instances", obj_barrel);
    else if (t == "medkit") instance_create_layer(px, py, "Instances", obj_medkit);
    else                    spawn_mob(t, px, py);
}

function dev_update() {
    if (!global.dev) return;
    var mx = mouse_x;
    var my = mouse_y;
    if (keyboard_check_pressed(ord("G"))) global.dev_god = !global.dev_god;
    if (keyboard_check_pressed(ord("H"))) global.player_hp = global.player_max_hp;
    if (keyboard_check_pressed(ord("K"))) {
        with (obj_enemy_parent) { if (!is_machine(object_index)) { fx_explode(x, y, 0.5); instance_destroy(); } }
        with (obj_bullet_enemy) instance_destroy();
    }
    if (keyboard_check_pressed(vk_pageup) || keyboard_check_pressed(ord("]"))) {
        global.floor_num = min(global.max_floors, global.floor_num + 1);
        room_goto(floor_room(global.floor_num));
    }
    if (keyboard_check_pressed(vk_pagedown) || keyboard_check_pressed(ord("["))) {
        global.floor_num = max(1, global.floor_num - 1);
        room_goto(floor_room(global.floor_num));
    }
    if (keyboard_check_pressed(ord("1"))) dev_spawn("shooter", mx, my);
    if (keyboard_check_pressed(ord("2"))) dev_spawn("chaser",  mx, my);
    if (keyboard_check_pressed(ord("3"))) dev_spawn("turret",  mx, my);
    if (keyboard_check_pressed(ord("4"))) dev_spawn("dasher",  mx, my);
    if (keyboard_check_pressed(ord("5"))) dev_spawn("sniper",  mx, my);
    if (keyboard_check_pressed(ord("6"))) dev_spawn("barrel",  mx, my);
    if (keyboard_check_pressed(ord("7"))) dev_spawn("medkit",  mx, my);
    if (keyboard_check_pressed(ord("O")) && instance_exists(obj_wave_manager)) obj_wave_manager.open_exit();
    if (keyboard_check_pressed(ord("B"))) {
        if (instance_exists(obj_wave_manager) && obj_wave_manager.state == "boss_intro") obj_wave_manager.timer = 1;
        if (instance_exists(obj_boss) && obj_boss.state == "intro") obj_boss.intro_timer = 1;
    }
    if (keyboard_check_pressed(ord("X")) && instance_exists(obj_power_node)) {
        var nn = instance_nearest(mx, my, obj_power_node);
        damage_enemy(nn, 9999);
    }
    if (keyboard_check_pressed(ord("Y")) && instance_exists(obj_boss)) {
        var list = dev_boss_patterns();
        var cur = 0;
        for (var i = 0; i < array_length(list); i++) { if (list[i] == obj_boss.dev_force) cur = i; }
        obj_boss.dev_force = list[(cur + 1) mod array_length(list)];
    }

    if (keyboard_check_pressed(ord("N")) && !instance_exists(obj_upgrade_ui)) {
        global.is_upgrade_phase = true;
        var du = instance_create_layer(0, 0, "Instances", obj_upgrade_ui);
        du.mode = "dev";
        du.picks_left = 1;
    }
    if (keyboard_check_pressed(ord("L"))) {
        var combos = [["", ""], ["laser", ""], ["laser", "lbeam"], ["laser", "wide"], ["scatter", ""], ["scatter", "cross"], ["scatter", "wall"]];
        var ci = 0;
        for (var i = 0; i < array_length(combos); i++) { if (combos[i][0] == global.aug && combos[i][1] == global.aug_spec) ci = i; }
        ci = (ci + 1) mod array_length(combos);
        global.aug = combos[ci][0];
        global.aug_spec = combos[ci][1];
    }
}

function dev_draw(gw, gh) {
    if (!global.dev) return;
    var lines = [
        "DEV MODE  (F10 to close)",
        "G god mode: " + (global.dev_god ? "ON" : "off"),
        "H heal    K kill all enemies",
        "[ / ]  previous / next floor",
        "1-5 shooter chaser turret dasher sniper at mouse",
        "6 barrel  7 medkit  (at mouse)",
        "O open exit   B skip boss intro   X break power node",
        "Y force boss attack: " + (instance_exists(obj_boss) ? (obj_boss.dev_force == "" ? "random" : obj_boss.dev_force) : "(no boss here)"),
        "N open an augment pick   L cycle weapon: " + aug_label()
    ];
    var pw = 420;
    var ph = 12 + array_length(lines) * 22;
    draw_set_alpha(0.7);
    draw_set_color(C_INK);
    draw_rectangle(gw - pw - 12, 70, gw - 12, 70 + ph, false);
    draw_set_alpha(1);
    for (var i = 0; i < array_length(lines); i++) {
        ui_text(gw - pw - 2, 78 + i * 22, lines[i], F_TINY, i == 0 ? C_ORANGE : c_white, 1, fa_left, 1);
    }
    draw_set_color(c_white);
}


function solid_px(px, py) {
    var cx = px_to_cell(px);
    var cy = px_to_cell(py);
    if (cell_is_wall(cx, cy)) return true;
    var z = zone_at_cell(cx, cy);
    return (is_gate(z) && gate_active(z));
}

function box_free(px, py, r) {
    return !solid_px(px - r, py - r) && !solid_px(px + r, py - r) && !solid_px(px - r, py + r) && !solid_px(px + r, py + r);
}

function move_free(dx, dy, r) {
    var moved = false;
    if (!box_free(x, y, r)) {
        if (!wall_at(x + dx, y + dy)) { x += dx; y += dy; moved = true; }
        return moved;
    }
    if (dx != 0) {
        if (box_free(x + dx, y, r)) { x += dx; moved = true; }
        else if (box_free(x + dx * 0.4, y, r)) { x += dx * 0.4; moved = true; }
    }
    if (dy != 0) {
        if (box_free(x, y + dy, r)) { y += dy; moved = true; }
        else if (box_free(x, y + dy * 0.4, r)) { y += dy * 0.4; moved = true; }
    }
    return moved;
}

function spot_free(px, py, r, me) {
    if (!box_free(px, py, r + 2)) return false;
    var bad = false;
    with (obj_enemy_parent) {
        if (id != me && !dying && point_distance(x, y, px, py) < 40) bad = true;
    }
    if (instance_exists(obj_player) && point_distance(px, py, obj_player.x, obj_player.y) < 64) bad = true;
    return !bad;
}

function snap_to_open_cell() {
    var cx = clamp(px_to_cell(x), 1, GRID_W - 2);
    var cy = clamp(px_to_cell(y), 1, GRID_H - 2);
    if (spot_free(x, y, 14, id)) return;
    for (var r = 0; r <= 10; r++) {
        for (var dx = -r; dx <= r; dx++) {
            for (var dy = -r; dy <= r; dy++) {
                if (max(abs(dx), abs(dy)) != r) continue;
                var px = cell_to_px(cx + dx);
                var py = cell_to_px(cy + dy);
                if (spot_free(px, py, 14, id)) { x = px; y = py; return; }
            }
        }
    }
}

function mob_init(r) {
    mob_r    = r;
    moving   = false;
    nav_t    = irandom(12);
    nav_x    = x;
    nav_y    = y;
    stuck_n  = 0;
    strafe_dir = choose(-1, 1);
    strafe_t   = 40 + irandom(60);
}

function mob_apply(dx, dy) {
    var ox = x;
    var oy = y;
    move_free(dx, dy, mob_r);
    moving = (abs(x - ox) + abs(y - oy)) > 0.05;
    if (!box_free(x, y, mob_r)) {
        stuck_n++;
        if (stuck_n > 30) { snap_to_open_cell(); stuck_n = 0; }
    } else stuck_n = 0;
    return moving;
}

function mob_waypoint(tx, ty) {
    if (line_clear(x, y, tx, ty)) { nav_t = 0; return [tx, ty]; }
    nav_t--;
    if (nav_t <= 0 || point_distance(x, y, nav_x, nav_y) < 10) {
        nav_t = 14;
        var wp = nav_next_point(tx, ty);
        if (is_undefined(wp)) { nav_x = tx; nav_y = ty; }
        else                  { nav_x = wp[0]; nav_y = wp[1]; }
    }
    return [nav_x, nav_y];
}

function mob_dir_move(a, spd) {
    var ts = global.time_scale;
    mob_apply(lengthdir_x(spd * ts, a), lengthdir_y(spd * ts, a));
    face_dir = dir_from_angle(a);
}

function mob_chase(tx, ty, spd) {
    var wp = mob_waypoint(tx, ty);
    mob_dir_move(point_direction(x, y, wp[0], wp[1]), spd);
}

function mob_flee(tx, ty, spd) {
    var a    = point_direction(tx, ty, x, y);
    var offs = [0, 40, -40, 80, -80, 120, -120];
    var best = a;
    for (var k = 0; k < 7; k++) {
        var aa = a + offs[k];
        if (box_free(x + lengthdir_x(mob_r + 10, aa), y + lengthdir_y(mob_r + 10, aa), mob_r)) { best = aa; break; }
    }
    mob_dir_move(best, spd);
}

function mob_strafe(tx, ty, spd) {
    var a = point_direction(x, y, tx, ty) + 90 * strafe_dir;
    if (!box_free(x + lengthdir_x(mob_r + 10, a), y + lengthdir_y(mob_r + 10, a), mob_r)) {
        strafe_dir = -strafe_dir;
        a = point_direction(x, y, tx, ty) + 90 * strafe_dir;
    }
    var ts = global.time_scale;
    mob_apply(lengthdir_x(spd * ts, a), lengthdir_y(spd * ts, a));
}

function mob_separate() {
    var me  = id;
    var mr  = mob_r;
    var sx  = 0;
    var sy  = 0;
    with (obj_enemy_parent) {
        if (id != me && !dying) {
            var orad = variable_instance_exists(id, "mob_r") ? mob_r : 24;
            var minD = orad + mr;
            var d    = point_distance(x, y, me.x, me.y);
            if (d < minD) {
                var a = (d < 0.5) ? random(360) : point_direction(x, y, me.x, me.y);
                var f = (minD - d) * (variable_instance_exists(id, "mob_r") ? 0.5 : 1);
                sx += lengthdir_x(f, a);
                sy += lengthdir_y(f, a);
            }
        }
    }
    if (instance_exists(obj_player) && obj_player.alive) {
        var dp = point_distance(obj_player.x, obj_player.y, x, y);
        if (dp < mr + 12) {
            var ap = (dp < 0.5) ? random(360) : point_direction(obj_player.x, obj_player.y, x, y);
            sx += lengthdir_x(mr + 12 - dp, ap) * 0.6;
            sy += lengthdir_y(mr + 12 - dp, ap) * 0.6;
        }
    }
    var m = point_distance(0, 0, sx, sy);
    if (m > 2.5) { sx = sx / m * 2.5; sy = sy / m * 2.5; }
    if (m > 0.01) move_free(sx, sy, mob_r);
}
