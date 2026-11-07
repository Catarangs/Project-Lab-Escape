if (!start_checked) {
    start_checked = true;

    with (obj_enemy_parent) {
        if (!is_machine(object_index)) {
            snap_to_open_cell();
            other.placed_start++;
        }
    }
    with (obj_pickup) snap_item_clear();
    with (obj_medkit) snap_item_clear();
}

switch (state) {

    case "briefing":
        timer--;
        if (timer <= 0) {
            state     = "mission";
            init_left = max(0, 7 + 3 * global.floor_num - placed_start);
            init_t    = 0;
            reinf_t   = reinf_interval;
        }
        break;

    case "mission":

        if (hint_t > 0) hint_t--;
        if (surge_t > 0) surge_t--;

        if (has_threat) {
            threat_t -= 1;
            if (threat_t <= 0) do_surge();
        }

        if (init_left <= 0 && hunt_max > 1) {
            hunt_t -= 1;
            if (hunt_t <= 0) {
                hunt_t = hunt_max;
                hunt_n++;
                if (mob_count() < enemy_cap + 6) spawn_group(2 + global.floor_num div 2);
            }
        }

        if (init_left > 0) {
            init_t--;
            if (init_t <= 0) { spawn_enemy(); init_left--; init_t = 30; }
        }

        var alive = mob_count();
        if (init_left <= 0 && alive < enemy_cap) {
            reinf_t -= global.time_scale;
            if (reinf_t <= 0) { spawn_enemy(); reinf_t = reinf_interval; }
        }

        var all_done = true;
        for (var i = 0; i < array_length(objectives); i++) {
            var o = objectives[i];
            switch (o.kind) {
                case "collect":
                    var want = o.item;
                    var left = 0;
                    with (obj_pickup) { if (item == want) left++; }
                    o.done = o.goal - left;
                    if (has_threat && o.done > cells_prev) {
                        threat_t = min(threat.time, threat_t + 900);
                        cells_prev = o.done;
                    }
                    break;
                case "destroy":
                    o.done = o.goal - instance_number(obj_generator);
                    break;
                case "survive":
                    o.done = min(o.goal, o.done + global.time_scale);
                    break;
            }
            if (o.done < o.goal) all_done = false;
        }
        if (all_done && array_length(objectives) > 0) {
            state = "complete";
            timer = 90;

            with (obj_enemy_parent) { if (!is_machine(object_index) || object_index == obj_generator) { fx_explode(x, y, 0.5); instance_destroy(); } }
            with (obj_bullet_enemy) instance_destroy();
        }
        break;

    case "complete":
        timer--;
        if (timer <= 0) open_exit();
        break;

    case "boss_intro":
        timer--;
        if (timer <= 0 && !boss_spawned) {
            boss_spawned = true;
            boss_id = instance_create_layer((GRID_W div 2) * TILE, 2 * TILE + TILE / 2, "Instances", obj_boss);
            fx_explode(boss_id.x, boss_id.y, 2.2);
            state = "boss_fight";
        }
        break;

    case "boss_fight":
        if (instance_exists(boss_id) && boss_id.state == "dead") open_exit();
        break;

    case "floor_done":
        break;
}
