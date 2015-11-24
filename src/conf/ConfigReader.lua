local ConfigReader = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FILE_NAME = 'settings.cfg';
local TEMPLATE_PATH = 'res/templates/settings.cfg';

local INVALID_CONFIG_HEADER   = 'Invalid config file';
local MISSING_SECTION_WARNING = 'Seems like the loaded configuration file is missing the [%s] section. The default settings will be used instead.';
local MISSING_VALUE_WARNING   = 'Seems like the loaded configuration file is missing the [%s] value in the [%s] section. The default settings will be used instead.';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local default;
local config;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Checks if the settings file exists on the user's system.
--
local function hasConfigFile()
    return love.filesystem.isFile(FILE_NAME);
end

---
-- Creates a new settings file on the user's system based on the default template.
-- @param name - The file name to use for the config file.
-- @param default - The path to the default settings file.
--
local function createConfigFile(name, default)
    for line in love.filesystem.lines(default) do
        love.filesystem.append(name, line .. '\r\n');
    end
end

---
-- Tries to transform strings to their actual types if possible.
-- @param value - The value to transform.
--
local function toType(value)
    value = value:match('^%s*(.-)%s*$');
    if value == 'true' then
        return true;
    elseif value == 'false' then
        return false;
    elseif tonumber(value) then
        return tonumber(value);
    else
        return value;
    end
end

local function loadFile(file)
    local config = {};
    local section;

    for line in love.filesystem.lines(file) do
        if line == '' or line:find(';') == 1 then
            -- Ignore comments and empty lines.
        elseif line:match('^%[(%w*)%]$') then
            -- Create a new section.
            local header = line:match('^%[(%w*)%]$');
            config[header] = {};
            section = config[header];
        else
            -- Store values in the section.
            local key, value = line:match('^([%g]+)%s-=%s-(.+)');

            -- Store multiple values in a table.
            if value and value:find(',') then
                section[key] = {};
                for val in value:gmatch('[^, ]+') do
                    section[key][#section[key] + 1] = toType(val);
                end
            elseif value then
                section[key] = toType(value);
            end
        end
    end

    return config;
end

---
-- Validates a loaded config file by comparing it to the default config file.
-- It checks if the file contains all the necessary sections and values. If it
-- doesn't a warning is displayed and the default config will be used.
-- @param default - The default file to use for comparison.
-- @param loaded - The settings file loaded from the user's system.
--
local function validateFile(default, loaded)
    print('Validating configuration file ... ');
    for skey, section in pairs(default) do

        -- If loaded config file doesn't contain section return default.
        if loaded[skey] == nil then
            love.window.showMessageBox(INVALID_CONFIG_HEADER, string.format(MISSING_SECTION_WARNING, skey), 'warning', false);
            return default;
        end

        -- If the loaded config file is missing a value, display warning and return default.
        if type(section) == 'table' then
            for vkey, _ in pairs(section) do
                if loaded[skey][vkey] == nil then
                    love.window.showMessageBox(INVALID_CONFIG_HEADER, string.format(MISSING_VALUE_WARNING, vkey, skey), 'warning', false);
                    return default;
                end
            end
        end
    end

    print('Done!');
    return loaded;
end

---
-- Replaces backslashes in paths with forwardslashes.
-- @param The loaded config.
--
local function validateRepositoryPaths(config)
    for project, path in pairs(config.repositories) do
        config.repositories[project] = path:gsub('\\+', '/');
    end
    return config;
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function ConfigReader.init()
    default = loadFile(TEMPLATE_PATH);

    if not hasConfigFile() then
        createConfigFile(FILE_NAME, TEMPLATE_PATH);
    end

    -- If the config hasn't been loaded yet, load and validate it.
    if not config then
        config = loadFile(FILE_NAME);
        config = validateFile(default, config);
        config = validateRepositoryPaths(config);
    end

    return config;
end

function ConfigReader.removeTmpFiles()
    print('Removing temporary files...');
    local function recursivelyDelete(item, depth)
        local ws = '';
        for _ = 1, depth do
            ws = ws .. '    ';
        end
        print(ws .. item);
        if love.filesystem.isDirectory(item) then
            for _, child in pairs(love.filesystem.getDirectoryItems(item)) do
                recursivelyDelete(item .. '/' .. child, depth + 1);
                love.filesystem.remove(item .. '/' .. child);
            end
        elseif love.filesystem.isFile(item) then
            love.filesystem.remove(item);
        end
        love.filesystem.remove(item);
    end

    recursivelyDelete('tmp', 0);
    print('... Done!');
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function ConfigReader.getConfig(section)
    return config[section];
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return ConfigReader;
