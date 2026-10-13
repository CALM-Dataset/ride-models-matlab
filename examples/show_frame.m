run(fullfile(fileparts(mfilename('fullpath')), '..', 'setup.m'));
cfg = ride.config();
r = ride.run(cfg);
[update, fig] = ride.render.frame_figure(r.P, r.road, r.out);
update(ride.render.frame_index(r, cfg.render.frame_at));
drawnow;
print(fig, [cfg.model '_frame.png'], '-dpng', '-r150');
