function P = load(file)
if nargin < 1
    here = fileparts(mfilename('fullpath'));
    file = fullfile(here, '..', '..', 'data', 'quartercar', 'params.json');
end
P = jsondecode(fileread(file));
P.model = 'quartercar';
end
