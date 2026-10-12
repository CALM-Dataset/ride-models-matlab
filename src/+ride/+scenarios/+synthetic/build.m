function sc = build(key, varargin)
c = ride.scenarios.synthetic.catalog();
opts = struct('flat_start_m', c.defaults.flat_start_m, 'gap_m', c.defaults.gap_m, 'speed_kmh', c.defaults.speed_kmh);
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
name = key;
key = regexprep(key, '^.*/', '');
if isfield(c.potholes, key)
    p = c.potholes.(key);
    rows = [opts.flat_start_m, -p.depth_m, p.width_m];
    description = strrep(key, '_', ' ');
else
    parts = strsplit(key, '_');
    rows = zeros(numel(parts), 3);
    names = cell(1, numel(parts));
    x = opts.flat_start_m;
    for i = 1:numel(parts)
        code = parts{i};
        is_hole = startsWith(code, 'h') && isfield(c.bumps, code(2:end));
        if is_hole
            code = code(2:end);
        end
        if ~isfield(c.bumps, code)
            error('ride:unknownScenario', 'unknown synthetic scenario key "%s"', key);
        end
        b = c.bumps.(code);
        height = b.height_m;
        label = b.name;
        if is_hole
            height = -height;
            label = strrep(label, 'bump', 'hole');
        end
        rows(i, :) = [x, height, b.width_m];
        names{i} = label;
        x = x + b.width_m + opts.gap_m;
    end
    description = strjoin(names, ' then ');
end
sc = ride.scenarios.make(name, ride.core.terrain.bumps(rows), 'description', description, ...
    'source', c.source, 'speed_mps', opts.speed_kmh / 3.6);
end
