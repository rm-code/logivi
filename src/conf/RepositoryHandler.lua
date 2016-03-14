local FILE_NAME = 'repositories.cfg';

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local RepositoryHandler = {};

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local repositories = {};

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Checks if the repository file exists on the user's system.
-- @return (boolean) Wether the file exists or not.
--
local function hasRepositoryFile()
    return love.filesystem.isFile( FILE_NAME );
end

---
-- Loads the repository file.
-- @return (table) The repository file as a lua table.
--
local function load()
    for line in love.filesystem.lines( FILE_NAME ) do
        if line == '' or line:find( ';' ) == 1 then
            -- Ignore comments and empty lines.
        else
            -- Store values in the section.
            local key, value = line:match( '^%s*([%g%s]*%g)%s*=%s*(.+)$' );
            repositories[key] = value;
        end
    end
end

---
-- Saves the repositories-table to the hard disk.
--
local function save()
    local file = love.filesystem.newFile( FILE_NAME, 'w' );

    file:write( '; This file keeps track of the paths where the repositories\r\n' );
    file:write( '; are located on the user\'s hard drive.\r\n' );
    file:write( '; Name = Path\r\n' );
    for key, value in pairs( repositories ) do
        local line = string.format( '%s = %s\r\n', key, value );
        file:write( line );
    end
    file:close();
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Initialises the handler and creates an empty repository file on the hard
-- disk if it doesn't exist already.
--
function RepositoryHandler.init()
    if not hasRepositoryFile() then
        save(); -- Create empty file.
    end
    load();
end

---
-- Adds a new repository to the list of repositories and saves the data to the
-- hard drive.
-- @param name (string) The repository's name.
-- @param path (string) The repository's location.
--
function RepositoryHandler.add( name, path )
    if repositories[name] then
        name = name .. '_' .. os.time();
    end
    repositories[name] = path;
    save();
end

---
-- Removes a repository from the list of repositories and saves the data to the
-- hard drive.
-- @param name (string) The repository's name.
--
function RepositoryHandler.remove( name )
    repositories[name] = nil;
    save();
end

---
-- Returns the repositories-table.
-- @return (table) The repositories.
--
function RepositoryHandler.getRepositories()
    return repositories;
end

return RepositoryHandler;
