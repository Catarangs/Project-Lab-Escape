// ---- Grid (Helltaker-style block movement) ----
#macro TILE   48
#macro STEP_PX (TILE / 7)      // pixels per frame for 1 tile per player step (a step lasts about 7 frames)
#macro COVER_HP 5
#macro GRID_W global.grid_w
#macro GRID_H global.grid_h

// Each floor has its own room (room_floor1 .. room_floor6). Drop enemies on the StartEnemies layer in the room editor
// to place them by hand. With FIXED_LAYOUTS every floor builds the same walls and traps each run, so what you see in a
// test run is where your enemies will stand. Set it to false for a new random layout every run.
#macro FIXED_LAYOUTS true

function floor_room(f) {
    switch (f) {
        case 1:  return room_floor1;
        case 2:  return room_floor2;
        case 3:  return room_floor3;
        case 4:  return room_floor4;
        case 5:  return room_floor5;
        default: return room_floor6;
    }
}

function cell_to_px(c) { return c * TILE + TILE / 2; }
function px_to_cell(p) { return floor(p / TILE); }

// bullets only fly up, down, left or right: 0 right, 90 up, 180 left, 270 down
function snap_dir(a) {
    return ((round(a / 90) mod 4) + 4) mod 4 * 90;
}

// ---- Floors of the facility ----
// boss floors are fought against the mecha: cut its power lines to shut it down
// w / h are in tiles, view_w is how much of the map the camera shows in pixels
// (the window is 960 wide, so 640 = a 1.5x zoom on the rabbit; boss floors stay wider to read bullets)
function floor_info(f) {
    switch (f) {
        case 1: return { name: "CELL BLOCK",    theme: 0, boss: false, tier: 0, layout: 0, w: 36, h: 27, view_w: 640 };
        case 2: return { name: "RESEARCH WING", theme: 1, boss: false, tier: 0, layout: 1, w: 40, h: 30, view_w: 640 };
        case 3: return { name: "SENTINEL BAY",  theme: 2, boss: true,  tier: 1, layout: 3, w: 30, h: 24, view_w: 960 };
        case 4: return { name: "REACTOR CORE",  theme: 3, boss: false, tier: 0, layout: 2, w: 44, h: 32, view_w: 640 };
        case 5: return { name: "SERVER VAULT",  theme: 4, boss: false, tier: 0, layout: 1, w: 48, h: 34, view_w: 640 };
        default: return { name: "WARDEN-9",     theme: 5, boss: true,  tier: 2, layout: 4, w: 34, h: 26, view_w: 960 };
    }
}

// What the player has to do on each floor instead of clearing every enemy.
// kind: "collect" (walk over the items), "destroy" (shoot the machines), "survive" (goal = frames of running time)
function floor_objectives(f) {
    switch (f) {
        case 1: return [ { kind: "collect", label: "KEYCARDS",      goal: 3,    done: 0, item: "keycard" } ];
        case 2: return [ { kind: "destroy", label: "GENERATORS",    goal: 3,    done: 0, item: "" } ];
        case 4: return [ { kind: "survive", label: "MELTDOWN",      goal: 3600, done: 0, item: "" },
                         { kind: "collect", label: "COOLANT CELLS", goal: 2,    done: 0, item: "cell" } ];
        case 5: return [ { kind: "collect", label: "DATA CHIPS",    goal: 4,    done: 0, item: "chip" },
                         { kind: "destroy", label: "SERVERS",       goal: 2,    done: 0, item: "" } ];
        default: return [];
    }
}

// tile frame + tint per theme (frames come from spr_floor / spr_wall)
function theme_info(t) {
    switch (t) {
        case 0: return { ff: 0, wf: 0, fc: c_white, wc: c_white };                                  // holding cells
        case 1: return { ff: 1, wf: 3, fc: c_white, wc: c_white };                                  // labs
        case 2: return { ff: 2, wf: 1, fc: c_white, wc: c_white };                                  // industrial bay
        case 3: return { ff: 2, wf: 3, fc: make_color_rgb(255,170,150), wc: make_color_rgb(255,150,130) }; // reactor
        case 4: return { ff: 0, wf: 1, fc: make_color_rgb(150,255,215), wc: make_color_rgb(170,255,225) }; // server vault
        default: return { ff: 1, wf: 3, fc: make_color_rgb(255,190,190), wc: make_color_rgb(255,170,170) }; // warden
    }
}

// where the mecha's power-line nodes sit (tile coordinates)
function boss_node_cells(tier) {
    var w = GRID_W;
    var h = GRID_H;
    if (tier <= 1) return [[1, 13], [w - 2, 13]];
    return [[1, 8], [w - 2, 8], [1, 17], [w - 2, 17]];
}

// ---- Arena building ----
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

// Fills global.wall_grid for one floor. Walls only, connectivity is fixed afterwards.
function fill_arena(info) {
    var w = GRID_W;
    var h = GRID_H;
    ds_grid_clear(global.wall_grid, 0);

    switch (info.layout) {
        case 0: // lab benches scattered around
            var count = (w * h) div 38;
            for (var i = 0; i < count; i++) {
                var bw = choose(2, 3, 4, 5);
                var bh = choose(1, 2);
                arena_rect(irandom_range(3, w - bw - 3), irandom_range(3, h - bh - 3), bw, bh);
            }
            break;

        case 1: // server racks: a loose grid of 2x2 pillars
            for (var px = 4; px < w - 5; px += 6) {
                for (var py = 4; py < h - 5; py += 5) {
                    if (irandom(3) != 0) arena_rect(px, py, 2, 2);
                }
            }
            break;

        case 2: // wings: two long dividers and a cross wall, each with doorways
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

        case 3: // boss arena, tier 1
            arena_rect(5, 7, 3, 2);      arena_rect(w - 8, 7, 3, 2);
            arena_rect(w div 2 - 2, 10, 4, 2);
            arena_rect(5, 16, 3, 2);     arena_rect(w - 8, 16, 3, 2);
            arena_rect(w div 2 - 2, 15, 4, 1);
            break;

        default: // boss arena, tier 2
            arena_rect(6, 6, 3, 2);      arena_rect(w - 9, 6, 3, 2);
            arena_rect(w div 2 - 6, 12, 3, 2);  arena_rect(w div 2 + 3, 12, 3, 2);
            arena_rect(6, 21, 3, 2);     arena_rect(w - 9, 21, 3, 2);
            break;
    }

    // outer ring
    arena_rect(0, 0, w, 1);
    arena_rect(0, h - 1, w, 1);
    arena_rect(0, 0, 1, h);
    arena_rect(w - 1, 0, 1, h);

    // always keep the spawn area and a lane down to the exit door free
    var sx = global.spawn_cx;
    var sy = global.spawn_cy;
    arena_clear(sx - 2, sy - 2, 5, 5);
    arena_clear(w div 2 - 1, sy, 3, h - 1 - sy);

    if (info.boss) {
        var nodes = boss_node_cells(info.tier);
        for (var i = 0; i < array_length(nodes); i++) {
            arena_clear(1, nodes[i][1] - 1, 3, 3);                  // the socket and its surroundings
            arena_clear(1, nodes[i][1], w - 2, 1);                  // a clear firing lane across the room
        }
    }
}

// Every open cell reachable from (sx, sy), as a list of cell indices (x + y * width)
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

// (Re)builds the wall grid and the mp_grid used for enemy pathfinding
function build_arena(floor_n) {
    if (variable_global_exists("wall_grid") && ds_exists(global.wall_grid, ds_type_grid))
        ds_grid_destroy(global.wall_grid);
    if (variable_global_exists("cover_hp") && ds_exists(global.cover_hp, ds_type_grid))
        ds_grid_destroy(global.cover_hp);
    if (variable_global_exists("nav_grid") && global.nav_grid != -1)
        mp_grid_destroy(global.nav_grid);
    if (!variable_global_exists("nav_path") || !path_exists(global.nav_path))
        global.nav_path = path_add();   // one shared scratch path, never leaks

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
    fill_arena(info);

    // anything the player can't walk to becomes solid, so nothing ever spawns in a sealed pocket
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
    make_cover(info);              // boss floors: the pillars can be shot to pieces
    fill_zones(info, floor_n);     // traps: force fields, sludge, stasis pads, laser gates

    global.nav_grid = mp_grid_create(0, 0, info.w, info.h, TILE, TILE);
    for (var cx = 0; cx < info.w; cx++) {
        for (var cy = 0; cy < info.h; cy++) {
            if (global.wall_grid[# cx, cy] >= 1) mp_grid_add_cell(global.nav_grid, cx, cy);
        }
    }
    randomize();     // the layout is done, everything after it is random again
}

function cell_is_wall(cx, cy) {
    if (cx < 0 || cy < 0 || cx >= GRID_W || cy >= GRID_H) return true;
    return global.wall_grid[# cx, cy] >= 1;     // 1 = wall, 2 = force field (solid for everything)
}
function wall_at(px, py) { return cell_is_wall(px_to_cell(px), px_to_cell(py)); }

// Moves the calling instance, sliding along walls (circle approximated by a box)
function move_solid(dx, dy) {
    var r = 11;
    if (!wall_at(x + dx + sign(dx) * r, y - r) && !wall_at(x + dx + sign(dx) * r, y + r)) x += dx;
    if (!wall_at(x - r, y + dy + sign(dy) * r) && !wall_at(x + r, y + dy + sign(dy) * r)) y += dy;
}

// True if nothing solid is between two points (three parallel rays for body width)
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

// A* over the mp_grid. Returns [x, y] of the next tile centre, or undefined if no route.
function nav_next_point(tx, ty) {
    if (mp_grid_path(global.nav_grid, global.nav_path, x, y, tx, ty, false)
        && path_get_number(global.nav_path) > 1) {
        return [path_get_point_x(global.nav_path, 1), path_get_point_y(global.nav_path, 1)];
    }
    return undefined;
}

// A random reachable floor tile at least min_dist pixels from the player, as [x, y]
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

// weighted pick: [shooter, chaser, turret, dasher, sniper], more dangerous types appear on later floors
function pick_enemy_type() {
    var f = global.floor_num;
    var w;
    if (f <= 1)      w = [5, 2, 1, 1, 0];
    else if (f == 2) w = [4, 2, 2, 2, 1];
    else if (f <= 4) w = [4, 1, 2, 2, 2];
    else             w = [3, 1, 2, 2, 3];
    var names = ["shooter", "chaser", "turret", "dasher", "sniper"];
    if (instance_number(obj_enemy_turret) >= 2 + f div 2) w[2] = 0;     // turrets never pile up
    var total = 0;
    for (var i = 0; i < 5; i++) total += w[i];
    var r = random(total);
    for (var i = 0; i < 5; i++) {
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
        default:       return obj_enemy_shooter;
    }
}

function spawn_mob(t, px, py) {
    var m = instance_create_layer(px, py, "Instances", mob_object(t));
    fx_explode(px, py, 0.4);
    return m;
}

// living enemies (the generators and the mecha's power lines are also children of the enemy parent)
function mob_count() {
    return instance_number(obj_enemy_parent) - instance_number(obj_generator) - instance_number(obj_power_node);
}

// pixels you can fly from a point along a lane before hitting something solid (for warning lines)
function ray_length(px, py, dir, maxlen) {
    var l = 0;
    while (l < maxlen) {
        if (wall_at(px + lengthdir_x(l, dir), py + lengthdir_y(l, dir))) break;
        l += 12;
    }
    return min(l, maxlen);
}

// damage the rabbit, with the usual grace period
function hurt_player(n) {
    if (!instance_exists(obj_player) || !obj_player.alive) return;
    global.player_hp -= n;
    obj_player.invincible_timer = obj_player.invincible_max;
    if (instance_exists(obj_hud)) obj_hud.flash_timer = 22;
    if (global.player_hp <= 0) obj_player.alive = false;
}

// true when a point is inside the camera view (plus a margin)
function in_view(px, py, margin) {
    var cam = view_camera[0];
    var vx  = camera_get_view_x(cam);
    var vy  = camera_get_view_y(cam);
    return (px > vx - margin && px < vx + camera_get_view_width(cam) + margin
         && py > vy - margin && py < vy + camera_get_view_height(cam) + margin);
}

// A reachable floor tile for an objective item: far from the player and from the items already placed
function random_item_spot(min_player, used) {
    var count = array_length(global.open_cells);
    var spot  = [cell_to_px(GRID_W div 2), cell_to_px(GRID_H div 2)];
    for (var i = 0; i < 200; i++) {
        var idx = global.open_cells[irandom(count - 1)];
        spot = [cell_to_px(idx mod GRID_W), cell_to_px(idx div GRID_W)];
        var ok = true;
        if (instance_exists(obj_player) && point_distance(spot[0], spot[1], obj_player.x, obj_player.y) < min_player) ok = false;
        for (var j = 0; j < array_length(used); j++) {
            if (point_distance(spot[0], spot[1], used[j][0], used[j][1]) < 260) ok = false;
        }
        if (ok) break;
    }
    return spot;
}

// arrow around the player pointing at something that is off screen
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
        case "speed":        return "Step between tiles faster";
        case "fire_rate":    return "Shorter wait between shots";
        case "damage":       return "+1 damage per bullet";
        case "max_hp":       return "+1 max HP and heal 1";
        case "heal":         return "Restore 2 HP right now";
        case "bullet_speed": return "Bullets fly faster";
        case "pierce":       return "Bullets pass through 1 extra target";
        default:             return "";
    }
}


// ---- Visual helpers ----
function fx_explode(px, py, sc) {
    var f = instance_create_layer(px, py, "Instances", obj_fx_explosion);
    f.sc = sc;
    return f;
}

// 0 = right, 1 = left, 2 = down, 3 = up  (GML angle in degrees)
function dir_from_angle(a) {
    a = ((a mod 360) + 360) mod 360;
    if (a >= 45  && a < 135) return 3;
    if (a >= 135 && a < 225) return 1;
    if (a >= 225 && a < 315) return 2;
    return 0;
}

// set = [idle_down, idle_side, idle_up, walk_down, walk_side, walk_up]
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

// the player is a lab rabbit: bunny ears on top of the humanoid sprite
// top = y of the head's top pixel inside the 32x32 frame
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

// crackling power cable between two points
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
        // energy pulse travelling toward the node
        var pulse = frac(t * 0.02 - f);
        if (pulse < 0.12) {
            draw_set_color(make_color_rgb(255, 255, 200));
            draw_line_width(lx, ly, nx, ny, 3);
        }
        lx = nx; ly = ny;
    }
    draw_set_color(c_white);
}


// ---- Camera ----
// Follows the player and never shows anything outside the arena.
// snap = true jumps straight to the target (floor start), otherwise it eases.
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


// ---- Floor zones (traps) ----
// FIELD   force field: solid for you, enemies and bullets (a solid cell in wall_grid, value 2)
// SLOW    sludge: your steps take much longer (so the world runs longer), enemies crawl
// STASIS  pad: stepping on it holds you in place for a moment while time keeps running (you can still shoot)
// GATE_A / GATE_B  laser gates that switch on and off in turns. A live gate blocks you, and burns you if it switches on under you
#macro ZONE_NONE   0
#macro ZONE_FIELD  1
#macro ZONE_SLOW   2
#macro ZONE_STASIS 3
#macro ZONE_GATE_A 4
#macro ZONE_GATE_B 5
#macro GATE_PERIOD 300

function gate_active(z) {
    var t = global.gate_t mod GATE_PERIOD;
    if (z == ZONE_GATE_A) return (t < 130);
    return (t >= 150 && t < 280);
}
// the 30 frames before a gate switches on
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

// can the rabbit step onto this tile right now?
function player_blocked(cx, cy) {
    if (cell_is_wall(cx, cy)) return true;
    var z = zone_at_cell(cx, cy);
    return (is_gate(z) && gate_active(z));
}

// spots where a trap is allowed: never near the spawn, the exit lane, or (boss floors) the mecha's firing lanes
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

// Drops one rectangular patch somewhere valid. Solid kinds (field, gate) must not cut the level in two.
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
            if (after != before - pw * ph) {                         // it sealed something off: undo
                ds_grid_set_region(global.wall_grid, x0, y0, x0 + pw - 1, y0 + ph - 1, 0);
                continue;
            }
            if (kind != ZONE_FIELD) ds_grid_set_region(global.wall_grid, x0, y0, x0 + pw - 1, y0 + ph - 1, 0);  // gates are only solid while live
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
    var k    = min(1, 0.6 + 0.1 * floor_n);          // a gentler first floor
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

    // force fields are solid now, so they leave the list of cells things can spawn on
    global.open_cells = arena_flood(global.spawn_cx, global.spawn_cy);
}

// draws the overlay for one trap tile (called from the background, visible tiles only)
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

// ---- Boss bullet formations ----
// offsets are in tiles, written for a formation flying DOWN: +dx is to the right, +dy is ahead of the formation
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
        case "triangle":                                           // flat base behind, apex ahead
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
        case "chevron":                                            // a V with the point ahead
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

// turns a "flying down" offset into one for a formation flying in dir (0 right, 90 up, 180 left, 270 down)
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


// ---- Destructible cover ----
// wall_grid value 3 = cover: solid like a wall, but enemy bullets chew through it (and the mecha smashes it).
// Boss floors turn every interior pillar into cover; destroyed generators leave scrap cover behind.
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

// wrecks every cover tile under a pixel rectangle (the mecha's body, claw and charge)
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
    if (abs(cx - GRID_W div 2) <= 1 && cy >= global.spawn_cy) return;           // keep the exit lane open
    var px = cell_to_px(cx), py = cell_to_px(cy);
    if (instance_exists(obj_player) && point_distance(px, py, obj_player.x, obj_player.y) < TILE * 0.9) return;
    var near = instance_nearest(px, py, obj_enemy_parent);
    if (near != noone && point_distance(px, py, near.x, near.y) < 40) return;
    global.wall_grid[# cx, cy] = 3;
    global.cover_hp[# cx, cy]  = hp;
    mp_grid_add_cell(global.nav_grid, cx, cy);
}

// a wrecked generator leaves scrap: its tile and two neighbours become low cover
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
    draw_set_color(make_color_rgb(255, 200, 40));            // hazard border: this one can be destroyed
    draw_rectangle(x0 + 1, y0 + 1, x0 + TILE - 2, y0 + TILE - 2, true);
    draw_set_color(C_INK);
    if (ratio < 0.85) draw_line_width(x0 + 10, y0 + 8,  x0 + 22, y0 + 26, 2);
    if (ratio < 0.65) draw_line_width(x0 + 22, y0 + 26, x0 + 14, y0 + 40, 2);
    if (ratio < 0.45) draw_line_width(x0 + 32, y0 + 6,  x0 + 36, y0 + 30, 2);
    if (ratio < 0.25) draw_line_width(x0 + 36, y0 + 30, x0 + 26, y0 + 44, 2);
    draw_set_color(c_white);
}


// moves a hand-placed enemy onto the nearest walkable tile (the walls are generated, so it may have landed inside one)
function snap_to_open_cell() {
    var cx = clamp(px_to_cell(x), 1, GRID_W - 2);
    var cy = clamp(px_to_cell(y), 1, GRID_H - 2);
    if (!cell_is_wall(cx, cy)) { x = cell_to_px(cx); y = cell_to_px(cy); return; }
    for (var r = 1; r <= 8; r++) {
        for (var dx = -r; dx <= r; dx++) {
            for (var dy = -r; dy <= r; dy++) {
                if (max(abs(dx), abs(dy)) != r) continue;
                if (!cell_is_wall(cx + dx, cy + dy)) { x = cell_to_px(cx + dx); y = cell_to_px(cy + dy); return; }
            }
        }
    }
}
