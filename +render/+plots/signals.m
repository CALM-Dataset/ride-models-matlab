function axes_out = signals(road, out, parent, region)
c = render.scene.colors();
st = render.scene.style();
if nargin < 3
    parent = figure('Color', 'w');
end
if nargin < 4
    region = [0.08 0.08 0.86 0.88];
end
t = out.t;
panels = {
    {{out.z_B * 100, out.z_Wf * 100, out.z_Wr * 100}, {c.z_body, c.z_wf, c.z_wr}, {'-', '--', ':'}, {'$z_B$', '$z_{W,f}$', '$z_{W,r}$'}, '$z\ [\mathrm{cm}]$'}
    {{out.phi * 180 / pi}, {c.phi}, {'-'}, {'$\varphi$'}, '$\varphi\ [\mathrm{deg}]$'}
    {{out.v * 3.6}, {c.speed}, {'-'}, {'$v$'}, '$v\ [\mathrm{km/h}]$'}
    {{out.z_B_ddot}, {c.accel}, {'-'}, {'$\ddot{z}_B$'}, '$\ddot{z}_B\ [\mathrm{m/s^2}]$'}
};
n = numel(panels);
gap = 0.018;
height = (region(4) - gap * (n - 1)) / n;
axes_out = gobjects(n, 1);
bump_t = zeros(0, 2);
for i = 1:size(road.bumps, 1)
    x0 = road.bumps(i, 1);
    L = road.bumps(i, 3);
    bump_t(end + 1, :) = [interp1(out.s, t, x0, 'linear', NaN), interp1(out.s, t, x0 + L, 'linear', NaN)];
end
for i = 1:n
    bottom = region(2) + (n - i) * (height + gap);
    ax = axes('Parent', parent, 'Position', [region(1) bottom region(3) height]);
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
    set(ax, 'YLim', yl, 'XLim', [0 t(end)], 'Box', 'off', 'FontName', st.font, 'FontSize', st.size, 'TickDir', 'out', 'Layer', 'top');
    ylabel(ax, panels{i}{5}, 'Interpreter', 'latex', 'FontSize', st.size + 2);
    if numel(series) > 1
        legend(ax, 'show', 'Interpreter', 'latex', 'Location', 'northeast', 'Orientation', 'horizontal', 'Box', 'off', 'FontSize', st.size);
    end
    grid(ax, 'on');
    set(ax, 'GridAlpha', 0.2);
    if i < n
        set(ax, 'XTickLabel', []);
    end
    axes_out(i) = ax;
end
xlabel(axes_out(end), '$t\ [\mathrm{s}]$', 'Interpreter', 'latex', 'FontSize', st.size + 2);
linkaxes(axes_out, 'x');
end
