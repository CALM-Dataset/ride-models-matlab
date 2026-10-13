run(fullfile(fileparts(mfilename('fullpath')), '..', 'setup.m'));
cfg = ride.config();
r = ride.run(cfg);
disp(r.metrics)
ride.render.plots.signals(r.road, r.out);
