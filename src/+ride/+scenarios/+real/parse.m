function sc = parse(d, varargin)
opts = struct('trim', true, 'tol_m', 0.01, 'margin_m', 0.5, 'speed_mps', 6.0);
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
ds = d.road.ds_m;
z = d.road.z(:);
starts = [];
ends = [];
heights = [];
if isfield(d, 'bumps') && ~isempty(d.bumps)
    b = d.bumps;
    starts = [b.s_start_m]';
    ends = [b.s_end_m]';
    heights = [b.peak_z_m]';
end
first = 1;
last = numel(z);
if opts.trim
    [first, last] = ride.scenarios.real.trim_edges(z, ds, starts, ends, opts.tol_m, opts.margin_m);
end
offset = (first - 1) * ds;
rows = zeros(0, 3);
if ~isempty(starts)
    rows = [starts - offset, heights, ends - starts];
end
road = ride.core.terrain.profile(z(first:last), ds, rows);
name = '';
if isfield(d, 'name')
    name = d.name;
end
meta = struct();
if isfield(d, 'meta')
    meta = d.meta;
end
if isfield(d, 'bumps') && ~isempty(d.bumps) && isfield(d.bumps, 'low_confidence')
    meta.low_confidence = any([d.bumps.low_confidence]);
end
meta.trim_offset_m = offset;
sc = ride.scenarios.make(name, road, 'description', 'measured road profile', 'speed_mps', opts.speed_mps, 'meta', meta);
end
