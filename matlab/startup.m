function startup
% startup script

update_module('CompGeom', fileparts(CompGeom_root));

addpath(CompGeom_root);  % update name here
addpath(fullfile(CompGeom_root, 'triangulation'));
addpath(fullfile(CompGeom_root, 'triangulation/memory'));

if exist(fullfile('..', '.gitmodule'), 'file') && ...
    ~exist(fullfile('..', 'cpp', 'src'), 'dir')
    % Checkout the submodule if not present
    system('git submodule update --init');
end

% Update module name here and also ../dependencies.txt
load_dependencies('CompGeom');
end

function load_dependencies(modulename)
% The function finds the list of dependencies in the file ../dependencies.txt
% and then try to locate then in getenv('MODNAME_HOME'), ../, and then ../../.
% If not found, it prompts the user to check out the dependency and run its
% startup automatically.

% Note: This function can be used in all numgeomworks modules.

if ~exist('../dependencies.txt', 'file')
    return
end

fileID = fopen('../dependencies.txt','r');
dependencies = textscan(fileID, '%s');
fclose(fileID);
dependencies = dependencies{1};

for i=1:length(dependencies)
    module = dependencies{i};
    % Try to locate submodule in <proj>
    if exist([module '_root.m'], 'file') && ...
            ~update_module(module, eval([module '_root']))
        continue;
    end

    module_path = {getenv([upper(module) '_HOME']), ...
        fullfile('..', module), ...
        fullfile('..', '..', module)};
    found = false;
    for j=1:length(module_path)
        if exist(fullfile(module_path{j}, [module '_root.m']), 'file') || ...
                exist(fullfile(module_path{j}, 'matlab', [module '_root.m']), 'file')
            module_home = module_path{j};
            found = true;
            break;
        end
    end

    if ~found
        checkout = true;
        parentdir = '../../';
        truedir = fileparts(fileparts(pwd));
        if ~strcmp(getenv('USER'), 'root')
            prompt = ['`' modulename '` depends on `' module '`. I can git-clone ' ...
                module ' into directory `' fullfile(truedir, module) '`. Do you want me to proceed?'];
            if usejava('desktop')
                reply = questdlg(['\fontsize{15}' prompt], ...
                    ['Check out ' module '?'], ...
                    struct('Default', 'Yes', 'Interpreter', 'tex'));
            else
                reply = input([prompt ' (Y|N)'], 's');
            end
            checkout = ~isempty(reply) && lower(reply(1)) == 'y';
        end

        if checkout
            fprintf(1, 'Checking out %s into %s%s ... ', module, parentdir, module);
            [status, result] = system(['git clone --recurse-submodules -q ' ...
                'https://github.com/numgeomworks/' module ' ' parentdir, module]);
            if status
                fprintf(2, 'Failed to Check out %s with error message:\n%s', module, result);
                continue;
            else
                module_home = fullfile(parentdir, module);
                fprintf(1, ['Done. You may want to run build_' module ' to compile its time-consuming functions.\n']);
            end
        else
            fprintf(2, ['You rejected cloning module %s. Please clone it ' ...
                'using the git command\n %s\n and then run its startup script manually.\n'], ...
                module, ['git clone --recurse-submodules -q ' ...
                'https://github.com/numgeomworks/' module]);
            continue;
        end
    end

    if exist(fullfile(module_home , [module '_root.m']), 'file')
        run(fullfile(module_home, 'startup.m'));
    elseif exist(fullfile(module_home, 'matlab', [module '_root.m']), 'file')
        run(fullfile(module_home, 'matlab', 'startup.m'));
    end
end

end

function update = update_module(module, dir)

olddir = pwd;
cd(dir);
cleanup = onCleanup(@()cd(olddir));

update = [];
[~,result] = system('git status');
if ~strcmp(getenv('USER'), 'root') && ...
        contains(result, 'Your branch is behind ''origin/')
    msg = regexp(result, ' is behind [^\n]+', 'match', 'once');
    prompt = [module msg ' Do you want to update it?'];
    if usejava('desktop')
        reply = questdlg(['\fontsize{15}' prompt], ...
            ['Update ' module '?'], ...
            struct('Default', 'Yes', 'Interpreter', 'tex'));
    else
        reply = input([prompt ' (Y|N)'], 's');
    end
    update = ~isempty(reply) && lower(reply(1)) == 'y';
end

if update
    fprintf(1, 'Updating %s in %s ... ', module, dir);
    [status, result] = system('git pull --recurse-submodules');
    if status
        fprintf(2, 'Failed to update %s with error message:\n%s', module, result);
        update = false;
    else
        fprintf(1, ['Done. Don''t forget to rebuild ' module ' if you built it previously. ' ...
            'You may need to delete old MEX files manually if some MATLAB files were moved to new directories.\n']);
    end
elseif ~isempty(update)
    fprintf(2, ['You rejected updating module %s. You can update it manually ' ...
        'using the git command\n %s\n and then run its startup script again.\n'], ...
        module, 'git pull --recurse-submodules');
else
    update = false;
end
end
