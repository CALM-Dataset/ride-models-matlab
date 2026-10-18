function test_metrics()
sc = ride.scenarios.get('synthetic:m');
for model = ride.models.list()
    P = ride.load(model{1});
    n_short = round(12 / P.DT);
    n_long = round(20 / P.DT);
    a = ride.simulate(model{1}, P, sc.road, sc.speed_mps * ones(n_short, 1));
    b = ride.simulate(model{1}, P, sc.road, sc.speed_mps * ones(n_long, 1));
    ma = ride.metrics.evaluate(a, P, sc, {'a_w', 'vdv', 'peak_acc', 'travel_time', 'mean_speed'});
    mb = ride.metrics.evaluate(b, P, sc, {'a_w', 'vdv', 'peak_acc', 'travel_time', 'mean_speed'});
    assert(abs(ma.a_w - mb.a_w) < 1e-9 && abs(ma.travel_time - mb.travel_time) < 1e-9, 'metrics must stop at the end of the trip');
    wheelbase = 0;
    if isfield(P, 'L')
        wheelbase = P.L;
    end
    expected_time = ride.core.terrain.end_point(sc.road, wheelbase) / sc.speed_mps;
    assert(abs(ma.travel_time - expected_time) < 2 * P.DT, 'the travel time must follow distance over speed');
    assert(abs(ma.mean_speed - sc.speed_mps) < 0.05, 'the mean speed of a constant drive must be its speed');
    assert(ma.a_w > 0 && ma.vdv > 0 && ma.peak_acc > 0, 'a bump must register in every comfort metric');
end
everything = ride.metrics.evaluate(a, P, sc, ride.metrics.list());
assert(isfield(everything, 'a_w'), 'every listed metric must evaluate');
ride.metrics.register('twice_peak', @(out, P, sc) 2 * max(abs(out.z_B_ddot)));
registered = onCleanup(@() ride.metrics.unregister('twice_peak'));
mine = ride.metrics.evaluate(a, P, sc, {'twice_peak', 'peak_acc'});
assert(abs(mine.twice_peak - 2 * mine.peak_acc) < 1e-12, 'a registered metric must run beside the built-ins');
try
    ride.metrics.evaluate(a, P, sc, {'no_such_metric'});
    failed = false;
catch
    failed = true;
end
assert(failed, 'an unknown metric must be an error');
end
