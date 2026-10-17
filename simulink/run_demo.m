function out = run_demo(vehicle, varargin)
if nargin < 1
    vehicle = 'halfcar';
end
here = fileparts(mfilename('fullpath'));
addpath(here);
addpath(fullfile(here, '..', 'src'));
r = ride.run(ride.config('model', vehicle, varargin{:}));
assignin('base', 'ride_road', r.road);
assignin('base', 'ride_speeds', r.speeds);
assignin('base', 'ride_dt', r.P.DT);
assignin('base', 'ride_dt_sim', r.P.DT_SIM);
mdl = ['ride_demo_' vehicle];
if ~isfile(fullfile(here, [mdl '.slx']))
    build_demo(vehicle);
end
open_system(fullfile(here, [mdl '.slx']));
out = sim(mdl);
heave = out.get('z_B_ddot');
n = numel(r.out.t);
fprintf('%s on %s: largest difference to ride.simulate in z_B_ddot %.2e m/s^2\n', vehicle, r.scenario.name, ...
    max(abs(heave(2:n + 1) - r.out.z_B_ddot)));
end
