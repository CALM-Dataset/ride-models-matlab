function [labels, values] = hud(out, k)
labels = {'$t\ [\mathrm{s}]$', '$s\ [\mathrm{m}]$', '$v\ [\mathrm{km/h}]$', '$z_B\ [\mathrm{mm}]$', '$z_W\ [\mathrm{mm}]$'};
values = {};
if nargin > 1
    values = {sprintf('%.2f', out.t(k)), sprintf('%.1f', out.s(k)), sprintf('%.1f', out.v(k) * 3.6), ...
        sprintf('%+.1f', out.z_B(k) * 1000), sprintf('%+.1f', out.z_W(k) * 1000)};
end
end
