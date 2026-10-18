function files = sync(names, varargin)
%SYNC Download recorded speed profiles from Hugging Face into the cache.
%   ride.profiles.library.sync('stuttgart_sb01') or 'all'. Needs HF_TOKEN.
opts = struct('repo', 'CALM-Dataset/CALM-Scenarios');
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
wo = ride.scenarios.real.hf_options();
if ischar(names) && strcmp(names, 'all')
    url = sprintf('https://huggingface.co/api/datasets/%s/tree/main/profiles', opts.repo);
    try
        listing = webread(url, wo);
    catch err
        ride.scenarios.real.hf_error(err, 'the recorded profile folder');
    end
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
            ride.scenarios.real.hf_error(err, sprintf('the recorded profile of "%s"', names{k}));
        end
    end
    files{k} = dest;
end
end
