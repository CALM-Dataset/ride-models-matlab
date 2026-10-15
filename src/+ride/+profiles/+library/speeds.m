function v = speeds(sc, source, dt, n, file)
if nargin > 4 && ~isempty(file)
    data = jsondecode(fileread(file));
else
    data = ride.profiles.library.load(regexprep(sc.name, '^.*/', ''));
end
if ~isfield(data.sources, source)
    error('ride:noRecordedProfile', 'the recorded profile of "%s" has no "%s" source, it has: %s', ...
        sc.name, source, strjoin(fieldnames(data.sources)', ', '));
end
recorded = data.sources.(source).v_mps(:);
t_src = (1:numel(recorded))' * data.dt_s;
t = (1:n)' * dt;
v = interp1(t_src, recorded, t, 'linear', recorded(end));
v(t < t_src(1)) = recorded(1);
end
