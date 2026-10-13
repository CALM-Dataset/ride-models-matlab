function [update, fig] = frame_figure(P, road, out)
fig = ride.render.scene.light_figure([100 100 1200 900]);
info = ride.models.get(out.model);
labels = info.hud(out);
hud = ride.render.scene.hud_create(fig, [0.06 0.935 0.88 0.04], labels);
ax_scene = axes('Parent', fig, 'Position', [0.06 0.50 0.88 0.42]);
axes_ts = ride.render.plots.signals(road, out, fig, [0.08 0.06 0.86 0.40]);
cursors = gobjects(numel(axes_ts), 1);
for i = 1:numel(axes_ts)
    cursors(i) = line(axes_ts(i), [0 0], get(axes_ts(i), 'YLim'), 'Color', [0.2 0.2 0.2], 'LineWidth', 1, 'HandleVisibility', 'off');
end
update = @(k) refresh(fig, P, road, out, k, ax_scene, hud, cursors);
set(fig, 'SizeChangedFcn', @(~, ~) redraw(fig, P, road, out, ax_scene, hud, cursors));
drawnow;
end

function redraw(fig, P, road, out, ax_scene, hud, cursors)
if isappdata(fig, 'last_frame')
    refresh(fig, P, road, out, getappdata(fig, 'last_frame'), ax_scene, hud, cursors);
end
end

function refresh(fig, P, road, out, k, ax_scene, hud, cursors)
setappdata(fig, 'last_frame', k);
info = ride.models.get(out.model);
info.frame(ax_scene, P, road, out, k);
[~, values] = info.hud(out, k);
ride.render.scene.hud_update(hud, values);
set(cursors, 'XData', [out.t(k) out.t(k)]);
drawnow;
end
