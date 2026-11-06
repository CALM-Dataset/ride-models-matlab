function files = sync(what, varargin)
%SYNC Download measured roads from Hugging Face into the local cache.
%   ride.scenarios.real.sync('all') downloads germany/crossings and italy/crossings,
%   ride.scenarios.real.sync('germany') one country and
%   ride.scenarios.real.sync('stuttgart_sb01') one road. split.yaml, which lists the
%   evaluation roads, comes along. Files already in the cache are kept. The dataset is
%   gated: request access on Hugging Face, then set HF_TOKEN first, setenv('HF_TOKEN', 'hf_...').
%
%   See also ride.scenarios.real.list, ride.scenarios.get.
opts = struct('repo', 'CALM-Dataset/CALM-Scenarios');
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
countries = {'germany', 'italy'};
parts = strsplit(char(what), '/');
name = '';
if strcmp(what, 'all')
    picked = countries;
elseif any(strcmp(parts{1}, countries))
    picked = parts(1);
    if numel(parts) > 1 && ~strcmp(parts{end}, 'crossings')
        name = parts{end};
    end
else
    picked = countries;
    name = parts{end};
end
wo = ride.scenarios.real.hf_options();
base = fullfile(ride.scenarios.cache_dir(), 'real');
fetch(opts.repo, 'split.yaml', fullfile(base, 'split.yaml'), wo, 'the split file "split.yaml"');
files = {};
for f = 1:numel(picked)
    folder = [picked{f} '/crossings'];
    url = sprintf('https://huggingface.co/api/datasets/%s/tree/main/%s', opts.repo, folder);
    try
        listing = webread(url, wo);
    catch err
        ride.scenarios.real.hf_error(err, sprintf('the scenario folder "%s"', folder));
    end
    for k = 1:numel(listing)
        entry = listing(k);
        if ~strcmp(entry.type, 'file') || ~endsWith(entry.path, '.json')
            continue
        end
        [~, road] = fileparts(entry.path);
        if ~isempty(name) && ~strcmp(road, name)
            continue
        end
        dest = fullfile(base, strrep(entry.path, '/', filesep));
        fetch(opts.repo, entry.path, dest, wo, sprintf('the scenario file "%s"', entry.path));
        files{end + 1, 1} = dest; %#ok<AGROW>
    end
end
end

function fetch(repo, path, dest, wo, what)
if isfile(dest)
    return
end
if ~isfolder(fileparts(dest))
    mkdir(fileparts(dest));
end
try
    websave(dest, sprintf('https://huggingface.co/datasets/%s/resolve/main/%s', repo, path), wo);
catch err
    if isfile(dest)
        delete(dest);
    end
    ride.scenarios.real.hf_error(err, what);
end
end
