function axes_out = signals(road, out, parent, region, wheelbase)
c = ride.render.scene.colors();
st = ride.render.scene.style();
if nargin < 3 || isempty(parent)
    parent = ride.render.scene.light_figure([100 100 1200 650]);
end
if nargin < 4 || isempty(region)
    region = [0.08 0.09 0.82 0.87];
end
if nargin < 5
    wheelbase = model_wheelbase(out.model);
end
t = out.t;
panels = ride.models.get(out.model).panels(out);
n = numel(panels);
gap = 0.018;
height = (region(4) - gap * (n - 1)) / n;
axes_out = gobjects(n, 1);
crossings = crossing_times(road, out, wheelbase);
ink = ride.render.scene.rgb(c.ink);
for i = 1:n
    bottom = region(2) + (n - i) * (height + gap);
    ax = axes('Parent', parent, 'Position', [region(1) bottom region(3) height]);
    hold(ax, 'on');
    p = panels{i};
    yl = y_limits(p.data);
    for b = 1:size(crossings, 1)
        patch(ax, crossings(b, [1 2 2 1]), yl([1 1 2 2]), [0.6 0.6 0.6], 'FaceAlpha', crossings(b, 3), ...
            'EdgeColor', 'none', 'HandleVisibility', 'off');
    end
    for j = 1:numel(p.data)
        plot(ax, t, p.data{j}, p.style{j}, 'Color', ride.render.scene.rgb(p.color{j}), 'LineWidth', 1.4, 'DisplayName', p.name{j});
    end
    set(ax, 'YLim', yl, 'XLim', [0 t(end)], 'Box', 'off', 'FontName', st.font, 'FontSize', st.size, 'TickDir', 'out', ...
        'Layer', 'top', 'Color', 'w', 'XColor', ink, 'YColor', ink);
    ylabel(ax, p.label, 'Interpreter', 'latex', 'FontSize', st.size + 2, 'Color', ink);
    if numel(p.data) > 1
        lg = legend(ax, 'show', 'Interpreter', 'latex', 'Location', 'none', 'Orientation', 'vertical', ...
            'Box', 'off', 'FontSize', st.size, 'TextColor', ink, 'Color', 'none', 'AutoUpdate', 'off');
        lg.ItemTokenSize = [18 18];
        lg.Units = 'normalized';
        lg.Position = [region(1) + region(3) + 0.005, bottom, lg.Position(3), height];
    end
    grid(ax, 'on');
    set(ax, 'GridAlpha', 0.15, 'GridColor', ink);
    if i < n
        set(ax, 'XTickLabel', []);
    end
    axes_out(i) = ax;
end
xlabel(axes_out(end), '$t\ [\mathrm{s}]$', 'Interpreter', 'latex', 'FontSize', st.size + 2, 'Color', ink);
linkaxes(axes_out, 'x');
end

function L = model_wheelbase(model)
L = 0;
P = ride.load(model);
if isfield(P, 'L')
    L = P.L;
end
end

function rows = crossing_times(road, out, wheelbase)
rows = zeros(0, 3);
offsets = unique([0, wheelbase]);
shade = [0.35, 0.18];
for a = 1:numel(offsets)
    for i = 1:size(road.bumps, 1)
        x0 = road.bumps(i, 1) + offsets(a);
        x1 = x0 + road.bumps(i, 3);
        span = [first_time(out, x0), first_time(out, x1)];
        if all(~isnan(span))
            rows(end + 1, :) = [span, shade(a)]; %#ok<AGROW>
        end
    end
end
end

function t = first_time(out, s)
k = find(out.s >= s, 1);
if isempty(k)
    t = NaN;
elseif k == 1 || out.s(k) == out.s(k - 1)
    t = out.t(k);
else
    t = interp1(out.s(k - 1:k), out.t(k - 1:k), s);
end
end

function yl = y_limits(data)
values = cell2mat(cellfun(@(d) d(:), data(:), 'UniformOutput', false));
values = values(isfinite(values));
if isempty(values)
    yl = [-1 1];
    return
end
lo = min(values);
hi = max(values);
span = hi - lo;
if span < 1e-9
    span = max(abs(hi), 1);
end
yl = [lo - 0.08 * span, hi + 0.08 * span];
end
