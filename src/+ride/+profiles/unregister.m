function unregister(type)
%UNREGISTER Remove a speed profile type added with ride.profiles.register.
map = ride.profiles.registry();
if isKey(map, type)
    remove(map, type);
end
end
