function test_terrain()
bump = [10 0.06 2.0];
ds = 0.01;
analytic = ride.core.terrain.bumps(bump);
sampled = ride.core.terrain.from_function(@(s) ride.core.terrain.height(analytic, s), 30, ds, bump);
s = (0:0.137:29)';
assert(max(abs(ride.core.terrain.height(sampled, s) - ride.core.terrain.height(analytic, s))) < 1e-5, ...
    'a sampled profile must follow the analytic bump');
v = 5;
rate_error = 0;
for x = s'
    rate_error = max(rate_error, abs(ride.core.terrain.height_dot(sampled, x, v) - ride.core.terrain.height_dot(analytic, x, v)));
end
assert(rate_error < 1e-2, 'the profile slope must follow the analytic slope');
assert(ride.core.terrain.height(sampled, -1) == 0 && ride.core.terrain.height(sampled, 31) == 0, 'terrain must be flat outside the profile');
assert(ride.core.terrain.height_dot(sampled, 40, v) == 0, 'terrain slope must vanish outside the profile');
hole = ride.core.terrain.bumps([5 -0.05 1.0]);
assert(ride.core.terrain.height(hole, 5.5) < 0, 'a negative height must be a hole');
assert(ride.core.terrain.end_point(analytic, 2.5) == 12 + 2.5, 'the trip ends one wheelbase after the last bump');
assert(ride.core.terrain.end_point(sampled, 2.5) > 30, 'the trip on a profile ends beyond the measured road');
for model = ride.models.list()
    P = ride.load(model{1});
    speeds = 6 * ones(round(8 / P.DT), 1);
    a = ride.simulate(model{1}, P, analytic, speeds);
    b = ride.simulate(model{1}, P, sampled, speeds);
    aw_a = ride.core.comfort.a_w(a.z_B_ddot, P.DT);
    aw_b = ride.core.comfort.a_w(b.z_B_ddot, P.DT);
    assert(abs(aw_a - aw_b) / aw_a < 0.02, 'a sampled profile and the analytic bump must ride the same');
end
end
