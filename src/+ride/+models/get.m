function info = get(name)
map = ride.models.registry();
if isKey(map, name)
    factory = map(name);
    info = factory();
    return
end
try
    info = feval(['ride.models.' name '.info']);
catch
    error('ride:unknownModel', 'unknown model "%s", available: %s', name, strjoin(ride.models.list(), ', '));
end
end
