classdef RideModelsTest < matlab.unittest.TestCase

    methods (TestClassSetup)
        function addPaths(~)
            here = fileparts(mfilename('fullpath'));
            root = fileparts(here);
            addpath(fullfile(root, 'src'), fullfile(root, 'simulink'));
            addpath(fullfile(here, 'core'), fullfile(here, 'models'));
        end
    end

    methods (Test)
        function versionMatchesCitation(~)
            test_version();
        end

        function wkWeighting(~)
            test_wk_weighting();
        end

        function config(~)
            test_config();
        end

        function modelRegistry(~)
            test_models();
        end

        function terrain(~)
            test_terrain();
        end

        function scenarios(~)
            test_scenarios();
        end

        function profiles(~)
            test_profiles();
        end

        function metrics(~)
            test_metrics();
        end

        function extensions(~)
            test_extensions();
        end

        function realDataValidation(~)
            test_validation();
        end

        function halfcarReference(~)
            test_halfcar_reference();
        end

        function halfcarEquilibriumAndScaling(~)
            test_halfcar_equilibrium_and_scaling();
        end

        function quartercarReference(~)
            test_quartercar_reference();
        end

        function quartercarEquilibriumAndScaling(~)
            test_quartercar_equilibrium_and_scaling();
        end

        function quartercarSimulink(tc)
            tc.assumeTrue(has_simulink(), 'Simulink is not installed');
            test_quartercar_simulink();
        end

        function halfcarSimulink(tc)
            tc.assumeTrue(has_simulink(), 'Simulink is not installed');
            test_halfcar_simulink();
        end
    end
end

function tf = has_simulink()
tf = ~isempty(ver('simulink')) && license('test', 'Simulink');
end
