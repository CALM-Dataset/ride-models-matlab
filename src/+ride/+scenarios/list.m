function names = list(source)
if nargin == 0
    names = [strcat('synthetic:', ride.scenarios.synthetic.list()); ...
             strcat('real:', ride.scenarios.real.list()); ...
             strcat('registered:', keys(ride.scenarios.registry())')];
    return
end
switch source
    case 'synthetic'
        names = ride.scenarios.synthetic.list();
    case 'real'
        names = ride.scenarios.real.list();
    case 'registered'
        names = keys(ride.scenarios.registry())';
    otherwise
        error('ride:unknownSource', 'unknown scenario source "%s"', source);
end
end
