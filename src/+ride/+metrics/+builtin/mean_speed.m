function value = mean_speed(out, P, sc)
k = ride.metrics.trip_end(out, P, sc);
value = out.s(k) / out.t(k);
end
