function zd = height_dot(road, s, v)
zd = 0;
for i = 1:size(road.bumps, 1)
    x0 = road.bumps(i, 1);
    A = road.bumps(i, 2);
    L = road.bumps(i, 3);
    dx = s - x0;
    if dx > 0 && dx < L
        zd = (A / 2) * (2 * pi / L) * sin(2 * pi * dx / L) * v;
        return
    end
end
end
