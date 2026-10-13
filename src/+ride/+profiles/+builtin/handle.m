function v = handle(profile, dt, n, sc)
v = profile.fn((1:n)' * dt);
end
