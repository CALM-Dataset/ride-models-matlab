function draw_frame(ax, P, road, out, k, varargin)
g = render.scene.geometry();
c = render.scene.colors();
lf = P.body.l_f;
lr = P.body.l_r;
L = P.L;
ys = g.y_scale;
s = out.s(k);
x_front = 0;
x_rear = -L;
z_B = out.z_B(k);
phi = out.phi(k);
z_Bf = z_B - lf * phi;
z_Br = z_B + lr * phi;
z_Wf = out.z_Wf(k);
z_Wr = out.z_Wr(k);
zeta_f = halfcar.road.height(road, s);
zeta_r = halfcar.road.height(road, s - L);

xlim = [x_rear - g.xlim_left_pad - g.mb_overhang, g.xlim_right];
cla(ax);
hold(ax, 'on');
set(ax, 'XLim', xlim, 'YLim', g.ylim, 'DataAspectRatio', [1 1 1]);
axis(ax, 'off');

n = 64;
sky = linspace(0, 1, n)';
sky_rgb = (1 - sky) * render.scene.rgb(c.sky_low) + sky * render.scene.rgb(c.sky_high);
img = reshape(sky_rgb, n, 1, 3);
image(ax, xlim, g.ylim, img);
set(ax, 'YDir', 'normal');

road_x = linspace(xlim(1) - 0.5, xlim(2) + 0.5, 400);
road_h = halfcar.road.height(road, s + road_x) * ys + g.ground_y;
fill(ax, [road_x, fliplr(road_x)], [road_h, (g.ylim(1) - 1) * ones(size(road_x))], render.scene.rgb(c.road), 'EdgeColor', 'none');
layer = 0.18;
fill(ax, [road_x, fliplr(road_x)], [road_h, fliplr(road_h - layer)], render.scene.rgb(c.road_top), 'EdgeColor', 'none');
ticks = floor((s + road_x(1)) / 2) * 2 : 2 : s + road_x(end);
for t = ticks
    xt = t - s;
    line(ax, [xt xt + 0.8], (g.ground_y - 0.35) * [1 1], 'Color', render.scene.rgb(c.road_tick), 'LineWidth', 1.6);
end

y_road_f = g.ground_y + zeta_f * ys;
y_road_r = g.ground_y + zeta_r * ys;
y_Wf = y_road_f + g.wheel_ry + min(z_Wf - zeta_f, 0) * ys;
y_Wr = y_road_r + g.wheel_ry + min(z_Wr - zeta_r, 0) * ys;
y_gap = g.y_b_nom - g.y_w_nom;
y_Bf = y_Wf + y_gap + (z_Bf - z_Wf) * ys;
y_Br = y_Wr + y_gap + (z_Br - z_Wr) * ys;
rot = s / g.wheel_r;

on_f = any(road.bumps(:, 1) <= s & s <= road.bumps(:, 1) + road.bumps(:, 3)) || abs(zeta_f) > g.obstacle_flag_m;
on_r = any(road.bumps(:, 1) <= s - L & s - L <= road.bumps(:, 1) + road.bumps(:, 3)) || abs(zeta_r) > g.obstacle_flag_m;
render.scene.draw_wheel(ax, x_front, y_Wf, y_road_f, y_Bf, on_f, rot, g, c, 'f');
render.scene.draw_wheel(ax, x_rear, y_Wr, y_road_r, y_Br, on_r, rot, g, c, 'r');

o = g.mb_overhang;
slope = (y_Bf - y_Br) / (x_front - x_rear);
fx = x_front + o; fy = y_Bf + slope * o;
rx = x_rear - o; ry = y_Br - slope * o;
hh = g.h_mb / 2;
fill(ax, [rx fx fx rx], [ry - hh, fy - hh, fy + hh, ry + hh], render.scene.rgb(c.body), 'EdgeColor', [0.2 0.2 0.2], 'LineWidth', 1.2);
x_mid = (x_front + x_rear) / 2;
y_mid = (y_Bf + y_Br) / 2;
plot(ax, x_mid, y_mid, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'w', 'MarkerSize', 3);
text(ax, x_mid, max(y_Bf, y_Br) + g.h_mb / 2 + 0.12, 'body', 'HorizontalAlignment', 'center', 'Color', render.scene.rgb(c.ink), 'FontSize', 10);

hud = sprintf('t %.2f s    s %.1f m    v %.1f km/h    z_B %+.1f mm    \\phi %+.2f deg', ...
    out.t(k), s, out.v(k) * 3.6, z_B * 1000, phi * 180 / pi);
text(ax, xlim(1) + 0.2, g.ylim(2) - 0.3, hud, 'Color', render.scene.rgb(c.ink), 'FontSize', 10, 'BackgroundColor', 'w', 'EdgeColor', [0.33 0.33 0.33]);
hold(ax, 'off');
end
