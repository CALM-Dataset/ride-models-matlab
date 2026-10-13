function value = susp_travel_peak(out, P, sc)
k = ride.metrics.trip_end(out, P, sc);
if isfield(out, 'susp')
    value = max(abs(out.susp(1:k)));
elseif isfield(out, 'susp_f')
    value = max(max(abs(out.susp_f(1:k))), max(abs(out.susp_r(1:k))));
else
    value = NaN;
end
end
