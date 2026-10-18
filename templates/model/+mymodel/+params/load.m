function P = load()
base = ride.models.quartercar.params.load();
P = struct('m_B', base.m_B, 'm_W', base.m_W, 'k_S', base.k_S, 'c_S', base.D, 'k_T', base.k_T, 'c_T', base.c_T, ...
    'DT', base.DT, 'DT_SIM', base.DT_SIM, 'N_SUB', base.N_SUB);
end
