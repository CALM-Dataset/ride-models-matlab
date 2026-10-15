function names = list()
found = dir(fullfile(ride.profiles.library.cache_dir(), '*.json'));
names = cellfun(@(f) f(1:end - 5), {found.name}, 'UniformOutput', false)';
end
