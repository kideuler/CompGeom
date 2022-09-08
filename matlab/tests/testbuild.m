function testbuild(varargin)
% testbuild Test compiled versions of files
%
%  testbuild [file1] [file2] ...
%
%  It will test a list of files. Without any argument, it will test
%  all the MATLAB files with a built-in test block.

curdir = pwd;
cleanup = onCleanup(@()cd(curdir));
cd(myproj_root);

if isempty(varargin)
    files = [grep_files('submodule1/**/*.m', '\n%!test') ...
        grep_files('submodule2/**/*.m', '\n%!test')];
else
    files = varargin;
end

incs = myproj_includes;
for i = 1:length(files)
    fprintf(1, 'Testing %s:\n', files{i});
    [srcdir,file] = fileparts(files{i});
    if ~isempty(srcdir); cd(srcdir); end
    mtest(files{i});

    if ~exist([file '.' mexext], 'file') && ...
        ~isempty(grep_files(which([file '.m']), '\n%#codegen\s+(-mex\s+)?-args'))

        codegen_lib('-mex', '-64', '-g', incs{:}, files{i});
        mtest(files{i});
        delete([files{i}(1:end-2) '.' mexext]);
    end
end

end
