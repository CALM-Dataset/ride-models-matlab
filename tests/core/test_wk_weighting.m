function test_wk_weighting()
dt = 0.02;
y = ride.core.comfort.wk_weight(3.0 * ones(2000, 1), dt);
assert(max(abs(y(100:1900))) < 1e-3, 'Wk must reject a constant offset');
t = (0:dt:20 - dt)';
y4 = ride.core.comfort.wk_weight(sin(2 * pi * 4 * t), dt);
y01 = ride.core.comfort.wk_weight(sin(2 * pi * 0.1 * t), dt);
assert(ride.core.comfort.rms(y4(200:end)) > 5 * ride.core.comfort.rms(y01(200:end)), ...
    'Wk must weight 4 Hz above 0.1 Hz');
end
