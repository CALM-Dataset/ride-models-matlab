function c = catalog()
persistent data
if isempty(data)
    data = jsondecode(fileread(fullfile(ride.root(), 'data', 'scenarios', 'synthetic.json')));
end
c = data;
end
