function hud_update(h, t, s, v, z_B, phi)
vals = {sprintf('%.2f', t), sprintf('%.1f', s), sprintf('%.1f', v * 3.6), ...
    sprintf('%+.1f', z_B * 1000), sprintf('%+.2f', phi * 180 / pi)};
for i = 1:numel(vals)
    set(h.values(i), 'String', vals{i});
end
end
