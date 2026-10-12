function road = profile(z, ds, bumps)
if nargin < 3
    bumps = zeros(0, 3);
end
z = z(:);
if isstruct(bumps)
    bumps = ride.core.terrain.bumps(bumps).bumps;
end
dz = zeros(size(z));
if numel(z) > 1
    dz = gradient(z, ds);
end
road = struct('type', 'profile', 'ds', ds, 'z', z, 'dz', dz, 'bumps', bumps);
end
