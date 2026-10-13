function value = min_speed(out, P, sc)
k = ride.metrics.trip_end(out, P, sc);
value = min(out.v(1:k));
end
