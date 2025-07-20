local Core = require "framework.core.base.Core"
local GlobalConst = require "framework.constants.GlobalConst"



---@class PlatformTimeProvider
local PlatformTimeProvider = {}


function PlatformTimeProvider.currentFrameTime()
    return Core.getFrameCount() * GlobalConst.LOGIC_FRAME_TIME
end

return PlatformTimeProvider
