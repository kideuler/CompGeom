function load_examples
% script for loading paths to examples

addpath(fullfile(myproj_root, 'examples'));

load_dependencies('myprojeg');

end

function load_dependencies(modulename)
% The function finds the list of dependencies in the file dependencies.txt
% and then try to locate then in getenv('MODNAME_HOME'), ../.., and then
% ../../../.  If not found, it prompts the user to check out the dependency
% and run its startup automatically.

% Note: This function can be used in all numgeomworks modules.

if ~exist('dependencies.txt', 'file')
    return
end

fileID = fopen('dependencies.txt','r');
dependencies = textscan(fileID, '%s');
fclose(fileID);
dependencies = dependencies{1};

for i=1:length(dependencies)
    % Try to locate submodule in <proj>
    if exist([dependencies{i} '_root.m'], 'file'); continue; end

    module_path = {getenv([upper(dependencies{i}) '_HOME']), ...
        fullfile('..', '..', dependencies{i}), ...
        fullfile('..', '..', '..', dependencies{i})};
    found = false;
    for j=1:length(module_path)
        if exist(fullfile(module_path{j}, [dependencies{i} '_root.m']), 'file') || ...
                exist(fullfile(module_path{j}, 'matlab', [dependencies{i} '_root.m']), 'file')
            module_home = module_path{j};
            found = true;
            break;
        end
    end

    if ~found
        checkout = true;
        parentdir = '../../../';
        truedir = fileparts(fileparts(fileparts(pwd)));
        if ~strcmp(getenv('USER'), 'root')
            prompt = ['`' modulename '` depends on `' dependencies{i} '`. I can git-clone ' ...
                dependencies{i} ' into directory `' fullfile(truedir, dependencies{i}) '`. Do you want me to proceed?'];
            if usejava('desktop')
                reply = questdlg(['\fontsize{15}' prompt], ...
                    ['Check out ' dependencies{i} '?'], ...
                    struct('Default', 'Yes', 'Interpreter', 'tex'));
            else
                reply = input([prompt ' (Y|N)'], 's');
            end
            checkout = ~isempty(reply) && lower(reply(1)) == 'y';
        end

        if checkout
            try
                fprintf(1, 'Checking out %s into %s%s ... ', dependencies{i}, parentdir, dependencies{i});
                system(['git clone --recurse-submodules -q ' ...
                    'https://github.com/numgeomworks/' dependencies{i} ' ' parentdir, dependencies{i}]);
                module_home = fullfile(parentdir, dependencies{i});
                fprintf(1, 'Done\n');
            catch
                continue;
            end
        else
            fprintf(2, ['You rejected cloning module %s. Please clone it ' ...
                'using the git command\n %s\n and then run its startup script manually.\n'], ...
                dependencies{i}, ['git clone --recurse-submodules -q ' ...
                'https://github.com/numgeomworks/' dependencies{i}]);
            continue;
        end
    end

    if exist(fullfile(module_home , [dependencies{i} '_root.m']), 'file')
        run(fullfile(module_home, 'startup.m'));
    elseif exist(fullfile(module_home, 'matlab', [dependencies{i} '_root.m']), 'file')
        run(fullfile(module_home, 'matlab', 'startup.m'));
    end
end

end
