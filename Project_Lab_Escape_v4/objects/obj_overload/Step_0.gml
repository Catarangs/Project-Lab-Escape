glow_t++;
if (state == "armed") {
    arm_t -= 1;
    if (arm_t <= 0) detonate();
}
else if (state == "cooling") {
    cool_t -= 1;
    if (cool_t <= 0) {
        state = "ready";
        fx_hit(x, y, spr_fx_hit_c, 2);
    }
}
if (instance_exists(obj_boss) && (obj_boss.state == "down" || obj_boss.state == "dead")) instance_destroy();
