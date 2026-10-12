function sc = make(name, road, varargin)
sc = struct('name', name, 'description', '', 'source', '', 'speed_mps', 6.0, 'road', road, 'meta', struct());
for i = 1:2:numel(varargin)
    sc.(varargin{i}) = varargin{i + 1};
end
end
