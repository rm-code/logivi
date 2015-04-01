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
};
]]