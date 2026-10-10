function p = assemble(node)
p = struct();
for group = {'tyre', 'spring', 'damper'}
    values = node.(group{1});
    names = fieldnames(values);
    for j = 1:numel(names)
        p.(names{j}) = values.(names{j});
    end
end
p.m_W = node.wheel_mass;
c = ride.core.suspension.damper_coefficients(p.D, p.A);
p.d1 = c.d1;
p.z1 = c.z1;
p.d2 = c.d2;
p.z2 = c.z2;
end
