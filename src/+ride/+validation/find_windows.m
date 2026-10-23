function map = find_windows(roots)
%FIND_WINDOWS Recorded windows under one or more sequences folders.
%   map = ride.validation.find_windows({'/path/CALM-ITALY/sequences', ...}) returns a
%   containers.Map from scenario name (for example 'nardo_sb01') to its window folder,
%   for the layout <root>/<location>/<scenario>/meta.yaml.
if ischar(roots) || isstring(roots)
    roots = cellstr(roots);
end
map = containers.Map('KeyType', 'char', 'ValueType', 'char');
for r = 1:numel(roots)
    if ~isfolder(roots{r})
        error('ride:validation:noFolder', 'recordings folder "%s" was not found', roots{r});
    end
    locations = dir(roots{r});
    locations = locations([locations.isdir] & ~startsWith({locations.name}, '.'));
    for l = 1:numel(locations)
        windows = dir(fullfile(roots{r}, locations(l).name));
        windows = windows([windows.isdir] & ~startsWith({windows.name}, '.'));
        for w = 1:numel(windows)
            folder = fullfile(roots{r}, locations(l).name, windows(w).name);
            if isfile(fullfile(folder, 'meta.yaml'))
                map(windows(w).name) = folder;
            end
        end
    end
end
end
