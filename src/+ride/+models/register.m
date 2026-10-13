function register(name, info_fn)
map = ride.models.registry();
map(name) = info_fn;
end
