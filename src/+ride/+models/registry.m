function map = registry()
persistent store
if isempty(store)
    store = containers.Map('KeyType', 'char', 'ValueType', 'any');
end
map = store;
end
