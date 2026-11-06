ui_init();

if (!variable_global_exists("dev")) { global.dev = false; global.dev_god = false; }

if (!variable_global_exists("new_run") || global.new_run) {
    global.new_run = false;
    global.player_max_hp       = 5;
    global.player_hp           = 5;
    global.player_speed        = 3.5;
    global.player_fire_rate    = 22;
    global.player_damage       = 1;
    global.player_bullet_speed = 10;
    global.player_pierce       = 0;
    global.aug       = "";
    global.aug_spec  = "";
    global.laser_flip = false;
    global.aug_have  = {};
    global.rerolls   = 2;
    global.aug_round = 0;
    global.shot_dmg  = 1;
    global.shots     = 0;
    global.wind_used = false;
    global.vamp_kills = 0;
    global.shield_hits = 0;
    global.start_pick = true;
    global.auto_fire = true;

    global.floor_num      = 1;
    global.max_floors     = 9;
    global.wave_num       = 0;
    global.waves_per_floor= 3;
    global.total_kills    = 0;
    global.score          = 0;
}

global.time_scale = 1;

global.is_upgrade_phase = false;
global.door_open        = false;

global.objectives = [];

global.set_player = [spr_player_idle_d, spr_player_idle_s, spr_player_idle_u, spr_player_walk_d, spr_player_walk_s, spr_player_walk_u];
global.set_guard  = [spr_guard_idle_d,  spr_guard_idle_s,  spr_guard_idle_u,  spr_guard_walk_d,  spr_guard_walk_s,  spr_guard_walk_u];
global.set_tech   = [spr_tech_idle_d,   spr_tech_idle_s,   spr_tech_idle_u,   spr_tech_walk_d,   spr_tech_walk_s,   spr_tech_walk_u];
global.set_dash   = [spr_dash_idle_d,   spr_dash_idle_s,   spr_dash_idle_u,   spr_dash_walk_d,   spr_dash_walk_s,   spr_dash_walk_u];
global.set_sniper = [spr_sniper_idle_d, spr_sniper_idle_s, spr_sniper_idle_u, spr_sniper_walk_d, spr_sniper_walk_s, spr_sniper_walk_u];

global.gate_t = 0;

for (var f = 1; f <= global.max_floors; f++) { if (room == floor_room(f)) global.floor_num = f; }

aug_build();
global.shield_hits = aug_n("g_shield");

build_arena(global.floor_num);
update_camera(true);

if (global.start_pick) {
    global.start_pick = false;
    global.is_upgrade_phase = true;
    var up = instance_create_layer(0, 0, "Instances", obj_upgrade_ui);
    up.mode = "start";
    up.picks_left = 1;
    up.choices = aug_offer();
}
