function o = hf_options()
token = getenv('HF_TOKEN');
if isempty(token)
    o = weboptions('Timeout', 60);
else
    o = weboptions('Timeout', 60, 'HeaderFields', {'Authorization', ['Bearer ' token]});
end
end
