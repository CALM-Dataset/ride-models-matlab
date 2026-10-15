function v = reactive(profile, dt, n, sc)
p = struct('speed_mps', 'scenario', 'v_min_mps', 8 / 3.6, 'preview_m', 40.0, 'steep_full_slow', 0.05, ...
    'hole_severity', 0.6, 'brake_margin', 3.0, 'a_brake', 2.5, 'a_accel', 2.0);
for name = fieldnames(p)'
    if isfield(profile, name{1})
        p.(name{1}) = profile.(name{1});
    end
end
v_max = p.speed_mps;
if ischar(v_max) || isstring(v_max)
    v_max = sc.speed_mps;
end
bumps = sc.road.bumps;
v = zeros(n, 1);
speed = v_max;
s = 0;
for k = 1:n
    a = decide(speed, s, bumps, v_max, p);
    speed = min(max(speed + a * dt, p.v_min_mps), v_max);
    s = s + speed * dt;
    v(k) = speed;
end
end

function a = decide(speed, s, bumps, v_max, p)
need_brake = false;
on_bump = false;
for i = 1:size(bumps, 1)
    x0 = bumps(i, 1);
    height = bumps(i, 2);
    length = bumps(i, 3);
    if s >= x0 + length
        continue
    end
    v_cross = crossing_speed(height, length, v_max, p);
    if s >= x0
        on_bump = true;
        if speed > v_cross
            need_brake = true;
        end
        continue
    end
    d = x0 - s;
    if d > p.preview_m || speed <= v_cross
        continue
    end
    d_brake = (speed ^ 2 - v_cross ^ 2) / (2 * p.a_brake);
    if d <= d_brake + p.brake_margin
        need_brake = true;
    end
end
if need_brake
    a = -p.a_brake;
elseif on_bump
    a = 0;
elseif speed < v_max
    a = p.a_accel;
else
    a = 0;
end
end

function v_cross = crossing_speed(height, length, v_max, p)
severity = abs(height) / max(length, 1e-6) / max(p.steep_full_slow, 1e-6);
if height < 0
    severity = max(severity, p.hole_severity);
end
severity = min(max(severity, 0), 1);
v_cross = v_max - severity * (v_max - p.v_min_mps);
end
