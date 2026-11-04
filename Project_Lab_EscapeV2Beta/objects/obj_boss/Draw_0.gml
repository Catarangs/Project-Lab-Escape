// power cables to every live node
if (state == "intro" || state == "fight") {
    with (obj_power_node) draw_cable(other.x, other.y + 10, x, y, current_time / 16);
}

var sx = (shake > 0) ? irandom_range(-3, 3) : 0;
var powered_down = (state == "down" || state == "dead");
var frame = powered_down ? 1 : 0;
var a = (state == "intro") ? clamp(1 - intro_timer / 110, 0.15, 1) : 1;
var tint = rage ? merge_colour(c_white, make_color_rgb(255, 80, 70), 0.35 + 0.25 * sin(current_time / 120)) : c_white;

draw_sprite_ext(spr_mecha, frame, x + sx, y, 1, 1, 0, tint, a);
if (flash > 0) {
    gpu_set_fog(true, c_white, 0, 1);
    draw_sprite_ext(spr_mecha, frame, x + sx, y, 1, 1, 0, c_white, 0.55 * (flash / 14));
    gpu_set_fog(false, c_white, 0, 1);
}

if (state == "fight") {
    // claw slab: where the mecha is about to slam
    if (mode == "claw_wind" || mode == "claw_hit") {
        var live_c = (mode == "claw_hit");
        draw_set_color(make_color_rgb(255, 60, 60));
        draw_set_alpha(live_c ? 0.75 : 0.18 + 0.2 * (1 - mode_t / max(1, mode_max)) + 0.1 * ((current_time mod 200) < 100));
        draw_rectangle(claw_r[0], claw_r[1], claw_r[2], claw_r[3], false);
        draw_set_alpha(1);
        draw_rectangle(claw_r[0], claw_r[1], claw_r[2], claw_r[3], true);
        if (live_c) {
            draw_set_color(make_color_rgb(255, 240, 225));
            for (var k = 0; k < 3; k++) {
                var kx = lerp(claw_r[0], claw_r[2], 0.2 + k * 0.3);
                draw_line_width(kx - 20, claw_r[1], kx + 20, claw_r[3], 5);
            }
        }
    }
    // charge lane
    if (mode == "charge_wind") {
        var cw  = charge_h ? hit_h + 8 : hit_w + 8;
        var lx1 = charge_h ? min(x, charge_tx) : x - cw;
        var lx2 = charge_h ? max(x, charge_tx) : x + cw;
        var ly1 = charge_h ? y - cw : min(y, charge_ty);
        var ly2 = charge_h ? y + cw : max(y, charge_ty);
        draw_set_color(make_color_rgb(255, 150, 40));
        draw_set_alpha(0.15 + 0.25 * (1 - mode_t / max(1, mode_max)) + 0.1 * ((current_time mod 160) < 80));
        draw_rectangle(lx1, ly1, lx2, ly2, false);
        draw_set_alpha(0.9);
        draw_rectangle(lx1, ly1, lx2, ly2, true);
        draw_set_alpha(1);
    }

    // ghost formations: where the next bullets will appear and which way they will fly
    var prog = 1 - wind_t / max(1, wind_max);
    for (var i = 0; i < array_length(ghosts); i++) {
        var g = ghosts[i];
        draw_set_color(g.col);
        for (var j = 0; j < array_length(g.cells); j++) {
            var gx = g.cells[j][0];
            var gy = g.cells[j][1];
            draw_set_alpha(0.2 + 0.3 * prog);
            draw_circle(gx, gy, 6 + 3 * prog, false);
            draw_set_alpha(0.35 + 0.5 * prog);
            draw_circle(gx, gy, 9 + 3 * prog, true);
            draw_line_width(gx, gy, gx + lengthdir_x(24, g.dir), gy + lengthdir_y(24, g.dir), 2);
        }
    }

    // laser beams
    for (var i = 0; i < array_length(beams); i++) {
        var bm = beams[i];
        var x2 = bm.v ? bm.px : bm.px + bm.len;
        var y2 = bm.v ? bm.py + bm.len : bm.py;
        if (bm.t < bm.warn) {
            // warning: the whole 2-tile lane lights up, brighter as it gets close
            var hw = bm.w / 2;
            draw_set_color(make_color_rgb(255, 70, 60));
            draw_set_alpha(0.1 + 0.25 * (bm.t / bm.warn));
            if (bm.v) draw_rectangle(bm.px - hw, bm.py, bm.px + hw, y2, false);
            else      draw_rectangle(bm.px, bm.py - hw, x2, bm.py + hw, false);
            draw_set_alpha(0.4 + 0.35 * ((current_time mod 160) < 80));
            if (bm.v) draw_rectangle(bm.px - hw, bm.py, bm.px + hw, y2, true);
            else      draw_rectangle(bm.px, bm.py - hw, x2, bm.py + hw, true);
        } else {
            draw_set_alpha(0.85);
            draw_set_color(make_color_rgb(255, 60, 60));
            draw_line_width(bm.px, bm.py, x2, y2, bm.w);
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(255, 240, 225));
            draw_line_width(bm.px, bm.py, x2, y2, bm.w * 0.4);
        }
    }
    draw_set_alpha(1);
}
draw_set_color(c_white);
