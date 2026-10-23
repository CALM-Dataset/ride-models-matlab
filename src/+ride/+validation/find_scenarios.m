function list = find_scenarios(folder)
%FIND_SCENARIOS Scenario files of a CALM-Scenarios folder with their region, split and confidence.
%   list = ride.validation.find_scenarios(folder) reads <folder>/<region>/<split>/*.json and
%   <folder>/split.yaml and returns a table: name, region, folder_split (train or eval),
%   paper_split (train or eval, from the paper_split list of split.yaml when present),
%   low_confidence and file.
files = dir(fullfile(folder, '*', '*', '*.json'));
paper_eval = paper_eval_names(fullfile(folder, 'split.yaml'));
n = numel(files);
name = strings(n, 1); region = strings(n, 1); folder_split = strings(n, 1);
low_confidence = false(n, 1); file = strings(n, 1);
for i = 1:n
    [~, name(i)] = fileparts(files(i).name);
    [rest, folder_split(i)] = fileparts(files(i).folder);
    [~, region(i)] = fileparts(rest);
    file(i) = fullfile(files(i).folder, files(i).name);
    data = jsondecode(fileread(file(i)));
    if isfield(data, 'bumps') && ~isempty(data.bumps) && isfield(data.bumps, 'low_confidence')
        low_confidence(i) = any([data.bumps.low_confidence]);
    end
end
paper_split = repmat("train", n, 1);
paper_split(ismember(name, paper_eval)) = "eval";
list = table(name, region, folder_split, paper_split, low_confidence, file);
list = sortrows(list, 'name');
end

function names = paper_eval_names(file)
names = strings(0, 1);
if ~isfile(file)
    return
end
lines = splitlines(fileread(file));
start = find(startsWith(lines, 'paper_split:'), 1);
if isempty(start)
    return
end
header = find(strcmp(strtrim(lines(start + 1:end)), 'eval:'), 1) + start;
for k = header + 1:numel(lines)
    item = regexp(lines{k}, '^\s+-\s*(\S+)\s*$', 'tokens', 'once');
    if isempty(item)
        break
    end
    names(end + 1, 1) = string(item{1}); %#ok<AGROW>
end
end
