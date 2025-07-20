local Logger               = require("framework.utils.Logger")
local api                  = require("framework.api")
local PlatformTimeProvider = require("framework.core.PlatformTimeProvider")
local Core                 = require("framework.core.base.Core")
local PlayerManager        = require("framework.core.PlayerManager")

local bootstrap            = {}

function bootstrap.start(param)
    if param.enableDeveloperMode then
        api.base.enableDeveloperMode()
    end

    Logger.init(param.logLevel, nil, PlatformTimeProvider.currentFrameTime)

    Core.init()

    PlayerManager.init()


end

return bootstrap
