function road = from_function(height_fn, length_m, ds, bumps)
if nargin < 4
    bumps = zeros(0, 3);
end
s = (0:ds:length_m)';
road = ride.core.terrain.profile(height_fn(s), ds, bumps);
end
