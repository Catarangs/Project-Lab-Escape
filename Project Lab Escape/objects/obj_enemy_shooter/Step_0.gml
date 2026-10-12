
if (dying) exit;
if (!instance_exists(obj_player) || !obj_player.alive) exit;


var dist   = point_distance(x, y, obj_player.x, obj_player.y);
var to_pl  = point_direction(x, y, obj_player.x, obj_player.y);
var mdir;

if      (dist < pref_dist - 25) mdir = to_pl + 180;         
else if (dist > pref_dist + 25) mdir = to_pl;               
else                             mdir = to_pl + 90 + irandom(1)*180; 
x += lengthdir_x(spd * global.time_scale, mdir);
y += lengthdir_y(spd * global.time_scale, mdir);
x = clamp(x, 50, room_width  - 50);
y = clamp(y, 50, room_height - 50);

shoot_timer -= global.time_scale;
if (shoot_timer <= 0) {
    shoot_timer = shoot_rate;
    var num   = 1 + (global.floor_num >= 3 ? 1 : 0);
    var spread= (num - 1) * 18;
    var base  = point_direction(x, y, obj_player.x, obj_player.y);
    for (var i = 0; i < num; i++) {
        var ang = base + (num > 1 ? (-spread/2 + spread/(num-1)*i) : 0);
        var b   = instance_create_layer(x, y, "Bullets", obj_bullet_enemy);
        b.bdir  = ang;
        b.bspd  = 3.5 + global.floor_num * 0.4;
        b.depth = -120;
    }
}
