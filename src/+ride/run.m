function r = run(cfg)
%RUN Simulate one drive and score it.
%   r = ride.run() uses the settings in config/default.json.
%   r = ride.run(cfg) uses the settings from ride.config.
%
%   r holds the model name and parameters (r.model, r.P), the scenario and
%   its road (r.scenario, r.road), the speed at every step (r.speeds), the
%   simulation signals (r.out) and the metrics (r.metrics).
%
%   Example
%       r = ride.run(ride.config('model', 'quartercar'));
%       disp(r.metrics)
%       ride.render.animate(r.P, r.road, r.out)
%
%   See also ride.config, ride.simulate, ride.metrics.evaluate.
if nargin < 1
    cfg = ride.config();
end
check_config(cfg);
r.cfg = cfg;
r.model = char(cfg.model);
r.P = ride.load(r.model);
r.scenario = ride.scenarios.get(cfg.scenario);
r.road = r.scenario.road;
profile = pick_profile(cfg);
dt = r.P.DT;
duration = cfg.drive.duration_s;
if ischar(duration) || isstring(duration)
    r.speeds = until_road_end(profile, dt, r.P, r.scenario);
else
    r.speeds = ride.profiles.speeds(profile, dt, round(duration / dt), r.scenario);
end
r.out = ride.simulate(r.model, r.P, r.road, r.speeds);
metrics = {'a_w', 'vdv', 'peak_acc', 'travel_time', 'mean_speed'};
if isfield(cfg, 'metrics')
    metrics = cfg.metrics;
end
r.metrics = ride.metrics.evaluate(r.out, r.P, r.scenario, metrics);
end

function speeds = until_road_end(profile, dt, P, scenario)
wheelbase = 0;
if isfield(P, 'L')
    wheelbase = P.L;
end
stop = ride.core.terrain.end_point(scenario.road, wheelbase);
all_speeds = ride.profiles.speeds(profile, dt, round(600 / dt), scenario);
k = find(cumsum(all_speeds) * dt >= stop + 5, 1);
if isempty(k)
    k = numel(all_speeds);
end
speeds = all_speeds(1:k);
end

function profile = pick_profile(cfg)
profile = cfg.drive.profile;
if isstruct(profile)
    return
end
name = char(profile);
available = {};
if isfield(cfg, 'profiles')
    available = fieldnames(cfg.profiles);
end
if ~any(strcmp(available, name))
    error('ride:unknownProfile', 'drive.profile is "%s", but the config defines only these profiles: %s', ...
        name, strjoin(available, ', '));
end
profile = cfg.profiles.(name);
end

function check_config(cfg)
if ~isstruct(cfg)
    error('ride:badConfig', 'ride.run takes the settings struct from ride.config');
end
for field = {'model', 'scenario', 'drive'}
    if ~isfield(cfg, field{1})
        error('ride:badConfig', 'the config has no "%s" setting', field{1});
    end
end
for field = {'profile', 'duration_s'}
    if ~isfield(cfg.drive, field{1})
        error('ride:badConfig', 'the config has no "drive.%s" setting', field{1});
    end
end
duration = cfg.drive.duration_s;
is_auto = (ischar(duration) || isstring(duration)) && strcmpi(duration, 'auto');
if ~is_auto && ~(isnumeric(duration) && isscalar(duration) && duration > 0)
    error('ride:badConfig', 'drive.duration_s must be "auto" or a positive number of seconds');
end
end
