function road = from_function(height_fn, length_m, ds, bumps)
%FROM_FUNCTION A road from a height function of distance.
%   road = ride.core.terrain.from_function(@(s) 0.03 * sin(2 * pi * s / 5), 60, 0.02)
%   samples the function every ds metres over length_m.
if nargin < 4
    bumps = zeros(0, 3);
end
s = (0:ds:length_m)';
road = ride.core.terrain.profile(height_fn(s), ds, bumps);
end
