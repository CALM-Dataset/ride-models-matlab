addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
P = halfcar.params.load();
road = halfcar.road.bumps([20 0.06 2.0]);
t = (1:900)' * P.DT;
profiles = {6 * ones(size(t)), 6 - 3 * exp(-((t - 3.5) .^ 2) / 2)};
names = {'constant', 'dip before the bump'};
for i = 1:numel(profiles)
    out = halfcar.sim.simulate(P, road, profiles{i});
    reached = find(out.s >= 20 + 2.0 + P.L, 1);
    k = min([reached, numel(out.t)]);
    fprintf('%-20s travel time %.2f s   weighted RMS %.3f m/s^2\n', names{i}, out.t(k), ...
        halfcar.comfort.a_w(out.z_B_ddot(1:k), P.DT));
end
