local Core = require "framework.core.base.Core"
local Logger = require "framework.utils.Logger"


local logger = Logger.new("LateFrameUpdater", "framework")



---@class LateFrameUpdater
---@field private callback function -- 回调函数，在每帧后调用
---@field private index integer -- 更新器的索引，用于注册和取消注册
---@field private running boolean -- 是否正在运行
local LateFrameUpdater = {}
LateFrameUpdater.__index = LateFrameUpdater

function LateFrameUpdater.new(callback)
    if type(callback) ~= "function" then
        error("LateFrameUpdater requires a callback function")
    end

    local self = setmetatable({}, LateFrameUpdater)
    LateFrameUpdater.callback = callback

    local updaterIndex = Core.registerLateFrameUpdater(self)
    self.index = updaterIndex

    self.running = true -- 是否正在运行
    return self
end

---设置帧回调函数
---@param callback function 回调函数
function LateFrameUpdater:setCallback(callback)
    self.callback = callback
end

---取消注册帧前回调
function LateFrameUpdater:cancel()
    if not self.running then
        logger:warn("LateFrameUpdater is not running, cannot cancel.")
        return
    end
    Core.unregisterLateFrameUpdater(self.index) -- 取消注册
end

function LateFrameUpdater:resume()
    if self.running then
        logger:warn("LateFrameUpdater is already running, cannot resume.")
        return
    end
    self.running = true
    self.index = Core.registerLateFrameUpdater(self)
end
