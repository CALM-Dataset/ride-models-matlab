function xlim = draw_background(ax, g, c, road, s, x_car)
pos = getpixelposition(ax);
xrange = (g.ylim(2) - g.ylim(1)) * pos(3) / pos(4);
xlim = [x_car - 0.32 * xrange, x_car + 0.68 * xrange];
cla(ax);
hold(ax, 'on');
set(ax, 'XLim', xlim, 'YLim', g.ylim, 'DataAspectRatio', [1 1 1]);
axis(ax, 'off');
n = 64;
sky = linspace(0, 1, n)';
sky_rgb = (1 - sky) * render.scene.rgb(c.sky_low) + sky * render.scene.rgb(c.sky_high);
image(ax, xlim, g.ylim, reshape(sky_rgb, n, 1, 3));
set(ax, 'YDir', 'normal');
road_x = linspace(xlim(1) - 0.5, xlim(2) + 0.5, 400);
road_h = terrain.height(road, s + road_x) * g.y_scale + g.ground_y;
fill(ax, [road_x, fliplr(road_x)], [road_h, (g.ylim(1) - 1) * ones(size(road_x))], render.scene.rgb(c.road), 'EdgeColor', 'none');
fill(ax, [road_x, fliplr(road_x)], [road_h, fliplr(road_h - 0.18)], render.scene.rgb(c.road_top), 'EdgeColor', 'none');
for t = floor((s + road_x(1)) / 2) * 2 : 2 : s + road_x(end)
    line(ax, [t - s, t - s + 0.8], (g.ground_y - 0.35) * [1 1], 'Color', render.scene.rgb(c.road_tick), 'LineWidth', 1.6);
end
end
