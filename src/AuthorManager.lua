local Resources = require( 'src.Resources' );
local Author = require( 'src.Author' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local AVATAR_SPRITE  = Resources.loadImage( 'avatar.png' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local AuthorManager = {};

-- ------------------------------------------------
-- Private Class Variables
-- ------------------------------------------------

local authors;
local aliases;
local addresses;
local visible;
local spritebatch;

local activeAuthor;

local graphCenterX, graphCenterY;

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Initialises the AuthorManager.
-- @param naliases (table)   Aliases used to replace author names.
-- @param nvisible (boolean) Wether to hide or show the AuthorManager.
--
function AuthorManager.init( naliases, nvisible )
    -- Set up the table to store all authors.
    authors = {};

    addresses = {};
    aliases = naliases;

    visible = nvisible;

    graphCenterX, graphCenterY = 0, 0;

    spritebatch = love.graphics.newSpriteBatch( AVATAR_SPRITE, 1000, 'stream' );
end

---
-- Draws a list of all authors working on the project.
-- @param rotation (number) The camera's current rotation.
-- @param scale    (number) The camera's current scale.
--
function AuthorManager.draw( rotation, scale )
    if visible then
        for _, author in pairs(authors) do
            author:draw(rotation, scale);
        end
        love.graphics.draw( spritebatch );
    end
end

---
-- Updates all authors.
-- @param dt (number) The delta time between frames.
--
function AuthorManager.update( dt, cameraRotation )
    spritebatch:clear();
    for _, author in pairs( authors ) do
        author:update( dt, cameraRotation );
    end
end

---
-- Adds a link from the current author to a file.
-- @param file     (table)  The file to link to.
-- @param modifier (string) The kind of modifier used on the file.
--
function AuthorManager.addFileLink( file, modifier )
    activeAuthor:addLink( file, modifier )
end

---
-- Receives a notification from an observable.
-- @param self  (table)  A reference to the AuthorManager table.
-- @param event (string) The identifier for a particular event.
-- @param ...   (vararg) One or multiple values sent with the event.
--
function AuthorManager.receive( self, event, ... )
    if event == 'NEW_COMMIT' then
        AuthorManager.setCommitAuthor( ... );
    elseif event == 'GRAPH_UPDATE_FILE' then
        AuthorManager.addFileLink( ... )
    elseif event == 'GRAPH_UPDATE_CENTER' then
        AuthorManager.setGraphCenter( ... );
    end
end

---
-- Sets the author of the currently processed commit to be the active author.
-- @param email (string) The email adress of the author to set.
-- @param name  (string) The name of the author to set.
--
function AuthorManager.setCommitAuthor( email, name )
    -- Reset the previous author.
    if activeAuthor then activeAuthor:resetLinks() end

    -- Check if we already have an alias or a name for this email address. If
    -- not we use the author's name.
    local nickname = aliases[email] or addresses[email] or name;

    -- If we don't have an author for that name yet, we create it.
    if not authors[nickname] then
        addresses[email] = name; -- Store this name as the default for this email address.
        authors[nickname] = Author.new( nickname, AVATAR_SPRITE, spritebatch, graphCenterX, graphCenterY );
    end

    activeAuthor = authors[nickname];
end

---
-- Sets the visibility of all authors.
-- @param nv (boolean) Wether or not to display authors.
--
function AuthorManager.setVisible( nv )
    visible = nv;
end

---
-- Returns the visibility of all authors.
--
function AuthorManager.isVisible()
    return visible;
end

---
-- Sets the graph's center coordinates.
-- @param ncx (number) The graph's center along the x-axis.
-- @param ncy (number) The graph's center along the y-axis.
--
function AuthorManager.setGraphCenter( ncx, ncy )
    graphCenterX, graphCenterY = ncx, ncy;
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return AuthorManager;
