function animate(P, road, out, varargin)
opts = struct('speed', 1, 'video', '', 'fps', 30);
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
[update, fig] = render.frame_figure(P, road, out);
frame_step = max(1, round(opts.speed / opts.fps / P.DT));
writer = [];
if ~isempty(opts.video)
    writer = VideoWriter(opts.video, 'MPEG-4');
    writer.FrameRate = opts.fps;
    open(writer);
end
for k = 1:frame_step:numel(out.t)
    update(k);
    if ~isempty(writer)
        writeVideo(writer, getframe(fig));
    end
end
if ~isempty(writer)
    close(writer);
end
end
