function unregister(name)
%UNREGISTER Remove a model added with ride.models.register.
map = ride.models.registry();
if isKey(map, name)
    remove(map, name);
end
end
