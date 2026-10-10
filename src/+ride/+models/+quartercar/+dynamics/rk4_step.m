function [x, acc] = rk4_step(x, road, s_pos, v, P)
dt = P.DT_SIM;
n = P.N_SUB;
for i = 1:n
    z0 = ride.core.terrain.height_dot(road, s_pos + (i - 1) * dt * v, v);
    zh = ride.core.terrain.height_dot(road, s_pos + (i - 0.5) * dt * v, v);
    ze = ride.core.terrain.height_dot(road, s_pos + i * dt * v, v);
    k1 = ride.models.quartercar.dynamics.ode_rhs(x, z0, P);
    k2 = ride.models.quartercar.dynamics.ode_rhs(x + 0.5 * dt * k1, zh, P);
    k3 = ride.models.quartercar.dynamics.ode_rhs(x + 0.5 * dt * k2, zh, P);
    k4 = ride.models.quartercar.dynamics.ode_rhs(x + dt * k3, ze, P);
    x = x + (dt / 6) * (k1 + 2 * k2 + 2 * k3 + k4);
end
s_end = s_pos + n * dt * v;
dx = ride.models.quartercar.dynamics.ode_rhs(x, ride.core.terrain.height_dot(road, s_end, v), P);
acc = struct('z_B_ddot', dx(4), 'z_W_ddot', dx(2));
end
