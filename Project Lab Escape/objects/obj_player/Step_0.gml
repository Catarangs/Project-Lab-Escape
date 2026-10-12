if (!alive) {
    death_timer++;
    if (death_timer >= 100) room_goto(room_gameover);
    exit;
}
if (global.is_upgrade_phase) exit;

var inp_x = (keyboard_check(ord("D")) || keyboard_check(vk_right))
          - (keyboard_check(ord("A")) || keyboard_check(vk_left));
var inp_y = (keyboard_check(ord("S")) || keyboard_check(vk_down))
          - (keyboard_check(ord("W")) || keyboard_check(vk_up));

var is_moving = (inp_x != 0 || inp_y != 0);

var ts_target = is_moving ? global.norm_time_target : global.slow_time_target;
global.time_scale = lerp(global.time_scale, ts_target, 0.18);

if (is_moving) {
    var mag = sqrt(inp_x*inp_x + inp_y*inp_y);
    move_dir_x = inp_x / mag;
    move_dir_y = inp_y / mag;
    x += move_dir_x * global.player_speed;
    y += move_dir_y * global.player_speed;
}

var wall = 40;
x = clamp(x, wall, room_width  - wall);
y = clamp(y, wall, room_height - wall);

var nearest = instance_nearest(x, y, obj_enemy_parent);
if (nearest != noone && is_moving) {
    angle_face = point_direction(x, y, nearest.x, nearest.y);
} else if (is_moving) {
    angle_face = point_direction(0, 0, inp_x, -inp_y);
}
if (is_moving) {
    fire_timer--;
    if (fire_timer <= 0) {
        fire_timer = global.player_fire_rate;
        var tgt = instance_nearest(x, y, obj_enemy_parent);
        if (tgt != noone) {
            var bdir = point_direction(x, y, tgt.x, tgt.y);
            var b = instance_create_layer(x, y, "Bullets", obj_bullet_player);
            b.bdir   = bdir;
            b.bspd   = global.player_bullet_speed;
            b.bdmg   = global.player_damage;
            b.pierce = global.player_pierce;
            b.depth  = -150;
        }
    }
}

if (invincible_timer > 0) invincible_timer--;

if (global.door_open && !global.is_upgrade_phase) {
    var door = instance_nearest(x, y, obj_exit_door);
    if (door != noone && point_distance(x, y, door.x, door.y) < 40) {
        global.is_upgrade_phase = true;
        instance_create_layer(0, 0, "Instances", obj_upgrade_ui);
    }
}
