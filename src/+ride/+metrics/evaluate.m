function result = evaluate(out, P, sc, names)
%EVALUATE Score a simulation.
%   m = ride.metrics.evaluate(out, P, scenario, names) computes the metrics
%   in the cell array names for the simulation signals out of a model with
%   parameters P. The built-ins stop at the end of the scenario's road.
%   Without names: a_w, vdv, peak_acc, travel_time and mean_speed.
%
%   Example
%       r = ride.run();
%       ride.metrics.evaluate(r.out, r.P, r.scenario, {'a_w', 'pitch_rms'})
%
%   See also ride.metrics.list, ride.metrics.register.
if nargin < 4
    names = {'a_w', 'vdv', 'peak_acc', 'travel_time', 'mean_speed'};
end
if nargin < 3
    sc = [];
end
if ischar(names) || isstring(names)
    names = cellstr(names);
end
if ~isstruct(out) || ~all(isfield(out, {'t', 's', 'v', 'z_B_ddot'}))
    error('ride:badSimulation', 'metrics need the simulation signals from ride.simulate (with t, s, v and z_B_ddot)');
end
if ~isstruct(P) || ~isfield(P, 'DT')
    error('ride:badParameters', 'metrics need the model parameters from ride.load (with the time step DT)');
end
map = ride.metrics.registry();
available = ride.metrics.list();
result = struct();
for i = 1:numel(names)
    name = names{i};
    if isKey(map, name)
        fn = map(name);
    elseif any(strcmp(available, name))
        fn = str2func(['ride.metrics.builtin.' name]);
    else
        error('ride:unknownMetric', 'unknown metric "%s", available: %s', name, strjoin(available, ', '));
    end
    result.(name) = fn(out, P, sc);
end
end
