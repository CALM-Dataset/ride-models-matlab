function c = compare(rec, scenario, varargin)
%COMPARE Simulated against measured vertical acceleration for one recorded window.
%   c = ride.validation.compare(rec, scenario) replays the human speed of the recording rec
%   (from ride.validation.load_recording) over the road of the scenario (the decoded
%   scenario JSON, or its file name) with the calibrated half-car and compares:
%     a_w_measured   ISO 2631-1 Wk-weighted RMS of the IMU vertical acceleration over the window
%     a_w_simulated  the same for the simulated body acceleration over the same time
%     error          (a_w_simulated - a_w_measured) / a_w_measured
%   and, in the time domain, both signals low-pass filtered at 'lowpass_hz' (10 Hz):
%     lag_s          delay that makes the simulated trace match the IMU best (positive: the
%                    measured response comes later than the simulated one), within 'max_lag_s' (0.5 s)
%     correlation    correlation of the two traces around the bump after the shift
%     peak_ratio     simulated over measured peak-to-peak acceleration around the bump
%   and the weighted RMS near the bump (from 0.5 s before the front axle reaches it to 1.5 s
%   after the rear axle leaves it) and away from it: a_w_measured_near, a_w_simulated_near,
%   a_w_measured_away, a_w_simulated_away.
%   Options: 'model' ('halfcar'), 'P' (parameters, default ride.load(model)), 'road'
%   ('scenario', 'FL', 'left_right', ...; see ride.validation.window_road), 'offset_m' (shift
%   of the scenario road, default meta.trim.offset_m of the scenario; 0 reproduces the original
%   CALM replay), 'speed_at' ('start': step k runs at the speed at the start of the step, as
%   in the original replay; 'end': at its end).
%
%   See also ride.validation.load_recording.
opts = struct('model', 'halfcar', 'P', [], 'road', 'scenario', 'offset_m', [], 'speed_at', 'start', ...
    'lowpass_hz', 10, 'max_lag_s', 0.5);
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i + 1};
end
if ischar(scenario) || isstring(scenario)
    scenario = jsondecode(fileread(scenario));
end
P = opts.P;
if isempty(P)
    P = ride.load(opts.model);
end
if ~isempty(opts.offset_m)
    scenario.meta.trim.offset_m = opts.offset_m;
end
[road, info] = ride.validation.window_road(opts.road, rec, scenario);
if strcmp(opts.speed_at, 'end')
    speeds = rec.v(2:end);
else
    speeds = rec.v(1:end - 1);
end
out = ride.simulate(opts.model, P, road, speeds);
c.name = rec.name;
c.road = opts.road;
c.offset_m = info.offset_m;
c.t = out.t;
c.s = out.s;
c.v = out.v;
c.z_B_ddot = out.z_B_ddot;
c.imu_t = rec.imu_t;
c.a_z = rec.a_z;
c.a_w_measured = ride.core.comfort.a_w(rec.a_z, rec.imu_dt);
c.a_w_simulated = ride.core.comfort.a_w(out.z_B_ddot, P.DT);
c.error = (c.a_w_simulated - c.a_w_measured) / c.a_w_measured;
[c.bump_s, c.bump_t] = bump_crossing(scenario, info.offset_m, out, P);
measured = lowpass(rec.a_z, rec.imu_dt, opts.lowpass_hz);
measured = interp1(rec.imu_t, measured, out.t, 'linear', 0);
simulated = lowpass(out.z_B_ddot, P.DT, opts.lowpass_hz);
c.measured_lp = measured;
c.simulated_lp = simulated;
c.lag_s = best_lag(measured, simulated, P.DT, opts.max_lag_s);
c.lag_at_limit = abs(c.lag_s) >= opts.max_lag_s - P.DT / 2;
shifted = interp1(out.t + c.lag_s, simulated, out.t, 'linear', 0);
c.simulated_shifted = shifted;
around = out.t >= c.bump_t(1) - 0.5 & out.t <= c.bump_t(2) + 1.5;
if nnz(around) < 10
    around = true(size(out.t));
end
c.around = around;
r = corrcoef(measured(around), shifted(around));
c.correlation = r(1, 2);
c.peak_ratio = (max(shifted(around)) - min(shifted(around))) / (max(measured(around)) - min(measured(around)));
weighted_measured = ride.core.comfort.wk_weight(rec.a_z, rec.imu_dt);
weighted_simulated = ride.core.comfort.wk_weight(out.z_B_ddot, P.DT);
near_measured = rec.imu_t >= c.bump_t(1) - 0.5 & rec.imu_t <= c.bump_t(2) + 1.5;
near_simulated = out.t >= c.bump_t(1) - 0.5 & out.t <= c.bump_t(2) + 1.5;
c.a_w_measured_near = ride.core.comfort.rms(weighted_measured(near_measured));
c.a_w_simulated_near = ride.core.comfort.rms(weighted_simulated(near_simulated));
c.a_w_measured_away = ride.core.comfort.rms(weighted_measured(~near_measured));
c.a_w_simulated_away = ride.core.comfort.rms(weighted_simulated(~near_simulated));
c.anchor_gap_m = interp1(rec.t, rec.s, rec.meta.anchor_t, 'linear', NaN) + rec.s0 - rec.meta.s_bump;
end

function [bump_s, bump_t] = bump_crossing(scenario, offset, out, P)
bump_s = [NaN NaN];
bump_t = [out.t(1) out.t(end)];
if ~isfield(scenario, 'bumps') || isempty(scenario.bumps) || isnan(offset)
    return
end
b = scenario.bumps(1);
wheelbase = 0;
if isfield(P, 'L')
    wheelbase = P.L;
end
bump_s = offset + [b.s_start_m, b.s_end_m];
enter = find(out.s >= bump_s(1), 1);
leave = find(out.s >= bump_s(2) + wheelbase, 1);
if isempty(enter)
    return
end
if isempty(leave)
    leave = numel(out.t);
end
bump_t = [out.t(enter), out.t(leave)];
end

function y = lowpass(x, dt, cutoff)
[b, a] = butter(4, cutoff / (0.5 / dt));
y = filtfilt(b, a, x(:));
end

function lag = best_lag(measured, simulated, dt, max_lag)
steps = round(max_lag / dt);
best = -Inf;
lag = 0;
for k = -steps:steps
    if k >= 0
        a = measured(1 + k:end);
        b = simulated(1:end - k);
    else
        a = measured(1:end + k);
        b = simulated(1 - k:end);
    end
    score = (a' * b) / max(norm(a) * norm(b), eps);
    if score > best
        best = score;
        lag = k * dt;
    end
end
end
