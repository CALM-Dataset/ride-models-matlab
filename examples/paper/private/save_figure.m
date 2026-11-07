function save_figure(fig, name, label)
folder = fullfile(ride.root(), 'figures');
if paper_style()
    folder = fullfile(folder, 'paper');
else
    footer = 0.08;
    layout = findobj(fig, 'Type', 'tiledlayout');
    if ~isempty(layout)
        layout(1).OuterPosition = [0 footer 1 1 - footer];
    end
    annotation(fig, 'textbox', [0.01 0 0.98 footer], 'String', sprintf('ride-models %s | %s', ride.version(), label), ...
        'EdgeColor', 'none', 'FontName', figure_font(), 'FontSize', 6.5, 'Color', [0.4 0.4 0.4], ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'Interpreter', 'none', 'FitBoxToText', 'off');
end
if ~isfolder(folder)
    mkdir(folder);
end
for ax = findobj(fig, 'Type', 'axes')'
    ax.Toolbar = [];
end
exportgraphics(fig, fullfile(folder, [name '.pdf']), 'ContentType', 'vector', 'BackgroundColor', 'white');
exportgraphics(fig, fullfile(folder, [name '.png']), 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('wrote %s.pdf and .png in %s\n', name, folder);
end
