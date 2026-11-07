function list = find_scenarios(folder)
%FIND_SCENARIOS Scenario files of a CALM-Scenarios folder with their region, split and confidence.
%   list = ride.validation.find_scenarios(folder) reads <folder>/<region>/crossings/*.json and
%   <folder>/split.yaml and returns a table: name, region, split (eval for the roads in the
%   eval list of split.yaml, excluded for those in its exclude list, train for all others),
%   low_confidence and file.
files = dir(fullfile(folder, '*', 'crossings', '*.json'));
[evaluation, excluded] = ride.scenarios.real.eval_names(fullfile(folder, 'split.yaml'));
n = numel(files);
name = strings(n, 1); region = strings(n, 1);
low_confidence = false(n, 1); file = strings(n, 1);
for i = 1:n
    [~, name(i)] = fileparts(files(i).name);
    [~, region(i)] = fileparts(fileparts(files(i).folder));
    file(i) = fullfile(files(i).folder, files(i).name);
    data = jsondecode(fileread(file(i)));
    if isfield(data, 'bumps') && ~isempty(data.bumps) && isfield(data.bumps, 'low_confidence')
        low_confidence(i) = any([data.bumps.low_confidence]);
    end
end
split = repmat("train", n, 1);
split(ismember(name, evaluation)) = "eval";
split(ismember(name, excluded)) = "excluded";
list = table(name, region, split, low_confidence, file);
list = sortrows(list, 'name');
end
