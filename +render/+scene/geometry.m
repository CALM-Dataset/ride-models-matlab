function g = geometry(model)
g = struct('y_scale', 5, 'ground_y', 1.5, 'wheel_ry', 0.5, 'hub_h', 0.12, 'h_mb', 0.45, ...
    'susp_scale', 0.65, 'sp_x', -0.42, 'sp_w', 0.10, 'sp_n', 5, 'da_x', 0.5, 'da_w', 0.25, ...
    'pist_frac', 0.48, 'obstacle_flag_m', 0.02, 'wheel_r', 0.32, 'ylim', [-0.6 5.6]);
switch model
    case 'halfcar'
        g.w_hub = 1.5;
        g.mb_overhang = 0.75;
        g.y_w_nom = 1.2;
        g.y_b_nom = 2.4;
        g.pist_h = 0.18;
        g.lower_stem = 0.12;
        g.cyl_h_susp = 0.53;
        g.cyl_h_tire = 0.48;
    case 'quartercar'
        g.w_hub = 1.75;
        g.w_mb = 1.75;
        g.y_w_nom = 2.0;
        g.y_b_nom = 4.0;
        g.pist_h = 0.05;
        g.lower_stem = 0.2;
        g.cyl_h_susp = 0.88;
        g.cyl_h_tire = 0.8;
    otherwise
        error('render:unknownModel', 'unknown model "%s"', model);
end
end
