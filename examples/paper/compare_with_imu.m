function results = compare_with_imu(folder)
%COMPARE_WITH_IMU Simulated comfort against the comfort measured in the car.
%   results = compare_with_imu(folder) takes the CALM export folder (comfort_scores.csv,
%   scenarios.csv and comfort_profiles/). For every recorded human drive on a measured road
%   it replays the recorded speeds over the measured road heights with the quarter-car, the
%   half-car and the half-car with its nominal (uncalibrated) suspension, and compares a_w
%   with a_w_imu, the ISO 2631-1 weighted RMS of the vertical acceleration measured by the
%   car's IMU on the same drive. Writes figures/imu_comparison.csv,
%   figures/imu_comparison_summary.csv, figures/imu_comparison_summary.tex and the figure
%   imu_comparison.
here = fileparts(mfilename('fullpath'));
run(fullfile(here, '..', '..', 'setup.m'));
scores = readtable(fullfile(folder, 'comfort_scores.csv'), 'TextType', 'string');
geometry = readtable(fullfile(folder, 'scenarios.csv'), 'TextType', 'string');
human = scores(scores.source == "human" & ~isnan(scores.a_w_imu) & scores.a_w_imu > 0, :);
[~, first] = unique(human.scenario, 'stable');
human = human(first, :);
variants = vehicle_variants();
n = height(human);
results = table(human.scenario, human.a_w_imu, 'VariableNames', {'scenario', 'a_w_imu'});
results.width_m = NaN(n, 1);
results.height_mm = NaN(n, 1);
results.region = strings(n, 1);
results.mean_speed_kmh = human.mean_speed_kmh;
for v = 1:size(variants, 1)
    results.(variants{v, 1}) = NaN(n, 1);
end
italy = ["carmiano", "salice_salentino", "nardo", "monteroni_di_lecce"];
for i = 1:n
    row = geometry.scenario == results.scenario(i);
    if any(row)
        results.width_m(i) = geometry.width_m(find(row, 1));
        results.height_mm(i) = geometry.height_mm(find(row, 1));
    end
    results.region(i) = "Germany";
    if any(startsWith(results.scenario(i), italy))
        results.region(i) = "Italy";
    end
    [road, speeds] = drive_of(folder, human.suite(i), results.scenario(i));
    if isempty(road)
        continue
    end
    for v = 1:size(variants, 1)
        out = ride.simulate(variants{v, 2}, variants{v, 3}, road, speeds);
        results.(variants{v, 1})(i) = ride.core.comfort.a_w(out.z_B_ddot, variants{v, 3}.DT);
    end
end
results = results(~isnan(results.(variants{1, 1})), :);
folder_out = fullfile(ride.root(), 'figures');
if ~isfolder(folder_out)
    mkdir(folder_out);
end
writetable(results, fullfile(folder_out, 'imu_comparison.csv'));
summary = summarise(results, variants);
writetable(summary, fullfile(folder_out, 'imu_comparison_summary.csv'));
write_tex(summary, fullfile(folder_out, 'imu_comparison_summary.tex'));
disp(summary);
by_group(results);
draw(results, variants);
end

function variants = vehicle_variants()
calibrated = ride.load('halfcar');
nominal = calibrated;
nominal.front = ride.core.suspension.assemble(calibrated.nominal.axles.front);
nominal.rear = ride.core.suspension.assemble(calibrated.nominal.axles.rear);
variants = {
    'halfcar', 'halfcar', calibrated, 'half-car, calibrated'
    'halfcar_nominal', 'halfcar', nominal, 'half-car, nominal'
    'quartercar', 'quartercar', ride.load('quartercar'), 'quarter-car'};
end

function [road, speeds] = drive_of(folder, suite, scenario)
road = [];
speeds = [];
profiles = fullfile(folder, 'comfort_profiles');
drive_file = fullfile(profiles, sprintf('%s__%s__human.csv', suite, scenario));
if ~isfile(drive_file)
    return
end
for candidate = [suite, "real_all", "real"]
    road_file = fullfile(profiles, sprintf('road__%s__%s.csv', candidate, scenario));
    if isfile(road_file)
        heights = readtable(road_file);
        road = ride.core.terrain.profile(heights.z_mm / 1000, heights.s_m(2) - heights.s_m(1));
        drive = readtable(drive_file);
        speeds = drive.v_kmh / 3.6;
        return
    end
end
end

function summary = summarise(results, variants)
rows = cell(size(variants, 1), 1);
measured = results.a_w_imu;
for v = 1:size(variants, 1)
    simulated = results.(variants{v, 1});
    error_pct = 100 * (simulated - measured) ./ measured;
    pearson = corrcoef(measured, simulated);
    spearman = corrcoef(tiedrank_local(measured), tiedrank_local(simulated));
    q = quantile_local(error_pct, [0.25 0.5 0.75]);
    rows{v} = {string(variants{v, 4}), numel(measured), median(abs(error_pct)), q(2), q(1), q(3), ...
        100 * mean(abs(error_pct) <= 30), pearson(1, 2), spearman(1, 2), pair_agreement(measured, simulated)};
end
summary = cell2table(vertcat(rows{:}), 'VariableNames', {'model', 'roads', 'median_abs_error_pct', ...
    'median_error_pct', 'error_q25_pct', 'error_q75_pct', 'within_30pct_of_roads', 'pearson', 'spearman', ...
    'pairs_ordered_alike'});
end

function share = pair_agreement(a, b)
[i, j] = find(triu(true(numel(a)), 1));
share = mean(sign(a(i) - a(j)) == sign(b(i) - b(j)));
end

function r = tiedrank_local(x)
[~, order] = sort(x);
r = zeros(size(x));
r(order) = 1:numel(x);
for value = unique(x(:))'
    same = x == value;
    r(same) = mean(r(same));
end
end

function q = quantile_local(x, p)
x = sort(x(~isnan(x)));
q = interp1(linspace(0, 1, numel(x)), x, p);
end

function by_group(results)
error_pct = 100 * (results.halfcar - results.a_w_imu) ./ results.a_w_imu;
fprintf('\nhalf-car, calibrated: error against the IMU by group\n');
groups = {
    'Germany', results.region == "Germany"
    'Italy', results.region == "Italy"
    'bump width < 2 m', results.width_m < 2
    'bump width 2 to 4.5 m', results.width_m >= 2 & results.width_m < 4.5
    'bump width >= 4.5 m', results.width_m >= 4.5
    'bump height < 40 mm', results.height_mm < 40
    'bump height >= 40 mm', results.height_mm >= 40};
for g = 1:size(groups, 1)
    pick = groups{g, 2};
    if any(pick)
        fprintf('  %-24s %3d roads, median error %+6.1f %%, median |error| %5.1f %%\n', groups{g, 1}, nnz(pick), ...
            median(error_pct(pick)), median(abs(error_pct(pick))));
    end
end
end

function write_tex(summary, file)
fid = fopen(file, 'w');
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '\\begin{tabular}{lrrrrrr}\n\\hline\n');
fprintf(fid, 'Model & Roads & median $|e|$ & median $e$ & IQR of $e$ & within 30\\%% & Spearman \\\\\n\\hline\n');
for i = 1:height(summary)
    fprintf(fid, '%s & %d & %.1f\\%% & %+.1f\\%% & %+.1f to %+.1f\\%% & %.0f\\%% & %.2f \\\\\n', summary.model(i), ...
        summary.roads(i), summary.median_abs_error_pct(i), summary.median_error_pct(i), summary.error_q25_pct(i), ...
        summary.error_q75_pct(i), summary.within_30pct_of_roads(i), summary.spearman(i));
end
fprintf(fid, '\\hline\n\\end{tabular}\n');
end

function draw(results, variants)
colors = model_colors();
shades = {colors.halfcar, colors.constant, colors.quartercar};
markers = {'o', 's', '^'};
fig = paper_figure(17, 13);
layout = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
ax = nexttile(layout);
hold(ax, 'on');
limit = [min([results.a_w_imu; results.halfcar; results.quartercar]) * 0.8, ...
    max([results.a_w_imu; results.halfcar; results.quartercar]) * 1.25];
plot(ax, limit, limit, '--', 'Color', [0.4 0.4 0.4], 'HandleVisibility', 'off');
fill(ax, [limit fliplr(limit)], [limit * 0.7 fliplr(limit) * 1.3], [0.9 0.9 0.9], 'EdgeColor', 'none', ...
    'FaceAlpha', 0.6, 'DisplayName', '\pm30 %');
for v = [1 3]
    scatter(ax, results.a_w_imu, results.(variants{v, 1}), 18, shades{v}, markers{v}, 'filled', ...
        'MarkerFaceAlpha', 0.8, 'DisplayName', variants{v, 4});
end
set(ax, 'XScale', 'log', 'YScale', 'log');
axis(ax, 'square');
xlim(ax, limit);
ylim(ax, limit);
xlabel(ax, 'a_w measured by the IMU [m/s^2]');
ylabel(ax, 'a_w simulated [m/s^2]');
legend(ax, 'Location', 'southoutside', 'Orientation', 'horizontal', 'Box', 'off', 'FontSize', 7.5);
title(ax, '(a) per road', 'FontWeight', 'normal');

ax = nexttile(layout);
hold(ax, 'on');
error_pct = zeros(height(results), size(variants, 1));
for v = 1:size(variants, 1)
    error_pct(:, v) = 100 * (results.(variants{v, 1}) - results.a_w_imu) ./ results.a_w_imu;
end
for v = 1:size(variants, 1)
    edges = -100:10:max(200, ceil(max(error_pct(:)) / 10) * 10);
    histogram(ax, error_pct(:, v), edges, 'DisplayStyle', 'stairs', 'EdgeColor', shades{v}, 'LineWidth', 1.3, ...
        'DisplayName', variants{v, 4});
end
xline(ax, 0, '-', 'Color', [0.3 0.3 0.3], 'HandleVisibility', 'off');
xlabel(ax, 'simulated against measured a_w [%]');
ylabel(ax, 'roads');
xlim(ax, [-100 350]);
legend(ax, 'Location', 'northeast', 'Box', 'off', 'FontSize', 7.5);
title(ax, '(b) error distribution', 'FontWeight', 'normal');

ax = nexttile(layout);
hold(ax, 'on');
for region = ["Germany", "Italy"]
    pick = results.region == region;
    marker = 'o';
    if region == "Italy"
        marker = 'd';
    end
    scatter(ax, results.width_m(pick), error_pct(pick, 1), 18, colors.(lower(char(region))), marker, 'filled', 'MarkerFaceAlpha', 0.7, ...
        'DisplayName', char(region));
end
yline(ax, 0, '-', 'Color', [0.3 0.3 0.3], 'HandleVisibility', 'off');
xlabel(ax, 'bump width [m]');
ylabel(ax, 'half-car error [%]');
legend(ax, 'Location', 'southeast', 'Box', 'off', 'FontSize', 7.5);
title(ax, '(c) against bump width', 'FontWeight', 'normal');

ax = nexttile(layout);
hold(ax, 'on');
scatter(ax, results.height_mm, error_pct(:, 1), 18, colors.halfcar, 'o', 'filled', 'MarkerFaceAlpha', 0.7);
yline(ax, 0, '-', 'Color', [0.3 0.3 0.3]);
xlabel(ax, 'bump height [mm]');
ylabel(ax, 'half-car error [%]');
title(ax, '(d) against bump height', 'FontWeight', 'normal');
save_figure(fig, 'imu_comparison', sprintf(['%d recorded human drives on measured roads (CALM export) | recorded speeds ', ...
    'replayed over the measured road heights | a_w against the IMU of the same drive'], height(results)));
end
