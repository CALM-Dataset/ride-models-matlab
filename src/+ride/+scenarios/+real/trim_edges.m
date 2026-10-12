function [first, last] = trim_edges(z, ds, starts, ends, tol, margin)
n = numel(z);
first = 1;
last = n;
if isempty(starts) || n == 0
    return
end
pos = (0:n - 1)' * ds;
level = abs(z) <= tol;
lo = min(starts);
hi = max(ends);
if ~level(1)
    ok = find(level & pos <= lo - margin, 1, 'first');
    if ~isempty(ok)
        first = ok;
    end
end
if ~level(end)
    ok = find(level & pos >= hi + margin, 1, 'last');
    if ~isempty(ok)
        last = ok;
    end
end
end
