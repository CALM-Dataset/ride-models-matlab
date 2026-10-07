addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
P = halfcar.params.load();
road = halfcar.road.bumps([20 0.06 2.0]);
t = (1:700)' * P.DT;
speeds = 6 - 3 * exp(-((t - 3.5) .^ 2) / 2);
out = halfcar.sim.simulate(P, road, speeds);
render.animate(P, road, out, 'speed', 1);
