function files = sync(names, varargin)
opts = struct('repo', 'CALM-Dataset/CALM-Scenarios');
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
wo = ride.scenarios.real.hf_options();
if ischar(names) && strcmp(names, 'all')
    url = sprintf('https://huggingface.co/api/datasets/%s/tree/main/profiles', opts.repo);
    listing = webread(url, wo);
    names = {};
    for k = 1:numel(listing)
        if strcmp(listing(k).type, 'file') && endsWith(listing(k).path, '.json')
            [~, base] = fileparts(listing(k).path);
            names{end + 1} = base; %#ok<AGROW>
        end
    end
elseif ischar(names)
    names = {names};
end
if ~isfolder(ride.profiles.library.cache_dir())
    mkdir(ride.profiles.library.cache_dir());
end
files = cell(numel(names), 1);
for k = 1:numel(names)
    dest = fullfile(ride.profiles.library.cache_dir(), [names{k} '.json']);
    if ~isfile(dest)
        try
            websave(dest, sprintf('https://huggingface.co/datasets/%s/resolve/main/profiles/%s.json', opts.repo, names{k}), wo);
        catch err
            error('ride:noRecordedProfile', ['no recorded speed profile for "%s" (%s). Recorded profiles exist ', ...
                'for the real scenarios only; for a private dataset set HF_TOKEN.'], names{k}, err.message);
        end
    end
    files{k} = dest;
end
end
