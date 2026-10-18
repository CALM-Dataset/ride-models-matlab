function animate(P, road, out, varargin)
%ANIMATE Play a simulation as an animated scene with charts.
%   ride.render.animate(P, road, out) plays it in real time.
%   Options: 'speed' (playback rate, 1 is real time), 'fps', and 'video' (an
%   .mp4 file name to record to).
%
%   Example
%       r = ride.run();
%       ride.render.animate(r.P, r.road, r.out, 'speed', 0.5)
opts = struct('speed', 1, 'video', '', 'fps', 30);
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
[update, fig] = ride.render.frame_figure(P, road, out);
frame_step = max(1, round(opts.speed / opts.fps / P.DT));
writer = [];
if ~isempty(opts.video)
    writer = VideoWriter(opts.video, 'MPEG-4');
    writer.FrameRate = opts.fps;
    open(writer);
end
started = tic;
n = numel(out.t);
k = 1;
drawn = 0;
while k <= n && isvalid(fig)
    update(k);
    drawn = k;
    if ~isempty(writer)
        writeVideo(writer, getframe(fig));
        k = k + frame_step;
        continue
    end
    lag = (out.t(k) - out.t(1)) / opts.speed - toc(started);
    if lag > 0
        pause(lag);
    end
    on_time = find(out.t - out.t(1) >= toc(started) * opts.speed, 1);
    if isempty(on_time)
        on_time = n + 1;
    end
    k = max(k + frame_step, on_time);
end
if drawn < n && isvalid(fig)
    update(n);
end
if ~isempty(writer)
    close(writer);
end
end
