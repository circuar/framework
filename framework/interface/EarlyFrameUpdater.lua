local Core = require "framework.core.base.Core"
local Logger = require "framework.utils.Logger"


local logger = Logger.new("EarlyFrameUpdater", "framework")



---@class EarlyFrameUpdater
---@field private callback function -- 回调函数，在每帧早期更新时调用
---@field private index integer -- 更新器的索引，用于注册和取消注册
---@field private running boolean -- 是否正在运行
local EarlyFrameUpdater = {}
EarlyFrameUpdater.__index = EarlyFrameUpdater

function EarlyFrameUpdater.new(callback)
    if type(callback) ~= "function" then
        error("EarlyFrameUpdater requires a callback function")
    end

    local self = setmetatable({}, EarlyFrameUpdater)
    EarlyFrameUpdater.callback = callback

    local updaterIndex = Core.registerEarlyFrameUpdater(self) -- 注册到Core的帧前updater列表
    self.index = updaterIndex

    self.running = true -- 是否正在运行
    return self
end

---设置帧回调函数
---@param callback function 回调函数
function EarlyFrameUpdater:setCallback(callback)
    self.callback = callback
end

---取消注册帧前回调
function EarlyFrameUpdater:cancel()
    if not self.running then
        logger:warn("EarlyFrameUpdater is not running, cannot cancel.")
        return
    end
    Core.unregisterEarlyFrameUpdater(self.index) -- 取消注册
end

function EarlyFrameUpdater:resume()
    if self.running then
        logger:warn("EarlyFrameUpdater is already running, cannot resume.")
        return
    end
    self.running = true
    self.index = Core.registerEarlyFrameUpdater(self) -- 重新注册到Core的帧前updater列表
end
