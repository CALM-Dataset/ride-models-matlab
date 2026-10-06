function test_equilibrium_and_scaling()
P = halfcar.params.load();
speeds = 6 * ones(300, 1);
flat = halfcar.sim.simulate(P, halfcar.road.bumps([20 0 2]), speeds);
assert(max(abs(flat.z_B_ddot)) < 1e-2, 'a car at rest on a flat road must not accelerate');
assert(max(abs(flat.phi_ddot)) < 1e-2, 'a car at rest on a flat road must not pitch');
low = halfcar.sim.simulate(P, halfcar.road.bumps([10 0.03 2]), speeds);
high = halfcar.sim.simulate(P, halfcar.road.bumps([10 0.06 2]), speeds);
assert(halfcar.comfort.a_w(high.z_B_ddot, P.DT) > halfcar.comfort.a_w(low.z_B_ddot, P.DT), ...
    'a taller bump must be less comfortable');
end
