function files = sync(folder, varargin)
%SYNC Download measured roads from Hugging Face into the local cache.
%   ride.scenarios.real.sync('germany/eval') downloads one folder;
%   'all' downloads germany/train, germany/eval, italy/train and italy/eval.
%   Files already in the cache are kept. The dataset is gated: request access
%   on Hugging Face, then set HF_TOKEN first, setenv('HF_TOKEN', 'hf_...').
%
%   See also ride.scenarios.real.list, ride.scenarios.get.
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
        ride.scenarios.real.hf_error(err, sprintf('the scenario folder "%s"', folders{f}));
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
            try
                websave(dest, sprintf('https://huggingface.co/datasets/%s/resolve/main/%s', opts.repo, entry.path), wo);
            catch err
                ride.scenarios.real.hf_error(err, sprintf('the scenario file "%s"', entry.path));
            end
        end
        files{end + 1, 1} = dest; %#ok<AGROW>
    end
end
end
