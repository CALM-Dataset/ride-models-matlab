function analysis = analyse_real_data(config)
%ANALYSE_REAL_DATA Error by bump size and spectra of the comparison with the recorded drives.
%   analysis = analyse_real_data('paths.json') reads results.mat written by run_real_data and
%   the scenario files, and writes to the same output folder:
%     geometry.csv   the a_w error of the calibrated half-car (aligned) by bump width and height
%     spectra.csv    simulated over measured RMS acceleration in frequency bands, per road
%     real_spectra   median power spectral density of the measured and simulated body
%                    acceleration over the usable roads, and their ratio
here = fileparts(mfilename('fullpath'));
run(fullfile(here, '..', '..', 'setup.m'));
paths = jsondecode(fileread(config));
output = paths.output;
if isempty(output)
    output = fullfile(ride.root(), 'figures', 'real_data');
end
saved = load(fullfile(output, 'results.mat'));
results = saved.results;
series = saved.series;
usable = ~results.low_confidence;
scenarios = ride.validation.find_scenarios(paths.scenarios);
[results.bump_width_m, results.bump_height_mm] = deal(nan(height(results), 1));
for i = 1:height(results)
    file = scenarios.file(scenarios.name == results.scenario(i));
    [results.bump_width_m(i), results.bump_height_mm(i)] = bump_size(jsondecode(fileread(file)));
end
analysis.geometry = by_geometry(results(usable, :));
writetable(analysis.geometry, fullfile(output, 'geometry.csv'));
disp(analysis.geometry);
[analysis.spectra, analysis.bands] = spectra(results(usable, :), series);
writetable(analysis.bands, fullfile(output, 'spectra.csv'));
disp(groupsummary(analysis.bands, [], 'median', analysis.bands.Properties.VariableNames(2:end)));
draw_spectra(analysis.spectra, nnz(usable), output);
end

function [width, height_mm] = bump_size(scenario)
width = NaN;
height_mm = NaN;
if ~isfield(scenario, 'bumps') || isempty(scenario.bumps)
    return
end
b = scenario.bumps(1);
width = b.s_end_m - b.s_start_m;
z = scenario.road.z(:);
s = (0:numel(z) - 1)' * scenario.road.ds_m;
inside = s >= b.s_start_m & s <= b.s_end_m;
edges = interp1(s, z, [b.s_start_m b.s_end_m], 'linear', 'extrap');
height_mm = 1e3 * (max(z(inside)) - mean(edges));
end

function t = by_geometry(r)
groups = {
    'bump width below 2 m', r.bump_width_m < 2
    'bump width 2 to 4.5 m', r.bump_width_m >= 2 & r.bump_width_m < 4.5
    'bump width 4.5 m and more', r.bump_width_m >= 4.5
    'bump height below 40 mm', r.bump_height_mm < 40
    'bump height 40 mm and more', r.bump_height_mm >= 40};
rows = cell(size(groups, 1), 5);
for g = 1:size(groups, 1)
    e = 100 * r.error_aligned(groups{g, 2});
    rows(g, :) = {groups{g, 1}, numel(e), median(e), median(abs(e)), 100 * mean(abs(e) <= 30)};
end
t = cell2table(rows, 'VariableNames', {'group', 'roads', 'median_error_pct', 'median_abs_error_pct', 'within_30_pct'});
end

function [s, bands] = spectra(r, series)
f = logspace(log10(0.3), log10(20), 120)';
names = string({series.name});
edges = [0.3 2; 2 8; 8 20];
measured = nan(numel(f), height(r));
simulated = nan(numel(f), height(r));
ratio = nan(height(r), size(edges, 1));
for k = 1:height(r)
    one = series(names == r.scenario(k));
    [fm, pm] = psd_hann(one.a_z, one.imu_t(2) - one.imu_t(1));
    [fs, ps] = psd_hann(one.simulated, one.t(2) - one.t(1));
    measured(:, k) = interp1(fm, pm, f);
    simulated(:, k) = interp1(fs, ps, f);
    for b = 1:size(edges, 1)
        ratio(k, b) = sqrt(band(fs, ps, edges(b, :)) / band(fm, pm, edges(b, :)));
    end
end
s = struct('f', f, 'measured', median(measured, 2), 'simulated', median(simulated, 2), ...
    'ratio', median(simulated ./ measured, 2), 'ratio_q', quantile(simulated ./ measured, [0.25 0.75], 2), ...
    'measured_q', quantile(measured, [0.25 0.75], 2), 'simulated_q', quantile(simulated, [0.25 0.75], 2));
bands = table(r.scenario, ratio(:, 1), ratio(:, 2), ratio(:, 3), 'VariableNames', ...
    {'scenario', 'rms_ratio_0p3_to_2_hz', 'rms_ratio_2_to_8_hz', 'rms_ratio_8_to_20_hz'});
end

function [f, p] = psd_hann(x, dt)
x = x(:) - mean(x);
n = numel(x);
w = 0.5 - 0.5 * cos(2 * pi * (0:n - 1)' / (n - 1));
X = fft(x .* w);
half = floor(n / 2) + 1;
p = abs(X(1:half)) .^ 2 * dt / sum(w .^ 2);
p(2:end - 1) = 2 * p(2:end - 1);
f = (0:half - 1)' / (n * dt);
end

function e = band(f, p, edge)
pick = f >= edge(1) & f < edge(2);
e = trapz(f(pick), p(pick));
end

function draw_spectra(s, n, output)
fig = ride.validation.white_figure(17, 10);
layout = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
ax = nexttile(layout);
hold(ax, 'on');
band_fill(ax, s.f, s.measured_q, [0.35 0.35 0.35]);
band_fill(ax, s.f, s.simulated_q, [197 14 31] / 255);
plot(ax, s.f, s.measured, '-', 'Color', [0.35 0.35 0.35], 'LineWidth', 1.4, 'DisplayName', 'IMU');
plot(ax, s.f, s.simulated, '-', 'Color', [197 14 31] / 255, 'LineWidth', 1.4, 'DisplayName', 'half-car, aligned');
set(ax, 'XScale', 'log', 'YScale', 'log', 'XTickLabel', []);
xlim(ax, [0.3 20]);
ylabel(ax, 'PSD [(m/s^2)^2/Hz]');
title(ax, sprintf('vertical body acceleration over the recorded window, median of %d roads, band = middle half', n));
legend(ax, 'Location', 'southwest', 'Box', 'off');
ax = nexttile(layout);
hold(ax, 'on');
band_fill(ax, s.f, s.ratio_q, [197 14 31] / 255);
plot(ax, s.f, s.ratio, '-', 'Color', [197 14 31] / 255, 'LineWidth', 1.4, 'HandleVisibility', 'off');
yline(ax, 1, '--', 'Color', [0.4 0.4 0.4]);
set(ax, 'XScale', 'log', 'YScale', 'log');
xlim(ax, [0.3 20]);
ylim(ax, [0.05 20]);
xlabel(ax, 'frequency [Hz]');
ylabel(ax, 'simulated / measured PSD');
annotation(fig, 'textbox', [0.01 0 0.98 0.06], 'String', sprintf('ride-models %s | %d usable recorded drives | calibrated half-car, aligned scenario roads', ...
    ride.version(), n), 'EdgeColor', 'none', 'FontName', 'Times New Roman', 'FontSize', 7, 'Color', [0.4 0.4 0.4], ...
    'Interpreter', 'none', 'VerticalAlignment', 'middle');
layout.OuterPosition = [0 0.06 1 0.94];
exportgraphics(fig, fullfile(output, 'real_spectra.pdf'), 'ContentType', 'vector', 'BackgroundColor', 'white');
exportgraphics(fig, fullfile(output, 'real_spectra.png'), 'Resolution', 300, 'BackgroundColor', 'white');
end

function band_fill(ax, f, q, color)
fill(ax, [f; flipud(f)], [q(:, 1); flipud(q(:, 2))], color, 'FaceAlpha', 0.12, 'EdgeColor', 'none', 'HandleVisibility', 'off');
end
