var bw = 28;
draw_set_color(make_color_rgb(30, 20, 50));
draw_rectangle(x - bw/2, y - 24, x + bw/2, y - 20, false);
draw_set_color(make_color_rgb(160, 40, 220));
draw_rectangle(x - bw/2, y - 24, x - bw/2 + (hp/max_hp)*bw, y - 20, false);

draw_set_color(make_color_rgb(140, 30, 200));
draw_primitive_begin(pr_trianglefan);
draw_vertex(x, y);
for (var i = 0; i <= 6; i++) {
    var ang = 360/6 * i;
    draw_vertex(x + lengthdir_x(13, ang), y + lengthdir_y(13, ang));
}
draw_primitive_end();

if (instance_exists(obj_player)) {
    var ad = point_direction(x, y, obj_player.x, obj_player.y);
    draw_set_color(make_color_rgb(255, 80, 80));
    draw_circle(x + lengthdir_x(18, ad), y + lengthdir_y(18, ad), 3, true);
}
