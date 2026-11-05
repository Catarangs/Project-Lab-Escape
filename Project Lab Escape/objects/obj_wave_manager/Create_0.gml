state        = "countdown";
spawn_timer  = 90;      
spawn_queue  = [];
spawn_index  = 0;
all_spawned  = false;
current_wave = 0;
door_created = false;

begin_wave = function(wnum) {
    current_wave  = wnum;
    global.wave_num = wnum;
    spawn_index   = 0;
    all_spawned   = false;
    spawn_queue   = [];

    var info = get_wave_enemies(global.floor_num, wnum);
    for (var i = 0; i < info.chasers;  i++) array_push(spawn_queue, "chaser");
    for (var i = 0; i < info.shooters; i++) array_push(spawn_queue, "shooter");

    for (var i = array_length(spawn_queue) - 1; i > 0; i--) {
        var j   = irandom(i);
        var tmp = spawn_queue[i];
        spawn_queue[i] = spawn_queue[j];
        spawn_queue[j] = tmp;
    }

    with (obj_enemy_parent)  instance_destroy();
    with (obj_bullet_enemy)  instance_destroy();
    with (obj_bullet_player) instance_destroy();

    state       = "countdown";
    spawn_timer = 90;
};

begin_wave(1);

// Cheat hook (called by obj_cheat_menu): instantly finish the wave in progress.
// Returns true if a wave was completed, false if there was nothing to complete.
complete_wave = function() {
    if (state != "countdown" && state != "spawning" && state != "waiting") return false;

    with (obj_enemy_parent) instance_destroy();   // every enemy on screen
    with (obj_bullet_enemy) instance_destroy();   // and their bullets

    spawn_index = array_length(spawn_queue);      // nothing left to spawn
    all_spawned = true;
    state       = "wave_done";                    // normal flow takes over: next wave,
    spawn_timer = 80;                             // or the exit door after the last wave
    return true;
};
