function [update, fig] = frame_figure(P, road, out)
fig = ride.render.scene.light_figure([100 100 1200 900]);
switch out.model
    case 'halfcar'
        labels = {'$t\ [\mathrm{s}]$', '$s\ [\mathrm{m}]$', '$v\ [\mathrm{km/h}]$', '$z_B\ [\mathrm{mm}]$', '$\varphi\ [\mathrm{deg}]$'};
    case 'quartercar'
        labels = {'$t\ [\mathrm{s}]$', '$s\ [\mathrm{m}]$', '$v\ [\mathrm{km/h}]$', '$z_B\ [\mathrm{mm}]$', '$z_W\ [\mathrm{mm}]$'};
    otherwise
        error('render:unknownModel', 'unknown model "%s"', out.model);
end
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
feval(['ride.render.' out.model '.frame'], ax_scene, P, road, out, k);
mm = @(x) sprintf('%+.1f', x * 1000);
switch out.model
    case 'halfcar'
        last = sprintf('%+.2f', out.phi(k) * 180 / pi);
    case 'quartercar'
        last = mm(out.z_W(k));
end
ride.render.scene.hud_update(hud, {sprintf('%.2f', out.t(k)), sprintf('%.1f', out.s(k)), ...
    sprintf('%.1f', out.v(k) * 3.6), mm(out.z_B(k)), last});
set(cursors, 'XData', [out.t(k) out.t(k)]);
drawnow;
end
