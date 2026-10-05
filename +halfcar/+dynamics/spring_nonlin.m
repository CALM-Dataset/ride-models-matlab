function F = spring_nonlin(dyn, p)
if dyn > p.dz_cmp
    dz_F = dyn - p.dz_cmp;
    F = p.k_S * (p.dz_S_stat * p.f1_cmp * (exp(dz_F * p.f2_cmp / p.dz_S_stat) - 1) - dz_F);
elseif dyn < -p.dz_rbd
    dz_F = -dyn - p.dz_rbd;
    F = -p.k_S * (p.dz_S_stat * p.f1_rbd * (exp(dz_F * p.f2_rbd / p.dz_S_stat) - 1) - dz_F);
else
    F = 0;
    return
end
F = min(max(F, -p.F_ks_nlin_max), p.F_ks_nlin_max);
end
