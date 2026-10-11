function mdl = build_quartercar(P, road, speeds)
mdl = 'quartercar_model';
if bdIsLoaded(mdl)
    close_system(mdl, 0);
end
new_system(mdl);
open_system(mdl);
n = numel(speeds);
assignin('base', 'zdot_ts', road_velocity_input(P, road, speeds));

set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'ode4', 'FixedStep', num2str(P.DT_SIM), ...
    'StopTime', num2str(n * P.DT));

add_block('simulink/Sources/From Workspace', [mdl '/road_velocity'], 'VariableName', 'zdot_ts', ...
    'Interpolate', 'on', 'OutputAfterFinalValue', 'Holding final value', 'Position', [40 150 140 190]);

dyn = [mdl '/dynamics'];
add_block('simulink/User-Defined Functions/MATLAB Function', dyn, 'Position', [220 100 380 220]);
chart = find(sfroot, '-isa', 'Stateflow.EMChart', 'Path', dyn);
chart.Script = dynamics_script(P);

add_block('simulink/Continuous/Integrator', [mdl '/states'], 'InitialCondition', '[0;0;0;0;0]', ...
    'Position', [460 110 500 150]);
add_block('simulink/Sinks/To Workspace', [mdl '/body_acceleration'], 'VariableName', 'acc_out', ...
    'SaveFormat', 'Array', 'SampleTime', num2str(P.DT), 'Position', [460 190 560 220]);
add_block('simulink/Sinks/To Workspace', [mdl '/state_log'], 'VariableName', 'state_out', ...
    'SaveFormat', 'Array', 'SampleTime', num2str(P.DT), 'Position', [560 110 660 140]);
add_block('simulink/Sinks/Scope', [mdl '/scope'], 'NumInputPorts', '1', 'Position', [600 190 640 220]);

add_line(mdl, 'road_velocity/1', 'dynamics/2');
add_line(mdl, 'states/1', 'dynamics/1');
add_line(mdl, 'dynamics/1', 'states/1');
add_line(mdl, 'dynamics/2', 'body_acceleration/1');
add_line(mdl, 'dynamics/2', 'scope/1');
add_line(mdl, 'states/1', 'state_log/1');
end

function code = dynamics_script(P)
names = {'m_B', 'm_W', 'k_T', 'c_T', 'k_S', 'dz_S_stat', 'dz_cmp', 'dz_rbd', 'f1_cmp', 'f2_cmp', ...
    'f1_rbd', 'f2_rbd', 'F_max', 'd1', 'z1', 'd2', 'z2', 'v_d', 'v_z'};
lines = cell(numel(names), 1);
for i = 1:numel(names)
    lines{i} = sprintf('%s = %.17g;', names{i}, P.(names{i}));
end
body = {
    'F_spring = k_S * x(3) + spring_nonlin(x(3), k_S, dz_S_stat, dz_cmp, dz_rbd, f1_cmp, f2_cmp, f1_rbd, f2_rbd, F_max);'
    'F_damp = damper(x(2) - x(4), d1, z1, d2, z2, v_d, v_z);'
    'F_tyre = k_T * x(1) + c_T * (zdot - x(2));'
    'dx = zeros(5, 1);'
    'dx(1) = zdot - x(2);'
    'dx(2) = (-F_spring - F_damp + F_tyre) / m_W;'
    'dx(3) = x(2) - x(4);'
    'dx(4) = (F_spring + F_damp) / m_B;'
    'dx(5) = x(4);'
    'acc = dx(4);'
    'end'
    ''
    'function F = spring_nonlin(dyn, k_S, dz_S_stat, dz_cmp, dz_rbd, f1_cmp, f2_cmp, f1_rbd, f2_rbd, F_max)'
    'if dyn > dz_cmp'
    '    dz_F = dyn - dz_cmp;'
    '    F = k_S * (dz_S_stat * f1_cmp * (exp(dz_F * f2_cmp / dz_S_stat) - 1) - dz_F);'
    'elseif dyn < -dz_rbd'
    '    dz_F = -dyn - dz_rbd;'
    '    F = -k_S * (dz_S_stat * f1_rbd * (exp(dz_F * f2_rbd / dz_S_stat) - 1) - dz_F);'
    'else'
    '    F = 0;'
    '    return'
    'end'
    'F = min(max(F, -F_max), F_max);'
    'end'
    ''
    'function F = damper(v_S, d1, z1, d2, z2, v_d, v_z)'
    'k = 50;'
    'w_cmp = 1 / (1 + exp(-k * v_S));'
    'F_base = (w_cmp * d1 + (1 - w_cmp) * z1) * v_S;'
    'w_hc = 1 / (1 + exp(-k * (v_S - v_d)));'
    'F_hc = w_hc * (d2 - d1) * (v_S - v_d);'
    'w_hr = 1 / (1 + exp(-k * (-v_S - v_z)));'
    'F_hr = w_hr * (z2 - z1) * (-v_S - v_z);'
    'F = F_base + F_hc - F_hr;'
    'end'
};
code = strjoin([{'function [dx, acc] = dynamics(x, zdot)'}; lines; body], newline);
end
