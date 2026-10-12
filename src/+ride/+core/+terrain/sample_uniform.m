function r = sample_uniform(values, ds, s)
n = numel(values);
r = zeros(size(s));
if n < 2
    return
end
pos = s / ds;
inside = pos >= 0 & pos <= n - 1;
i = min(floor(pos(inside)), n - 2);
frac = pos(inside) - i;
r(inside) = values(i + 1) .* (1 - frac) + values(i + 2) .* frac;
end
