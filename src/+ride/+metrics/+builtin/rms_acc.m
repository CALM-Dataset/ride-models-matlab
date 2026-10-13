function value = rms_acc(out, P, sc)
k = ride.metrics.trip_end(out, P, sc);
value = ride.core.comfort.rms(out.z_B_ddot(1:k));
end
