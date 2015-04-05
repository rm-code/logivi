local LogCreator = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local GIT_COMMAND = 'git log --reverse --numstat --pretty=format:"info: %an|%ae|%ct" --name-status --no-merges';
local LOG_FOLDER = 'logs/';
local LOG_FILE = '/log.txt';

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Checks if git is available on the system.
--
local function hasGit()
    return os.execute('git version') == 0;
end

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
    print('Checking for git:')
    if not hasGit() then
        print('Git isn\'t availalbe on your system.');
    elseif love.filesystem.isFile(LOG_FOLDER .. projectname .. LOG_FILE) then
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

return LogCreator;
