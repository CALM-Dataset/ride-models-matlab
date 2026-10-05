function z = height(road, s)
z = zeros(size(s));
for i = 1:size(road.bumps, 1)
    x0 = road.bumps(i, 1);
    A = road.bumps(i, 2);
    L = road.bumps(i, 3);
    dx = s - x0;
    inside = dx >= 0 & dx <= L;
    z(inside) = z(inside) + (A / 2) * (1 - cos(2 * pi * dx(inside) / L));
end
end
