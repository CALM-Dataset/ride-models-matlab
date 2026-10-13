function [labels, values] = hud(out, k)
labels = {'$t\ [\mathrm{s}]$', '$s\ [\mathrm{m}]$', '$v\ [\mathrm{km/h}]$', '$z_B\ [\mathrm{mm}]$', '$\varphi\ [\mathrm{deg}]$'};
values = {};
if nargin > 1
    values = {sprintf('%.2f', out.t(k)), sprintf('%.1f', out.s(k)), sprintf('%.1f', out.v(k) * 3.6), ...
        sprintf('%+.1f', out.z_B(k) * 1000), sprintf('%+.2f', out.phi(k) * 180 / pi)};
end
end
