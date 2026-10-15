function v = recorded(profile, dt, n, sc)
file = '';
if isfield(profile, 'file')
    file = profile.file;
end
v = ride.profiles.library.speeds(sc, profile.source, dt, n, file);
end
