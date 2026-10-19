run(fullfile(fileparts(mfilename('fullpath')), '..', 'setup.m'));
cfg = ride.config();
r = ride.run(cfg);
[update, fig] = ride.render.frame_figure(r.P, r.road, r.out);
update(ride.render.frame_index(r, cfg.render.frame_at));
drawnow;
folder = fullfile(ride.root(), 'figures');
if ~isfolder(folder)
    mkdir(folder);
end
file = fullfile(folder, [cfg.model '_frame.png']);
exportgraphics(fig, file, 'Resolution', 150);
fprintf('wrote %s\n', file);
