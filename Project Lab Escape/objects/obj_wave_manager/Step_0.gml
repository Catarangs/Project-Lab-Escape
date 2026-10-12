switch (state) {

    case "countdown":
        spawn_timer--;
        if (spawn_timer <= 0) {
            state       = "spawning";
            spawn_timer = 10;   
        }
        break;

    case "spawning":
        spawn_timer--;
        if (spawn_timer <= 0) {
            spawn_timer = 30;   
            if (spawn_index < array_length(spawn_queue)) {
                var margin = 55;
                var side   = irandom(3);
                var sx, sy;
                switch (side) {
                    case 0: sx = margin + irandom(room_width  - margin*2); sy = margin; break;
                    case 1: sx = room_width  - margin; sy = margin + irandom(room_height - margin*2); break;
                    case 2: sx = margin + irandom(room_width  - margin*2); sy = room_height - margin; break;
                    case 3: sx = margin;               sy = margin + irandom(room_height - margin*2); break;
                }
                var etype = spawn_queue[spawn_index];
                if (etype == "chaser")  instance_create_layer(sx, sy, "Instances", obj_enemy_chaser);
                if (etype == "shooter") instance_create_layer(sx, sy, "Instances", obj_enemy_shooter);
                spawn_index++;
            } else {
                all_spawned = true;
                state       = "waiting";
            }
        }
        break;

    case "waiting":
        if (all_spawned && instance_number(obj_enemy_parent) == 0) {
            state       = "wave_done";
            spawn_timer = 80;
        }
        break;

    case "wave_done":
        spawn_timer--;
        if (spawn_timer <= 0) {
            if (current_wave < global.waves_per_floor) {
                begin_wave(current_wave + 1);
            } else {
                state = "floor_done";
                if (!door_created) {
                    door_created = true;
                    var d   = instance_create_layer(room_width/2, room_height - 80, "Instances", obj_exit_door);
                    global.door_open = true;
                }
            }
        }
        break;

    case "floor_done":
        break;
}
