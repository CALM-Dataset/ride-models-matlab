function sc = load(spec, varargin)
if isfile(spec)
    path = spec;
else
    path = cached(spec);
    if isempty(path)
        ride.scenarios.real.sync(spec);
        path = cached(spec);
    end
    if isempty(path)
        error('ride:unknownScenario', 'real scenario "%s" was not found', spec);
    end
end
sc = ride.scenarios.real.parse(jsondecode(fileread(path)), varargin{:});
if isempty(sc.name)
    sc.name = spec;
end
sc.source = 'real';
end

function path = cached(spec)
base = fullfile(ride.scenarios.cache_dir(), 'real');
path = fullfile(base, [strrep(spec, '/', filesep) '.json']);
if contains(spec, '/') && isfile(path)
    return
end
path = '';
[~, road] = fileparts(spec);
found = dir(fullfile(base, '*', 'crossings', [road '.json']));
if ~isempty(found)
    path = fullfile(found(1).folder, found(1).name);
end
end
