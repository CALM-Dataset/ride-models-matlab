function out = simulate(model, P, road, speeds)
%SIMULATE Drive a model over a road at the given speeds.
%   out = ride.simulate(model, P, road, speeds) returns a struct of column
%   vectors with one value per speed step: t, s, v, z_B_ddot and the
%   model's own signals. speeds holds one speed in m/s per step of P.DT.
%
%   Example
%       P = ride.load('quartercar');
%       out = ride.simulate('quartercar', P, ride.core.terrain.bumps([20 0.06 2]), 6 * ones(400, 1));
%
%   See also ride.run, ride.load.
info = ride.models.get(model);
out = info.simulate(P, road, speeds);
out.model = model;
end
