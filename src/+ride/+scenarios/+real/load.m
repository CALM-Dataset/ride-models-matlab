function sc = load(spec, varargin)
if isfile(spec)
    path = spec;
else
    path = fullfile(ride.scenarios.cache_dir(), 'real', [strrep(spec, '/', filesep) '.json']);
    if ~isfile(path)
        ride.scenarios.real.sync(fileparts(spec));
    end
    if ~isfile(path)
        error('ride:unknownScenario', 'real scenario "%s" was not found', spec);
    end
end
sc = ride.scenarios.real.parse(jsondecode(fileread(path)), varargin{:});
if isempty(sc.name)
    sc.name = spec;
end
sc.source = 'real';
end
