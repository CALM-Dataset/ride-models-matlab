function validate(name, varargin)
%VALIDATE Check a model against the model contract.
%   ride.models.validate(name) loads the parameters, simulates a short drive
%   over a bump and checks the outputs, chart panels and header strip.
%   ride.models.validate(name, 'draw', true) also draws one frame.
%
%   See also docs/add-a-model.md.
opts = struct('draw', false);
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
info = ride.models.get(name);
for field = {'name', 'load', 'simulate', 'frame', 'panels', 'hud'}
    assert(isfield(info, field{1}), 'model "%s" must provide info.%s', name, field{1});
end
P = info.load();
assert(isfield(P, 'DT'), 'model "%s" parameters must hold the time step DT', name);
road = ride.core.terrain.bumps([5 0.03 1]);
speeds = 5 * ones(100, 1);
out = info.simulate(P, road, speeds);
for field = {'t', 's', 'v', 'z_B_ddot'}
    assert(isfield(out, field{1}) && numel(out.(field{1})) == numel(speeds), ...
        'model "%s" must return out.%s with one value per step', name, field{1});
end
panels = info.panels(out);
assert(iscell(panels) && ~isempty(panels), 'model "%s" must return a cell array of chart panels', name);
[labels, values] = info.hud(out, 1);
assert(numel(labels) == numel(values), 'model "%s" must give one header value per label', name);
if opts.draw
    fig = figure('Visible', 'off');
    ax = axes(fig);
    info.frame(ax, P, road, out, 50);
    close(fig);
end
end
