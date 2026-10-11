function fig = light_figure(position)
if nargin < 1
    position = [100 100 1200 900];
end
fig = figure('Color', 'w', 'Position', position, 'InvertHardcopy', 'off');
try
    theme(fig, 'light');
catch
end
set(fig, 'Color', 'w');
end
