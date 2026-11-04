// The mecha: its armour is immune. Shoot its power lines (nodes) to shut it down.
// It fights with telegraphed bullet formations (diamonds, triangles, squares, chevrons, X and plus shapes),
// bullet rain, aimed lances, laser beams and minion summons. Every bullet flies along a row or a column.
tier        = floor_info(global.floor_num).tier;
state       = "intro";      // intro -> fight -> down -> dead
intro_timer = 110;
depth       = -80;

node_cells  = boss_node_cells(tier);
nodes_total = array_length(node_cells);
prev_alive  = nodes_total;
phase       = 0;            // how many power lines have been cut
rage        = false;        // last power line left: faster and meaner

attack_cd    = 70;
pattern      = "";
last_pattern = "";
pattern_count = 0;
since_special = 0;
volleys_left = 0;
volley_wait  = 0;
wind_t       = 0;           // telegraph timer: the ghost shapes show where bullets are about to appear
wind_max     = 1;
ghosts       = [];          // shapes waiting to be released
beams        = [];          // laser beams (warning, then live)
stream_t     = 0;
stream_next  = 0;

// ---- the mecha hovers over the arena and hunts the player ----
hit_w    = 100;          // half size of its hitbox (it is 288 x 144 on screen)
hit_h    = 50;
goto_x   = x;
goto_y   = y;
goto_spd = 0;
stride_t = 0;            // running time since its last 3-tile stride (21 frames = 3 player steps)
mode     = "hunt";       // hunt, claw_wind, claw_hit, charge_align, charge_wind, charge_dash, charge_rest
mode_t   = 0;
mode_max = 1;
claw_dir = 0;
claw_n   = 0;
claw_r   = [0, 0, 0, 0];
charge_h = true;
charge_dir = 0;
charge_tx = 0;
charge_ty = 0;
shake        = 0;
flash        = 0;
down_t       = 0;

// ---- helpers ----
fire = function(px, py, dir, spd, col = -1) {
    var b = instance_create_layer(px, py, "Bullets", obj_bullet_enemy);
    b.bdir  = dir;
    b.bspd  = spd * 3;       // formation speeds below are written small; this is about 1 to 1.5 tiles per player step
    b.ramp  = false;         // formations appear mid-room, so no slow first step
    b.depth = -120;
    if (col != -1) b.bcol = col;
    return b;
};

end_pattern = function(cd) {
    pattern   = "";
    attack_cd = cd;
};

// queues a ghost formation. anchor = column when flying down, row when flying in from a side wall
add_ghost = function(kind, r, dir, spd, anchor) {
    var base = shape_cells(kind, r);
    var rot  = [];
    var mnx = 999, mxx = -999, mny = 999;
    for (var i = 0; i < array_length(base); i++) {
        var p = rot_offset(base[i], dir);
        array_push(rot, p);
        mnx = min(mnx, p[0]);
        mxx = max(mxx, p[0]);
        mny = min(mny, p[1]);
    }
    var gx, gy;
    if (dir == 270)    { gx = anchor;                gy = 1 - mny; }     // formations drop in from the ceiling vents
    else if (dir == 0) { gx = 1 - mnx;               gy = anchor; }      // enters at the left wall
    else               { gx = GRID_W - 2 - mxx;      gy = anchor; }      // enters at the right wall
    var cells = [];
    for (var i = 0; i < array_length(rot); i++) {
        var cx = gx + rot[i][0];
        var cy = gy + rot[i][1];
        if (!cell_is_wall(cx, cy)) array_push(cells, [cell_to_px(cx), cell_to_px(cy)]);
    }
    array_push(ghosts, { cells: cells, dir: dir, spd: spd, col: shape_color(kind) });
};

// one telegraphed volley of a shape: the main one is aimed at the player, spares are spread around it
shape_volley = function(kind, r, dir, spd, anchor, wind) {
    var gw = GRID_W;
    var gh = GRID_H;
    if (dir == 270) {
        var a1 = clamp(anchor, r + 1, gw - r - 2);
        add_ghost(kind, r, dir, spd, a1);
        var mir = gw - 1 - a1;
        if (abs(mir - a1) > 2 * r + 1) add_ghost(kind, r, dir, spd, mir);
        if (phase >= 2 || tier >= 2) {
            var c2 = irandom_range(r + 1, gw - r - 2);
            if (abs(c2 - a1) > 2 * r + 1 && abs(c2 - mir) > 2 * r + 1) add_ghost(kind, r, dir, spd, c2);
        }
    } else {
        var a1 = clamp(anchor, 4 + r, gh - 2 - r);
        add_ghost(kind, r, dir, spd, a1);
        if (phase >= 1 || tier >= 2) {
            var a2 = clamp(a1 + choose(-1, 1) * (2 * r + 3), 4 + r, gh - 2 - r);
            if (abs(a2 - a1) > 2 * r + 1) add_ghost(kind, r, dir, spd, a2);
        }
    }
    wind_t   = wind;
    wind_max = wind;
};

release_ghosts = function() {
    for (var i = 0; i < array_length(ghosts); i++) {
        var g = ghosts[i];
        for (var j = 0; j < array_length(g.cells); j++) fire(g.cells[j][0], g.cells[j][1], g.dir, g.spd, g.col);
    }
    ghosts = [];
};

add_beam = function(vertical, cell) {
    var b = { v: vertical, t: 0, warn: 55, live: 36, px: 0, py: 0, len: 0, w: 2 * TILE };   // boss beams are 2 tiles wide
    if (vertical) {
        b.px  = (cell + 1) * TILE;                       // centred on the line between two columns
        b.py  = cell_to_px(1);
        b.len = global.arena_h - b.py;                 // lasers ignore walls and cover
    } else {
        b.px  = cell_to_px(1);
        b.py  = (cell + 1) * TILE;                       // centred on the line between two rows
        b.len = global.arena_w - 2 * TILE;
    }
    array_push(beams, b);
};

choose_pattern = function() {
    var pool = ["diamonds", "triangles", "rain"];
    if (tier >= 2) { array_push(pool, "lance"); array_push(pool, "chevrons"); }
    if (phase >= 1) {
        if (tier < 2) { array_push(pool, "chevrons"); array_push(pool, "lance"); }
        array_push(pool, "beams");
        array_push(pool, "squares");
    }
    if (tier >= 2 && phase >= 2) { array_push(pool, "stream"); array_push(pool, "xcross"); }

    var pick = pool[irandom(array_length(pool) - 1)];
    for (var i = 0; i < 6 && pick == last_pattern; i++) pick = pool[irandom(array_length(pool) - 1)];

    // every fifth attack calls in reinforcements while the floor is quiet
    if (pattern_count mod 5 == 4 && (phase >= 1 || tier >= 2) && mob_count() < 5) pick = "summon";
    // now and then a special: a claw swipe when you are close, a charge when you are far.
    // Random timing (never back to back, never more than 4 attacks apart) so it can't be predicted.
    since_special++;
    if (since_special >= 2 && instance_exists(obj_player) && (random(1) < 0.35 || since_special >= 5)) {
        pick = (point_distance(x, y, obj_player.x, obj_player.y) <= 7.5 * TILE) ? "claw" : "charge";
        since_special = 0;
    }

    pattern       = pick;
    last_pattern  = pick;
    pattern_count++;
    ghosts        = [];
    wind_t        = 0;
    volley_wait   = 20;
    var extra = rage ? 1 : 0;
    switch (pick) {
        case "diamonds":  volleys_left = 3 + extra; break;
        case "triangles": volleys_left = 3 + extra; break;
        case "squares":   volleys_left = 2 + extra; break;
        case "chevrons":  volleys_left = 4 + extra; break;
        case "xcross":    volleys_left = 3 + extra; break;
        case "rain":      volleys_left = 3 + extra; break;
        case "lance":     volleys_left = 4 + extra; break;
        case "beams":     volleys_left = 3;         break;
        default:          volleys_left = 1;         break;     // summon, stream, claw, charge
    }
    if (pick == "claw")   begin_claw();
    if (pick == "charge") begin_charge();
};

do_volley = function() {
    var gw  = GRID_W;
    var gh  = GRID_H;
    var pcx = instance_exists(obj_player) ? px_to_cell(obj_player.x) : gw div 2;
    var pcy = instance_exists(obj_player) ? px_to_cell(obj_player.y) : gh div 2;
    var sp  = 1 + 0.1 * phase + (rage ? 0.2 : 0);
    var wind = max(32, 56 - 6 * phase - (rage ? 8 : 0));
    var oy_px = cell_to_px(1);                  // rain and lances fall from the ceiling vents

    switch (pattern) {
        case "diamonds":  shape_volley("diamond",  (phase >= 1 || tier >= 2) ? 3 : 2, 270, 2.5 * sp, pcx, wind); break;
        case "triangles": shape_volley("triangle", 3, 270, 2.5 * sp, pcx, wind); break;
        case "squares":   shape_volley("square",   2, 270, 2.4 * sp, pcx, wind); break;
        case "xcross":    shape_volley((volleys_left mod 2 == 0) ? "x" : "plus", 3, 270, 2.5 * sp, pcx, wind); break;
        case "chevrons":  shape_volley("chevron",  4, (volleys_left mod 2 == 0) ? 0 : 180, 3.1 * sp, pcy, wind); break;

        case "rain":   // a curtain of bullets falling down every column except a few gaps
            var period = (phase >= 1 || tier >= 2) ? 3 : 4;
            var off    = irandom(period - 1);
            for (var c = 2; c < gw - 2; c++) {
                if ((c + off) mod period == 0) continue;
                fire(cell_to_px(c), oy_px, 270, 2.2 * sp);
            }
            volley_wait = 52;
            break;

        case "lance":  // columns dropped on wherever the player stands, re-aimed every volley
            var span = (phase >= 2 || tier >= 2) ? 2 : 1;
            for (var i = -span; i <= span; i++) fire(cell_to_px(clamp(pcx + i, 2, gw - 3)), oy_px, 270, 3.4 * sp, make_color_rgb(255, 120, 200));
            volley_wait = 30;
            break;

        case "beams":  // laser beams: a thin warning line, then a burning column or row
            var cols = [clamp(pcx - irandom(1), 2, gw - 4)];
            var want = (phase >= 1 || tier >= 2) ? 3 : 2;
            for (var tries = 0; tries < 20 && array_length(cols) < want; tries++) {
                var cc = irandom_range(2, gw - 4);
                var far = true;
                for (var j = 0; j < array_length(cols); j++) { if (abs(cc - cols[j]) < 4) far = false; }
                if (far) array_push(cols, cc);
            }
            for (var j = 0; j < array_length(cols); j++) add_beam(true, cols[j]);
            if (phase >= 1 || tier >= 2) add_beam(false, clamp(pcy - irandom(1), 5, gh - 4));
            volley_wait = 82;
            break;

        case "stream": // a falling snake of bullets that weaves across the room
            stream_t    = 200;
            stream_next = 0;
            break;

        case "summon":
            var n = 2 + phase + ((tier >= 2) ? 1 : 0);
            for (var i = 0; i < n; i++) {
                var spot = random_spawn_point(380);
                spawn_mob(choose("chaser", "dasher", "shooter", "sniper"), spot[0], spot[1]);
            }
            volley_wait = 70;
            break;
    }
};
// ---- special attacks ----
// claw: a red slab in front of the mecha shows where it will slam down
aim_claw = function(wind) {
    claw_dir = snap_dir(point_direction(x, y, obj_player.x, obj_player.y));
    switch (claw_dir) {
        case 0:   claw_r = [x + hit_w - 10,   y - 120,           x + hit_w + 150, y + 120];          break;
        case 180: claw_r = [x - hit_w - 150,  y - 120,           x - hit_w + 10,  y + 120];          break;
        case 270: claw_r = [x - 120,          y + hit_h - 10,    x + 120,         y + hit_h + 150];  break;
        default:  claw_r = [x - 120,          y - hit_h - 150,   x + 120,         y - hit_h + 10];   break;
    }
    mode     = "claw_wind";
    mode_t   = wind;
    mode_max = wind;
};
begin_claw = function() {
    claw_n = (phase >= 1 || tier >= 2) ? 2 : 1;
    aim_claw(rage ? 38 : 50);
};

// charge: it lines up with you, shows its lane, then dashes across the room
begin_charge = function() {
    charge_h = (abs(obj_player.x - x) >= abs(obj_player.y - y));
    if (charge_h) { goto_x = x; goto_y = clamp(obj_player.y, TILE * 1.6, global.arena_h - TILE * 1.6); }
    else          { goto_y = y; goto_x = clamp(obj_player.x, TILE * 2.4, global.arena_w - TILE * 2.4); }
    goto_spd = 12;
    mode     = "charge_align";
};

// ---- power line sockets ----
for (var i = 0; i < nodes_total; i++) {
    instance_create_layer(cell_to_px(node_cells[i][0]), cell_to_px(node_cells[i][1]), "Instances", obj_power_node);
}
