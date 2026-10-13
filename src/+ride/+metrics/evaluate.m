function result = evaluate(out, P, sc, names)
if nargin < 4
    names = {'a_w', 'vdv', 'peak_acc', 'travel_time', 'mean_speed'};
end
if ischar(names)
    names = {names};
end
map = ride.metrics.registry();
available = ride.metrics.list();
result = struct();
for i = 1:numel(names)
    name = names{i};
    if isKey(map, name)
        fn = map(name);
    elseif any(strcmp(available, name))
        fn = str2func(['ride.metrics.builtin.' name]);
    else
        error('ride:unknownMetric', 'unknown metric "%s", available: %s', name, strjoin(available, ', '));
    end
    result.(name) = fn(out, P, sc);
end
end
