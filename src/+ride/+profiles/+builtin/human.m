function v = human(profile, dt, n, sc)
file = '';
if isfield(profile, 'file')
    file = profile.file;
end
v = ride.profiles.library.speeds(sc, 'human', dt, n, file);
end
