local api = require "framework.api"
local Logger = require("framework.utils.Logger")

local logger = Logger.new("Core", "framework")

---@class Core
---@field earlyUpdaters table<function>
---@field lateUpdaters table<function>
---@field frameCount number -- 当前帧计数
local Core = {
    earlyFrameUpdaters = {},
    lateFrameUpdaters = {},
    frameCount = 0,
    initialized = false
}



local function registerFrameUpdateProxy()
    logger:info("registering frame update proxy function.")
    local function earlyUpdateProxy()
        for index, value in ipairs(Core.earlyFrameUpdaters) do
            value.callback()
        end
    end

    local function lateUpdateProxy()
        for index, value in ipairs(Core.lateFrameUpdaters) do
            value.callback()
        end
        Core.frameCount = Core.frameCount + 1
    end

    api.base.registerFrameHandler(earlyUpdateProxy, lateUpdateProxy)
end

function Core.init()
    if Core.initialized then
        return
    end
    registerFrameUpdateProxy()
    Core.initialized = true

    logger:info("core initialized.")
end

---注册帧前回调
---@param updater EarlyFrameUpdater
---@return integer index 返回更新器的索引
function Core.registerEarlyFrameUpdater(updater)
    table.insert(Core.earlyFrameUpdaters, updater)
    return #Core.earlyFrameUpdaters
end

---取消注册帧前回调
---@param index integer 更新器的索引
function Core.unregisterEarlyFrameUpdater(index)
    table.remove(Core.earlyFrameUpdaters, index)
end

---注册帧后回调
---@param updater LateFrameUpdater
---@return integer index 返回更新器的索引
function Core.registerLateFrameUpdater(updater)
    table.insert(Core.lateFrameUpdaters, updater)
    return #Core.lateFrameUpdaters
end

---取消注册帧后回调
---@param index integer 更新器的索引
function Core.unregisterLateFrameUpdater(index)
    table.remove(Core.lateFrameUpdaters, index)
end

---获取当前帧计数
---@return integer
function Core.getFrameCount()
    return Core.frameCount
end

return Core
