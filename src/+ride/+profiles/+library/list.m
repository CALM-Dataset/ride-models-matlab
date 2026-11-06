function names = list()
%LIST Measured roads with comfort speed profiles in the local cache.
found = dir(fullfile(ride.profiles.library.cache_dir(), '*', '*.json'));
names = {};
if ~isempty(found)
    [~, names] = cellfun(@fileparts, unique({found.folder}), 'UniformOutput', false);
end
names = names(:);
end
