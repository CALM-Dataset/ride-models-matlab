function road = bumps(rows)
%BUMPS A road made of raised-cosine bumps and holes.
%   road = ride.core.terrain.bumps([start_m height_m length_m; ...]) or a
%   struct array with start_m, height_m and length_m. A negative height is
%   a hole.
if isstruct(rows)
    rows = [[rows.start_m]', [rows.height_m]', [rows.length_m]'];
end
if isempty(rows)
    rows = zeros(0, 3);
end
road = struct('type', 'bumps', 'bumps', rows);
end
