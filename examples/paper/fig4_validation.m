run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'setup.m'));
cases = {'quartercar', 'speed_ramp_over_bump'; 'halfcar', 'braking_then_accelerating_over_bump'};
colors = model_colors();
fig = paper_figure(17, 9);
layout = tiledlayout(fig, 2, size(cases, 1), 'TileSpacing', 'compact', 'Padding', 'compact');
for c = 1:size(cases, 1)
    model = cases{c, 1};
    ref = jsondecode(fileread(fullfile(ride.root(), 'data', 'models', model, 'reference', [cases{c, 2} '.json'])));
    P = ride.load(model);
    out = ride.simulate(model, P, ride.core.terrain.bumps(ref.road.bumps), ref.drive.speed_mps(:));
    expected = ref.expected.body.heave_acc_mps2(:);
    ax = nexttile(layout, c);
    hold(ax, 'on');
    plot(ax, out.t, expected, 'o', 'MarkerSize', 2.5, 'Color', [0.55 0.55 0.55], 'DisplayName', 'reference (Python)');
    plot(ax, out.t, out.z_B_ddot, '-', 'Color', colors.(model), 'DisplayName', 'ride.simulate (MATLAB)');
    title(ax, sprintf('%s, %s', ride.models.get(model).title, strrep(cases{c, 2}, '_', ' ')), 'FontWeight', 'normal');
    ylabel(ax, 'z_B'''' [m/s^2]');
    legend(ax, 'Location', 'northeast', 'Box', 'off');
    ax = nexttile(layout, c + size(cases, 1));
    semilogy(ax, out.t, max(abs(out.z_B_ddot - expected), eps) / max(abs(expected)), '-', 'Color', colors.(model));
    ylim(ax, [1e-18 1e-12]);
    xlabel(ax, 't [s]');
    ylabel(ax, '|error| / max|z_B''''|');
end
save_figure(fig, 'fig4_validation', 'reference runs in data/models/*/reference | quarter-car: speed_ramp_over_bump | half-car: braking_then_accelerating_over_bump');
