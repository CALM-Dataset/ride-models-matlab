function info = get(name)
%GET The info struct of a model: name, title and handles to its parts.
%   See also ride.models.list, the Adding a model page of the wiki.
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
