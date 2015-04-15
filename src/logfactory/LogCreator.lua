local LogCreator = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local GIT_COMMAND = 'git log --reverse --numstat --pretty=format:"info: %an|%ae|%ct" --name-status --no-merges';
local LOG_FOLDER = 'logs/';
local LOG_FILE = '/log.txt';
local INFO_FILE = '/info.lua';

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Creates a git log if git is available and no log has been
-- created in the target folder yet.
-- @param projectname
-- @param path
--
function LogCreator.createGitLog(projectname, path, force)
    if not force and love.filesystem.isFile(LOG_FOLDER .. projectname .. LOG_FILE) then
        io.write('Git log for ' .. projectname .. ' already exists!\r\n');
    else
        io.write('Writing log for ' .. projectname .. '.\r\n');
        love.filesystem.createDirectory(LOG_FOLDER .. projectname);

        local cmd = 'cd ' .. path .. '&&' .. GIT_COMMAND;
        local handle = io.popen(cmd);
        local fileContent = '';
        for line in handle:lines() do
            fileContent = fileContent .. line .. '\r\n';
        end
        handle:close();
        love.filesystem.write(LOG_FOLDER .. projectname .. LOG_FILE, fileContent);
        io.write('Done!\r\n');
    end
end

function LogCreator.createInfoFile(projectname, path, force)
    if not force and love.filesystem.isFile(LOG_FOLDER .. projectname .. INFO_FILE) then
        io.write('Info file for ' .. projectname .. ' already exists!\r\n');
    elseif love.system.getOS() ~= 'Windows' then
        local fileContent = '';
        fileContent = fileContent .. 'return {\r\n';

        -- Project name.
        fileContent = fileContent .. '    name = "' .. projectname .. '",\r\n';

        -- First commit.
        local handle = io.popen('cd ' .. path .. '&&git log --pretty=format:%ct|tail -1');
        fileContent = fileContent .. '    firstCommit = ' .. handle:read('*a'):gsub('[%s]+', '') .. ',\r\n';
        handle:close();

        -- Latest commit.
        local handle = io.popen('cd ' .. path .. '&&git log --pretty=format:%ct|head -1');
        fileContent = fileContent .. '    latestCommit = ' .. handle:read('*a'):gsub('[%s]+', '') .. ',\r\n';
        handle:close();

        -- Number of commits.
        local handle = io.popen('cd ' .. path .. '&&git rev-list HEAD --count');
        fileContent = fileContent .. '    totalCommits = ' .. handle:read('*a'):gsub('[%s]+', '') .. '\r\n';
        handle:close();

        fileContent = fileContent .. '};\r\n';

        love.filesystem.write(LOG_FOLDER .. projectname .. INFO_FILE, fileContent);
    end
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Checks if git is available on the system.
--
function LogCreator.isGitAvailable()
    return os.execute('git version') == 0;
end


return LogCreator;
