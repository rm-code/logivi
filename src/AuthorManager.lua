local Author = require('src.Author');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local AuthorManager = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local PATH_DEFAULT_AVATAR = 'res/img/avatar.png';

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local authors;
local defaultAvatar;
local aliases;
local addresses;
local visible;

local activeAuthor;

local graphCenterX, graphCenterY;

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function AuthorManager.init(naliases, visibility)
    -- Set up the table to store all authors.
    authors = {};

    addresses = {};
    aliases = naliases;

    visible = visibility;

    defaultAvatar = love.graphics.newImage( PATH_DEFAULT_AVATAR );

    graphCenterX, graphCenterY = 0, 0;
end

---
-- Draws a list of all authors working on the project.
--
function AuthorManager.drawLabels(rotation, scale)
    if visible then
        for _, author in pairs(authors) do
            author:draw(rotation, scale);
        end
    end
end

---
-- Updates all authors.
-- @param dt
--
function AuthorManager.update(dt)
    for name, author in pairs(authors) do
        author:update(dt);
    end
end

---
-- Adds a link from the current author to a file.
-- @param file
--
function AuthorManager.addFileLink(file, modifier)
    activeAuthor:addLink(file, modifier)
end

---
-- Receives a notification from an observable.
-- @param self
-- @param event
-- @param ...
--
function AuthorManager.receive(self, event, ...)
    if event == 'NEW_COMMIT' then
        AuthorManager.setCommitAuthor(...);
    elseif event == 'GRAPH_UPDATE_FILE' then
        AuthorManager.addFileLink(...)
    elseif event == 'GRAPH_UPDATE_CENTER' then
        AuthorManager.setGraphCenter(...);
    end
end

---
-- Sets the author of the currently processed commit and resets the previously
-- active one. If he doesn't exist yet he will be created and added to the list
-- of authors for. Before storing the author the function checks the config file
-- to see if an alias is associated with the specific email address.
-- If it is, it will use the alias and ignore the name found in the log file.
-- If there isn't an alias, it will check if there already is another nickname
-- stored for that email address. If there isn't, it will use the nickname found
-- in the log.
-- @param nemail
-- @param nauthor
-- @param cx
-- @param cy
--
function AuthorManager.setCommitAuthor(nemail, nauthor)
    if activeAuthor then activeAuthor:resetLinks() end

    local nickname = aliases[nemail] or addresses[nemail] or nauthor;
    if not authors[nickname] then
        addresses[nemail] = nauthor; -- Store this name as the default for this email address.
        authors[nickname] = Author.new( nickname, defaultAvatar, graphCenterX, graphCenterY );
    end

    activeAuthor = authors[nickname];
end

---
-- Shows / Hides authors.
-- @param nv
--
function AuthorManager.setVisible(nv)
    visible = nv;
end

---
-- Returns visibility of authors.
--
function AuthorManager.isVisible()
    return visible;
end

---
-- @param ncx
-- @param ncy
--
function AuthorManager.setGraphCenter(ncx, ncy)
    graphCenterX, graphCenterY = ncx, ncy;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return AuthorManager;
