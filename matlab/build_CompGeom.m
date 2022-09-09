function build_CompGeom(varargin)

disp('Building project ...');

curpath = pwd;
cleanup = onCleanup(@()cd(curpath));
cd(CompGeom_root);

files = [grep_files('triangulation/memory/*.m', '\n%#codegen\s+(-mex\s+)?-args') ...
            grep_files('triangulation/*.m', '\n%#codegen\s+(-mex\s+)?-args')];

incs = CompGeom_includes;
parfor (i = 1:length(files), (1-usejava('desktop'))*ompGetMaxThreads)
    file = files{i};
    codegen_lib('-mex', '-O3', incs{:}, varargin{:}, file);
end

%codegen_lib('-mex', '-O3', incs{:}, varargin{:}, 'CompGeomesh_delaunay_triangulation.m');
end
