model = 'halfcar';
addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
P = ride.load(model);
road = terrain.bumps([20 0.06 2.0]);
wheelbase = 0;
if isfield(P, 'L')
    wheelbase = P.L;
end
t = (1:900)' * P.DT;
profiles = {6 * ones(size(t)), 6 - 3 * exp(-((t - 3.5) .^ 2) / 2)};
names = {'constant', 'dip before the bump'};
for i = 1:numel(profiles)
    out = ride.simulate(model, P, road, profiles{i});
    k = min([find(out.s >= 22 + wheelbase, 1), numel(out.t)]);
    fprintf('%-20s travel time %.2f s   weighted RMS %.3f m/s^2\n', names{i}, out.t(k), comfort.a_w(out.z_B_ddot(1:k), P.DT));
end
