function results = run_real_data(config, varargin)
%RUN_REAL_DATA Compare the simulation with the recorded drives of the CALM dataset.
%   results = run_real_data('paths.json') reads the data folders from a JSON file laid out
%   like paths.example.json (or from a struct with the same fields):
%     recordings    the sequences folders of CALM-ITALY and CALM-Germany (read in place)
%     scenarios     the CALM-Scenarios folder with the scenario files and split.yaml
%     study_scores  optional: comfort_scores.csv of the original study, to check the port
%     output        optional: where tables and figures go (default figures/real_data)
%   For every scenario with a recording it runs ride.validation.compare for the calibrated
%   half-car on the aligned scenario road, and the variants listed in the variants table
%   below. Writes results.csv, summary.csv, summary.tex and results.mat, then draws the
%   figures with draw_real_data. run_real_data(config, 'reuse', true) only redraws.
opts = struct('reuse', false, 'only', {{}});
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
here = fileparts(mfilename('fullpath'));
run(fullfile(here, '..', '..', 'setup.m'));
paths = read_paths(config);
output = paths.output;
if isempty(output)
    output = fullfile(ride.root(), 'figures', 'real_data');
end
if ~isfolder(output)
    mkdir(output);
end
store = fullfile(output, 'results.mat');
if opts.reuse && isfile(store)
    saved = load(store);
    results = saved.results;
    series = saved.series;
else
    [results, series] = compare_all(paths, opts.only);
    save(store, 'results', 'series', '-v7');
end
writetable(results, fullfile(output, 'results.csv'));
summary = summarise(results);
writetable(summary, fullfile(output, 'summary.csv'));
write_summary_tex(summary, fullfile(output, 'summary.tex'));
disp(summary);
draw_real_data(results, series, summary, output);
end

function paths = read_paths(config)
if ischar(config) || isstring(config)
    if ~isfile(config)
        error('ride:validation:noConfig', 'paths file "%s" was not found; copy paths.example.json and fill it in', config);
    end
    paths = jsondecode(fileread(config));
else
    paths = config;
end
defaults = struct('recordings', {{}}, 'scenarios', '', 'study_scores', '', 'output', '');
for f = fieldnames(defaults)'
    if ~isfield(paths, f{1})
        paths.(f{1}) = defaults.(f{1});
    end
end
paths.recordings = cellstr(paths.recordings);
end

function variants = variant_table()
variants = {
    'aligned', 'halfcar', 'scenario', [], 'half-car, scenario road aligned with meta.trim'
    'study', 'halfcar', 'scenario', 0, 'half-car, scenario road not shifted (original CALM replay)'
    'quartercar', 'quartercar', 'scenario', [], 'quarter-car, scenario road aligned'
    'nominal', 'halfcar_nominal', 'scenario', [], 'half-car with nominal suspension, aligned'
    'road_fl', 'halfcar', 'FL', [], 'half-car, raw front-left wheel excitation'
    'road_lr', 'halfcar', 'left_right', [], 'half-car, mean of the raw front wheel excitations'};
end

function [results, series] = compare_all(paths, only)
scenarios = ride.validation.find_scenarios(paths.scenarios);
windows = ride.validation.find_windows(paths.recordings);
profiles = fullfile(paths.scenarios, 'profiles');
study = table();
if ~isempty(paths.study_scores) && isfile(paths.study_scores)
    study = readtable(paths.study_scores, 'TextType', 'string');
    study = study(study.source == "human", :);
end
variants = variant_table();
models = struct('halfcar', ride.load('halfcar'), 'quartercar', ride.load('quartercar'));
nominal = models.halfcar;
nominal.front = ride.core.suspension.assemble(nominal.nominal.axles.front);
nominal.rear = ride.core.suspension.assemble(nominal.nominal.axles.rear);
models.halfcar_nominal = nominal;
rows = {};
series = struct('name', {}, 't', {}, 'imu_t', {}, 'a_z', {}, 'measured_lp', {}, 'simulated', {}, ...
    'simulated_lp', {}, 'simulated_shifted', {}, 'v', {}, 'bump_t', {}, 'study_simulated', {});
for i = 1:height(scenarios)
    name = char(scenarios.name(i));
    if ~isempty(only) && ~any(strcmp(only, name))
        continue
    end
    if ~isKey(windows, name)
        fprintf('%-26s no recording\n', name);
        continue
    end
    started = tic;
    rec = ride.validation.load_recording(windows(name));
    scenario = jsondecode(fileread(scenarios.file(i)));
    row = struct();
    row.scenario = string(name);
    row.location = string(regexprep(name, '_sb\d+$', ''));
    row.region = scenarios.region(i);
    row.paper_split = scenarios.paper_split(i);
    row.low_confidence = scenarios.low_confidence(i);
    row.trim_offset_m = scenario.meta.trim.offset_m;
    row.anchor_gap_m = interp1(rec.t, rec.s, rec.meta.anchor_t, 'linear', NaN) + rec.s0 - rec.meta.s_bump;
    row.window_s = rec.t(end);
    row.gravity_axis_mps2 = rec.accel_mean(3);
    row.horizontal_mean_mps2 = norm(rec.accel_mean(1:2));
    row.imu_rate_hz = 1 / rec.imu_dt;
    row.imu_start_gap_ms = 1e3 * rec.imu_t(1);
    row.mean_speed_kmh = 3.6 * mean(rec.v);
    row.staged_speed_gap_mps = staged_speed_gap(profiles, name, rec);
    for v = 1:size(variants, 1)
        c = ride.validation.compare(rec, scenario, 'model', model_of(variants{v, 2}), 'P', models.(variants{v, 2}), ...
            'road', variants{v, 3}, 'offset_m', variants{v, 4});
        key = variants{v, 1};
        if v == 1
            row.a_w_measured = c.a_w_measured;
            row.lag_s = c.lag_s;
            row.lag_at_limit = c.lag_at_limit;
            row.correlation = c.correlation;
            row.peak_ratio = c.peak_ratio;
            row.a_w_measured_near = c.a_w_measured_near;
            row.a_w_simulated_near = c.a_w_simulated_near;
            row.a_w_measured_away = c.a_w_measured_away;
            row.a_w_simulated_away = c.a_w_simulated_away;
            main = c;
        end
        row.(['a_w_' key]) = c.a_w_simulated;
        row.(['error_' key]) = c.error;
        if v == 2
            study_trace = c.z_B_ddot;
            row.lag_study_s = c.lag_s;
            row.correlation_study = c.correlation;
        end
    end
    row.study_a_w = NaN;
    row.study_a_w_imu = NaN;
    if ~isempty(study)
        match = study.scenario == string(name) & study.suite == "real_all";
        if any(match)
            row.study_a_w = study.a_w(find(match, 1));
            row.study_a_w_imu = study.a_w_imu(find(match, 1));
        end
    end
    rows{end + 1, 1} = row; %#ok<AGROW>
    series(end + 1) = struct('name', string(name), 't', main.t, 'imu_t', main.imu_t, 'a_z', main.a_z, ...
        'measured_lp', main.measured_lp, 'simulated', main.z_B_ddot, 'simulated_lp', main.simulated_lp, ...
        'simulated_shifted', main.simulated_shifted, 'v', main.v, 'bump_t', main.bump_t, 'study_simulated', study_trace); %#ok<AGROW>
    fprintf('%-26s measured %.3f aligned %.3f (%+5.1f %%) study %+5.1f %% lag %+.2f / %+.2f s offset %.2f  %.1f s\n', name, ...
        row.a_w_measured, row.a_w_aligned, 100 * row.error_aligned, 100 * row.error_study, row.lag_s, row.lag_study_s, ...
        row.trim_offset_m, toc(started));
end
results = struct2table([rows{:}]);
end

function model = model_of(key)
model = regexprep(key, '_nominal$', '');
end

function gap = staged_speed_gap(folder, name, rec)
gap = NaN;
file = fullfile(folder, [name '.json']);
if ~isfile(file)
    return
end
data = jsondecode(fileread(file));
if ~isfield(data.sources, 'human')
    return
end
staged = data.sources.human.v_mps(:);
n = min(numel(staged), numel(rec.v));
gap = max(abs(staged(1:n) - rec.v(1:n)));
end

function summary = summarise(results)
usable = ~results.low_confidence;
sets = {
    'usable, all', usable
    'usable, paper training', usable & results.paper_split == "train"
    'usable, paper held out', usable & results.paper_split == "eval"
    'usable, Germany', usable & results.region == "germany"
    'usable, Italy', usable & results.region == "italy"
    'low confidence', results.low_confidence};
variants = variant_table();
rows = {};
for s = 1:size(sets, 1)
    pick = sets{s, 2};
    if ~any(pick)
        continue
    end
    for v = 1:size(variants, 1)
        e = 100 * results.(['error_' variants{v, 1}])(pick);
        simulated = results.(['a_w_' variants{v, 1}])(pick);
        measured = results.a_w_measured(pick);
        q = quantile_local(e, [0.25 0.5 0.75]);
        r = NaN(2);
        if numel(measured) > 2
            r = corrcoef(measured, simulated);
        end
        rows(end + 1, :) = {string(sets{s, 1}), string(variants{v, 5}), nnz(pick), median(abs(e)), q(2), q(1), q(3), ...
            100 * mean(abs(e) <= 10), 100 * mean(abs(e) <= 20), 100 * mean(abs(e) <= 30), r(1, 2), ...
            spearman(measured, simulated)}; %#ok<AGROW>
    end
end
summary = cell2table(rows, 'VariableNames', {'set', 'variant', 'roads', 'median_abs_error_pct', 'median_error_pct', ...
    'error_q25_pct', 'error_q75_pct', 'within_10_pct', 'within_20_pct', 'within_30_pct', 'pearson', 'spearman'});
end

function r = spearman(a, b)
if numel(a) < 3
    r = NaN;
    return
end
r = corrcoef(rank_of(a), rank_of(b));
r = r(1, 2);
end

function r = rank_of(x)
[~, order] = sort(x);
r = zeros(size(x));
r(order) = 1:numel(x);
end

function q = quantile_local(x, p)
x = sort(x(~isnan(x)));
if numel(x) < 2
    q = NaN(size(p));
    if ~isempty(x)
        q(:) = x(1);
    end
    return
end
q = interp1(linspace(0, 1, numel(x)), x, p);
end

function write_summary_tex(summary, file)
fid = fopen(file, 'w');
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '\\begin{tabular}{llrrrrrr}\n\\hline\n');
fprintf(fid, 'Roads & Variant & $n$ & median $|e|$ & median $e$ & IQR of $e$ & within 30\\%% & Spearman \\\\\n\\hline\n');
for i = 1:height(summary)
    fprintf(fid, '%s & %s & %d & %.1f\\%% & %+.1f\\%% & %+.1f to %+.1f\\%% & %.0f\\%% & %.2f \\\\\n', summary.set(i), ...
        summary.variant(i), summary.roads(i), summary.median_abs_error_pct(i), summary.median_error_pct(i), ...
        summary.error_q25_pct(i), summary.error_q75_pct(i), summary.within_30_pct(i), summary.spearman(i));
end
fprintf(fid, '\\hline\n\\end{tabular}\n');
end
