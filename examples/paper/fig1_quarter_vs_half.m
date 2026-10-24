run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'setup.m'));
scenario = 'synthetic:01_single_bump/m';
speeds_kmh = [10 20 30];
models = {'quartercar', 'halfcar'};
colors = model_colors();
fig = paper_figure(17, 6);
layout = tiledlayout(fig, 1, numel(speeds_kmh), 'TileSpacing', 'compact', 'Padding', 'compact');
for i = 1:numel(speeds_kmh)
    ax = nexttile(layout);
    hold(ax, 'on');
    for m = 1:numel(models)
        cfg = ride.config('model', models{m}, 'scenario', scenario, 'drive.profile', 'constant');
        cfg.profiles.constant.speed_mps = speeds_kmh(i) / 3.6;
        r = ride.run(cfg);
        x0 = r.road.bumps(1, 1);
        plot(ax, r.out.s - x0, r.out.z_B_ddot, 'Color', colors.(models{m}), 'DisplayName', ride.models.get(models{m}).title);
    end
    xlim(ax, [-3 12]);
    yl = ylim(ax);
    L = r.road.bumps(1, 3);
    shade = patch(ax, [0 L L 0], yl([1 1 2 2]), [0.9 0.9 0.9], 'EdgeColor', 'none', 'HandleVisibility', 'off');
    ax.Children = [setdiff(ax.Children, shade, 'stable'); shade];
    ylim(ax, yl);
    title(ax, sprintf('%d km/h', speeds_kmh(i)), 'FontWeight', 'normal');
    if i == 1
        ylabel(ax, 'body acceleration z_B'''' [m/s^2]');
        legend(ax, 'Location', 'southeast', 'Box', 'off');
    end
end
xlabel(layout, 'distance of the front axle from the bump start [m]', 'FontName', figure_font(), 'FontSize', 9);
save_figure(fig, 'fig1_quarter_vs_half', sprintf('%s | constant speed %s km/h | quarter-car and half-car', ...
    scenario, strjoin(string(speeds_kmh), ', ')));
