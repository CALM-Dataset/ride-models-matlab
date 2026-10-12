function d = cache_dir()
d = getenv('RIDE_CACHE');
if isempty(d)
    d = fullfile(ride.root(), 'data', 'cache', 'scenarios');
end
end
