function testall(varargin)
%TESTALL  Test uncompiled and compiled versions of files
%
%  testall [file1] [file2] ...
%
%  It will test a list of files. Without any argument, it will
%  test all the MATLAB files with a built-in test block.

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
    [srcdir, file] = fileparts(files{i});
    if ~isempty(srcdir); cd(srcdir); end
    mtest(files{i});

    if ~isempty(grep_files(which([file '.m']), '\n%#codegen\s+(-mex\s+)?-args'))
        backup = exist([file '.' mexext], 'file');
        if backup; movefile([file '.' mexext], [file '.' mexext '.bak']); end

        fprintf(1, 'Testing compiled %s in column-major:\n', files{i});
        codegen_lib('-rowmajor', '-mex', '-64', '-force', '-checking', '-no-report', incs{:}, file);
        mtest(file);
        delete([files{i}(1:end-2) '.' mexext]);
        if backup; movefile([file '.' mexext '.bak'], [file '.' mexext]); end
    end
end

end
