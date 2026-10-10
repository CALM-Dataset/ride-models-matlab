function P = load(file)
if nargin < 1
    file = fullfile(ride.root(), 'data', 'models', 'quartercar', 'params.json');
end
tree = jsondecode(fileread(file));
P = ride.core.suspension.assemble(tree.axle);
P.m_B = tree.body.m_B;
P.DT = tree.integration.dt_s;
P.DT_SIM = tree.integration.dt_sim_s;
P.N_SUB = tree.integration.substeps;
P.model = 'quartercar';
end
