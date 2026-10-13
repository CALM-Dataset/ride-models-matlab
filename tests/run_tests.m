function run_tests()
here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..', 'src'));
addpath(genpath(here));
test_wk_weighting();
test_config();
test_models();
test_terrain();
test_scenarios();
test_profiles();
test_metrics();
test_halfcar_reference();
test_halfcar_equilibrium_and_scaling();
test_quartercar_reference();
test_quartercar_equilibrium_and_scaling();
fprintf('all checks passed\n');
end
