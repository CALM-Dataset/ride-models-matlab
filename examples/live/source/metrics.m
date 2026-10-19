%% Metrics: scoring a drive
% A metric turns the simulation into one number. The built-ins follow
% ISO 2631-1 for comfort and add trip time and speeds.
assert(~isempty(which('ride.run')), 'Run setup in the repository folder first (not needed with the toolbox installed).');
r = ride.run();
disp(ride.metrics.list())
m = ride.metrics.evaluate(r.out, r.P, r.scenario, ride.metrics.list())
%% Weighted acceleration
% |a_w| is the RMS of the Wk-weighted body acceleration. The weighting keeps
% 4 to 8 Hz, where people are most sensitive, and drops slow motion.
w = ride.core.comfort.wk_weight(r.out.z_B_ddot, r.P.DT);
figure; plot(r.out.t, r.out.z_B_ddot, r.out.t, w); grid on
legend('raw', 'Wk-weighted'); xlabel('t [s]'); ylabel('m/s^2')
%% A metric of your own
ride.metrics.register('peak_pitch_deg', @(out, P, sc) max(abs(out.phi)) * 180 / pi);
ride.metrics.evaluate(r.out, r.P, r.scenario, {'a_w', 'peak_pitch_deg'})
