function k = trip_end(out, P, sc)
wheelbase = 0;
if isfield(P, 'L')
    wheelbase = P.L;
end
k = numel(out.t);
if nargin > 2 && ~isempty(sc)
    reached = find(out.s >= ride.core.terrain.end_point(sc.road, wheelbase), 1);
    if ~isempty(reached)
        k = reached;
    end
end
end
