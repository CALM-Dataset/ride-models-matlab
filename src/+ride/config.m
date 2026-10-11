function cfg = config(varargin)
file = fullfile(ride.root(), 'config', 'default.json');
if mod(numel(varargin), 2) == 1
    file = varargin{1};
    varargin(1) = [];
end
cfg = jsondecode(fileread(file));
for i = 1:2:numel(varargin)
    cfg = set_path(cfg, strsplit(varargin{i}, '.'), varargin{i + 1});
end
end

function s = set_path(s, parts, value)
if isscalar(parts)
    s.(parts{1}) = value;
    return
end
if ~isfield(s, parts{1})
    s.(parts{1}) = struct();
end
s.(parts{1}) = set_path(s.(parts{1}), parts(2:end), value);
end
