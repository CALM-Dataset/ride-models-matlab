function frame(ax, P, road, out, k)
g = ride.render.scene.geometry('quartercar');
c = ride.render.scene.colors();
ys = g.y_scale;
s = out.s(k);
z_B = out.z_B(k);
z_W = out.z_W(k);
zeta = ride.core.terrain.height(road, s);
ride.render.scene.draw_background(ax, g, c, road, s, 0);
y_road = g.ground_y + zeta * ys;
y_W = y_road + g.wheel_ry + min(z_W - zeta, 0) * ys;
y_B = y_W + (g.y_b_nom - g.y_w_nom) + (z_B - z_W) * ys;
on_road = any(road.bumps(:, 1) <= s & s <= road.bumps(:, 1) + road.bumps(:, 3)) || abs(zeta) > g.obstacle_flag_m;
ride.render.scene.draw_wheel(ax, 0, y_W, y_road, y_B, on_road, s / g.wheel_r, g, c, '');
rectangle('Parent', ax, 'Position', [-g.w_mb / 2, y_B - g.h_mb / 2, g.w_mb, g.h_mb], ...
    'FaceColor', ride.render.scene.rgb(c.body), 'EdgeColor', [0.2 0.2 0.2], 'LineWidth', 1.2);
plot(ax, 0, y_B, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'MarkerSize', 3);
hold(ax, 'off');
end
