function sc = from_file(path, varargin)
%FROM_FILE A scenario from a JSON file with a bump list or a measured profile.
%   See the Scenarios page of the wiki for the two layouts.
d = jsondecode(fileread(path));
if isfield(d, 'road') && isfield(d.road, 'ds_m')
    sc = ride.scenarios.real.parse(d, varargin{:});
elseif isfield(d, 'bumps')
    sc = ride.scenarios.make('custom', ride.core.terrain.bumps(d.bumps));
else
    error('ride:badScenario', '"%s" needs a "road" profile or a list of "bumps"', path);
end
[~, base] = fileparts(path);
if isfield(d, 'name') && ~isempty(d.name)
    sc.name = d.name;
elseif isempty(sc.name) || strcmp(sc.name, 'custom')
    sc.name = base;
end
if isfield(d, 'description')
    sc.description = d.description;
end
if isfield(d, 'speed_mps')
    sc.speed_mps = d.speed_mps;
end
end
