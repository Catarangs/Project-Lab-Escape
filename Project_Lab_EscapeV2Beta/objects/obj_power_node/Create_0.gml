// one of the mecha's power lines: shoot it until it blows
tier      = floor_info(global.floor_num).tier;
hp        = 8 + 2 * tier;
max_hp    = hp;
dying     = false;
hit_flash = 0;
depth     = -90;
