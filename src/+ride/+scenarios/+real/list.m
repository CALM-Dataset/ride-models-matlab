function names = list(filter)
%LIST Measured roads in the local cache, as country/crossings/name.
%   ride.scenarios.real.list('germany') limits the list to one country;
%   ride.scenarios.real.list('eval') to the evaluation roads of split.yaml,
%   ride.scenarios.real.list('exclude') to the roads it leaves out of training and
%   ride.scenarios.real.list('train') to all the others.
%
%   See also ride.scenarios.real.sync.
base = fullfile(ride.scenarios.cache_dir(), 'real');
names = {};
if ~isfolder(base)
    return
end
found = dir(fullfile(base, '*', 'crossings', '*.json'));
evaluation = strings(0, 1);
excluded = strings(0, 1);
if nargin > 0 && any(strcmp(filter, {'eval', 'train', 'exclude'}))
    [evaluation, excluded] = ride.scenarios.real.eval_names();
end
for i = 1:numel(found)
    rel = strrep(fullfile(found(i).folder, found(i).name), [base filesep], '');
    rel = strrep(rel(1:end - 5), filesep, '/');
    road = found(i).name(1:end - 5);
    if nargin == 0
        keep = true;
    elseif strcmp(filter, 'eval')
        keep = ismember(road, evaluation);
    elseif strcmp(filter, 'exclude')
        keep = ismember(road, excluded);
    elseif strcmp(filter, 'train')
        keep = ~ismember(road, evaluation) && ~ismember(road, excluded);
    else
        keep = startsWith(rel, filter);
    end
    if keep
        names{end + 1, 1} = rel; %#ok<AGROW>
    end
end
names = sort(names);
end
