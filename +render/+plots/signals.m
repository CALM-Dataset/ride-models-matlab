function axes_out = signals(road, out, parent, n_rows, first_row)
c = render.scene.colors();
if nargin < 3
    parent = figure('Color', 'w');
end
if nargin < 5
    n_rows = 4;
    first_row = 1;
end
t = out.t;
panels = {
    {{out.z_B * 100, out.z_Wf * 100, out.z_Wr * 100}, {c.z_body, c.z_wf, c.z_wr}, {'-', '--', ':'}, {'z_B', 'z_{W,f}', 'z_{W,r}'}, 'z [cm]'}
    {{out.phi * 180 / pi}, {c.phi}, {'-'}, {'\phi'}, '\phi [deg]'}
    {{out.v * 3.6}, {c.speed}, {'-'}, {'v'}, 'v [km/h]'}
    {{out.z_B_ddot}, {c.accel}, {'-'}, {'z_B ddot'}, 'z_B ddot [m/s^2]'}
};
axes_out = gobjects(numel(panels), 1);
bump_t = [];
for i = 1:size(road.bumps, 1)
    x0 = road.bumps(i, 1);
    L = road.bumps(i, 3);
    bump_t = [bump_t; interp1(out.s, t, x0, 'linear', NaN), interp1(out.s, t, x0 + L, 'linear', NaN)];
end
for i = 1:numel(panels)
    ax = subplot(n_rows, 1, first_row + i - 1, 'Parent', parent);
    hold(ax, 'on');
    series = panels{i}{1};
    for j = 1:numel(series)
        plot(ax, t, series{j}, panels{i}{3}{j}, 'Color', render.scene.rgb(panels{i}{2}{j}), 'LineWidth', 1.4, 'DisplayName', panels{i}{4}{j});
    end
    yl = get(ax, 'YLim');
    for b = 1:size(bump_t, 1)
        if all(~isnan(bump_t(b, :)))
            patch(ax, [bump_t(b, 1) bump_t(b, 2) bump_t(b, 2) bump_t(b, 1)], [yl(1) yl(1) yl(2) yl(2)], [0.75 0.75 0.75], 'FaceAlpha', 0.35, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        end
    end
    set(ax, 'YLim', yl, 'Box', 'off', 'FontName', 'Times');
    ylabel(ax, panels{i}{5});
    if numel(series) > 1
        legend(ax, 'show', 'Location', 'eastoutside');
    end
    grid(ax, 'on');
    axes_out(i) = ax;
end
xlabel(axes_out(end), 't [s]');
end
