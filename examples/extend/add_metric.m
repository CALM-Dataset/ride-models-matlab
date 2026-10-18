run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'setup.m'));

ride.metrics.register('peak_jerk', @peak_jerk);

r = ride.run(ride.config('metrics', {'a_w', 'peak_jerk'}));
fprintf('peak jerk %.1f m/s^3, a_w %.3f m/s^2\n', r.metrics.peak_jerk, r.metrics.a_w);

function value = peak_jerk(out, P, sc)
k = ride.metrics.trip_end(out, P, sc);
value = max(abs(diff(out.z_B_ddot(1:k)))) / P.DT;
end
