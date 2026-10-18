function unregister(name)
%UNREGISTER Remove a scenario added with ride.scenarios.register.
map = ride.scenarios.registry();
if isKey(map, name)
    remove(map, name);
end
end
