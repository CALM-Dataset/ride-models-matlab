function v = human(profile, dt, n, sc)
if ~isfield(profile, 'file') || isempty(profile.file)
    error('ride:noRecordedProfile', ['the human type needs a profile file with a "human" source in the "file" field; ', ...
        'the datasets on Hugging Face have no recorded human speeds']);
end
v = ride.profiles.library.speeds(sc, 'human', dt, n, profile.file);
end
