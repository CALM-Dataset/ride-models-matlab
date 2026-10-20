run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'setup.m'));
scenarios = [ride.scenarios.synthetic.list('01_single_bump'); ride.scenarios.synthetic.list('08_potholes')];
speeds_kmh = 5:2.5:50;
models = {'quartercar', 'halfcar'};
fig = paper_figure(17, 7.5);
layout = tiledlayout(fig, 1, numel(models), 'TileSpacing', 'compact', 'Padding', 'compact');
results = struct();
for m = 1:numel(models)
    ax = nexttile(layout);
    hold(ax, 'on');
    a_w = zeros(numel(scenarios), numel(speeds_kmh));
    for j = 1:numel(scenarios)
        for i = 1:numel(speeds_kmh)
            cfg = ride.config('model', models{m}, 'scenario', ['synthetic:' scenarios{j}], 'drive.profile', 'constant');
            cfg.profiles.constant.speed_mps = speeds_kmh(i) / 3.6;
            r = ride.run(cfg);
            a_w(j, i) = r.metrics.a_w;
        end
        style = '-';
        if contains(scenarios{j}, 'pothole')
            style = '--';
        end
        plot(ax, speeds_kmh, a_w(j, :), style, 'DisplayName', regexprep(scenarios{j}, '^.*/', ''));
    end
    results.(models{m}) = a_w;
    set(ax, 'YScale', 'log');
    title(ax, ride.models.get(models{m}).title, 'FontWeight', 'normal');
    xlabel(ax, 'constant speed [km/h]');
    if m == 1
        ylabel(ax, 'a_w [m/s^2]');
    else
        key = legend(ax, 'Box', 'off', 'Interpreter', 'none');
        key.Layout.Tile = 'east';
    end
end
save_figure(fig, 'fig2_aw_vs_speed', sprintf(['synthetic suites 01_single_bump (s, m, l, c, sv) and 08_potholes | constant speed %g to %g km/h | ', ...
    'a_w over the whole trip, 40 m lead-in included'], speeds_kmh(1), speeds_kmh(end)));
for m = 1:numel(models)
    a_w = results.(models{m});
    for j = 1:numel(scenarios)
        [~, worst] = max(a_w(j, :));
        rising = all(diff(a_w(j, :)) >= 0);
        fprintf('%-10s %-28s a_w %.3f at %4.1f km/h, %.3f at %4.1f km/h; worst at %4.1f km/h%s\n', models{m}, scenarios{j}, ...
            a_w(j, 1), speeds_kmh(1), a_w(j, end), speeds_kmh(end), speeds_kmh(worst), repmat(' (rises with speed throughout)', 1, rising));
    end
end
