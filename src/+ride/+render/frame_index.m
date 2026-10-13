function k = frame_index(r, when)
if ischar(when) || isstring(when)
    switch char(when)
        case 'bump'
            k = find(r.out.s >= min(r.road.bumps(:, 1)), 1);
        otherwise
            error('ride:badFrame', 'unknown frame moment "%s", use a time in seconds or "bump"', char(when));
    end
else
    k = find(r.out.t >= when, 1);
end
if isempty(k)
    k = numel(r.out.t);
end
end
