function register(name, fn)
map = ride.metrics.registry();
map(name) = fn;
end
