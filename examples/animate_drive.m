run(fullfile(fileparts(mfilename('fullpath')), '..', 'setup.m'));
cfg = ride.config();
r = ride.scenario.run(cfg);
ride.render.animate(r.P, r.road, r.out, 'speed', cfg.render.speed, 'fps', cfg.render.fps, 'video', cfg.render.video);
