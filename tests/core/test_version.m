function test_version()
v = ride.version();
assert(~isempty(regexp(v, '^\d+\.\d+\.\d+$', 'once')), 'VERSION must hold a version like 1.2.3');
cff = fileread(fullfile(ride.root(), 'CITATION.cff'));
listed = regexp(cff, '(?m)^version:\s*"?([^"\s]+)"?', 'tokens', 'once');
assert(~isempty(listed) && strcmp(listed{1}, v), 'CITATION.cff must carry the version in VERSION');
end
