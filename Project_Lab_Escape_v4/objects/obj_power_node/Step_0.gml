var boss_rage = (instance_exists(obj_boss) && obj_boss.rage) ? 1.35 : 1;
gap_ang = (gap_ang + gap_dir * gap_spd * boss_rage * max(0.4, global.time_scale) + 360) mod 360;
if (hit_flash > 0) hit_flash--;
if (block_flash > 0) block_flash--;
if (gap_flash > 0) gap_flash--;
