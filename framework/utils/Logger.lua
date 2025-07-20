local LogLevel = require("framework.constants.LogLevel")


local DEFAULT_LOG_LEVEL = LogLevel.INFO
local DEFAULT_BUFFER_SIZE = 256

local LogLevelStringMap = {
    [LogLevel.DEBUG] = "DEBUG",
    [LogLevel.INFO] = "INFO",
    [LogLevel.WARN] = "WARN",
    [LogLevel.ERROR] = "ERROR",
    [LogLevel.DISABLE] = "DISABLE"
}

---@class Logger
---@field private name string -- 日志记录器名称
---@field private channel string -- 日志通道
---@field private level LogLevel -- 日志级别
---@field private bufferSize number -- 缓冲区大小
---@field private buffer table -- 缓冲区，用于存储日志记录
---@field private bufferIndex number -- 当前缓冲区索引
---@field private timeProvider function -- 时间提供者函数，返回当前时间戳
---@field private initialized boolean -- 是否已经初始化
local Logger = {
    level = DEFAULT_LOG_LEVEL,        -- 默认日志级别
    bufferSize = DEFAULT_BUFFER_SIZE, -- 默认缓冲区大小
    buffer = {},                      -- 缓冲区，用于存储日志记录
    bufferIndex = 1,                  -- 当前缓冲区索引
    timeProvider = function()
        return 0                      -- 默认时间提供者，返回当前时间戳
    end,
    initialized = false               -- 是否已经初始化
}
Logger.__index = Logger


-- 预分配日志缓冲区
local function createBuffer(size)
    local buffer = {}
    for i = 1, size do buffer[i] = nil end
    return buffer
end

-- 格式化
local function format(logLevel, name, channel, message)
    local time = Logger.timeProvider()
    return string.format("$ %s [%s] %s @ %s >>> %s", time, logLevel, name, channel, message)
end

-- 日志级别转换为字符串
local function logLevelToString(logLevel)
    return LogLevelStringMap[logLevel] or "UNKNOWN"
end

---初始化日志记录器
---@param level LogLevel?
---@param bufferSize integer?
---@param timeProvider function?
function Logger.init(level, bufferSize, timeProvider)
    if Logger.initialized then
        print("[ logger ] Logger is already initialized, ignored.")
        return false
    end

    Logger.level = level or DEFAULT_LOG_LEVEL
    Logger.bufferSize = bufferSize or DEFAULT_BUFFER_SIZE
    if timeProvider then
        Logger.timeProvider = timeProvider
    end

    ---初始化日志缓冲区
    Logger.buffer = createBuffer(Logger.bufferSize)

    Logger.initialized = true

    return true
end

--- 构造器
---@param name string 日志记录器名称
---@param chanel string 日志通道
---@return Logger
function Logger.new(name, chanel)
    local self = setmetatable({
        name = name or "default",
        channel = chanel or "none"
    }, Logger)
    return self
end

--- 记录日志
---@param logLevel LogLevel 日志级别
---@param message string 日志消息
function Logger:log(logLevel, message)
    if not Logger.initialized then
        print("[ logger ] Logger is not initialized, please call Logger.init() first.")
        return
    end

    if logLevel < Logger.level then
        return -- 如果日志级别低于当前设置的级别，则不记录日志
    end

    local formattedMessage = format(logLevelToString(logLevel), self.name, self.channel, message)

    -- 将日志消息存储到缓冲区
    self.buffer[self.bufferIndex] = formattedMessage
    self.bufferIndex = (self.bufferIndex % self.bufferSize) + 1

    print(formattedMessage)
end

---打印调试日志
---@param message string
function Logger:debug(message) self:log(LogLevel.DEBUG, message) end

---打印一般日志
---@param message string
function Logger:info(message) self:log(LogLevel.INFO, message) end

---打印警告日志
---@param message string
function Logger:warn(message) self:log(LogLevel.WARN, message) end

---打印错误日志
---@param message string
function Logger:error(message) self:log(LogLevel.ERROR, message) end

---清空日志缓冲区
function Logger.clearBuffer()
    for i = 1, Logger.bufferSize do Logger.buffer[i] = nil end
    Logger.bufIndex = 1
end

return Logger
