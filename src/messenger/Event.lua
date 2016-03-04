local EVENT = {};

EVENT.GRAPH_UPDATE_DIMENSIONS = 'GRAPH_UPDATE_DIMENSIONS';
EVENT.GRAPH_UPDATE_CENTER     = 'GRAPH_UPDATE_CENTER';
EVENT.GRAPH_UPDATE_FILE       = 'GRAPH_UPDATE_FILE';
EVENT.NEW_COMMIT              = 'NEW_COMMIT';
EVENT.LOGREADER_CHANGED_FILE  = 'LOGREADER_CHANGED_FILE';

-- Make table read-only.
return setmetatable( EVENT, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key );
    end,
    __newindex = function()
        error( "Can't change a constant value." );
    end
});
