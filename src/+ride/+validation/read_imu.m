function imu = read_imu(file)
%READ_IMU Read the IMU records of export/output.laz.sensor_export.json.
%   imu = ride.validation.read_imu(file) returns ts (us), accel (n x 3, m/s^2, x y z) and
%   gyro (n x 3, rad/s), sorted by time.
if ~isfile(file)
    error('ride:validation:noFile', 'sensor export "%s" was not found', file);
end
data = jsondecode(fileread(file));
if ~isfield(data, 'imu') || isempty(data.imu)
    error('ride:validation:badFile', '"%s" holds no imu records', file);
end
records = data.imu;
if iscell(records)
    records = [records{:}];
end
ts = double([records.timestamp]');
[ts, order] = sort(ts);
accel = [[records.accel_x]', [records.accel_y]', [records.accel_z]'];
gyro = [[records.gyro_x]', [records.gyro_y]', [records.gyro_z]'];
imu = struct('ts', ts, 'accel', accel(order, :), 'gyro', gyro(order, :));
end
