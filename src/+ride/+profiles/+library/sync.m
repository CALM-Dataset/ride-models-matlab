function files = sync(names, varargin)
%SYNC Download the comfort speed profiles of measured roads from Hugging Face into the cache.
%   ride.profiles.library.sync('stuttgart_sb01') or 'all' downloads the PPO and MPC speed
%   profiles, sequences/<area>/<road>/comfort_profiles/ppo.json and mpc.json of CALM-Germany
%   and CALM-Italy. Only the roads whose bump is not low confidence have them. Needs HF_TOKEN.
opts = struct('germany', 'CALM-Dataset/CALM-Germany', 'italy', 'CALM-Dataset/CALM-Italy', 'sources', {{'ppo', 'mpc'}});
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
everything = (ischar(names) || isstring(names)) && strcmp(names, 'all');
if everything
    roads = ride.scenarios.real.sync('all');
else
    names = cellstr(names);
    roads = cellfun(@scenario_file, names, 'UniformOutput', false);
end
wo = ride.scenarios.real.hf_options();
files = {};
for k = 1:numel(roads)
    [folder, name] = fileparts(roads{k});
    [~, country] = fileparts(fileparts(folder));
    road = jsondecode(fileread(roads{k}));
    if isfield(road, 'bumps') && ~isempty(road.bumps) && isfield(road.bumps, 'low_confidence') && road.bumps(1).low_confidence
        if everything
            continue
        end
        error('ride:noRecordedProfile', 'the road "%s" has no comfort profiles because its bump is low confidence', name);
    end
    if ~isfield(opts, country)
        error('ride:noRecordedProfile', 'no dataset with comfort profiles is known for the country "%s"', country);
    end
    area = regexprep(name, '_sb\d+$', '');
    dest_folder = fullfile(ride.profiles.library.cache_dir(), name);
    if ~isfolder(dest_folder)
        mkdir(dest_folder);
    end
    for s = 1:numel(opts.sources)
        dest = fullfile(dest_folder, [opts.sources{s} '.json']);
        if ~isfile(dest)
            path = sprintf('sequences/%s/%s/comfort_profiles/%s.json', area, name, opts.sources{s});
            try
                websave(dest, sprintf('https://huggingface.co/datasets/%s/resolve/main/%s', opts.(country), path), wo);
            catch err
                if isfile(dest)
                    delete(dest);
                end
                ride.scenarios.real.hf_error(err, sprintf('the %s profile of "%s"', opts.sources{s}, name));
            end
        end
        files{end + 1, 1} = dest; %#ok<AGROW>
    end
end
end

function file = scenario_file(name)
[~, name] = fileparts(name);
base = fullfile(ride.scenarios.cache_dir(), 'real');
found = dir(fullfile(base, '*', 'crossings', [name '.json']));
if isempty(found)
    ride.scenarios.real.sync(name);
    found = dir(fullfile(base, '*', 'crossings', [name '.json']));
end
if isempty(found)
    error('ride:unknownScenario', 'real scenario "%s" was not found', name);
end
file = fullfile(found(1).folder, found(1).name);
end
