function h = hud_create(parent, position)
st = render.scene.style();
ax = axes('Parent', parent, 'Position', position, 'XLim', [0 1], 'YLim', [0 1]);
axis(ax, 'off');
hold(ax, 'on');
rectangle('Parent', ax, 'Position', [0 0 1 1], 'FaceColor', 'w', 'EdgeColor', [0.33 0.33 0.33], 'LineWidth', 0.8);
labels = {'$t\ [\mathrm{s}]$', '$s\ [\mathrm{m}]$', '$v\ [\mathrm{km/h}]$', '$z_B\ [\mathrm{mm}]$', '$\varphi\ [\mathrm{deg}]$'};
n = numel(labels);
h.values = gobjects(n, 1);
for i = 1:n
    x0 = (i - 1) / n;
    if i > 1
        line(ax, [x0 x0], [0.12 0.88], 'Color', [0.73 0.73 0.73], 'LineWidth', 0.7);
    end
    text(ax, x0 + 0.5 / n, 0.74, labels{i}, 'Interpreter', 'latex', 'HorizontalAlignment', 'center', ...
        'FontSize', st.hud_label_size + 1, 'Color', [0.23 0.27 0.31]);
    h.values(i) = text(ax, x0 + 0.5 / n, 0.28, '', 'HorizontalAlignment', 'center', ...
        'FontName', st.font, 'FontSize', st.size + 1, 'Color', [0.07 0.07 0.07]);
end
h.axes = ax;
end
