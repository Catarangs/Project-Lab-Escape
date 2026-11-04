ui_init();

// stats persist from floor to floor; they only reset when a new run starts from the title screen
if (!variable_global_exists("new_run") || global.new_run) {
    global.new_run = false;
    global.player_max_hp       = 5;
    global.player_hp           = 5;
    global.player_speed        = 3.5;
    global.player_fire_rate    = 22;
    global.player_damage       = 1;
    global.player_bullet_speed = 10;
    global.player_pierce       = 0;

    global.floor_num      = 1;
    global.max_floors     = 6;
    global.wave_num       = 0;
    global.waves_per_floor= 3;
    global.total_kills    = 0;
    global.score          = 0;
}

// 1 while the player acts (steps or fires), 0 when everything is frozen
global.time_scale = 0;

global.is_upgrade_phase = false;
global.door_open        = false;

global.objectives = [];     // this floor's objectives, filled in by the wave manager

// sprite sets: [idle_down, idle_side, idle_up, walk_down, walk_side, walk_up]
global.set_player = [spr_player_idle_d, spr_player_idle_s, spr_player_idle_u, spr_player_walk_d, spr_player_walk_s, spr_player_walk_u];
global.set_guard  = [spr_guard_idle_d,  spr_guard_idle_s,  spr_guard_idle_u,  spr_guard_walk_d,  spr_guard_walk_s,  spr_guard_walk_u];
global.set_tech   = [spr_tech_idle_d,   spr_tech_idle_s,   spr_tech_idle_u,   spr_tech_walk_d,   spr_tech_walk_s,   spr_tech_walk_u];
global.set_dash   = [spr_dash_idle_d,   spr_dash_idle_s,   spr_dash_idle_u,   spr_dash_walk_d,   spr_dash_walk_s,   spr_dash_walk_u];
global.set_sniper = [spr_sniper_idle_d, spr_sniper_idle_s, spr_sniper_idle_u, spr_sniper_walk_d, spr_sniper_walk_s, spr_sniper_walk_u];

global.gate_t = 0;

// the room decides the floor (so any floor room can also be test-run from the editor)
for (var f = 1; f <= 6; f++) { if (room == floor_room(f)) global.floor_num = f; }

build_arena(global.floor_num);
update_camera(true);
