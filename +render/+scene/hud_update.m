function hud_update(h, values)
for i = 1:numel(values)
    set(h.values(i), 'String', values{i});
end
end
