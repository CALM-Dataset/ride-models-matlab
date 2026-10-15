function v = mpc(profile, dt, n, sc)
file = '';
if isfield(profile, 'file')
    file = profile.file;
end
v = ride.profiles.library.speeds(sc, 'mpc', dt, n, file);
end
