function value = vdv(out, P, sc)
k = ride.metrics.trip_end(out, P, sc);
w = ride.core.comfort.wk_weight(out.z_B_ddot(1:k), P.DT);
value = (sum(w .^ 4) * P.DT) ^ 0.25;
end
