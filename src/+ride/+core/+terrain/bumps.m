function road = bumps(rows)
if isstruct(rows)
    rows = [[rows.start_m]', [rows.height_m]', [rows.length_m]'];
end
road = struct('type', 'bumps', 'bumps', rows);
end
