function value = peak_acc(out, P, sc)
k = ride.metrics.trip_end(out, P, sc);
value = max(abs(out.z_B_ddot(1:k)));
end
