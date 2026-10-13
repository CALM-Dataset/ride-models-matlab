function register(type, fn)
map = ride.profiles.registry();
map(type) = fn;
end
