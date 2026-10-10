function dx = ode_rhs(x, z_dot, P)
F_spring = P.k_S * x(3) + ride.core.suspension.spring_nonlin(x(3), P);
F_damp = ride.core.suspension.damper(x(2) - x(4), P);
F_tyre = P.k_T * x(1) + P.c_T * (z_dot - x(2));
dx = zeros(6, 1);
dx(1) = z_dot - x(2);
dx(2) = (-F_spring - F_damp + F_tyre) / P.m_W;
dx(3) = x(2) - x(4);
dx(4) = (F_spring + F_damp) / P.m_B;
dx(5) = 0;
dx(6) = x(4);
end
