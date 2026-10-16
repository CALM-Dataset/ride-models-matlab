function fig = light_figure(position)
if nargin < 1
    position = [100 100 1200 900];
end
fig = figure('Color', 'w', 'Position', fit_to_screen(position), 'InvertHardcopy', 'off');
try
    theme(fig, 'light');
catch
end
set(fig, 'Color', 'w');
end

function position = fit_to_screen(position)
screen = get(groot, 'ScreenSize');
if screen(3) < 2 || screen(4) < 2
    return
end
room = [screen(3), screen(4) - 80] * 0.92;
scale = min([1, room ./ position(3:4)]);
fig_size = round(position(3:4) * scale);
position = [screen(1) + round((screen(3) - fig_size(1)) / 2), screen(2) + max(round((screen(4) - fig_size(2)) / 2) - 20, 40), fig_size];
end
