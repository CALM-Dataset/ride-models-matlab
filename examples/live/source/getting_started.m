%% Getting started with ride models
% A car drives over a speed bump. How much does the body shake, and does
% driving slower help? This script runs one drive, looks at the result and
% changes one setting at a time. Everything here works offline.
%% Set up
% Run |setup| once in the repository folder; it puts the package on the
% path. With the toolbox installed this step is not needed.
assert(~isempty(which('ride.run')), 'Run setup in the repository folder first (not needed with the toolbox installed).');
%% One drive with the default settings
% The settings live in |config/default.json|: a half-car, a medium bump and a
% driver who slows down before it.
cfg = ride.config();
r = ride.run(cfg);
disp(r.metrics)
%% 
% |a_w| is the ISO 2631-1 weighted RMS body acceleration in m/s^2. Lower is
% more comfortable.
%% Look at it
% The scene shows the car at the moment it reaches the bump; the charts
% show the whole drive with the bump crossings shaded.
[update, fig] = ride.render.frame_figure(r.P, r.road, r.out);
update(ride.render.frame_index(r, 'bump'));
%% 
% To watch the drive: |ride.render.animate(r.P, r.road, r.out)|.
%% Change the model, the road and the speed
r2 = ride.run(ride.config('model', 'quartercar', 'scenario', 'synthetic:s_l', 'drive.profile', 'constant'));
fprintf('quarter-car over a short and a long bump at %.1f km/h: a_w = %.3f m/s^2\n', 3.6 * r2.speeds(1), r2.metrics.a_w);
%% How does speed change comfort?
% Drive the same bump at several constant speeds. Try other roads too, for
% example the long bump 'synthetic:l'.
speeds_kmh = 10:5:50;
a_w = zeros(size(speeds_kmh));
for i = 1:numel(speeds_kmh)
    cfg = ride.config('model', 'quartercar', 'scenario', 'synthetic:m', 'drive.profile', 'constant');
    cfg.profiles.constant.speed_mps = speeds_kmh(i) / 3.6;
    run_i = ride.run(cfg);
    a_w(i) = run_i.metrics.a_w;
end
figure; plot(speeds_kmh, a_w, 'o-'); grid on
xlabel('speed [km/h]'); ylabel('a_w [m/s^2]'); title('Medium bump, quarter-car')
%% Next
% The wiki at https://github.com/CALM-Dataset/ride-models-matlab/wiki has
% pages on roads, speed profiles and metrics, and adding a vehicle model.
