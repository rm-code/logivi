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
        showLabels = true,
        showTimeline = true,
        commitDelay = 0.2,
        edgeWidth = 5,
        backgroundColor = { 0, 0, 0 },
        removeTmpFiles = false,
        screenWidth = 0,
        screenHeight = 0,
        fullscreen = true,
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
        toggleFileList = '2',    -- Hide / Show file panel
        toggleLabels = '3',      -- Hide / Show folder labels
        toggleTimeline = '4',    -- Hide / Show timeline

        toggleSimulation = ' ',  -- Stop / Play the simulation
        toggleRewind = 'backspace',  -- Make simulation run backwards
        loadNextCommit = 'right',    -- Manually load the next commit
        loadPrevCommit = 'left',     -- Manually load the previous commit

        toggleFullscreen = 'f',  -- Toggle fullscreen
    },
};
]]