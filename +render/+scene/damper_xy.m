function d = damper_xy(x_c, y_top, y_bot, cyl_h, w, pist_h, pist_frac, lower_stem)
hw = w / 2;
gap = max(y_top - y_bot, 0.05);
cyl_bot = y_bot + lower_stem;
cyl_top = cyl_bot + cyl_h;
pist_top = min(max(y_bot + gap * pist_frac, cyl_bot + pist_h + 0.005), cyl_top - 0.005);
pist_bot = pist_top - pist_h;
m = 0.01;
d.upper_rod = {[x_c x_c], [pist_top y_top]};
d.lower_rod = {[x_c x_c], [y_bot cyl_bot]};
d.cylinder = {[x_c - hw, x_c - hw, x_c + hw, x_c + hw], [cyl_top, cyl_bot, cyl_bot, cyl_top]};
d.piston = {[x_c - hw + m, x_c + hw - m, x_c + hw - m, x_c - hw + m], [pist_bot, pist_bot, pist_bot + pist_h, pist_bot + pist_h]};
end
