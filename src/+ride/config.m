function cfg = config(varargin)
%CONFIG Settings for ride.run, read from config/default.json.
%   cfg = ride.config() reads config/default.json.
%   cfg = ride.config(file) reads another JSON file with the same layout.
%   cfg = ride.config(..., name, value, ...) overrides single settings. A
%   dotted name reaches into nested settings.
%
%   Example
%       cfg = ride.config('model', 'quartercar', 'scenario', 'synthetic:s_l', 'drive.profile', 'constant');
%
%   See also ride.run.
file = fullfile(ride.root(), 'config', 'default.json');
if mod(numel(varargin), 2) == 1
    file = char(varargin{1});
    varargin(1) = [];
    if ~isfile(file)
        error('ride:config:noFile', 'config file "%s" was not found', file);
    end
end
try
    cfg = jsondecode(fileread(file));
catch err
    error('ride:config:badFile', 'config file "%s" is not valid JSON: %s', file, err.message);
end
for i = 1:2:numel(varargin)
    name = varargin{i};
    if ~(ischar(name) || (isstring(name) && isscalar(name)))
        error('ride:config:badName', 'settings are overridden with name and value pairs, and argument %d is not a name', i);
    end
    cfg = set_path(cfg, strsplit(char(name), '.'), varargin{i + 1});
end
end

function s = set_path(s, parts, value)
if isscalar(parts)
    s.(parts{1}) = value;
    return
end
if ~isfield(s, parts{1}) || ~isstruct(s.(parts{1}))
    s.(parts{1}) = struct();
end
s.(parts{1}) = set_path(s.(parts{1}), parts(2:end), value);
end
