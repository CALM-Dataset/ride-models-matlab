function v = version()
%VERSION Version of the ride models package, from the VERSION file.
v = strtrim(fileread(fullfile(ride.root(), 'VERSION')));
end
