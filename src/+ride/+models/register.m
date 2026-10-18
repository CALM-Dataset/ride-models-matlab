function register(name, info_fn)
%REGISTER Add a model for this MATLAB session.
%   ride.models.register(name, info_fn) where info_fn returns the struct
%   described in docs/add-a-model.md.
%
%   See also ride.models.validate.
map = ride.models.registry();
map(name) = info_fn;
end
