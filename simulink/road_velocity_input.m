function ts = road_velocity_input(P, road, speeds)
n = numel(speeds);
N = P.N_SUB;
dt = P.DT_SIM;
t = zeros(2 * N * n + 1, 1);
z = zeros(size(t));
z(1) = ride.core.terrain.height_dot(road, 0, speeds(1));
idx = 1;
s = 0;
for k = 1:n
    v = speeds(k);
    for i = 1:N
        for j = [0.5 1.0]
            idx = idx + 1;
            t(idx) = (k - 1) * P.DT + (i - 1 + j) * dt;
            z(idx) = ride.core.terrain.height_dot(road, s + (i - 1 + j) * dt * v, v);
        end
    end
    s = s + v * P.DT;
end
ts = timeseries(z, t);
end
