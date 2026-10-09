model = 'halfcar';
addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
P = ride.load(model);
road = terrain.bumps([20 0.06 2.0]);
t = (1:700)' * P.DT;
speeds = 6 - 3 * exp(-((t - 3.5) .^ 2) / 2);
out = ride.simulate(model, P, road, speeds);
render.animate(P, road, out, 'speed', 1);
