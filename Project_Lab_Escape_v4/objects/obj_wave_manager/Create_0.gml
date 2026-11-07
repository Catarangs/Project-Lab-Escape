start_checked = false;
hint_t = 1500;
threat = floor_threat(global.floor_num);
has_threat = is_struct(threat);
threat_t = has_threat ? threat.time : 0;
surge_n = 0;
surge_t = 0;
cells_prev = 0;
hunt_t = 0;
hunt_max = 1;
hunt_n = 0;
global.exit_cx = -100;
global.exit_cy = -100;
var ec = pick_exit_cell();
global.exit_cx = ec[0];
global.exit_cy = ec[1];
placed_start  = 0;
state        = "briefing";
timer        = 240;
door_created = false;
boss_id      = noone;
boss_spawned = false;

open_exit = function() {
    state = "floor_done";
    if (!door_created) {
        door_created = true;
        instance_create_layer(cell_to_px(global.exit_cx), cell_to_px(global.exit_cy), "Instances", obj_exit_door);
        global.door_open = true;
    }
};

objectives = [];
global.objectives = objectives;
init_left  = 0;
init_t     = 0;
reinf_t    = 0;
has_survive = false;

do_surge = function() {
    if (!has_threat) return;
    surge_n++;
    surge_t = 150;
    threat_t = threat.again;
    if (instance_exists(obj_player)) {
        fx_explode(obj_player.x, obj_player.y, 2.4);
        if (global.player_hp > 1) hurt_player(1);
    }
    if (instance_exists(obj_hud)) obj_hud.flash_timer = 22;
    repeat (3 + surge_n) {
        var sp = random_spawn_point(380);
        spawn_mob(choose("chaser", "chaser", "dasher"), sp[0], sp[1]);
    }
};

spawn_group = function(n) {
    repeat (n) {
        var sp = random_spawn_point(420);
        var t = pick_enemy_type();
        if (global.floor_num == 4 && random(1) < 0.5) t = choose("chaser", "dasher");
        spawn_mob(t, sp[0], sp[1]);
    }
};

spawn_enemy = function() {
    var sp = random_spawn_point(520);
    spawn_mob(pick_enemy_type(), sp[0], sp[1]);
};

var med_used = [];
for (var i = 0; i < 4 + global.floor_num; i++) {
    var mspot = random_item_spot(200, med_used);
    array_push(med_used, mspot);
    instance_create_layer(mspot[0], mspot[1], "Instances", obj_medkit);
}

if (floor_info(global.floor_num).boss) {
    state = "boss_intro";
    timer = 150;
    var gcells = boss_gen_cells(floor_info(global.floor_num).tier);
    for (var gi = 0; gi < array_length(gcells); gi++) {
        instance_create_layer(cell_to_px(gcells[gi][0]), cell_to_px(gcells[gi][1]), "Instances", obj_overload);
    }
} else {
    objectives = floor_objectives(global.floor_num);
    global.objectives = objectives;

    var used = [];
    for (var i = 0; i < array_length(objectives); i++) {
        var o = objectives[i];
        if (o.kind == "survive") { has_survive = true; continue; }
        for (var n = 0; n < o.goal; n++) {
            var spot = random_item_spot(300, used);
            array_push(used, spot);
            if (o.kind == "collect") {
                var pk = instance_create_layer(spot[0], spot[1], "Instances", obj_pickup);
                pk.item = o.item;
            } else {
                instance_create_layer(spot[0], spot[1], "Instances", obj_generator);
            }
        }
    }

    enemy_cap       = 10 + 3 * global.floor_num + (has_survive ? 4 : 0) + ((has_threat) ? 4 : 0);
    reinf_interval  = max(70, 240 - global.floor_num * 24) * (has_survive ? 0.7 : 1);
    hunt_max        = max(660, 1500 - global.floor_num * 90);
    hunt_t          = hunt_max;
}
