function out = simulate(P, road, speeds)
n = numel(speeds);
x = zeros(5, 1);
s = 0;
out = struct('t', (1:n)' * P.DT, 's', zeros(n, 1), 'v', speeds(:), 'z_B_ddot', zeros(n, 1), ...
    'z_W_ddot', zeros(n, 1), 'z_B', zeros(n, 1), 'z_W', zeros(n, 1));
for k = 1:n
    v = speeds(k);
    for i = 1:P.N_SUB
        s0 = s + (i - 1) * P.DT_SIM * v;
        zd = [ride.core.terrain.height_dot(road, s0, v), ...
              ride.core.terrain.height_dot(road, s0 + 0.5 * P.DT_SIM * v, v), ...
              ride.core.terrain.height_dot(road, s0 + P.DT_SIM * v, v)];
        k1 = rhs(x, zd(1), P);
        k2 = rhs(x + 0.5 * P.DT_SIM * k1, zd(2), P);
        k3 = rhs(x + 0.5 * P.DT_SIM * k2, zd(2), P);
        k4 = rhs(x + P.DT_SIM * k3, zd(3), P);
        x = x + (P.DT_SIM / 6) * (k1 + 2 * k2 + 2 * k3 + k4);
    end
    s = s + v * P.DT;
    dx = rhs(x, ride.core.terrain.height_dot(road, s, v), P);
    out.s(k) = s;
    out.z_B_ddot(k) = dx(4);
    out.z_W_ddot(k) = dx(2);
    out.z_B(k) = x(5);
    out.z_W(k) = x(5) + x(3);
end
end

function dx = rhs(x, z_dot, P)
F_S = P.k_S * x(3) + P.c_S * (x(2) - x(4));
F_T = P.k_T * x(1) + P.c_T * (z_dot - x(2));
dx = [z_dot - x(2); (F_T - F_S) / P.m_W; x(2) - x(4); F_S / P.m_B; x(4)];
end
