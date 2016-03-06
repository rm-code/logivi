local FILE_NAME = 'repositories.lua';

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
    return love.filesystem.load( FILE_NAME )();
end

---
-- Saves the repositories-table to the hard disk.
--
local function save()
    local file = love.filesystem.newFile( FILE_NAME, 'w' );

    file:write( 'return {\r\n' );
    file:write( '    -- ["Name"] = "Path",\r\n' );
    for key, value in pairs( repositories ) do
        file:write( string.format('    ["%s"] = "%s",\r\n', key, value ));
    end
    file:write( '}' );
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
    repositories = load();
end

---
-- Adds a new repository to the list of repositories and saves the data to the
-- hard drive.
-- @param name (string) The repository's name.
-- @param path (string) The repository's location.
--
function RepositoryHandler.add( name, path )
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
