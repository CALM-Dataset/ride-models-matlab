function sc = make(name, road, varargin)
%MAKE A scenario from a road.
%   sc = ride.scenarios.make(name, road, 'speed_mps', 8, 'description', '...')
%   where road comes from ride.core.terrain.bumps, .profile or .from_function.
%
%   See also ride.scenarios.register.
sc = struct('name', name, 'description', '', 'source', '', 'speed_mps', 6.0, 'road', road, 'meta', struct());
for i = 1:2:numel(varargin)
    sc.(varargin{i}) = varargin{i + 1};
end
end
