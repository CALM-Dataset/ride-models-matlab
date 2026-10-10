function out = simulate(model, P, road, speeds)
switch model
    case 'halfcar'
        out = ride.models.halfcar.sim.simulate(P, road, speeds);
    case 'quartercar'
        out = ride.models.quartercar.sim.simulate(P, road, speeds);
    otherwise
        error('ride:unknownModel', 'unknown model "%s", use halfcar or quartercar', model);
end
end
