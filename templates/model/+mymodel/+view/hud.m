function [labels, values] = hud(out, k)
if nargin < 2
    labels = ride.models.quartercar.view.hud(out);
    values = {};
else
    [labels, values] = ride.models.quartercar.view.hud(out, k);
end
end
