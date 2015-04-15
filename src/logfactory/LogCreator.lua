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
function LogCreator.createGitLog(projectname, path)
    if love.filesystem.isFile(LOG_FOLDER .. projectname .. LOG_FILE) then
        print('Git log for ' .. projectname .. ' already exists!');
    else
        print('Writing log for ' .. projectname .. '.');
        love.filesystem.createDirectory(LOG_FOLDER .. projectname);

        local cmd = 'cd ' .. path .. '&&' .. GIT_COMMAND;
        local handle = io.popen(cmd);
        for line in handle:lines() do
            love.filesystem.append(LOG_FOLDER .. projectname .. LOG_FILE, line .. '\r\n');
        end
        handle:close();
        print('Done!');
    end
end

function LogCreator.createInfoFile(projectname, path)
    if love.filesystem.isFile(LOG_FOLDER .. projectname .. INFO_FILE) then
        print('Info file for ' .. projectname .. ' already exists!');
    else
        love.filesystem.append(LOG_FOLDER .. projectname .. INFO_FILE, 'return {\r\n');

        -- Project name.
        love.filesystem.append(LOG_FOLDER .. projectname .. INFO_FILE, '    name = "' .. projectname .. '",\r\n');

        -- First commit.
        local handle = io.popen('cd ' .. path .. '&&git log --pretty=format:%ct|tail -1');
        love.filesystem.append(LOG_FOLDER .. projectname .. INFO_FILE, '    firstCommit = ' .. handle:read('*a'):gsub('[%s]+', '') .. ',\r\n');
        handle:close();

        -- Latest commit.
        local handle = io.popen('cd ' .. path .. '&&git log --pretty=format:%ct|head -1');
        love.filesystem.append(LOG_FOLDER .. projectname .. INFO_FILE, '    latestCommit = ' .. handle:read('*a'):gsub('[%s]+', '') .. ',\r\n');
        handle:close();

        -- Number of commits.
        local handle = io.popen('cd ' .. path .. '&&git rev-list HEAD --count');
        love.filesystem.append(LOG_FOLDER .. projectname .. INFO_FILE, '    totalCommits = ' .. handle:read('*a'):gsub('[%s]+', '') .. '\r\n');
        handle:close();

        love.filesystem.append(LOG_FOLDER .. projectname .. INFO_FILE, '};\r\n');
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
