function sc = build(key, varargin)
%BUILD A synthetic road from the size-code catalog.
%   sc = ride.scenarios.synthetic.build('s_hm_c') builds a short bump, a
%   medium hole and a raised crosswalk. Options: 'flat_start_m', 'gap_m'
%   and 'speed_kmh'. The codes and sizes are in data/scenarios/synthetic.json.
%
%   See also ride.scenarios.get, ride.scenarios.synthetic.list.
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
            error('ride:unknownScenario', ['unknown synthetic scenario "%s": a name joins the codes %s with "_" ', ...
                '(an "h" in front makes a hole), or is one of %s. ride.scenarios.synthetic.list() shows them all.'], ...
                key, strjoin(fieldnames(c.bumps)', ', '), strjoin(fieldnames(c.potholes)', ', '));
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
