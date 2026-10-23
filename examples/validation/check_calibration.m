function grid = check_calibration(config, varargin)
%CHECK_CALIBRATION How well other suspension scalings of the half-car match the recorded drives.
%   grid = check_calibration('paths.json') scales the nominal spring rates and damper
%   coefficients of the half-car by a grid of factors, replays every usable recorded drive over
%   its aligned scenario road and compares a_w with the IMU. The factors are chosen on the paper
%   training roads only and scored on the held-out roads, to see whether the calibrated
%   suspension (springs 1.06, dampers 0.16 times nominal) is an in-sample fit. Nothing is
%   changed in the parameter files. Writes calibration.csv and calibration.png/.pdf to the
%   output folder of run_real_data. Options: 'springs' and 'dampers' (the factors).
opts = struct('springs', [0.9 1.0 1.06 1.15 1.3], 'dampers', [0.08 0.12 0.16 0.2 0.25 0.35 0.5 1.0]);
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
here = fileparts(mfilename('fullpath'));
run(fullfile(here, '..', '..', 'setup.m'));
paths = jsondecode(fileread(config));
output = paths.output;
if isempty(output)
    output = fullfile(ride.root(), 'figures', 'real_data');
end
if ~isfolder(output)
    mkdir(output);
end
drives = load_drives(paths);
base = ride.load('halfcar');
[S, D] = ndgrid(opts.springs, opts.dampers);
errors = nan(numel(drives), numel(S));
for g = 1:numel(S)
    P = scaled(base, S(g), D(g));
    started = tic;
    for k = 1:numel(drives)
        out = ride.simulate('halfcar', P, drives(k).road, drives(k).speeds);
        errors(k, g) = ride.core.comfort.a_w(out.z_B_ddot, P.DT) / drives(k).a_w_measured - 1;
    end
    fprintf('springs %.2f dampers %.2f  training %.1f %%  held out %.1f %%  %.0f s\n', S(g), D(g), ...
        100 * median(abs(errors([drives.train], g))), 100 * median(abs(errors(~[drives.train], g))), toc(started));
end
train = [drives.train]';
grid = table(S(:), D(:), 'VariableNames', {'spring_factor', 'damper_factor'});
grid.train_median_abs_pct = 100 * median(abs(errors(train, :)), 1)';
grid.train_median_pct = 100 * median(errors(train, :), 1)';
grid.held_out_median_abs_pct = 100 * median(abs(errors(~train, :)), 1)';
grid.held_out_median_pct = 100 * median(errors(~train, :), 1)';
grid.all_median_abs_pct = 100 * median(abs(errors), 1)';
grid.all_within_30_pct = 100 * mean(abs(errors) <= 0.3, 1)';
writetable(grid, fullfile(output, 'calibration.csv'));
[~, best] = min(grid.train_median_abs_pct);
fprintf('best on training: springs %.2f dampers %.2f, training %.1f %%, held out %.1f %%\n', ...
    grid.spring_factor(best), grid.damper_factor(best), grid.train_median_abs_pct(best), grid.held_out_median_abs_pct(best));
draw(grid, opts, output, nnz(train), nnz(~train));
end

function drives = load_drives(paths)
scenarios = ride.validation.find_scenarios(paths.scenarios);
windows = ride.validation.find_windows(cellstr(paths.recordings));
drives = struct('name', {}, 'road', {}, 'speeds', {}, 'a_w_measured', {}, 'train', {});
for i = 1:height(scenarios)
    name = char(scenarios.name(i));
    if scenarios.low_confidence(i) || ~isKey(windows, name)
        continue
    end
    rec = ride.validation.load_recording(windows(name));
    scenario = jsondecode(fileread(scenarios.file(i)));
    road = ride.validation.window_road('scenario', rec, scenario);
    drives(end + 1) = struct('name', string(name), 'road', road, 'speeds', rec.v(1:end - 1), ...
        'a_w_measured', ride.core.comfort.a_w(rec.a_z, rec.imu_dt), 'train', scenarios.paper_split(i) == "train"); %#ok<AGROW>
end
fprintf('%d usable drives, %d training, %d held out\n', numel(drives), nnz([drives.train]), nnz(~[drives.train]));
end

function P = scaled(base, spring, damper)
P = base;
for axle = {'front', 'rear'}
    node = base.nominal.axles.(axle{1});
    node.spring.k_S = spring * node.spring.k_S;
    node.damper.D = damper * node.damper.D;
    P.(axle{1}) = ride.core.suspension.assemble(node);
end
end

function draw(grid, opts, output, n_train, n_held)
fig = ride.validation.white_figure(17, 8.5);
layout = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
fields = {'train_median_abs_pct', sprintf('training roads (%d)', n_train); ...
    'held_out_median_abs_pct', sprintf('held-out roads (%d)', n_held)};
for k = 1:2
    ax = nexttile(layout);
    values = reshape(grid.(fields{k, 1}), numel(opts.springs), numel(opts.dampers));
    imagesc(ax, 1:numel(opts.dampers), 1:numel(opts.springs), values);
    colormap(ax, flipud(gray(256)) * 0.75 + 0.25);
    clim(ax, [10 60]);
    for i = 1:numel(opts.springs)
        for j = 1:numel(opts.dampers)
            text(ax, j, i, sprintf('%.0f', values(i, j)), 'HorizontalAlignment', 'center', 'FontSize', 7.5, 'Color', [0.1 0.1 0.1]);
        end
    end
    hold(ax, 'on');
    [~, row] = min(abs(opts.springs - 1.06));
    [~, col] = min(abs(opts.dampers - 0.16));
    rectangle(ax, 'Position', [col - 0.5, row - 0.5, 1, 1], 'EdgeColor', [197 14 31] / 255, 'LineWidth', 1.6);
    set(ax, 'XTick', 1:numel(opts.dampers), 'XTickLabel', compose('%g', opts.dampers), ...
        'YTick', 1:numel(opts.springs), 'YTickLabel', compose('%g', opts.springs), 'YDir', 'normal', ...
        'XGrid', 'off', 'YGrid', 'off', 'Box', 'on');
    xlabel(ax, 'damper factor (times nominal)');
    ylabel(ax, 'spring factor (times nominal)');
    title(ax, ['median |e| [%], ' fields{k, 2}]);
end
annotation(fig, 'textbox', [0.01 0 0.98 0.07], 'String', sprintf(['ride-models %s | half-car, aligned scenario roads | ' ...
    'red box: calibrated suspension (springs 1.06, dampers 0.16)'], ride.version()), 'EdgeColor', 'none', ...
    'FontName', 'Times New Roman', 'FontSize', 7, 'Color', [0.4 0.4 0.4], 'Interpreter', 'none', 'VerticalAlignment', 'middle');
layout.OuterPosition = [0 0.07 1 0.93];
exportgraphics(fig, fullfile(output, 'calibration.pdf'), 'ContentType', 'vector', 'BackgroundColor', 'white');
exportgraphics(fig, fullfile(output, 'calibration.png'), 'Resolution', 300, 'BackgroundColor', 'white');
end
