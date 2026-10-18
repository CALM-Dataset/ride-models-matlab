function r = a_w(z_B_ddot, dt)
%A_W ISO 2631-1 Wk-weighted RMS of a vertical acceleration signal sampled every dt seconds.
r = ride.core.comfort.rms(ride.core.comfort.wk_weight(z_B_ddot, dt));
end
