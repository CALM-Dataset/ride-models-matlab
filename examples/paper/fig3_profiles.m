run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'setup.m'));
scenarios = {'synthetic:01_single_bump/m', 'synthetic:01_single_bump/sv', 'synthetic:01_single_bump/l', 'synthetic:02_two_bumps/s_c'};
profiles = {'constant', 'dip', 'reactive'};
model = 'halfcar';
colors = model_colors();
a_w = zeros(numel(scenarios), numel(profiles));
trip = zeros(size(a_w));
for j = 1:numel(scenarios)
    for p = 1:numel(profiles)
        r = ride.run(ride.config('model', model, 'scenario', scenarios{j}, 'drive.profile', profiles{p}));
        a_w(j, p) = r.metrics.a_w;
        trip(j, p) = r.metrics.travel_time;
    end
end
labels = regexprep(scenarios, '^.*/', '');
fig = paper_figure(17, 6.5);
layout = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
for panel = 1:2
    ax = nexttile(layout);
    values = a_w;
    name = 'a_w [m/s^2]';
    if panel == 2
        values = trip;
        name = 'trip time [s]';
    end
    b = bar(ax, categorical(labels, labels), values, 'grouped', 'EdgeColor', 'none');
    for p = 1:numel(profiles)
        b(p).FaceColor = colors.(profiles{p});
        b(p).DisplayName = profiles{p};
    end
    ylabel(ax, name);
    set(ax, 'XGrid', 'off', 'TickLabelInterpreter', 'none');
    if panel == 1
        legend(ax, 'Location', 'northoutside', 'Orientation', 'horizontal', 'Box', 'off');
    end
end
cfg = ride.config();
save_figure(fig, 'fig3_profiles', sprintf('half-car | %s | profiles from config/default.json: constant, dip (%.1f m/s deep, slowest %.0f m before the bump), reactive', ...
    strjoin(scenarios, ', '), cfg.profiles.dip.depth_mps, cfg.profiles.dip.lead_m));
for j = 1:numel(scenarios)
    fprintf('%-30s', scenarios{j});
    for p = 1:numel(profiles)
        fprintf('  %s a_w %.3f trip %.2f s', profiles{p}, a_w(j, p), trip(j, p));
    end
    fprintf('\n');
end
