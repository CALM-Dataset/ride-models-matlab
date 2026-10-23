function draw_real_data(results, series, summary, output)
%DRAW_REAL_DATA Figures of the comparison with the recorded drives (see run_real_data).
colors = struct('measured', [0.35 0.35 0.35], 'aligned', [197 14 31] / 255, 'study', [243 148 0] / 255, ...
    'quartercar', [0 64 247] / 255, 'nominal', [0 123 106] / 255, 'road_fl', [0.55 0.35 0.65], 'road_lr', [0.2 0.2 0.2]);
usable = ~results.low_confidence;
label = sprintf('ride-models %s | %d usable recorded drives of CALM-Germany and CALM-Italy | calibrated half-car unless stated', ...
    ride.version(), nnz(usable));
draw_scatter(results(usable, :), colors, output, label);
draw_errors(results(usable, :), colors, output, label);
draw_near_away(results(usable, :), colors, output, label);
draw_locations(results(usable, :), colors, output, label);
draw_examples(results(usable, :), series, colors, output, label);
draw_checks(results(usable, :), colors, output, label);
end

function draw_scatter(r, colors, output, label)
fig = ride.validation.white_figure(17, 8);
layout = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
limit = [0.03, 1.6];
pairs = {'aligned', 'scenario road aligned'; 'study', 'road not shifted (original replay)'};
for k = 1:2
    ax = nexttile(layout);
    hold(ax, 'on');
    fill(ax, [limit fliplr(limit)], [limit * 0.7 fliplr(limit) * 1.3], [0.92 0.92 0.92], 'EdgeColor', 'none', 'DisplayName', '\pm30 %');
    plot(ax, limit, limit, '--', 'Color', [0.4 0.4 0.4], 'HandleVisibility', 'off');
    train = r.paper_split == "train";
    scatter(ax, r.a_w_measured(train), r.(['a_w_' pairs{k, 1}])(train), 16, colors.(pairs{k, 1}), 'o', 'filled', ...
        'MarkerFaceAlpha', 0.75, 'DisplayName', 'training roads');
    scatter(ax, r.a_w_measured(~train), r.(['a_w_' pairs{k, 1}])(~train), 30, colors.(pairs{k, 1}), 'd', ...
        'LineWidth', 1.1, 'DisplayName', 'evaluation roads (held out)');
    set(ax, 'XScale', 'log', 'YScale', 'log');
    axis(ax, 'square');
    xlim(ax, limit);
    ylim(ax, limit);
    xlabel(ax, 'a_w measured by the IMU [m/s^2]');
    ylabel(ax, 'a_w simulated [m/s^2]');
    title(ax, sprintf('(%s) %s', char('a' + k - 1), pairs{k, 2}));
    legend(ax, 'Location', 'southeast', 'Box', 'off', 'FontSize', 7.5);
end
save_figure(fig, output, 'real_scatter', label);
end

function draw_near_away(r, colors, output, label)
fig = ride.validation.white_figure(17, 8);
layout = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
parts = {'near', 'near the bump'; 'away', 'away from the bump'};
limit = [0.01, 2];
for k = 1:2
    ax = nexttile(layout);
    hold(ax, 'on');
    fill(ax, [limit fliplr(limit)], [limit * 0.7 fliplr(limit) * 1.3], [0.92 0.92 0.92], 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(ax, limit, limit, '--', 'Color', [0.4 0.4 0.4], 'HandleVisibility', 'off');
    measured = r.(['a_w_measured_' parts{k, 1}]);
    simulated = r.(['a_w_simulated_' parts{k, 1}]);
    scatter(ax, measured, simulated, 16, colors.aligned, 'filled', 'MarkerFaceAlpha', 0.75);
    set(ax, 'XScale', 'log', 'YScale', 'log');
    axis(ax, 'square');
    xlim(ax, limit);
    ylim(ax, limit);
    xlabel(ax, 'weighted RMS measured [m/s^2]');
    ylabel(ax, 'weighted RMS simulated [m/s^2]');
    title(ax, sprintf('(%s) %s: median ratio %.2f', char('a' + k - 1), parts{k, 2}, median(simulated ./ measured)));
end
save_figure(fig, output, 'real_near_away', [label ' | near: 0.5 s before the front axle reaches the bump to 1.5 s after the rear axle leaves it']);
end

function draw_errors(r, colors, output, label)
fig = ride.validation.white_figure(17, 7);
ax = axes(fig);
hold(ax, 'on');
names = {'aligned', 'half-car, aligned'; 'study', 'half-car, not shifted'; 'nominal', 'half-car, nominal suspension'; ...
    'quartercar', 'quarter-car'; 'road_fl', 'half-car, raw FL wheel track'};
edges = -100:10:300;
for k = 1:size(names, 1)
    e = 100 * r.(['error_' names{k, 1}]);
    e = min(e, edges(end) - 1);
    histogram(ax, e, edges, 'DisplayStyle', 'stairs', 'EdgeColor', colors.(names{k, 1}), 'LineWidth', 1.3, ...
        'DisplayName', sprintf('%s (median |e| %.0f %%)', names{k, 2}, median(abs(e))));
end
xline(ax, 0, '-', 'Color', [0.3 0.3 0.3], 'HandleVisibility', 'off');
xlabel(ax, 'e = (a_w simulated - a_w measured) / a_w measured [%], last bin holds everything above');
ylabel(ax, 'roads');
legend(ax, 'Location', 'northeast', 'Box', 'off', 'FontSize', 7.5);
save_figure(fig, output, 'real_errors', label);
end

function draw_locations(r, colors, output, label)
fig = ride.validation.white_figure(17, 7);
ax = axes(fig);
hold(ax, 'on');
locations = unique(r.location);
for i = 1:numel(locations)
    pick = r.location == locations(i);
    e = 100 * r.error_aligned(pick);
    jitter = 0.18 * (mod((1:nnz(pick))' * 0.618034, 1) - 0.5);
    scatter(ax, i + jitter, e, 14, colors.aligned, 'filled', 'MarkerFaceAlpha', 0.6, 'HandleVisibility', 'off');
    plot(ax, i + [-0.3 0.3], median(e) * [1 1], '-', 'Color', [0.1 0.1 0.1], 'LineWidth', 1.6, 'HandleVisibility', 'off');
end
yline(ax, 0, '-', 'Color', [0.4 0.4 0.4]);
set(ax, 'XTick', 1:numel(locations), 'XTickLabel', strrep(cellstr(locations), '_', ' '), 'XTickLabelRotation', 30, 'XGrid', 'off');
xlim(ax, [0.4 numel(locations) + 0.6]);
ylabel(ax, 'e, half-car aligned [%]');
counts = arrayfun(@(l) nnz(r.location == l), locations);
title(ax, sprintf('error per location (roads: %s), bar = median', strjoin(string(counts), ', ')));
save_figure(fig, output, 'real_locations', label);
end

function draw_examples(r, series, colors, output, label)
[~, order] = sort(abs(r.error_aligned));
n = numel(order);
pick = order(unique([1 2 3 round(n / 2) round(n / 2) + 1 n - 2 n - 1 n]));
fig = ride.validation.white_figure(17, 22);
layout = tiledlayout(fig, numel(pick), 1, 'TileSpacing', 'compact', 'Padding', 'compact');
names = string({series.name});
for k = 1:numel(pick)
    row = r(pick(k), :);
    s = series(names == row.scenario);
    ax = nexttile(layout);
    hold(ax, 'on');
    yl = [min([s.measured_lp; s.simulated]) max([s.measured_lp; s.simulated])] * 1.15;
    patch(ax, s.bump_t([1 2 2 1]), yl([1 1 2 2]), [0.9 0.9 0.9], 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(ax, s.imu_t, s.a_z, '-', 'Color', [0.82 0.82 0.82], 'LineWidth', 0.5, 'DisplayName', 'IMU, raw');
    plot(ax, s.t, s.measured_lp, '-', 'Color', colors.measured, 'LineWidth', 1.2, 'DisplayName', 'IMU, 10 Hz low-pass');
    plot(ax, s.t, s.simulated, '-', 'Color', colors.aligned, 'LineWidth', 1.2, 'DisplayName', 'half-car, aligned');
    plot(ax, s.t, s.study_simulated, ':', 'Color', colors.study, 'LineWidth', 1.1, 'DisplayName', 'half-car, not shifted');
    ylim(ax, yl);
    xlim(ax, [0 s.t(end)]);
    ylabel(ax, 'm/s^2');
    title(ax, sprintf('%s (%s, %s): measured a_w %.3f, simulated %.3f (%+.0f %%), lag %+.2f s', ...
        strrep(row.scenario, '_', '\_'), row.region, row.paper_split, row.a_w_measured, row.a_w_aligned, ...
        round(100 * row.error_aligned) + 0, row.lag_s), 'FontSize', 8);
    if k == 1
        lg = legend(ax, 'Box', 'off', 'FontSize', 7, 'NumColumns', 4);
        lg.Layout.Tile = 'north';
    end
    if k < numel(pick)
        set(ax, 'XTickLabel', []);
    end
end
xlabel(ax, 't [s] from the first pose of the window; grey band: simulated front axle on the bump to rear axle off it');
save_figure(fig, output, 'real_examples', [label ' | three best, two median, three worst']);
end

function draw_checks(r, colors, output, label)
fig = ride.validation.white_figure(17, 12);
layout = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
ax = nexttile(layout);
hold(ax, 'on');
shifted = r.trim_offset_m > 0;
scatter(ax, r.trim_offset_m(shifted), r.lag_study_s(shifted), 16, colors.study, 'filled', 'MarkerFaceAlpha', 0.8, 'DisplayName', 'road not shifted');
scatter(ax, r.trim_offset_m(shifted), r.lag_s(shifted), 16, colors.aligned, 'filled', 'MarkerFaceAlpha', 0.8, 'DisplayName', 'road aligned');
yline(ax, 0, '-', 'Color', [0.4 0.4 0.4], 'HandleVisibility', 'off');
xlabel(ax, 'meta.trim.offset\_m [m]');
ylabel(ax, 'lag of the IMU behind the simulation [s]');
legend(ax, 'Location', 'southwest', 'Box', 'off', 'FontSize', 7.5);
title(ax, sprintf('(a) roads with a trimmed start (%d)', nnz(shifted)));
ax = nexttile(layout);
histogram(ax, r.lag_s, -0.525:0.05:0.525, 'FaceColor', colors.aligned, 'EdgeColor', 'none');
xlabel(ax, 'lag of the IMU behind the simulation [s]');
ylabel(ax, 'roads');
title(ax, '(b) time alignment');
ax = nexttile(layout);
histogram(ax, r.anchor_gap_m, 30, 'FaceColor', colors.aligned, 'EdgeColor', 'none');
xlabel(ax, 'distance at anchor\_ts minus s\_bump [m]');
xlim(ax, [-5 5]);
ylabel(ax, 'roads');
title(ax, '(c) bump position in meta.yaml');
ax = nexttile(layout);
scatter(ax, r.gravity_axis_mps2, r.horizontal_mean_mps2, 14, colors.aligned, 'filled', 'MarkerFaceAlpha', 0.7);
xlabel(ax, 'mean IMU z acceleration [m/s^2]');
ylabel(ax, 'mean horizontal acceleration [m/s^2]');
title(ax, '(d) IMU axes');
save_figure(fig, output, 'real_checks', label);
end

function save_figure(fig, output, name, label)
fig.Units = 'centimeters';
footer = 1.0 / fig.Position(4);
for child = findobj(fig, 'Type', 'tiledlayout')'
    child.OuterPosition = [0 footer 1 1 - footer];
end
for child = findobj(fig, 'Type', 'axes', '-depth', 1)'
    child.OuterPosition = [0 footer 1 1 - footer];
end
annotation(fig, 'textbox', [0.01 0 0.98 footer * 0.8], 'String', label, 'EdgeColor', 'none', 'FontName', 'Times New Roman', ...
    'FontSize', 6.5, 'Color', [0.4 0.4 0.4], 'Interpreter', 'none', 'VerticalAlignment', 'bottom');
exportgraphics(fig, fullfile(output, [name '.pdf']), 'ContentType', 'vector', 'BackgroundColor', 'white');
exportgraphics(fig, fullfile(output, [name '.png']), 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('wrote %s\n', fullfile(output, name));
end
