function out = simulate(P, road, speeds)
n = numel(speeds);
dt = P.DT;
x = zeros(11, 1);
x(9) = speeds(1);
s = 0;
v_prev = speeds(1);
out = struct('model', 'halfcar', 't', (1:n)' * dt, 's', zeros(n, 1), 'v', speeds(:), 'z_B_ddot', zeros(n, 1), ...
    'phi_ddot', zeros(n, 1), 'z_Wf_ddot', zeros(n, 1), 'z_Wr_ddot', zeros(n, 1), ...
    'susp_f', zeros(n, 1), 'susp_r', zeros(n, 1), 'phi', zeros(n, 1), 'z_B', zeros(n, 1), ...
    'z_Wf', zeros(n, 1), 'z_Wr', zeros(n, 1));
for k = 1:n
    v = speeds(k);
    a = (v - v_prev) / dt;
    v_prev = v;
    x(9) = v;
    s_start = s;
    s = s + v * dt;
    [x, acc] = halfcar.dynamics.rk4_step(x, road, s_start, v, a, P);
    out.s(k) = s;
    out.z_B_ddot(k) = acc.z_B_ddot;
    out.phi_ddot(k) = acc.phi_ddot;
    out.z_Wf_ddot(k) = acc.z_Wf_ddot;
    out.z_Wr_ddot(k) = acc.z_Wr_ddot;
    out.susp_f(k) = x(7);
    out.susp_r(k) = x(5);
    out.phi(k) = x(11);
    out.z_B(k) = x(10);
    out.z_Wf(k) = x(10) - P.body.l_f * x(11) + x(7);
    out.z_Wr(k) = x(10) + P.body.l_r * x(11) + x(5);
end
end
