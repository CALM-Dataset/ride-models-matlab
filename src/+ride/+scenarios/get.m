function sc = get(spec, varargin)
%GET A road scenario by name, file or struct.
%   sc = ride.scenarios.get('synthetic:m')                 a synthetic road (the prefix is optional)
%   sc = ride.scenarios.get('real:germany/eval/stuttgart_sb01')   a measured road from Hugging Face
%   sc = ride.scenarios.get('file:my_road.json')           a road from a JSON file
%   sc = ride.scenarios.get('registered:washboard')        a road registered with ride.scenarios.register
%   sc = ride.scenarios.get(struct('bumps', ...))          a road from a struct
%   Extra name and value pairs go to the source, for example 'gap_m' for
%   synthetic roads or 'trim' for measured ones.
%
%   sc has the fields name, description, source, road, speed_mps and meta.
%
%   See also ride.scenarios.list, ride.scenarios.make, ride.scenarios.register.
if isstruct(spec)
    sc = from_struct(spec, varargin{:});
    return
end
if ~(ischar(spec) || (isstring(spec) && isscalar(spec)))
    error('ride:badScenario', 'a scenario is a name such as "synthetic:m", a file or a struct');
end
spec = char(spec);
registered = ride.scenarios.registry();
split = strfind(spec, ':');
if isempty(split) || (ispc && split(1) == 2)
    source = '';
    name = spec;
else
    source = spec(1:split(1) - 1);
    name = spec(split(1) + 1:end);
end
switch source
    case 'synthetic'
        sc = ride.scenarios.synthetic.build(name, varargin{:});
    case 'real'
        sc = ride.scenarios.real.load(name, varargin{:});
    case 'file'
        sc = from_file(name, varargin{:});
    case 'registered'
        sc = from_registry(registered, name);
    case ''
        if isKey(registered, spec)
            sc = from_registry(registered, spec);
        elseif isfile(spec)
            sc = ride.scenarios.from_file(spec, varargin{:});
        else
            sc = ride.scenarios.synthetic.build(spec, varargin{:});
        end
    otherwise
        error('ride:unknownSource', 'unknown scenario source "%s", use synthetic, real, file or registered', source);
end
end

function sc = from_struct(spec, varargin)
if isfield(spec, 'road') && isstruct(spec.road) && isfield(spec.road, 'type')
    sc = spec;
elseif isfield(spec, 'road') && isfield(spec.road, 'ds_m')
    sc = ride.scenarios.real.parse(spec, varargin{:});
elseif isfield(spec, 'bumps')
    sc = ride.scenarios.make('custom', ride.core.terrain.bumps(spec.bumps), varargin{:});
else
    error('ride:badScenario', 'a scenario struct needs a road, a measured profile or a list of bumps');
end
end

function sc = from_file(path, varargin)
if ~isfile(path)
    error('ride:unknownScenario', 'scenario file "%s" was not found', path);
end
sc = ride.scenarios.from_file(path, varargin{:});
end

function sc = from_registry(registered, name)
if ~isKey(registered, name)
    names = keys(registered);
    if isempty(names)
        error('ride:unknownScenario', 'no scenario is registered as "%s"; register one with ride.scenarios.register', name);
    end
    error('ride:unknownScenario', 'no scenario is registered as "%s"; registered: %s', name, strjoin(names, ', '));
end
factory = registered(name);
sc = ride.scenarios.get(factory());
end
