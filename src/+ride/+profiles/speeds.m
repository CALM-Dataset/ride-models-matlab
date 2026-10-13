function v = speeds(profile, dt, n, sc)
if nargin < 4
    sc = [];
end
map = ride.profiles.registry();
if isKey(map, profile.type)
    fn = map(profile.type);
else
    if ~any(strcmp(ride.profiles.list(), profile.type))
        error('ride:unknownProfile', 'unknown speed profile "%s", available: %s', profile.type, strjoin(ride.profiles.list(), ', '));
    end
    fn = str2func(['ride.profiles.builtin.' profile.type]);
end
v = fn(profile, dt, n, sc);
v = v(:);
end
