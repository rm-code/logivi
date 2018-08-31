local FileManager = {};

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local extensions = {};
local sortedList = {};
local totalFiles = 0;
local colors;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Sorts the list of extensions and sorts them based on the amount of files
-- which currently exist in the repository.
--
local function createSortedList()
    for k in pairs( sortedList ) do
        sortedList[k] = nil;
    end

    for _, tbl in pairs( extensions ) do
        sortedList[#sortedList + 1] = tbl;
    end

    table.sort( sortedList, function( a, b )
        return a.amount > b.amount;
    end);
end

---
-- Creates a new custom color for the extension if it doesn't have one yet.
-- @param ext (string) The extension to add a new file for.
-- @return    (table)  A table containing the RGB values for this extension.
--
local function assignColor( ext )
    if not colors[ext] then
        colors[ext] = {
            r = love.math.random( 0, 255 )/255,
            g = love.math.random( 0, 255 )/255,
            b = love.math.random( 0, 255 )/255
        };
    end
    return colors[ext];
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Adds a new file belonging to a certain extension to the list. If the
-- extension doesn't exist yet we allocate a new table for it.
-- @param ext (string) The extension to add a new file for.
-- @return    (table)  The table containing RGB values for this extension.
-- @return    (string) The extension string.
--
function FileManager.add( ext )
    if not extensions[ext] then
        extensions[ext] = {};
        extensions[ext].extension = ext;
        extensions[ext].amount = 0;
        extensions[ext].color = assignColor( ext );
    end
    extensions[ext].amount = extensions[ext].amount + 1;
    totalFiles = totalFiles + 1;

    createSortedList( extensions );

    return extensions[ext].color, ext;
end

---
-- Decrements the counter for a certain extension. If there are no more files
-- of that extension, it will remove it from the table.
-- @param ext (string) The extension to remove a file from.
--
function FileManager.remove( ext )
    if not extensions[ext] then
        error( 'Tried to remove the non existing file extension "' .. ext .. '".' );
    end

    extensions[ext].amount = extensions[ext].amount - 1;
    totalFiles = totalFiles - 1;
    if extensions[ext].amount == 0 then
        extensions[ext] = nil;
    end

    createSortedList( extensions );
end

---
-- Resets the state of the FileManager.
--
function FileManager.reset()
    extensions = {};
    sortedList = {};
    totalFiles = 0;
    colors = nil;
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Gets the color table for a certain file extension.
-- @param ext (string) The extension to return the color for.
-- @return    (table)  A table containing the RGB values for the extension.
--
function FileManager.getColor( ext )
    return extensions[ext].color;
end

---
-- Returns the sorted list of file extensions.
-- @return (table) The sorted list of file extensions.
--
function FileManager.getSortedList()
    return sortedList;
end

---
-- Returns the total amount of files in the repository.
-- @return (number) The total amount of files in the repository.
--
function FileManager.getTotalFiles()
    return totalFiles;
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- Sets the default color table. This can be used to specify colors for
-- certain extensions (instead of randomly creating them).
-- @param ncol (table) The table containing RGBA values belonging to a certain
--                      file extension.
--
function FileManager.setColorTable( ncol )
    colors = ncol;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return FileManager;
