function v = speeds(sc, source, dt, n, file)
if nargin > 4 && ~isempty(file)
    if ~isfile(file)
        error('ride:noRecordedProfile', 'recorded profile file "%s" was not found', file);
    end
    data = jsondecode(fileread(file));
elseif isempty(sc) || ~strcmp(sc.source, 'real')
    error('ride:noRecordedProfile', ['recorded "%s" speeds exist only for the measured real: scenarios. ', ...
        'For other roads give a profile file in the "file" field.'], source);
else
    data = ride.profiles.library.load(regexprep(sc.name, '^.*/', ''));
end
if ~isfield(data, 'name')
    data.name = 'recorded';
end
if ~isfield(data, 'sources') || ~isfield(data, 'dt_s')
    error('ride:noRecordedProfile', 'the recorded profile "%s" needs "dt_s" and "sources" fields', data.name);
end
if ~isfield(data.sources, source)
    error('ride:noRecordedProfile', 'the recorded profile "%s" has no "%s" source, it has: %s', ...
        data.name, source, strjoin(fieldnames(data.sources)', ', '));
end
recorded = data.sources.(source).v_mps(:);
t_src = (1:numel(recorded))' * data.dt_s;
t = (1:n)' * dt;
v = interp1(t_src, recorded, t, 'linear', recorded(end));
v(t < t_src(1)) = recorded(1);
end
