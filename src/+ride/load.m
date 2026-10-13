function P = load(model)
info = ride.models.get(model);
P = info.load();
P.model = model;
end
