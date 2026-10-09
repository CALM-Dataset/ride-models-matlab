function run_tests()
here = fileparts(mfilename('fullpath'));
addpath(here);
addpath(fullfile(here, '..'));
test_halfcar_reference();
test_halfcar_equilibrium_and_scaling();
test_quartercar_reference();
test_quartercar_equilibrium_and_scaling();
test_wk_weighting();
fprintf('all checks passed\n');
end
