run(fullfile(fileparts(mfilename('fullpath')), '..', 'setup.m'));
cfg = ride.config();
r = ride.scenario.run(cfg);
[update, fig] = ride.render.frame_figure(r.P, r.road, r.out);
update(find(r.out.t >= cfg.render.frame_at_s, 1));
drawnow;
print(fig, [cfg.model '_frame.png'], '-dpng', '-r150');
