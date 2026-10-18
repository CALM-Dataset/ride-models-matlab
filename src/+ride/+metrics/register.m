function register(name, fn)
%REGISTER Add a metric for this MATLAB session.
%   ride.metrics.register(name, fn) where value = fn(out, P, scenario).
%
%   See also ride.metrics.evaluate.
map = ride.metrics.registry();
map(name) = fn;
end
