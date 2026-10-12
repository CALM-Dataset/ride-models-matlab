function files = sync(folder, varargin)
opts = struct('repo', 'CALM-Dataset/CALM-Scenarios');
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
if strcmp(folder, 'all')
    folders = {'germany/train', 'germany/eval', 'italy/train', 'italy/eval'};
else
    folders = {folder};
end
files = {};
wo = ride.scenarios.real.hf_options();
for f = 1:numel(folders)
    url = sprintf('https://huggingface.co/api/datasets/%s/tree/main/%s', opts.repo, folders{f});
    try
        listing = webread(url, wo);
    catch err
        error('ride:hfAccess', ['could not list %s on Hugging Face (%s). If the dataset is private, set the ', ...
            'HF_TOKEN environment variable to an access token.'], folders{f}, err.message);
    end
    for k = 1:numel(listing)
        entry = listing(k);
        if ~strcmp(entry.type, 'file') || ~endsWith(entry.path, '.json')
            continue
        end
        dest = fullfile(ride.scenarios.cache_dir(), 'real', strrep(entry.path, '/', filesep));
        if ~isfolder(fileparts(dest))
            mkdir(fileparts(dest));
        end
        if ~isfile(dest)
            websave(dest, sprintf('https://huggingface.co/datasets/%s/resolve/main/%s', opts.repo, entry.path), wo);
        end
        files{end + 1, 1} = dest; %#ok<AGROW>
    end
end
end
