addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
P = halfcar.params.load();
road = halfcar.road.bumps([20 0.06 2.0]);
speeds = 6 * ones(700, 1);
out = halfcar.sim.simulate(P, road, speeds);
fprintf('weighted RMS acceleration %.3f m/s^2\n', halfcar.comfort.a_w(out.z_B_ddot, P.DT));
render.plots.signals(road, out);
