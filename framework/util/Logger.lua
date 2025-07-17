-- Logger.lua
local Logger = {}
Logger.__index = Logger

-- Log levels
Logger.levels = { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4, NONE = 5 }

-- Default settings
local DEFAULT_LEVEL = Logger.levels.INFO
local DEFAULT_BUFFER_SIZE = 1024

-- Utility: pre-allocate buffer table
local function createBuffer(size)
    local buf = {}
    for i = 1, size do buf[i] = nil end
    return buf
end

-- Constructor
-- name: string identifier for the logger
-- opts: table { level, bufferSize, timeProvider, sinks }
function Logger.new(name, opts)
    opts = opts or {}
    local self = setmetatable({}, Logger)
    self.name = name or ""
    self.level = opts.level or DEFAULT_LEVEL
    self.bufferSize = opts.bufferSize or DEFAULT_BUFFER_SIZE
    self.buffer = createBuffer(self.bufferSize)
    self.bufIndex = 1
    -- timeProvider: function returning a numeric timestamp
    self.timeProvider = opts.timeProvider or function() return 0 end
    -- sinks: a table of functions(message, level)
    self.sinks = {}
    -- default sink uses game engine print or fallback to standard print
    local defaultSink = opts.defaultSink or function(message, level)
        if _G.print then _G.print(message) end
    end
    self.sinks[1] = defaultSink
    return self
end

-- Internal: format message
function Logger:formatEntry(levelName, message)
    local timestamp = self.timeProvider()
    -- Example format: [1234.56] [LoggerName] [INFO] Message
    return string.format("[%.3f] [%s] [%s] %s", timestamp, self.name, levelName, tostring(message))
end

-- Internal: record to buffer
function Logger:recordEntry(entry)
    self.buffer[self.bufIndex] = entry
    self.bufIndex = self.bufIndex % self.bufferSize + 1
end

-- Internal: output to all sinks
function Logger:outputEntry(formatted, levelVal)
    for _, sink in ipairs(self.sinks) do
        local ok, err = pcall(sink, formatted, levelVal)
        if not ok then
            _G.print(string.format("Logger sink error: %s", err))
        end
    end
end

-- Generic log method
function Logger:log(levelName, levelVal, message)
    if levelVal < self.level then return end
    local formatted = self:formatEntry(levelName, message)
    -- record and output
    self:recordEntry({ time = self.timeProvider(), level = levelName, message = message })
    self:outputEntry(formatted, levelVal)
end

-- Level-specific methods
function Logger:debug(message) self:log("DEBUG", Logger.levels.DEBUG, message) end

function Logger:info(message) self:log("INFO", Logger.levels.INFO, message) end

function Logger:warn(message) self:log("WARN", Logger.levels.WARN, message) end

function Logger:error(message) self:log("ERROR", Logger.levels.ERROR, message) end

-- Change log level
function Logger:setLevel(levelName)
    local lvl = Logger.levels[levelName]
    if lvl then self.level = lvl end
end

-- Add a sink: function(message, level)
function Logger:addSink(sinkFn)
    table.insert(self.sinks, sinkFn)
end

-- Remove a sink by reference
function Logger:removeSink(sinkFn)
    for i = #self.sinks, 1, -1 do
        if self.sinks[i] == sinkFn then
            table.remove(self.sinks, i)
        end
    end
end

-- Retrieve recent log history (most recent first)
function Logger:getHistory(count)
    count = count or self.bufferSize
    local records = {}
    local idx = self.bufIndex - 1
    if idx == 0 then idx = self.bufferSize end
    for i = 1, math.min(count, self.bufferSize) do
        local entry = self.buffer[idx]
        if not entry then break end
        table.insert(records, entry)
        idx = idx - 1
        if idx == 0 then idx = self.bufferSize end
    end
    return records
end

-- Clear buffer history
function Logger:clearHistory()
    for i = 1, self.bufferSize do self.buffer[i] = nil end
    self.bufIndex = 1
end

return Logger
