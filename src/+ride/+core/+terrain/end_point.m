function s = end_point(road, wheelbase)
if nargin < 2
    wheelbase = 0;
end
switch road.type
    case 'profile'
        s = (numel(road.z) - 1) * road.ds + wheelbase + 3.0;
    case 'bumps'
        if isempty(road.bumps)
            s = 0;
        else
            s = max(road.bumps(:, 1) + road.bumps(:, 3)) + wheelbase;
        end
    otherwise
        error('ride:unknownTerrain', 'unknown terrain type "%s"', road.type);
end
end
