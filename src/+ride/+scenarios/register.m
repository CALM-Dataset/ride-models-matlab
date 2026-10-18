function register(name, factory)
%REGISTER Add a scenario for this MATLAB session.
%   ride.scenarios.register(name, factory) where factory() returns a
%   scenario, a road struct or a bump list. Use it as 'registered:<name>'.
%
%   See also ride.scenarios.get, ride.scenarios.make.
map = ride.scenarios.registry();
map(name) = factory;
end
