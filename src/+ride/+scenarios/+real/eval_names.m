function [names, excluded] = eval_names(file)
%EVAL_NAMES The evaluation roads and the excluded roads listed in a split.yaml file.
%   [names, excluded] = ride.scenarios.real.eval_names() reads split.yaml of the local cache:
%   names are the roads under eval:, excluded the roads under exclude:, which are left out of
%   training. Every other measured road is a training road.
if nargin == 0
    file = fullfile(ride.scenarios.cache_dir(), 'real', 'split.yaml');
end
names = strings(0, 1);
excluded = strings(0, 1);
if ~isfile(file)
    return
end
lines = splitlines(fileread(file));
names = section(lines, 'eval:');
excluded = section(lines, 'exclude:');
end

function names = section(lines, key)
names = strings(0, 1);
start = find(strcmp(deblank(lines), key), 1);
if isempty(start)
    return
end
for k = start + 1:numel(lines)
    item = regexp(lines{k}, '^\s*-\s*(\S+)\s*$', 'tokens', 'once');
    if isempty(item)
        break
    end
    names(end + 1, 1) = string(item{1}); %#ok<AGROW>
end
end
