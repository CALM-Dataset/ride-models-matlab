function [x, acc] = rk4_step(x, road, s_pos, v, a, P)
dt = P.DT_SIM;
n = P.N_SUB;
L = P.L;
b = P.body;
for i = 1:n
    s0 = s_pos + (i - 1) * dt * v;
    sh = s_pos + (i - 0.5) * dt * v;
    se = s_pos + i * dt * v;
    zf = [ride.core.terrain.height_dot(road, s0, v), ride.core.terrain.height_dot(road, sh, v), ride.core.terrain.height_dot(road, se, v)];
    zr = [ride.core.terrain.height_dot(road, s0 - L, v), ride.core.terrain.height_dot(road, sh - L, v), ride.core.terrain.height_dot(road, se - L, v)];
    k1 = ride.models.halfcar.dynamics.ode_rhs(x, zf(1), zr(1), P, a);
    k2 = ride.models.halfcar.dynamics.ode_rhs(x + 0.5 * dt * k1, zf(2), zr(2), P, a);
    k3 = ride.models.halfcar.dynamics.ode_rhs(x + 0.5 * dt * k2, zf(2), zr(2), P, a);
    k4 = ride.models.halfcar.dynamics.ode_rhs(x + dt * k3, zf(3), zr(3), P, a);
    x = x + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4);
end
s_end = s_pos + n * dt * v;
dx = ride.models.halfcar.dynamics.ode_rhs(x, ride.core.terrain.height_dot(road, s_end, v), ride.core.terrain.height_dot(road, s_end - L, v), P, a);
acc = struct('z_B_ddot', dx(6), 'phi_ddot', dx(8), 'z_Wf_ddot', dx(4), 'z_Wr_ddot', dx(2));
end
