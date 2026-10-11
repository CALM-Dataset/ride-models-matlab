run(fullfile(fileparts(mfilename('fullpath')), '..', 'setup.m'));
cfg = ride.config();
r = ride.scenario.run(cfg);
fprintf('%s weighted RMS acceleration %.3f m/s^2\n', cfg.model, ride.core.comfort.a_w(r.out.z_B_ddot, r.P.DT));
ride.render.plots.signals(r.road, r.out);
