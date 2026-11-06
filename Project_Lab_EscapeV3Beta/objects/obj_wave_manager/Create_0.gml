start_checked = false;
placed_start  = 0;
state        = "briefing";
timer        = 100;
door_created = false;
boss_id      = noone;
boss_spawned = false;

open_exit = function() {
    state = "floor_done";
    if (!door_created) {
        door_created = true;
        instance_create_layer(cell_to_px(GRID_W div 2), cell_to_px(GRID_H - 2), "Instances", obj_exit_door);
        global.door_open = true;
    }
};

objectives = [];
global.objectives = objectives;
init_left  = 0;
init_t     = 0;
reinf_t    = 0;
has_survive = false;

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

    enemy_cap       = 8 + 2 * global.floor_num + (has_survive ? 3 : 0);
    reinf_interval  = max(110, 300 - global.floor_num * 30) * (has_survive ? 0.7 : 1);
}
