function P = load(model)
switch model
    case 'halfcar'
        P = halfcar.params.load();
    case 'quartercar'
        P = quartercar.params.load();
    otherwise
        error('ride:unknownModel', 'unknown model "%s", use halfcar or quartercar', model);
end
end
