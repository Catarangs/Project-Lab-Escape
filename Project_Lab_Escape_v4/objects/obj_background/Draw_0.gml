var info = floor_info(global.floor_num);
var th   = theme_info(info.theme);

var cam = view_camera[0];
var c0  = max(0, floor(camera_get_view_x(cam) / TILE));
var c1  = min(GRID_W - 1, floor((camera_get_view_x(cam) + camera_get_view_width(cam)) / TILE));
var r0  = max(0, floor(camera_get_view_y(cam) / TILE));
var r1  = min(GRID_H - 1, floor((camera_get_view_y(cam) + camera_get_view_height(cam)) / TILE));

for (var cx = c0; cx <= c1; cx++) {
    for (var cy = r0; cy <= r1; cy++) {
        var wv = global.wall_grid[# cx, cy];
        if (wv == 1) {
            draw_sprite_ext(spr_wall, th.wf, cx * TILE, cy * TILE, 1, 1, 0, th.wc, 1);
        } else {
            var shade = ((cx + cy) mod 2 == 0) ? c_white : make_color_rgb(228, 228, 236);
            draw_sprite_ext(spr_floor, th.ff, cx * TILE, cy * TILE, 1, 1, 0, merge_colour(th.fc, shade, 0.5), 1);
        }
        var zz = global.zone_grid[# cx, cy];
        if (zz != ZONE_NONE) draw_zone_cell(cx, cy, zz);
        if (wv == 3) draw_cover_cell(cx, cy, th);
    }
}
draw_set_color(c_white);
