if (!alive) {
    death_timer++;
    if (death_timer >= 100) room_goto(room_gameover);
    exit;
}
if (global.is_upgrade_phase) { global.time_scale = 0; exit; }

// ---- Block-by-block input (one tile per move, no diagonals) ----
var dirs = [vk_right, vk_left, vk_down, vk_up];
var alts = [ord("D"), ord("A"), ord("S"), ord("W")];
var dx_t = [1, -1, 0, 0];
var dy_t = [0, 0, 1, -1];
var face_ang = [0, 180, 270, 90];

var want = -1;
var held = -1;
for (var i = 0; i < 4; i++) {
    var down = keyboard_check(dirs[i]) || keyboard_check(alts[i]);
    var hit  = keyboard_check_pressed(dirs[i]) || keyboard_check_pressed(alts[i]);
    if (hit)  last_dir_key = i;
    if (down) held = i;
}
// Prefer the newest press, otherwise any held key
if (held != -1) {
    want = held;
    if (last_dir_key != -1
        && (keyboard_check(dirs[last_dir_key]) || keyboard_check(alts[last_dir_key]))) {
        want = last_dir_key;
    }
} else {
    last_dir_key = -1;
}

var slide_frames = max(4, ceil(TILE / (global.player_speed * 2)));

// Finish / advance the current slide
if (sliding) {
    slide_t += 1 / cur_frames;
    if (slide_t >= 1) {
        slide_t = 1;
        sliding = false;
        grid_x = px_to_cell(slide_to_x);
        grid_y = px_to_cell(slide_to_y);
        if (zone_at_cell(grid_x, grid_y) == ZONE_STASIS) stuck_t = 70;     // stasis pad: held in place
    }
    var e = 1 - power(1 - slide_t, 2);       // ease-out
    x = lerp(slide_from_x, slide_to_x, e);
    y = lerp(slide_from_y, slide_to_y, e);
}

// Start a new step (also chains straight into the next one when a key is held)
if (!sliding && want != -1 && stuck_t <= 0) {
    var tx = grid_x + dx_t[want];
    var ty = grid_y + dy_t[want];
    face_dir   = want;
    angle_face = face_ang[want];
    // walls, force fields and live laser gates block the step
    if (!player_blocked(tx, ty)) {
        // sludge on the tile you leave or the tile you enter slows the whole step
        var slowed = (zone_at_cell(tx, ty) == ZONE_SLOW || zone_at_cell(grid_x, grid_y) == ZONE_SLOW);
        cur_frames   = slowed ? ceil(slide_frames * 2.6) : slide_frames;
        sliding      = true;
        slide_t      = 0;
        slide_from_x = x;
        slide_from_y = y;
        slide_to_x   = cell_to_px(tx);
        slide_to_y   = cell_to_px(ty);
        move_dir_x   = dx_t[want];
        move_dir_y   = dy_t[want];
    }
}

// ---- Manual fire: space / J shoots the way you face, left click shoots toward the mouse ----
// Bullets only ever travel along a row or a column.
if (fire_timer > 0) fire_timer--;
var click = mouse_check_button(mb_left);
if ((keyboard_check(vk_space) || keyboard_check(ord("J")) || click) && fire_timer <= 0) {
    var shot_ang = click ? snap_dir(point_direction(x, y, mouse_x, mouse_y)) : face_ang[face_dir];
    face_dir   = dir_from_angle(shot_ang);
    angle_face = shot_ang;
    fire_timer = global.player_fire_rate;
    act_timer  = 10;
    var b = instance_create_layer(x + lengthdir_x(16, shot_ang), y + lengthdir_y(16, shot_ang), "Bullets", obj_bullet_player);
    b.bdir   = shot_ang;
    b.bspd   = global.player_bullet_speed;
    b.bdmg   = global.player_damage;
    b.pierce = global.player_pierce;
    b.depth  = -150;
}
if (act_timer > 0) act_timer--;

// Time only runs while you act: a step, or the moment after a shot.
// Standing still freezes every enemy and every bullet.
if (stuck_t > 0) stuck_t--;
global.time_scale = (sliding || act_timer > 0 || stuck_t > 0) ? 1 : 0;

// a laser gate that switches on while you stand in it burns you
var zhere = zone_at_cell(grid_x, grid_y);
if (!sliding && is_gate(zhere) && gate_active(zhere) && invincible_timer <= 0) hurt_player(1);

anim_t += sliding ? 0.3 : 0.05;

if (invincible_timer > 0 && global.time_scale > 0) invincible_timer--;

if (global.door_open && !global.is_upgrade_phase) {
    var door = instance_nearest(x, y, obj_exit_door);
    if (door != noone && !sliding && grid_x == px_to_cell(door.x) && grid_y == px_to_cell(door.y)) {
        if (global.floor_num >= global.max_floors) {
            room_goto(room_win);          // final floor: the rabbit escapes!
        } else {
            global.is_upgrade_phase = true;
            instance_create_layer(0, 0, "Instances", obj_upgrade_ui);
        }
    }
}
