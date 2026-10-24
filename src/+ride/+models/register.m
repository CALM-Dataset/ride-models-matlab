function register(name, info_fn)
%REGISTER Add a model for this MATLAB session.
%   ride.models.register(name, info_fn) where info_fn returns the struct
%   described in the Adding a model page of the wiki.
%
%   See also ride.models.validate.
map = ride.models.registry();
map(name) = info_fn;
end
