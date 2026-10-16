function draw_wheel(ax, x_c, y_W, y_road, y_body_corner, on_obstacle, rot, g, c)
part = c.tire_part;
if on_obstacle
    part = c.tire_hit;
end
th = linspace(0, 2 * pi, 60);
rx = g.wheel_ry;
ry = g.wheel_ry;
fill(ax, x_c + rx * cos(th), y_W + ry * sin(th), ride.render.scene.rgb(c.tire), 'EdgeColor', ride.render.scene.rgb(c.tire_edge), 'LineWidth', 1.2);
fill(ax, x_c + 0.6 * rx * cos(th), y_W + 0.6 * ry * sin(th), ride.render.scene.rgb(c.rim), 'EdgeColor', ride.render.scene.rgb(c.rim_edge), 'LineWidth', 1.0);
ang = rot + (0:4) * 2 * pi / 5;
for a = ang
    line(ax, [x_c, x_c + 0.36 * rx * cos(a)], [y_W, y_W + 0.36 * ry * sin(a)], 'Color', ride.render.scene.rgb(c.rim_edge), 'LineWidth', 1.3);
end
y_top = y_W - g.hub_h / 2;
if y_top > y_road + 0.05
    [sx, sy] = ride.render.scene.spring_xy(x_c + g.sp_x, y_top, y_road, g.sp_n, g.sp_w);
    line(ax, sx, sy, 'Color', ride.render.scene.rgb(part), 'LineWidth', 1.6);
    d = ride.render.scene.damper_xy(x_c + g.da_x, y_top, y_road, g.cyl_h_tire, g.da_w, g.pist_h, g.pist_frac, g.lower_stem);
    line(ax, d.upper_rod{:}, 'Color', ride.render.scene.rgb(part), 'LineWidth', 1.3);
    line(ax, d.lower_rod{:}, 'Color', ride.render.scene.rgb(part), 'LineWidth', 1.3);
    line(ax, d.cylinder{:}, 'Color', ride.render.scene.rgb(part), 'LineWidth', 1.8);
    fill(ax, d.piston{:}, ride.render.scene.rgb(part), 'EdgeColor', 'none');
end
rectangle('Parent', ax, 'Position', [x_c - g.w_hub / 2, y_W - g.hub_h / 2, g.w_hub, g.hub_h], ...
    'FaceColor', ride.render.scene.rgb(c.wheel_hub), 'EdgeColor', [0.2 0.2 0.2], 'LineWidth', 1.2);
plot(ax, x_c, y_W, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'MarkerSize', 3);
if on_obstacle
    plot(ax, x_c, y_road, 'o', 'MarkerFaceColor', ride.render.scene.rgb(c.contact), 'MarkerEdgeColor', ride.render.scene.rgb(c.contact), 'MarkerSize', 6);
end
y_susp_bot = y_W + g.hub_h / 2;
y_susp_top = y_body_corner - g.h_mb / 2;
if y_susp_top > y_susp_bot + 0.05
    k = g.susp_scale;
    [sx, sy] = ride.render.scene.spring_xy(x_c + g.sp_x, y_susp_top, y_susp_bot, g.sp_n, g.sp_w * k);
    line(ax, sx, sy, 'Color', ride.render.scene.rgb(c.spring), 'LineWidth', 2.0 * k);
    d = ride.render.scene.damper_xy(x_c + g.da_x, y_susp_top, y_susp_bot, g.cyl_h_susp, g.da_w * k, g.pist_h * k, g.pist_frac, g.lower_stem);
    col = ride.render.scene.rgb(c.damper);
    line(ax, d.upper_rod{:}, 'Color', col, 'LineWidth', 1.5 * k);
    line(ax, d.lower_rod{:}, 'Color', col, 'LineWidth', 1.5 * k);
    line(ax, d.cylinder{:}, 'Color', col, 'LineWidth', 2.0 * k);
    fill(ax, d.piston{:}, col, 'EdgeColor', 'none');
end
end
