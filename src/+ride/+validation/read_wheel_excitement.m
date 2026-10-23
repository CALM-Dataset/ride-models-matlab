function wheels = read_wheel_excitement(file)
%READ_WHEEL_EXCITEMENT Read export/wheel_excitement.json of a recorded window.
%   wheels = ride.validation.read_wheel_excitement(file) returns a struct with one field per
%   wheel (FL, FR, RL, RR). Each holds pose_ts (us), pose_xyz (m), and the excitation table:
%   ts (us), s (m, along-track distance) and z (m, road height under the wheel).
if ~isfile(file)
    error('ride:validation:noFile', 'wheel excitation file "%s" was not found', file);
end
text = fileread(file);
names = regexp(text, '"cariad_wheel_(\w\w)"', 'tokens');
names = unique(cellfun(@(c) c{1}, names, 'UniformOutput', false), 'stable');
if isempty(names)
    error('ride:validation:badFile', '"%s" holds no cariad_wheel_* entries', file);
end
wheels = struct();
for i = 1:numel(names)
    start = strfind(text, ['"cariad_wheel_' names{i} '"']);
    block = text(start(1):end);
    poses = numbers_of(block, '"poses"', 8);
    table = numbers_of(block, '"wheel_excitement"', 4);
    wheels.(names{i}) = struct('pose_ts', poses(:, 1), 'pose_xyz', poses(:, 2:4), ...
        'ts', table(:, 1), 's', table(:, 3), 'z', table(:, 4));
end
end

function values = numbers_of(block, key, per_row)
at = strfind(block, key);
if isempty(at)
    error('ride:validation:badFile', 'wheel excitation block has no %s', key);
end
rest = block(at(1) + numel(key):end);
open = find(rest == '[', 1);
depth = cumsum((rest == '[') - (rest == ']'));
depth(1:open - 1) = 1;
close = find(depth == 0, 1);
inner = rest(open:close);
inner(inner == '[' | inner == ']' | inner == ',') = ' ';
values = sscanf(inner, '%f');
if mod(numel(values), per_row) ~= 0
    error('ride:validation:badFile', '%s does not hold rows of %d numbers', key, per_row);
end
values = reshape(values, per_row, [])';
end
