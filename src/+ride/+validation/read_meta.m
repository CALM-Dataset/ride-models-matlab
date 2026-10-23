function meta = read_meta(file)
%READ_META The window times and bump position of a recorded window (meta.yaml).
if ~isfile(file)
    error('ride:validation:noFile', 'window description "%s" was not found', file);
end
text = fileread(file);
meta.source_sequence = token(text, '(?m)^source_sequence:\s*(\S+)');
meta.s_bump = number(text, '(?m)^s_bump:\s*([-\d.eE+]+)');
meta.anchor_ts = number(text, '(?m)^anchor_ts:\s*(\d+)');
meta.window_ts = [number(text, '(?m)^window:\s*\n\s+start_ts:\s*(\d+)'), number(text, '(?m)^window:\s*\n\s+start_ts:\s*\d+\s*\n\s+end_ts:\s*(\d+)')];
meta.encounter_ts = [number(text, '(?m)^encounter:\s*\n\s+start_ts:\s*(\d+)'), number(text, '(?m)^encounter:\s*\n\s+start_ts:\s*\d+\s*\n\s+end_ts:\s*(\d+)')];
meta.sb_count = number(text, '(?m)^sb_count:\s*(\d+)');
end

function value = token(text, pattern)
found = regexp(text, pattern, 'tokens', 'once');
value = '';
if ~isempty(found)
    value = found{1};
end
end

function value = number(text, pattern)
value = str2double(token(text, pattern));
end
