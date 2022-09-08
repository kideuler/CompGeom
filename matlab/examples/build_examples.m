function build_examples(varargin)
% building script for examples

load_examples;
% build_momp2cpp(varargin{:}); % optionally, build each dependency

files = grep_files(fullfile(sfelib_root, 'examples', '*.m'), '\n%#codegen\s+(-mex\s+)?-args');

parfor (i = 1:length(files), (1-usejava('desktop'))*ompGetMaxThreads)
    codegen_lib('-mex', '-O3', varargin{:}, files{i});
end

end
