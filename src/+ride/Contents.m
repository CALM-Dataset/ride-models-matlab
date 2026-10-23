% Ride models: quarter-car and half-car ride comfort over road anomalies.
%
% Run
%   ride.config            settings from config/default.json, with overrides
%   ride.run               model + scenario + speed profile -> simulation and metrics
%   ride.load              vehicle parameters of a model
%   ride.simulate          simulate one drive
%   ride.version           package version
%   ride.root              package folder
%
% Plug-ins (each has list, register and unregister)
%   ride.models            get, validate; one folder per model in +ride/+models
%   ride.scenarios         get, make, from_file; synthetic and real sources
%   ride.profiles          speeds; recorded profiles in ride.profiles.library
%   ride.metrics           evaluate, trip_end
%
% Building blocks
%   ride.core.terrain      bumps, profile, from_function, height, height_dot, end_point
%   ride.core.comfort      wk_weight, rms, a_w
%   ride.core.suspension   spring_nonlin, damper, damper_coefficients
%   ride.render            animate, frame_figure, frame_index; plots.signals
%   ride.validation        load_recording, window_road, compare; against the CALM recordings
%
% Simulink (simulink folder)
%   ride_lib               library: Quarter-car, Half-car, Axle, Road, Drive
%   run_demo               demo model driven by ride.run
%
% Start with the getting-started guide in docs or examples/live/getting_started.mlx.
