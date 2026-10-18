run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'setup.m'));

file = fullfile(tempdir, 'measured_road.csv');
s = (0:0.05:40)';
z = 0.04 * exp(-((s - 20) / 0.8) .^ 2);
writematrix([s z], file);

load_csv_road = @(path) ride.scenarios.make('measured_road', ...
    ride.core.terrain.profile(readmatrix(path) * [0; 1], 0.05, [18.5 0.04 3.0]), ...
    'description', 'height profile from a CSV file with columns s and z', 'source', 'csv', 'speed_mps', 6);
ride.scenarios.register('csv_road', @() load_csv_road(file));

r = ride.run(ride.config('model', 'quartercar', 'scenario', 'registered:csv_road', 'drive.profile', 'constant'));
fprintf('csv_road: a_w %.3f m/s^2 over %.1f s\n', r.metrics.a_w, r.metrics.travel_time);
