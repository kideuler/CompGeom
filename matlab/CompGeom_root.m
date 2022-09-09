function rt = CompGeom_root
% root folder

persistent root__;

if isempty(root__)
    root__ = fileparts(which('CompGeom_root'));  % update filename
end

rt = root__;
end
