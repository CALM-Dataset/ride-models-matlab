function value = a_w(out, P, sc)
k = ride.metrics.trip_end(out, P, sc);
value = ride.core.comfort.rms(ride.core.comfort.wk_weight(out.z_B_ddot(1:k), P.DT));
end
