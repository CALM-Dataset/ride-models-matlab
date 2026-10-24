run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'setup.m'));
fig = paper_figure(17, 10.5);
ax = axes(fig, 'Position', [0 0.08 1 0.92], 'XLim', [0 100], 'YLim', [0 62]);
axis(ax, 'off');
hold(ax, 'on');
ink = [0.15 0.15 0.15];
fill_entry = [0.93 0.95 0.98];
fill_plugin = [0.98 0.95 0.90];
fill_core = [0.94 0.94 0.94];

box(ax, [2 52 30 8], fill_entry, 'ride.config', 'config/default.json + overrides');
box(ax, [36 52 28 8], fill_entry, 'ride.run', 'model + scenario + profile + metrics');
box(ax, [68 52 30 8], fill_entry, 'ride.render', 'animate, frame_figure, plots.signals');
arrow(ax, [32 56], [36 56]);

plugins = {
    'ride.models', strjoin(ride.models.list(), ', ')
    'ride.scenarios', 'synthetic, real, file, registered'
    'ride.profiles', wrap(ride.profiles.list(), 3)
    'ride.metrics', wrap(ride.metrics.list(), 2)};
for i = 1:size(plugins, 1)
    x = 2 + (i - 1) * 24.5;
    box(ax, [x 26 22 18], fill_plugin, plugins{i, 1}, plugins{i, 2});
    arrow(ax, [50 52], [x + 11 44]);
end
text(ax, 2, 48.5, 'plug-in registries: list, register, unregister', ...
    'FontSize', 8, 'FontAngle', 'italic', 'Color', ink);

core = {'suspension', 'terrain', 'comfort'};
for i = 1:numel(core)
    package = meta.package.fromName(['ride.core.' core{i}]);
    names = sort({package.FunctionList.Name});
    x = 2 + (i - 1) * 24.5;
    box(ax, [x 4 22 16], fill_core, package.Name, wrap(names, 2));
end
box(ax, [75.5 4 22.5 16], [0.92 0.96 0.92], 'Simulink library', {'Quarter-car, Half-car', 'Axle, Road, Drive'});
text(ax, 2, 22.5, 'building blocks', 'FontSize', 8, 'FontAngle', 'italic', 'Color', ink);
arrow(ax, [13 26], [13 20]);
arrow(ax, [15 26], [35.5 20]);
arrow(ax, [37.5 26], [37.5 20]);
arrow(ax, [86.5 26], [64 20]);
here = fileparts(mfilename('fullpath'));
save_figure(fig, 'architecture', 'boxes list the models, profile types, metrics and core functions found in src/+ride');

function box(ax, rect, color, heading, body)
rectangle(ax, 'Position', rect, 'FaceColor', color, 'EdgeColor', [0.35 0.35 0.35], 'LineWidth', 0.8, 'Curvature', 0.08);
text(ax, rect(1) + rect(3) / 2, rect(2) + rect(4) - 2, heading, 'HorizontalAlignment', 'center', ...
    'FontWeight', 'bold', 'FontSize', 9, 'Interpreter', 'none');
text(ax, rect(1) + rect(3) / 2, rect(2) + (rect(4) - 3.5) / 2, body, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', 'FontSize', 7.5, 'Interpreter', 'none');
end

function arrow(ax, from, to)
plot(ax, [from(1) to(1)], [from(2) to(2)], '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 0.8);
direction = (to - from) / norm(to - from);
side = [-direction(2) direction(1)];
tip = [to; to - 1.6 * direction + 0.7 * side; to - 1.6 * direction - 0.7 * side];
fill(ax, tip(:, 1), tip(:, 2), [0.35 0.35 0.35], 'EdgeColor', 'none');
end

function text_lines = wrap(names, per_line)
names = names(:)';
text_lines = {};
for i = 1:per_line:numel(names)
    text_lines{end + 1} = strjoin(names(i:min(i + per_line - 1, end)), ', '); %#ok<AGROW>
end
end
