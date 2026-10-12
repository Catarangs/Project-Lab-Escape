var bw = 28;
draw_set_color(make_color_rgb(60, 20, 20));
draw_rectangle(x - bw/2, y - 24, x + bw/2, y - 20, false);
draw_set_color(make_color_rgb(220, 50, 50));
draw_rectangle(x - bw/2, y - 24, x - bw/2 + (hp/max_hp)*bw, y - 20, false);

draw_set_color(make_color_rgb(230, 110, 20));
draw_circle(x, y, 13, false);

if (instance_exists(obj_player)) {
    var ed = point_direction(x, y, obj_player.x, obj_player.y);
    var efx = lengthdir_x(6, ed);
    var efy = lengthdir_y(6, ed);
    var esx = lengthdir_x(4, ed + 90);
    var esy = lengthdir_y(4, ed + 90);
    draw_set_color(c_black);
    draw_circle(x + efx + esx, y + efy + esy, 3, false);
    draw_circle(x + efx - esx, y + efy - esy, 3, false);
}
