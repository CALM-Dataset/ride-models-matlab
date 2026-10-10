model = 'halfcar';
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src'));
P = ride.load(model);
road = ride.core.terrain.bumps([20 0.06 2.0]);
speeds = 6 * ones(700, 1);
out = ride.simulate(model, P, road, speeds);
[update, fig] = ride.render.frame_figure(P, road, out);
update(find(out.s >= 21, 1));
print(fig, [model '_frame.png'], '-dpng', '-r150');
