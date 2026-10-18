function test_models()
names = ride.models.list();
assert(all(ismember({'halfcar', 'quartercar'}, names)), 'the built-in models must be listed');
for i = 1:numel(names)
    ride.models.validate(names{i});
    P = ride.load(names{i});
    out = ride.simulate(names{i}, P, ride.core.terrain.bumps([5 0.03 1]), 5 * ones(60, 1));
    assert(strcmp(out.model, names{i}), 'the output must name its model');
end
ride.models.register('quartercar_copy', @() ride.models.get('quartercar'));
registered = onCleanup(@() ride.models.unregister('quartercar_copy'));
assert(any(strcmp(ride.models.list(), 'quartercar_copy')), 'a registered model must be listed');
ride.models.validate('quartercar_copy');
try
    ride.models.get('no_such_model');
    failed = false;
catch
    failed = true;
end
assert(failed, 'an unknown model must be an error');
ride.models.unregister('quartercar_copy');
assert(~any(strcmp(ride.models.list(), 'quartercar_copy')), 'an unregistered model must leave the list');
end
