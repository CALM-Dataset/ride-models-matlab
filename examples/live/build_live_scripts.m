function build_live_scripts()
here = fileparts(mfilename('fullpath'));
sources = dir(fullfile(here, 'source', '*.m'));
for i = 1:numel(sources)
    [~, name] = fileparts(sources(i).name);
    target = fullfile(here, [name '.mlx']);
    matlab.internal.liveeditor.openAndSave(fullfile(sources(i).folder, sources(i).name), target);
    fprintf('wrote %s\n', target);
end
end
