function register(type, fn)
%REGISTER Add a speed profile type for this MATLAB session.
%   ride.profiles.register(type, fn) where v = fn(profile, dt, n, scenario)
%   returns n speeds in m/s.
%
%   See also ride.profiles.speeds.
map = ride.profiles.registry();
map(type) = fn;
end
