function v = table(profile, dt, n, sc)
t = (1:n)' * dt;
v = interp1(profile.t_s(:), profile.v_mps(:), t, 'linear', 'extrap');
v(t < profile.t_s(1)) = profile.v_mps(1);
v(t > profile.t_s(end)) = profile.v_mps(end);
end
