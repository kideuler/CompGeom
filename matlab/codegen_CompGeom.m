function codegen_CompGeom(varargin)
% Build script for myproj
%
%    codegen_myproj <options>
%
% Options are passed to codegen_lib.

files = grep_files('myproj/*.m', '\n%#codegen\s+(-lib\s+)?-args');

incs = myproj_includes;
if ~empty(files)
    codegen_lib('-rowmajor', '-O3', '-64', '-o', 'myproj_internal', '-namespace', 'myproj', ...
        '-post', '-headeronly', '-copyto', '../cpp/src', incs{:}, varargin{:}, files{:});
end
