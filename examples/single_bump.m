model = 'halfcar';
addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
P = ride.load(model);
road = terrain.bumps([20 0.06 2.0]);
speeds = 6 * ones(700, 1);
out = ride.simulate(model, P, road, speeds);
fprintf('weighted RMS acceleration %.3f m/s^2\n', comfort.a_w(out.z_B_ddot, P.DT));
render.plots.signals(road, out);
