function P = load(model)
switch model
    case 'halfcar'
        P = ride.models.halfcar.params.load();
    case 'quartercar'
        P = ride.models.quartercar.params.load();
    otherwise
        error('ride:unknownModel', 'unknown model "%s", use halfcar or quartercar', model);
end
end
