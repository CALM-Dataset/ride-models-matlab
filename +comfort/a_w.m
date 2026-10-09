function r = a_w(z_B_ddot, dt)
r = comfort.rms(comfort.wk_weight(z_B_ddot, dt));
end
