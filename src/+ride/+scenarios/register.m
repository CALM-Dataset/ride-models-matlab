function register(name, factory)
map = ride.scenarios.registry();
map(name) = factory;
end
