local LogLoader = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LOG_FOLDER = 'logs';
local LOG_FILE = 'log.txt';
local INFO_FILE = 'info.lua';

local TAG_INFO = 'info: ';

local WARNING_TITLE = 'No git log found.';
local WARNING_MESSAGE = [[
Looks like you are using LoGiVi for the first time. An example git log has been created in the save directory. Press '%s' to continue to the main menu, where you can watch the example.

Press '%s' to open the save directory, where you can add your own logs and edit the configuration file.

Press '%s' to view the wiki for more information on how to generate your own logs.
]];

local EXAMPLE_TEMPLATE_PATH = 'res/templates/example_log.txt';
local EXAMPLE_TARGET_PATH = 'logs/example/';

-- ------------------------------------------------
-- Local variables
-- ------------------------------------------------

local list;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Remove the specified tag from the line.
-- @param line
-- @param tag
--
local function removeTag(line, tag)
    return line:gsub(tag, '');
end

---
-- @param author
--
local function splitLine(line, delimiter)
    local tmp = {}
    for part in line:gmatch('[^' .. delimiter .. ']+') do
        tmp[#tmp + 1] = part;
    end
    return tmp;
end

---
-- Creates a list of all folders found in the LOG_FOLDER directory, which
-- contain a LOG_FILE. Returns a sequence which contains the names of the folders
-- and the path to the log files in those folders.
-- @param dir
--
local function fetchProjectFolders(dir)
    local folders = {};

    for _, name in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local subdir = dir .. '/' .. name;
        if love.filesystem.isDirectory(subdir) and love.filesystem.isFile(subdir .. '/' .. LOG_FILE) then
            folders[#folders + 1] = { name = name, path = subdir .. '/' .. LOG_FILE };
        end
    end

    return folders;
end

---
-- Reads the whole log file and stores each line in a sequence.
-- @param path
--
local function parseLog(path)
    local file = {};
    for line in love.filesystem.lines(path) do
        if line ~= '' then
            file[#file + 1] = line;
        end
    end
    return file;
end

---
-- Turns a unix timestamp into a human readable date string.
-- @param timestamp
--
local function createDateFromUnixTimestamp(timestamp)
    local date = os.date('*t', tonumber(timestamp));
    return string.format("%02d:%02d:%02d - %02d-%02d-%04d", date.hour, date.min, date.sec, date.day, date.month, date.year);
end

---
-- Splits a commit line into modifier, path, file and extension.
-- @param line - The line to split.
--
local function buildCommitLine( line )
    local modifier  = line:sub( 1, 1 );
    local path      = line:gsub( '^(%a)%s*', '' );
    local file      = path:match( '/?([^/]+)$' );
    local extension = file:match( '(%.[^.]+)$' ) or '.?';

    path = path:gsub( '/?([^/]+)$', '' ); -- Remove the filename from the path.
    if path ~= '' then
        path = '/' .. path;
    end

    return { modifier = modifier, path = path, file = file, extension = extension };
end

---
-- Splits the log table into commits. Each commit is a new nested table.
-- @param log
--
local function splitCommits(log)
    local commits = {};
    local index = 0;
    for i = 1, #log do
        local line = log[i];

        if line:find(TAG_INFO) then
            index = index + 1;
            commits[index] = {};

            local info = splitLine(removeTag(line, TAG_INFO), '|');
            commits[index].author, commits[index].email, commits[index].date = info[1], info[2], info[3];

            -- Transform unix timestamp to a table containing a human-readable date.
            commits[index].date = createDateFromUnixTimestamp(commits[index].date);
        elseif commits[index] then
            commits[index][#commits[index] + 1] = buildCommitLine( line );
        end
    end

    return commits;
end

---
-- Returns the index of a stored log if it can be found.
-- @param name
--
local function searchLog(name)
    for i, log in ipairs(list) do
        if log.name == name then
            return i;
        end
    end
end

---
-- Checks if the log folder exists and if it is empty or not.
--
local function hasLogs()
    return (love.filesystem.isDirectory(LOG_FOLDER) and #list ~= 0);
end

---
-- Displays a warning message for the user which gives him the option
-- to open the wiki page or the folder in which the logs need to be placed.
--
local function showWarning()
    local buttons = { "Proceed", "Open Folder", "Show Help (Online)", enterbutton = 1 };

    local msg = string.format(WARNING_MESSAGE, buttons[1], buttons[2], buttons[3]);

    local pressedbutton = love.window.showMessageBox(WARNING_TITLE, msg, buttons, 'warning', false);
    if pressedbutton == 2 then
        love.system.openURL('file://' .. love.filesystem.getSaveDirectory());
    elseif pressedbutton == 3 then
        love.system.openURL('https://github.com/rm-code/logivi/wiki#instructions');
    end
end

---
-- Write an example log file to the save directory.
--
local function createExample()
    love.filesystem.createDirectory(EXAMPLE_TARGET_PATH);
    if not love.filesystem.isFile(EXAMPLE_TARGET_PATH .. LOG_FILE) then
        local example = love.filesystem.read(EXAMPLE_TEMPLATE_PATH);
        love.filesystem.write(EXAMPLE_TARGET_PATH .. LOG_FILE, example);
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Try to load a certain log stored in the list.
--
function LogLoader.load(log)
    local index = searchLog(log);
    local rawLog = parseLog(list[index].path);
    return splitCommits(rawLog);
end

---
-- Loads information about a git repository.
-- @param name
--
function LogLoader.loadInfo(name)
    if love.filesystem.isFile(LOG_FOLDER .. '/' .. name .. '/' .. INFO_FILE) then
        local successful, info = pcall(love.filesystem.load, LOG_FOLDER .. '/' .. name .. '/' .. INFO_FILE);
        if successful then
            info = info(); -- Run the lua file.
            info.firstCommit = createDateFromUnixTimestamp(info.firstCommit);
            info.latestCommit = createDateFromUnixTimestamp(info.latestCommit);
            info.aliases = info.aliases or {};
            info.colors = info.colors or {};
            return info;
        end
    end
    return {
        name = name,
        firstCommit = '<no information available>',
        latestCommit = '<no information available>',
        totalCommits = '<no information available>',
        aliases = {},
        colors = {},
    };
end

---
-- Initialises the LogLoader. It will fetch a list of all folders
-- containing a log file. If the list is empty it will display a
-- warning to the user.
--
function LogLoader.init()
    list = fetchProjectFolders(LOG_FOLDER);

    if not hasLogs() then
        createExample();
        showWarning();
        list = fetchProjectFolders(LOG_FOLDER);
    end

    return list;
end

return LogLoader;
