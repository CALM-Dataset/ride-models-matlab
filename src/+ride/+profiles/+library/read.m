function data = read(file)
%READ A speed profile file as a struct with name, dt_s and sources.<source>.v_mps.
%   data = ride.profiles.library.read(file) reads a comfort_profiles file of CALM-Germany or
%   CALM-Italy (source and samples of t_s, s_m and v_kmh) or a file with the fields dt_s and
%   sources, where each source holds v_mps.
raw = jsondecode(fileread(file));
[~, base] = fileparts(file);
if ~isfield(raw, 'samples')
    data = raw;
    if ~isfield(data, 'name')
        data.name = base;
    end
    return
end
source = base;
if isfield(raw, 'source')
    source = raw.source;
end
t = [raw.samples.t_s]';
v = [raw.samples.v_kmh]' / 3.6;
dt = 0.02;
if numel(t) > 1
    dt = round(median(diff(t)), 6);
end
data = struct('name', base, 'dt_s', dt, 'sources', struct(source, struct('v_mps', v, 'dt_s', dt)));
end
