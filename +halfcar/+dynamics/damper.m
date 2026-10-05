function F = damper(v_S, p)
k = 50;
w_cmp = 1 / (1 + exp(-k * v_S));
F_base = (w_cmp * p.d1 + (1 - w_cmp) * p.z1) * v_S;
w_hc = 1 / (1 + exp(-k * (v_S - p.v_d)));
F_hc = w_hc * (p.d2 - p.d1) * (v_S - p.v_d);
w_hr = 1 / (1 + exp(-k * (-v_S - p.v_z)));
F_hr = w_hr * (p.z2 - p.z1) * (-v_S - p.v_z);
F = F_base + F_hc - F_hr;
end
