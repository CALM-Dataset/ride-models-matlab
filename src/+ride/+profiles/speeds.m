function v = speeds(profile, dt, n, sc)
%SPEEDS The speed at every step of a drive.
%   v = ride.profiles.speeds(profile, dt, n, scenario) returns n speeds in
%   m/s, one every dt seconds. profile is a struct with a type and the
%   parameters of that type, for example
%       struct('type', 'constant', 'speed_mps', 8)
%   The scenario is needed by types that read the road or its suggested
%   speed ("speed_mps": "scenario").
%
%   ride.profiles.list() shows the types. See the Speed profiles and metrics page of the wiki.
%
%   See also ride.profiles.register, ride.run.
if nargin < 4
    sc = [];
end
if ~isstruct(profile) || ~isfield(profile, 'type')
    error('ride:badProfile', 'a speed profile is a struct with a "type" field, for example struct(''type'', ''constant'', ''speed_mps'', 8)');
end
if ~(isnumeric(dt) && isscalar(dt) && dt > 0)
    error('ride:badProfile', 'the step dt must be a positive number of seconds');
end
if ~(isnumeric(n) && isscalar(n) && n >= 1 && n == round(n))
    error('ride:badProfile', 'the number of steps n must be a positive whole number');
end
type = char(profile.type);
map = ride.profiles.registry();
if isKey(map, type)
    fn = map(type);
else
    available = ride.profiles.list();
    if ~any(strcmp(available, type))
        error('ride:unknownProfile', 'unknown speed profile "%s", available: %s', type, strjoin(available, ', '));
    end
    fn = str2func(['ride.profiles.builtin.' type]);
end
try
    v = fn(profile, dt, n, sc);
catch err
    if isempty(sc) && strcmp(err.identifier, 'MATLAB:structRefFromNonStruct')
        error('ride:badProfile', 'the "%s" profile needs a scenario: pass it as the fourth argument', type);
    end
    if strcmp(err.identifier, 'MATLAB:nonExistentField')
        field = regexp(err.message, '"([^"]+)"', 'tokens', 'once');
        if isempty(field)
            field = {'?'};
        end
        error('ride:badProfile', 'the "%s" profile needs the field "%s"', type, field{1});
    end
    rethrow(err);
end
v = v(:);
if numel(v) ~= n || any(~isfinite(v)) || any(v < 0)
    error('ride:badProfile', 'the "%s" profile must give %d finite, non-negative speeds', type, n);
end
end
