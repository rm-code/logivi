local RepositoryInfos = {};

local INFO_FILE  = 'logs/%s/info.lua';
local COUNT_FILE = 'logs/%s/.commits';

---
-- Returns true if an info file for the given project already exists.
-- @param projectname (string)  The name under which to store the info file.
-- @return            (boolean) True if the file already exists.
--
function RepositoryInfos.hasCommitCountFile( projectname )
    return love.filesystem.isFile( string.format( INFO_FILE, projectname ));
end

---
-- Creates an info file for a certain project / repository. This file keeps
-- track of things like the total amount of commits in the repository, custom
-- author names, custom colors, etc.
-- @param projectname (string)  The name under which to store the info file.
--
function RepositoryInfos.createInfoFile( projectname )
    local fileContent = 'return {\r\n';

    fileContent = fileContent .. '    name = "' .. projectname .. '",\r\n';
    fileContent = fileContent .. '    aliases = {},\r\n';
    fileContent = fileContent .. '    colors = {},\r\n';

    fileContent = fileContent .. '}\r\n';

    love.filesystem.write( string.format( INFO_FILE, projectname ), fileContent );
end

---
-- Creates a file which stores the amount of commits in the repository. This
-- will be used to check if the log file needs to be updated.
-- @param projectname (string) The name under which to store the info file.
-- @param commits     (number) The count of commits to write to the file.
--
function RepositoryInfos.createCommitCountFile( projectname, commits )
    local count = commits or 0;

    local fileContent = 'return {\r\n';
    fileContent = fileContent .. '    commits = ' .. count .. '\r\n';
    fileContent = fileContent .. '}\r\n';

    love.filesystem.write( string.format( COUNT_FILE, projectname ), fileContent );
end

---
-- Loads information about a git repository.
-- @param name (string) The name of the git log to load the info file for.
-- @return     (table)  A table containing information about the git log.
--
function RepositoryInfos.loadInfo( name )
    local successful, info = pcall( love.filesystem.load, string.format( INFO_FILE, name ));
    if successful then
        return info();
    end
end

function RepositoryInfos.loadCommitCount( name )
    local successful, count = pcall( love.filesystem.load, string.format( COUNT_FILE, name ));
    if successful then
        return count();
    end
end

return RepositoryInfos;
