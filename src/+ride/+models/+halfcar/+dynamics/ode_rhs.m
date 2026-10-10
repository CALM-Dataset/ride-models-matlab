function dx = ode_rhs(x, zf_dot, zr_dot, P, a)
b = P.body;
corner_vel_f = x(6) - b.l_f * x(8);
corner_vel_r = x(6) + b.l_r * x(8);
[Fs_f, Ft_f] = axle_force(x(7), x(4) - corner_vel_f, x(3), zf_dot, x(4), P.front);
[Fs_r, Ft_r] = axle_force(x(5), x(2) - corner_vel_r, x(1), zr_dot, x(2), P.rear);
dx = zeros(11, 1);
dx(1) = zr_dot - x(2);
dx(2) = (-Fs_r + Ft_r) / P.rear.m_W;
dx(3) = zf_dot - x(4);
dx(4) = (-Fs_f + Ft_f) / P.front.m_W;
dx(5) = x(2) - x(6) - b.l_r * x(8);
dx(6) = (Fs_f + Fs_r) / b.m_B;
dx(7) = x(4) - x(6) + b.l_f * x(8);
if a > 0
    p_h = b.h_T;
else
    p_h = b.h_B;
end
dx(8) = (b.l_r * Fs_r - b.l_f * Fs_f - p_h * P.m_tot * a) / b.I_B;
dx(9) = 0;
dx(10) = x(6);
dx(11) = x(8);
end

function [F_susp, F_tire] = axle_force(susp, susp_vel, tyre, zr_dot, zw_vel, p)
F_susp = p.k_S * susp + ride.core.suspension.spring_nonlin(susp, p) + ride.core.suspension.damper(susp_vel, p);
F_tire = p.k_T * tyre + p.c_T * (zr_dot - zw_vel);
end
