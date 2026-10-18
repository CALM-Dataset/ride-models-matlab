function r = root()
%ROOT Folder that holds config, data, docs and src.
here = fileparts(mfilename('fullpath'));
r = fullfile(here, '..', '..');
end
