function test_quartercar_equilibrium_and_scaling()
P = ride.models.quartercar.params.load();
speeds = 6 * ones(300, 1);
flat = ride.models.quartercar.sim.simulate(P, ride.core.terrain.bumps([20 0 2]), speeds);
assert(max(abs(flat.z_B_ddot)) < 1e-2, 'a car at rest on a flat road must not accelerate');
low = ride.models.quartercar.sim.simulate(P, ride.core.terrain.bumps([10 0.03 2]), speeds);
high = ride.models.quartercar.sim.simulate(P, ride.core.terrain.bumps([10 0.06 2]), speeds);
assert(ride.core.comfort.a_w(high.z_B_ddot, P.DT) > ride.core.comfort.a_w(low.z_B_ddot, P.DT), 'a taller bump must be less comfortable');
end
