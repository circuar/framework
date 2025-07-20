local bootstrap = require("framework.bootstrap")
local LogLevel  = require("framework.constants.LogLevel")
local Logger    = require("framework.utils.Logger")


local logger = Logger.new("bootstrap", "framework")



---@module "init"
---程序初始化入口
---你需要确保init模块在程序执行时最先被require
local init = {
    started = false, --初始化标志
}



function init.run(logLevel, runTest, enableDeveloperMode)
    -- 初始化逻辑

    if init.started then
        print("[ init ] already started, skip re-initialization.")
        return
    end

    local banner = require("framework.resources.banner")

    print(banner)

    local bootParams = {
        logLevel = logLevel or LogLevel.INFO,              -- 日志级别
        runTest = runTest or false,                        -- 是否运行测试
        enableDeveloperMode = enableDeveloperMode or false -- 是否启用开发者模式
    }

    bootstrap.start(bootParams) -- 调用bootstrap模块的初始化方法

    logger:info("boot success.")

    init.started = true -- 设置初始化标志为true
end

return init
