function r = root()
%ROOT Folder that holds config, data, docs and src.
r = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end
