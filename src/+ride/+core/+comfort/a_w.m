function r = a_w(z_B_ddot, dt)
r = ride.core.comfort.rms(ride.core.comfort.wk_weight(z_B_ddot, dt));
end
