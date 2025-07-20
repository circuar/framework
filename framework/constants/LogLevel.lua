---@alias LogLevel
---| 1 DEBUG 调试信息
---| 2 INFO  一般信息
---| 3 WARN 警告信息
---| 4 ERROR 错误信息
---| 5 DISABLE 禁用日志

---@type LogLevel
local LogLevel = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    DISABLE = 5,
}

return LogLevel
