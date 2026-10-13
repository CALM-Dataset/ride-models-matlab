function out = simulate(model, P, road, speeds)
info = ride.models.get(model);
out = info.simulate(P, road, speeds);
out.model = model;
end
