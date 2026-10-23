function rec = load_recording(folder, varargin)
%LOAD_RECORDING Speed, distance and vertical IMU acceleration of one recorded window.
%   rec = ride.validation.load_recording(folder) reads <folder>/meta.yaml,
%   <folder>/export/wheel_excitement.json and <folder>/export/output.laz.sensor_export.json.
%
%   The human speed follows the original CALM analysis: the along-track distance of the
%   front-left wheel, interpolated onto its pose times, starting at zero, resampled every
%   20 ms and differentiated with a Savitzky-Golay filter (51 samples, order 3), negative
%   speeds set to zero. Options: 'wheel' ('FL'), 'dt' (0.02), 'window' (51), 'order' (3).
%
%   rec.t, rec.s       pose time (s, from the first pose) and distance (m, from the first pose)
%   rec.grid, rec.v    20 ms time grid and the human speed on it (m/s)
%   rec.imu_t, rec.a_z IMU time (s, same origin) and vertical acceleration with its mean removed
%   rec.wheels         the four wheel tracks (s from the first FL pose, z road height)
%   rec.meta           meta.yaml, with the anchor and encounter times in s; its s_bump is measured
%                      along the source sequence, rec.s0 is that distance at the first pose
%
%   See also ride.validation.compare.
opts = struct('wheel', 'FL', 'dt', 0.02, 'window', 51, 'order', 3);
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
if ~isfolder(folder)
    error('ride:validation:noFolder', 'recording folder "%s" was not found', folder);
end
wheels = ride.validation.read_wheel_excitement(fullfile(folder, 'export', 'wheel_excitement.json'));
imu = ride.validation.read_imu(fullfile(folder, 'export', 'output.laz.sensor_export.json'));
meta = ride.validation.read_meta(fullfile(folder, 'meta.yaml'));
if ~isfield(wheels, opts.wheel)
    error('ride:validation:noWheel', 'the recording has no wheel %s', opts.wheel);
end
lead = wheels.(opts.wheel);
ts0 = lead.pose_ts(1);
s_on_poses = interp1(lead.ts, lead.s, lead.pose_ts, 'linear', 'extrap');
s0 = s_on_poses(1);
rec.name = folder_name(folder);
rec.folder = folder;
rec.t = (lead.pose_ts - ts0) / 1e6;
rec.s = s_on_poses - s0;
rec.grid = (0:opts.dt:rec.t(end))';
s_grid = interp1(rec.t, rec.s, rec.grid);
rec.v = max(ride.validation.savgol_derivative(s_grid, opts.window, opts.order, opts.dt), 0);
rec.dt = opts.dt;
inside = imu.ts >= lead.pose_ts(1) & imu.ts <= lead.pose_ts(end);
rec.imu_t = (imu.ts(inside) - ts0) / 1e6;
rec.a_z_raw = imu.accel(inside, 3);
rec.a_z = rec.a_z_raw - mean(rec.a_z_raw);
rec.accel_mean = mean(imu.accel(inside, :), 1);
rec.imu_dt = median(diff(rec.imu_t));
rec.s0 = s0;
names = fieldnames(wheels);
for i = 1:numel(names)
    w = wheels.(names{i});
    rec.wheels.(names{i}) = struct('s', w.s - s0, 'z', w.z, 't', (w.ts - ts0) / 1e6);
end
meta.anchor_t = (meta.anchor_ts - ts0) / 1e6;
meta.encounter_t = (meta.encounter_ts - ts0) / 1e6;
meta.window_t = (meta.window_ts - ts0) / 1e6;
rec.meta = meta;
end

function name = folder_name(folder)
[~, name] = fileparts(regexprep(folder, '[\\/]+$', ''));
end
