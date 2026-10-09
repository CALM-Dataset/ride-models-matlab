function out = simulate(model, P, road, speeds)
switch model
    case 'halfcar'
        out = halfcar.sim.simulate(P, road, speeds);
    case 'quartercar'
        out = quartercar.sim.simulate(P, road, speeds);
    otherwise
        error('ride:unknownModel', 'unknown model "%s", use halfcar or quartercar', model);
end
end
