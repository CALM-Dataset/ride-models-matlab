function names = list(folder)
base = fullfile(ride.scenarios.cache_dir(), 'real');
names = {};
if ~isfolder(base)
    return
end
found = dir(fullfile(base, '**', '*.json'));
for i = 1:numel(found)
    rel = strrep(fullfile(found(i).folder, found(i).name), [base filesep], '');
    rel = strrep(rel(1:end - 5), filesep, '/');
    if nargin == 0 || startsWith(rel, folder)
        names{end + 1, 1} = rel; %#ok<AGROW>
    end
end
names = sort(names);
end
