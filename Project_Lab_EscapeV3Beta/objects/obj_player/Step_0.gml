if (!alive) {
    death_timer++;
    if (death_timer >= 100) room_goto(room_gameover);
    exit;
}
if (global.is_upgrade_phase) { global.time_scale = 0; exit; }

var ix = (keyboard_check(ord("D")) || keyboard_check(vk_right)) - (keyboard_check(ord("A")) || keyboard_check(vk_left));
var iy = (keyboard_check(ord("S")) || keyboard_check(vk_down))  - (keyboard_check(ord("W")) || keyboard_check(vk_up));
if (stuck_t > 0) { stuck_t--; ix = 0; iy = 0; }

var zhere = zone_at(x, y);
var spd   = global.player_speed * ((zhere == ZONE_SLOW) ? 0.5 : 1);
var tvx   = 0;
var tvy   = 0;
if (ix != 0 || iy != 0) {
    var il = point_distance(0, 0, ix, iy);
    tvx = ix / il * spd;
    tvy = iy / il * spd;
}
var acc = (zhere == ZONE_ICE) ? 0.05 : 0.45;
vx = lerp(vx, tvx, acc);
vy = lerp(vy, tvy, acc);
if (abs(vx) < 0.04) vx = 0;
if (abs(vy) < 0.04) vy = 0;

var ox = x;
var oy = y;
move_free(vx, vy, 11);
if (vx != 0 && abs(x - ox) < 0.001) vx = 0;
if (vy != 0 && abs(y - oy) < 0.001) vy = 0;

is_moving = (point_distance(0, 0, vx, vy) > 0.9);

if (zhere == ZONE_STASIS && stasis_cd <= 0 && stuck_t <= 0) {
    stuck_t   = 60;
    stasis_cd = 150;
    vx = 0;
    vy = 0;
}
if (stasis_cd > 0) stasis_cd--;

var target = (is_moving || stuck_t > 0) ? 1 : SLOW_TS;
global.time_scale = lerp(global.time_scale, target, (target > global.time_scale) ? 0.4 : 0.14);
var ts = global.time_scale;

aim_ang  = point_direction(x, y, mouse_x, mouse_y);
face_dir = dir_from_angle(aim_ang);

if (keyboard_check_pressed(ord("Q"))) global.auto_fire = !global.auto_fire;
fire_timer -= is_moving ? 1 : ts;
var wants = mouse_check_button(mb_left) || keyboard_check(vk_space) || keyboard_check(ord("J")) || (global.auto_fire && is_moving);
if (wants && fire_timer <= 0) {
    fire_timer = global.player_fire_rate;
    fire_weapon(aim_ang);
}
if (echo_t > 0) {
    echo_t--;
    if (echo_t == 0) {
        global.shot_dmg = player_damage_now();
        fire_weapon_raw(echo_ang);
    }
}

if (is_gate(zhere) && gate_active(zhere) && invincible_timer <= 0) hurt_player(1);

anim_t += is_moving ? 0.3 : 0.05;
if (invincible_timer > 0) invincible_timer -= max(0.35, ts);

if (global.door_open && !global.is_upgrade_phase) {
    var door = instance_nearest(x, y, obj_exit_door);
    if (door != noone && point_distance(x, y, door.x, door.y) < 30) {
        if (global.floor_num >= global.max_floors) {
            room_goto(room_win);
        } else {
            global.is_upgrade_phase = true;
            instance_create_layer(0, 0, "Instances", obj_upgrade_ui);
        }
    }
}
