function data = load(name)
folder = fullfile(ride.profiles.library.cache_dir(), name);
if isempty(dir(fullfile(folder, '*.json')))
    ride.profiles.library.sync(name);
end
found = dir(fullfile(folder, '*.json'));
data = struct('name', name, 'dt_s', [], 'sources', struct());
for k = 1:numel(found)
    part = ride.profiles.library.read(fullfile(folder, found(k).name));
    for source = fieldnames(part.sources)'
        data.sources.(source{1}) = part.sources.(source{1});
    end
    if isempty(data.dt_s)
        data.dt_s = part.dt_s;
    end
end
end
