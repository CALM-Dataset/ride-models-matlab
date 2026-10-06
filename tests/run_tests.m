function run_tests()
here = fileparts(mfilename('fullpath'));
addpath(here);
addpath(fullfile(here, '..'));
test_reference();
test_equilibrium_and_scaling();
test_wk_weighting();
fprintf('all checks passed\n');
end
