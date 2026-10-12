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
