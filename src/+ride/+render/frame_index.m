function k = frame_index(r, when)
%FRAME_INDEX Step of a run at a time in seconds, or "bump" for the first bump.
if ischar(when) || isstring(when)
    switch char(when)
        case 'bump'
            if isempty(r.road.bumps)
                k = round(numel(r.out.t) / 2);
            else
                k = find(r.out.s >= min(r.road.bumps(:, 1)), 1);
            end
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
