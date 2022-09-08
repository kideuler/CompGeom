function build_myproj(varargin)

disp('Building project ...');

curpath = pwd;
cleanup = onCleanup(@()cd(curpath));
cd(myproj_root);

files = [grep_files('submodule1/*.m', '\n%#codegen\s+(-mex\s+)?-args') ...
    grep_files('submodule2/*.m', '\n%#codegen\s+(-mex\s+)?-args')];

incs = myproj_includes;
parfor (i = 1:length(files), (1-usejava('desktop'))*ompGetMaxThreads)
    file = files{i};

    codegen_lib('-mex', '-O3', incs{:}, varargin{:}, file);
end

end
