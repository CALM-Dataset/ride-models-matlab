function out = simulate(P, road, speeds)
n = numel(speeds);
dt = P.DT;
x = zeros(6, 1);
x(5) = speeds(1);
s = 0;
out = struct('model', 'quartercar', 't', (1:n)' * dt, 's', zeros(n, 1), 'v', speeds(:), ...
    'z_B_ddot', zeros(n, 1), 'z_W_ddot', zeros(n, 1), 'susp', zeros(n, 1), ...
    'z_B', zeros(n, 1), 'z_W', zeros(n, 1));
for k = 1:n
    v = speeds(k);
    s_start = s;
    s = s + v * dt;
    x(5) = v;
    [x, acc] = ride.models.quartercar.dynamics.rk4_step(x, road, s_start, v, P);
    out.s(k) = s;
    out.z_B_ddot(k) = acc.z_B_ddot;
    out.z_W_ddot(k) = acc.z_W_ddot;
    out.susp(k) = x(3);
    out.z_B(k) = x(6);
    out.z_W(k) = x(6) + x(3);
end
end
