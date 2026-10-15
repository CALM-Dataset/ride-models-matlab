function data = load(name)
path = fullfile(ride.profiles.library.cache_dir(), [name '.json']);
if ~isfile(path)
    ride.profiles.library.sync(name);
end
data = jsondecode(fileread(path));
end
