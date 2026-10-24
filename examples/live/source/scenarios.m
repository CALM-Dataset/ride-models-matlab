%% Scenarios: the road under the car
% A scenario is a road plus a suggested speed. This script shows the three
% kinds: synthetic roads from a size-code catalog, your own roads, and
% measured roads from Hugging Face.
assert(~isempty(which('ride.run')), 'Run setup in the repository folder first (not needed with the toolbox installed).');
%% Synthetic roads
% A name joins one code per feature with "_": s, m, l, c and sv are bumps of
% growing size, an "h" in front makes a hole.
names = ride.scenarios.synthetic.list();
fprintf('%d synthetic roads, for example %s\n', numel(names), strjoin(names(1:5)', ', '));
sc = ride.scenarios.get('synthetic:s_hm_c');
disp(sc.description)
s = linspace(0, 120, 2000);
figure; plot(s, 1000 * ride.core.terrain.height(sc.road, s)); grid on
xlabel('s [m]'); ylabel('height [mm]'); title(sc.description)
%% Your own road, from a function of distance
road = ride.core.terrain.from_function(@(s) 0.02 * sin(2 * pi * s / 4) .* (s > 20 & s < 40), 60, 0.02);
washboard = ride.scenarios.make('washboard', road, 'speed_mps', 6);
r = ride.run(ride.config('model', 'quartercar', 'scenario', washboard, 'drive.profile', 'constant'));
fprintf('washboard: a_w = %.3f m/s^2\n', r.metrics.a_w);
%% Your own road, by name
% Register it once and use the name anywhere a scenario is expected,
% including the config file.
ride.scenarios.register('washboard', @() washboard);
r = ride.run(ride.config('scenario', 'registered:washboard'));
%% Measured roads
% The measured roads are in a gated Hugging Face dataset. After access is granted, with an access
% token in the HF_TOKEN environment variable:
%
%   setenv('HF_TOKEN', 'hf_...')
%   ride.scenarios.real.sync('germany/eval')
%   sc = ride.scenarios.get('real:germany/eval/stuttgart_sb01');
