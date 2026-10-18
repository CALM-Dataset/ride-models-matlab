function test_extensions()
root = ride.root();
work = tempname;
target = fullfile(work, '+ride', '+models', '+template_check');
mkdir(fileparts(target));
copyfile(fullfile(root, 'templates', 'model', '+mymodel'), target);
addpath(work);
cleanup = onCleanup(@() remove_folder(work));
assert(any(strcmp(ride.models.list(), 'template_check')), 'a model folder on the path must be found without registering it');
ride.models.validate('template_check', 'draw', true);
r = ride.run(ride.config('model', 'template_check', 'drive.profile', 'constant'));
assert(r.metrics.a_w > 0, 'the template model must ride over the bump');

examples = fullfile(root, 'examples', 'extend');
evalc('run(fullfile(examples, ''add_scenario_source.m''))');
evalc('run(fullfile(examples, ''add_speed_profile.m''))');
evalc('run(fullfile(examples, ''add_metric.m''))');
registered = onCleanup(@() unregister_examples());
assert(any(strcmp(ride.scenarios.list('registered'), 'csv_road')), 'the scenario source example must register its road');
assert(any(strcmp(ride.profiles.list(), 'creep')), 'the profile example must register its type');
assert(any(strcmp(ride.metrics.list(), 'peak_jerk')), 'the metric example must register its metric');
cfg = ride.config('model', 'quartercar', 'scenario', 'registered:csv_road', 'metrics', {'a_w', 'peak_jerk'});
cfg.profiles.creep = struct('type', 'creep', 'cruise_mps', 8, 'creep_mps', 3, 'margin_m', 5);
cfg.drive.profile = 'creep';
r = ride.run(cfg);
assert(min(r.speeds) == 3 && r.metrics.peak_jerk > 0, 'registered plug-ins must work together in one run');
end

function remove_folder(work)
rmpath(work);
rmdir(work, 's');
end

function unregister_examples()
ride.scenarios.unregister('csv_road');
ride.profiles.unregister('creep');
ride.metrics.unregister('peak_jerk');
end
