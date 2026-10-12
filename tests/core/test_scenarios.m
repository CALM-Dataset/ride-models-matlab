function test_scenarios()
here = fileparts(mfilename('fullpath'));
fixtures = fullfile(here, '..', 'fixtures');
c = ride.scenarios.synthetic.catalog();
total = 0;
for i = 1:numel(c.suites)
    total = total + numel(c.suites(i).keys);
end
all_names = ride.scenarios.synthetic.list();
assert(numel(all_names) == total, 'every suite entry must be listed');
for i = 1:numel(all_names)
    sc = ride.scenarios.get(['synthetic:' all_names{i}]);
    rows = sc.road.bumps;
    key = regexprep(all_names{i}, '^.*/', '');
    expected = numel(strsplit(key, '_'));
    if startsWith(key, 'pothole')
        expected = 1;
    end
    assert(size(rows, 1) == expected, 'a scenario must have one road feature per code');
    assert(rows(1, 1) == c.defaults.flat_start_m, 'the first feature starts after the flat lead-in');
    assert(all(diff(rows(:, 1)) > rows(1:end - 1, 3)), 'features must not overlap');
    assert(abs(sc.speed_mps - c.defaults.speed_kmh / 3.6) < 1e-12, 'the suggested speed must follow the catalog');
end
assert(ride.scenarios.get('synthetic:hs').road.bumps(1, 2) < 0, 'an h prefix must make a hole');
assert(ride.scenarios.get('synthetic:pothole_severe').road.bumps(1, 2) < 0, 'a pothole must be below the road');
assert(isequal(ride.scenarios.get('m').road, ride.scenarios.get('synthetic:m').road), 'the synthetic source is the default');
assert(throws(@() ride.scenarios.get('synthetic:zz')), 'an unknown code must be an error');
wide = ride.scenarios.get('synthetic:s_l', 'gap_m', 50);
tight = ride.scenarios.get('synthetic:s_l', 'gap_m', 10);
assert(wide.road.bumps(2, 1) - wide.road.bumps(1, 1) > tight.road.bumps(2, 1) - tight.road.bumps(1, 1), 'the gap option must space the bumps');

sc = ride.scenarios.get(['file:' fullfile(fixtures, 'profile_example.json')]);
z = sc.road.z;
tol = 0.01;
assert(abs(z(1)) <= tol && abs(z(end)) <= tol, 'trimming must leave a level road at both ends');
assert(numel(z) < 601, 'trimming must remove the uneven ends');
assert(abs(max(z) - 0.06) < 1e-3, 'trimming must keep the bump');
row = sc.road.bumps(1, :);
centre = ride.core.terrain.height(sc.road, row(1) + row(3) / 2);
assert(abs(centre - row(2)) < 2e-3, 'the labelled bump must sit where the profile rises');
assert(row(1) >= 0 && row(1) + row(3) <= (numel(z) - 1) * sc.road.ds, 'the labelled bump must lie on the trimmed road');
untrimmed = ride.scenarios.real.parse(jsondecode(fileread(fullfile(fixtures, 'profile_example.json'))), 'trim', false);
assert(numel(untrimmed.road.z) == 601, 'trim can be switched off');

custom = ride.scenarios.get(['file:' fullfile(fixtures, 'bumps_example.json')]);
assert(strcmp(custom.name, 'two_ramps') && custom.speed_mps == 5.0, 'a custom file may name itself and suggest a speed');
assert(custom.road.bumps(2, 2) < 0, 'a custom hole must stay a hole');

ride.scenarios.register('test_ramp', @() ride.scenarios.make('test_ramp', ride.core.terrain.bumps([5 0.03 1])));
assert(strcmp(ride.scenarios.get('registered:test_ramp').name, 'test_ramp'), 'a registered scenario must be retrievable');
assert(any(strcmp(ride.scenarios.list('registered'), 'test_ramp')), 'a registered scenario must be listed');
inline = ride.scenarios.get(struct('bumps', struct('start_m', 3, 'height_m', 0.02, 'length_m', 1)));
assert(size(inline.road.bumps, 1) == 1, 'a struct with bumps is a scenario');
end

function tf = throws(fn)
tf = false;
try
    fn();
catch
    tf = true;
end
end
