--==================================================================================================
-- Copyright (C) 2014 - 2015 by Robert Machmer                                                     =
--                                                                                                 =
-- Permission is hereby granted, free of charge, to any person obtaining a copy                    =
-- of this software and associated documentation files (the "Software"), to deal                   =
-- in the Software without restriction, including without limitation the rights                    =
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell                       =
-- copies of the Software, and to permit persons to whom the Software is                           =
-- furnished to do so, subject to the following conditions:                                        =
--                                                                                                 =
-- The above copyright notice and this permission notice shall be included in                      =
-- all copies or substantial portions of the Software.                                             =
--                                                                                                 =
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR                      =
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,                        =
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE                     =
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER                          =
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,                   =
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN                       =
-- THE SOFTWARE.                                                                                   =
--==================================================================================================

local ConfigReader = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FILE_NAME = 'settings.cfg';
local TEMPLATE_PATH = 'res/templates/settings.cfg';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local default;
local config;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

local function hasConfigFile()
    return love.filesystem.isFile(FILE_NAME);
end

local function createConfigFile(name, default)
    for line in love.filesystem.lines(default) do
        love.filesystem.append(name, line .. '\r\n');
    end
end

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
            local key, value = line:match('^([%w_]+)%s-=%s-(.+)');

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

    -- Validate file paths.
    for project, path in pairs(config.repositories) do
        config.repositories[project] = path:gsub('\\+', '/');
    end

    return config;
end

local function validateFile(default, loaded)
    print('Validating configuration file ... ');
    for skey, section in pairs(default) do

        -- If loaded config file doesn't contain section return default.
        if loaded[skey] == nil then
            love.window.showMessageBox('Invalid config file', 'Seems like the loaded configuration file is missing the "' ..
                    skey .. '" section. The default settings will be used instead.', 'warning', false);
            return default;
        end

        if type(section) == 'table' then
            for vkey, _ in pairs(section) do
                if loaded[skey][vkey] == nil then
                    love.window.showMessageBox('Invalid config file',
                        'Seems like the loaded configuration file is missing the "' ..
                                vkey .. '" value in the "' .. skey .. '" section. The default settings will be used instead.', 'warning', false);
                    return default;
                end
            end
        end
    end

    print('Done!');
    return loaded;
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
