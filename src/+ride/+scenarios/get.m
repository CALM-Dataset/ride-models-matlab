function sc = get(spec, varargin)
if isstruct(spec)
    if isfield(spec, 'road') && isstruct(spec.road) && isfield(spec.road, 'type')
        sc = spec;
    elseif isfield(spec, 'road') && isfield(spec.road, 'ds_m')
        sc = ride.scenarios.real.parse(spec, varargin{:});
    elseif isfield(spec, 'bumps')
        sc = ride.scenarios.make('custom', ride.core.terrain.bumps(spec.bumps), varargin{:});
    else
        error('ride:badScenario', 'a scenario struct needs a road, a measured profile or a list of bumps');
    end
    return
end
spec = char(spec);
registered = ride.scenarios.registry();
split = strfind(spec, ':');
if isempty(split)
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
        sc = ride.scenarios.from_file(name, varargin{:});
    case 'registered'
        factory = registered(name);
        sc = ride.scenarios.get(factory());
    otherwise
        if isKey(registered, spec)
            factory = registered(spec);
            sc = ride.scenarios.get(factory());
        elseif isfile(spec)
            sc = ride.scenarios.from_file(spec, varargin{:});
        else
            sc = ride.scenarios.synthetic.build(spec, varargin{:});
        end
end
end
