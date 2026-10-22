function results = replay_calm_profiles(folder)
%REPLAY_CALM_PROFILES Replay the speed profiles of the CALM comfort study through the half-car.
%   results = replay_calm_profiles(folder) reads the comfort_profiles folder and the
%   comfort_scores.csv file that the CALM repository exports (the folder that holds both),
%   drives the half-car of this package with every recorded or planned speed profile, and
%   compares the body acceleration step by step and a_w with the exported values.
%   Synthetic roads are rebuilt from this package's catalog, measured roads from the
%   exported road__<suite>__<scenario>.csv height files. Writes figures/calm_replay.csv
%   and the figure calm_replay.
here = fileparts(mfilename('fullpath'));
run(fullfile(here, '..', '..', 'setup.m'));
profiles = fullfile(folder, 'comfort_profiles');
if ~isfolder(profiles)
    error('ride:noData', 'expected the CALM export with a comfort_profiles folder in "%s"', folder);
end
scores = table();
if isfile(fullfile(folder, 'comfort_scores.csv'))
    scores = readtable(fullfile(folder, 'comfort_scores.csv'), 'TextType', 'string');
end
files = dir(fullfile(profiles, '*.csv'));
files = files(~startsWith({files.name}, 'road__'));
P = ride.load('halfcar');
n = numel(files);
suite = strings(n, 1); scenario = strings(n, 1); source = strings(n, 1);
max_error = NaN(n, 1); peak = NaN(n, 1); a_w_package = NaN(n, 1); a_w_export = NaN(n, 1); a_w_study = NaN(n, 1);
for i = 1:n
    parts = split(erase(files(i).name, '.csv'), '__');
    [suite(i), scenario(i), source(i)] = deal(parts{1}, parts{2}, parts{3});
    road = road_of(profiles, suite(i), scenario(i));
    if isempty(road)
        continue
    end
    drive = readtable(fullfile(profiles, files(i).name));
    out = ride.simulate('halfcar', P, road, drive.v_kmh / 3.6);
    max_error(i) = max(abs(out.z_B_ddot - drive.a_body));
    peak(i) = max(abs(drive.a_body));
    a_w_package(i) = ride.core.comfort.a_w(out.z_B_ddot, P.DT);
    a_w_export(i) = ride.core.comfort.a_w(drive.a_body, P.DT);
    if ~isempty(scores)
        row = scores.suite == suite(i) & scores.scenario == scenario(i) & scores.source == source(i);
        if any(row)
            a_w_study(i) = scores.a_w(find(row, 1));
        end
    end
end
results = table(suite, scenario, source, max_error, peak, a_w_package, a_w_export, a_w_study);
folder_out = fullfile(ride.root(), 'figures');
if ~isfolder(folder_out)
    mkdir(folder_out);
end
writetable(results, fullfile(folder_out, 'calm_replay.csv'));
report(results);
draw(results);
end

function road = road_of(profiles, suite, scenario)
road = [];
if startsWith(suite, 'real')
    for candidate = [suite, "real_all", "real"]
        file = fullfile(profiles, sprintf('road__%s__%s.csv', candidate, scenario));
        if isfile(file)
            heights = readtable(file);
            road = ride.core.terrain.profile(heights.z_mm / 1000, heights.s_m(2) - heights.s_m(1));
            return
        end
    end
else
    road = ride.scenarios.get(sprintf('synthetic:%s/%s', suite, scenario)).road;
end
end

function report(results)
done = ~isnan(results.max_error);
measured = startsWith(results.suite, 'real');
relative = results.max_error ./ results.peak;
fprintf('%d profiles replayed, %d without a road\n', nnz(done), nnz(~done));
groups = {~measured & done, 'synthetic roads'; measured & done, 'measured roads'};
for g = 1:2
    pick = groups{g, 1};
    if ~any(pick)
        continue
    end
    fprintf('%s (%d profiles): body acceleration differs by at most %.2g m/s^2 (%.2g of the peak, median %.2g)\n', ...
        groups{g, 2}, nnz(pick), max(results.max_error(pick)), max(relative(pick)), median(relative(pick)));
    gap = abs(results.a_w_package(pick) - results.a_w_export(pick)) ./ results.a_w_export(pick);
    fprintf('   a_w from the replay against a_w of the exported acceleration: median %.2g, max %.2g\n', median(gap), max(gap));
end
listed = done & ~isnan(results.a_w_study);
if any(listed)
    gap = abs(results.a_w_package(listed) - results.a_w_study(listed)) ./ results.a_w_study(listed);
    fprintf('a_w against comfort_scores.csv (%d profiles): median %.2g, max %.2g\n', nnz(listed), median(gap), max(gap));
end
end

function draw(results)
colors = model_colors();
fig = paper_figure(17, 7);
layout = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
ax = nexttile(layout);
hold(ax, 'on');
listed = ~isnan(results.a_w_study) & ~isnan(results.a_w_package);
limit = max([results.a_w_study(listed); results.a_w_package(listed); eps]) * 1.05;
plot(ax, [0 limit], [0 limit], '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
for name = ["human", "const", "mpc", "ppo"]
    pick = listed & results.source == name;
    if any(pick)
        scatter(ax, results.a_w_study(pick), results.a_w_package(pick), 14, colors.(char(name)), 'filled', 'DisplayName', char(name));
    end
end
axis(ax, 'square');
xlim(ax, [0 limit]);
ylim(ax, [0 limit]);
xlabel(ax, 'a_w in comfort\_scores.csv [m/s^2]');
ylabel(ax, 'a_w, ride.simulate [m/s^2]');
legend(ax, 'Location', 'northwest', 'Box', 'off');
ax = nexttile(layout);
done = ~isnan(results.max_error);
histogram(ax, log10(results.max_error(done) ./ results.peak(done)), 30, 'FaceColor', colors.halfcar, 'EdgeColor', 'none');
xlabel(ax, 'log_{10} (largest step error / peak body acceleration)');
ylabel(ax, 'profiles');
save_figure(fig, 'calm_replay', sprintf('half-car | %d speed profiles of the CALM comfort study (human, const, MPC, RL) replayed', nnz(done)));
end
