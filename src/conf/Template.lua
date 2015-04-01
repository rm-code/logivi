return [[
-- ------------------------------- --
-- LoGiVi - Configuration File.    --
-- ------------------------------- --

return {
    -- Associates an email address with a author. This name will
    -- then be used instead of the one found in the git log.
    aliases = {
        -- ['email'] = 'Author',
    },
    -- Assigns an avatar to an author.
    avatars = {
        -- ['author'] = 'urlToAvatar',
    },
    options = {
        showFileList = true,
        showAuthors = true,
        commitDelay = 0.2,
        edgeWidth = 5,
        backgroundColor = { 0, 0, 0 },
        removeTmpFiles = false,
        screenWidth = 800,
        screenHeight = 600,
        fullscreen = false,
        fullscreenType = 'desktop',
        vsync = true,
        msaa = 0,
        display = 1,
    },

    -- See https://love2d.org/wiki/KeyConstant for a list of possible keycodes.
    keyBindings = {
        camera_n = 'w',          -- Move camera up
        camera_w = 'a',          -- Move camera left
        camera_s = 's',          -- Move camera down
        camera_e = 'd',          -- Move camera right
        camera_rotateL = 'q',    -- Rotate camera left
        camera_rotateR = 'e',    -- Rotate camera right
        camera_zoomIn  = '+',    -- Zoom in
        camera_zoomOut = '-',    -- Zoom out

        toggleAuthors = '1',     -- Hide / Show authors
    },
};
]]