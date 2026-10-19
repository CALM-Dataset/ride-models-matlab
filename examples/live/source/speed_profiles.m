%% Speed profiles: how the car is driven
% A speed profile gives the speed at every 20 ms step. The same road driven
% with different profiles gives different comfort and trip times.
assert(~isempty(which('ride.run')), 'Run setup in the repository folder first (not needed with the toolbox installed).');
%% The built-in types
disp(ride.profiles.list())
%% Compare three drivers on one road
cfg = ride.config('model', 'halfcar', 'scenario', 'synthetic:m_sv');
figure; hold on; grid on
for name = {'constant', 'dip', 'reactive'}
    cfg.drive.profile = name{1};
    r = ride.run(cfg);
    plot(r.out.s, 3.6 * r.out.v, 'DisplayName', sprintf('%s, a_w = %.2f m/s^2', name{1}, r.metrics.a_w));
end
xlabel('s [m]'); ylabel('v [km/h]'); legend('Location', 'southwest')
%% A profile of your own
% Any function of time works, from code:
p = struct('type', 'handle', 'fn', @(t) 8 - 3 * (t > 4 & t < 7));
v = ride.profiles.speeds(p, 0.02, 600, ride.scenarios.get('synthetic:m'));
%% 
% A type you can name in the config is registered once:
%
%   ride.profiles.register('my_type', @(profile, dt, n, scenario) ...)
%
% See |examples/extend/add_speed_profile.m| for a full example.
