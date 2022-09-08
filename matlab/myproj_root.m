function rt = myproj_root
% root folder

persistent root__;

if isempty(root__)
    root__ = fileparts(which('myproj_root'));  % update filename
end

rt = root__;
end
