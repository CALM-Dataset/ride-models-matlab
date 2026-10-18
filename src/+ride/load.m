function P = load(model)
%LOAD Vehicle parameters of a model.
%   P = ride.load('halfcar') reads data/models/halfcar/params.json. P.DT is
%   the output time step in seconds.
%
%   See also ride.simulate, ride.models.list.
info = ride.models.get(model);
P = info.load();
P.model = model;
end
