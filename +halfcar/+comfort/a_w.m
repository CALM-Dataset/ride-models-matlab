function r = a_w(z_B_ddot, dt)
r = halfcar.comfort.rms(halfcar.comfort.wk_weight(z_B_ddot, dt));
end
