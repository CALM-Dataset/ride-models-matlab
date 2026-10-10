function P = load(file)
if nargin < 1
    file = fullfile(ride.root(), 'data', 'models', 'halfcar', 'params.json');
end
P = jsondecode(fileread(file));
P.DT = P.integration.dt_s;
P.DT_SIM = P.integration.dt_sim_s;
P.N_SUB = P.integration.substeps;
P.front = ride.core.suspension.assemble(P.axles.front);
P.rear = ride.core.suspension.assemble(P.axles.rear);
P.m_tot = P.body.m_B + P.front.m_W + P.rear.m_W;
P.L = P.body.l_f + P.body.l_r;
end
