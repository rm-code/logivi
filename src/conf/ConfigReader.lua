local ConfigReader = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FILE_NAME = 'settings.cfg';
local TEMPLATE_PATH = 'res/templates/settings_template.cfg';

local INVALID_CONFIG_HEADER   = 'Invalid config file';
local MISSING_SECTION_WARNING = 'Seems like the loaded configuration file is missing the [%s] section. The default settings will be used instead.';
local MISSING_VALUE_WARNING   = 'Seems like the loaded configuration file is missing the [%s] value in the [%s] section. The default settings will be used instead.';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local config;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Checks if the settings file exists on the user's system.
--
local function hasConfigFile()
    return love.filesystem.isFile( FILE_NAME );
end

---
-- Creates a new settings file on the user's system based on the default template.
-- @param filename     (string) The file name to use for the config file.
-- @param templatePath (string) The path to the template settings file.
--
local function createConfigFile( filename, templatePath )
    for line in love.filesystem.lines( templatePath ) do
        love.filesystem.append( filename, line .. '\r\n' );
    end
end

---
-- Tries to transform strings to their actual types if possible.
-- @param value (string)  The value to transform.
-- @return      (various) The actual type of the setting.
--
local function toType( value )
    value = value:match( '^%s*(.-)%s*$' );
    if value == 'true' then
        return true;
    elseif value == 'false' then
        return false;
    elseif tonumber( value ) then
        return tonumber( value );
    else
        return value;
    end
end

---
-- Parses the config file and stores the values in a table.
-- @param filePath (string) The path to the config file.
-- @return         (table)  The loaded config stored in a table.
--
local function loadFile( filePath )
    local loadedConfig = {};
    local section;

    for line in love.filesystem.lines( filePath ) do
        if line == '' or line:find( ';' ) == 1 then
            -- Ignore comments and empty lines.
        elseif line:match( '^%[(%w*)%]$' ) then
            -- Create a new section.
            local header = line:match( '^%[(%w*)%]$' );
            loadedConfig[header] = {};
            section = loadedConfig[header];
        else
            -- Store values in the section.
            local key, value = line:match( '^([%g]+)%s-=%s-(.+)' );

            -- Store multiple values in a table.
            if value and value:find( ',' ) then
                section[key] = {};
                for val in value:gmatch( '[^, ]+' ) do
                    section[key][#section[key] + 1] = toType( val );
                end
            elseif value then
                section[key] = toType( value );
            end
        end
    end

    return loadedConfig;
end

---
-- Validates a loaded config file by comparing it to the default config file.
-- It checks if the file contains all the necessary sections and values. If it
-- doesn't, a warning is displayed and the default config will be used.
-- @param default (table) The default config file to use for comparison.
--
local function validateFile( default )
    print( 'Validating configuration file ... ' );
    for skey, section in pairs( default ) do

        -- If loaded config file doesn't contain section return default.
        if config[skey] == nil then
            love.window.showMessageBox( INVALID_CONFIG_HEADER, string.format( MISSING_SECTION_WARNING, skey ), 'warning', false );
            return default;
        end

        -- If the loaded config file is missing a value, display warning and return default.
        if type( section ) == 'table' then
            for vkey, _ in pairs( section ) do
                if config[skey][vkey] == nil then
                    love.window.showMessageBox( INVALID_CONFIG_HEADER, string.format( MISSING_VALUE_WARNING, vkey, skey ), 'warning', false );
                    return default;
                end
            end
        end
    end
    print( 'Done!' );
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function ConfigReader.init()
    local default = loadFile( TEMPLATE_PATH );

    if not hasConfigFile() then
        createConfigFile( FILE_NAME, TEMPLATE_PATH );
    end

    -- If the config hasn't been loaded yet, load and validate it.
    if not config then
        config = loadFile( FILE_NAME );
        validateFile( default );
    end

    return config;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return ConfigReader;
