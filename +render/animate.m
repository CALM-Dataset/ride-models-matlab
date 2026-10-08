function animate(P, road, out, varargin)
opts = struct('speed', 1, 'video', '', 'fps', 30);
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
fig = figure('Color', 'w', 'Position', [100 100 1200 900]);
hud = render.scene.hud_create(fig, [0.06 0.935 0.88 0.04]);
ax_scene = axes('Parent', fig, 'Position', [0.06 0.50 0.88 0.42]);
axes_ts = render.plots.signals(road, out, fig, [0.08 0.06 0.86 0.40]);
cursors = gobjects(numel(axes_ts), 1);
for i = 1:numel(axes_ts)
    yl = get(axes_ts(i), 'YLim');
    cursors(i) = line(axes_ts(i), [0 0], yl, 'Color', [0.2 0.2 0.2], 'LineWidth', 1, 'HandleVisibility', 'off');
end
frame_step = max(1, round(opts.speed / opts.fps / P.DT));
frames = 1:frame_step:numel(out.t);
writer = [];
if ~isempty(opts.video)
    writer = VideoWriter(opts.video, 'MPEG-4');
    writer.FrameRate = opts.fps;
    open(writer);
end
for k = frames
    render.scene.draw_frame(ax_scene, P, road, out, k);
    render.scene.hud_update(hud, out.t(k), out.s(k), out.v(k), out.z_B(k), out.phi(k));
    set(cursors, 'XData', [out.t(k) out.t(k)]);
    drawnow;
    if ~isempty(writer)
        writeVideo(writer, getframe(fig));
    end
end
if ~isempty(writer)
    close(writer);
end
end
