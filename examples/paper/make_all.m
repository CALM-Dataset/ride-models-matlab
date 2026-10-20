here = fileparts(mfilename('fullpath'));
for name = {'fig1_quarter_vs_half', 'fig2_aw_vs_speed', 'fig3_profiles', 'fig4_validation', 'fig_architecture'}
    close all
    run(fullfile(here, [name{1} '.m']));
end
