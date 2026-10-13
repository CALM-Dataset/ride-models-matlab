function value = pitch_rms(out, P, sc)
value = NaN;
if isfield(out, 'phi')
    k = ride.metrics.trip_end(out, P, sc);
    value = ride.core.comfort.rms(out.phi(1:k));
end
end
