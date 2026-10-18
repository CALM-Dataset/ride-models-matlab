function unregister(name)
%UNREGISTER Remove a metric added with ride.metrics.register.
map = ride.metrics.registry();
if isKey(map, name)
    remove(map, name);
end
end
