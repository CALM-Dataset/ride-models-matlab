function axes_out = signals(road, out, parent, region)
c = ride.render.scene.colors();
st = ride.render.scene.style();
if nargin < 3
    parent = ride.render.scene.light_figure([100 100 1200 650]);
end
if nargin < 4
    region = [0.08 0.08 0.86 0.88];
end
t = out.t;
panels = ride.models.get(out.model).panels(out);
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
    p = panels{i};
    for j = 1:numel(p.data)
        plot(ax, t, p.data{j}, p.style{j}, 'Color', ride.render.scene.rgb(p.color{j}), 'LineWidth', 1.4, 'DisplayName', p.name{j});
    end
    yl = get(ax, 'YLim');
    for b = 1:size(bump_t, 1)
        if all(~isnan(bump_t(b, :)))
            patch(ax, [bump_t(b, 1) bump_t(b, 2) bump_t(b, 2) bump_t(b, 1)], [yl(1) yl(1) yl(2) yl(2)], [0.75 0.75 0.75], 'FaceAlpha', 0.35, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        end
    end
    ink = ride.render.scene.rgb(c.ink);
    set(ax, 'YLim', yl, 'XLim', [0 t(end)], 'Box', 'off', 'FontName', st.font, 'FontSize', st.size, 'TickDir', 'out', 'Layer', 'top', ...
        'Color', 'w', 'XColor', ink, 'YColor', ink, 'GridColor', ink);
    ylabel(ax, p.label, 'Interpreter', 'latex', 'FontSize', st.size + 2, 'Color', ink);
    if numel(p.data) > 1
        legend(ax, 'show', 'Interpreter', 'latex', 'Location', 'northeast', 'Orientation', 'horizontal', 'Box', 'off', 'FontSize', st.size, 'TextColor', ink);
    end
    grid(ax, 'on');
    set(ax, 'GridAlpha', 0.2, 'GridColor', ink);
    if i < n
        set(ax, 'XTickLabel', []);
    end
    axes_out(i) = ax;
end
xlabel(axes_out(end), '$t\ [\mathrm{s}]$', 'Interpreter', 'latex', 'FontSize', st.size + 2, 'Color', ride.render.scene.rgb(c.ink));
linkaxes(axes_out, 'x');
end
