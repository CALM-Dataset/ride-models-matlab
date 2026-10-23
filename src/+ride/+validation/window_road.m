function [road, info] = window_road(source, rec, scenario)
%WINDOW_ROAD The road in the coordinates of a recorded window.
%   [road, info] = ride.validation.window_road(source, rec, scenario) returns a terrain
%   profile whose s = 0 is the first front-left pose of the recording rec.
%   source 'scenario': the measured profile of the scenario file, shifted by meta.trim.offset_m
%   (scenario is the decoded scenario JSON). 'FL', 'FR', 'RL', 'RR': the raw excitation of one
%   wheel. 'left_right': the mean of the two front wheels. Outside the data the height is held.
%   info.offset_m is the shift applied to the scenario profile.
info = struct('offset_m', NaN);
switch source
    case 'scenario'
        z = scenario.road.z(:);
        ds = scenario.road.ds_m;
        offset = 0;
        if isfield(scenario, 'meta') && isfield(scenario.meta, 'trim')
            offset = scenario.meta.trim.offset_m;
        end
        info.offset_m = offset;
        s_profile = offset + (0:numel(z) - 1)' * ds;
    case {'FL', 'FR', 'RL', 'RR'}
        w = rec.wheels.(source);
        [s_profile, z, ds] = unique_track(w.s, w.z);
    case 'left_right'
        [s_l, z_l, ds] = unique_track(rec.wheels.FL.s, rec.wheels.FL.z);
        [s_r, z_r] = unique_track(rec.wheels.FR.s, rec.wheels.FR.z);
        s_profile = s_l;
        z = (z_l + interp1(s_r, z_r, s_l, 'linear', 'extrap')) / 2;
    otherwise
        error('ride:validation:badRoad', 'unknown road source "%s", use scenario, FL, FR, RL, RR or left_right', source);
end
length_m = max(s_profile(end), rec.s(end)) + 10;
grid = (0:ds:length_m)';
heights = interp1(s_profile, z, grid, 'linear');
heights(grid < s_profile(1)) = z(1);
heights(grid > s_profile(end)) = z(end);
road = ride.core.terrain.profile(heights, ds);
end

function [s, z, ds] = unique_track(s, z)
[s, keep] = unique(s(:));
z = z(keep);
ds = 0.05;
grid = (s(1):ds:s(end))';
z = interp1(s, z, grid);
s = grid;
end
