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
panels = panel_definitions(out, c);
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

function panels = panel_definitions(out, c)
speed = struct('data', {{out.v * 3.6}}, 'color', {{c.speed}}, 'style', {{'-'}}, 'name', {{'$v$'}}, 'label', '$v\ [\mathrm{km/h}]$');
accel = struct('data', {{out.z_B_ddot}}, 'color', {{c.accel}}, 'style', {{'-'}}, 'name', {{'$\ddot{z}_B$'}}, 'label', '$\ddot{z}_B\ [\mathrm{m/s^2}]$');
switch out.model
    case 'halfcar'
        heave = struct('data', {{out.z_B * 100, out.z_Wf * 100, out.z_Wr * 100}}, ...
            'color', {{c.z_body, c.z_wf, c.z_wr}}, 'style', {{'-', '--', ':'}}, ...
            'name', {{'$z_B$', '$z_{W,f}$', '$z_{W,r}$'}}, 'label', '$z\ [\mathrm{cm}]$');
        pitch = struct('data', {{out.phi * 180 / pi}}, 'color', {{c.phi}}, 'style', {{'-'}}, ...
            'name', {{'$\varphi$'}}, 'label', '$\varphi\ [\mathrm{deg}]$');
        panels = {heave, pitch, speed, accel};
    case 'quartercar'
        heave = struct('data', {{out.z_B * 100, out.z_W * 100}}, 'color', {{c.z_body, c.z_wf}}, ...
            'style', {{'-', '--'}}, 'name', {{'$z_B$', '$z_W$'}}, 'label', '$z\ [\mathrm{cm}]$');
        panels = {heave, speed, accel};
    otherwise
        error('render:unknownModel', 'unknown model "%s"', out.model);
end
end
