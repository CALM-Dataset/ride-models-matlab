% Ride models
%
% Run
%   ride.config          read the settings in config/default.json
%   ride.run             model + scenario + speed profile -> simulation and metrics
%   ride.load            vehicle parameters of a model
%   ride.simulate        simulate one drive
%
% Plug-ins
%   ride.models          list, get, register, validate
%   ride.scenarios       get, list, register, make, from_file; synthetic and real sources
%   ride.profiles        speeds, list, register
%   ride.metrics         evaluate, list, register
%
% Building blocks
%   ride.core.terrain    bumps, profile, from_function, height, height_dot, end_point
%   ride.core.comfort    wk_weight, rms, a_w
%   ride.core.suspension spring_nonlin, damper
%   ride.render          animate, frame_figure, frame_index; scene and plots
