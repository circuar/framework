--[[
StateMachine.lua

功能 (Features):
  • 轻量级、可嵌套状态机支持 (Nested state machines)
  • 状态栈与历史回退 (State stack & history)
  • 本地与全局转换规则 (Local & global transitions)
  • 可定制历史深度与递归深度 (Configurable history & recursion limits)

用法示例 (Usage Example):
```lua
-- 定义状态回调
local states = {
  Idle = {
    onEnter  = function(self) print("Entered Idle")  end,
    onExit   = function(self) print("Exited Idle")   end,
    onUpdate = function(self, dt) print("Updating Idle", dt) end,
  },
  Run = {
    onEnter = function(self) print("Entered Run") end,
    onExit  = function(self) print("Exited Run")  end,
  },
}

-- 定义转换规则
local transitions = { Idle = { Run = true }, Run = { Idle = true } }

-- 创建主状态机
local sm = StateMachine.new{
  states = states,
  initialState = "Idle",
  transitions = transitions,
  globalTransitions = {},
  subMachines = {},
  subMachineInitialStates = {},
  historyLimit = 10,
  maxRecursion = 5,
}

-- 切换并更新状态
sm:changeState("Run")       -- 切换到 Run
sm:update(0.16)              -- 调用 Run.onUpdate (如果定义)
sm:pushState("Idle")        -- 临时回到 Idle
sm:popState()                -- 回退到 Run
```
]]

local StateMachine = {}
StateMachine.__index = StateMachine

--- 创建并返回一个状态机实例
--
-- @param config table 配置表，字段：
--   • states table<string,State> — 状态定义表 (必须)
--     - State 为含 onEnter/onExit/onUpdate 函数的 table
--   • initialState string — 初始状态名称 (必须)
--   • transitions table<string,table<string,boolean>> — 本地转换规则 (可选)
--   • globalTransitions table<string,table<{ fromMap?:table<string,boolean>, to:string }>> — 全局转换规则 (可选)
--   • subMachines table<string,StateMachine> — 子状态机实例映射 (可选)
--   • subMachineInitialStates table<string,string> — 子机初始状态映射 (可选)
--   • historyLimit number — 历史记录最大长度，默认100 (可选)
--   • maxRecursion number — 最大递归深度，默认10 (可选)
--
-- @return StateMachine 新实例
--
-- 注意事项 (Notes):
-- • config.states 和 config.initialState 必须提供且匹配，否则行为未定义。
-- • transitions 和 globalTransitions 优先级：本地 > 全局。
--
function StateMachine.new(config)
    local self                   = setmetatable({}, StateMachine)
    self.states                  = config.states or {}
    self.currentState            = config.initialState
    self.previousStates          = {}
    self.stateStack              = {}
    self.transitions             = config.transitions or {}
    self.globalTransitions       = config.globalTransitions or {}
    self.subMachines             = config.subMachines or {}
    self.subMachineInitialStates = config.subMachineInitialStates or {}
    self.historyLimit            = config.historyLimit or 100
    self.maxRecursion            = config.maxRecursion or 10
    return self
end

--- 获取当前活动状态名称
--
-- @return string 当前状态名
--
-- @example
-- local name = sm:getCurrentState()
-- print(name)  -- "Idle"
--
function StateMachine:getCurrentState()
    return self.currentState
end

--- 获取当前状态对象
--
-- @return table? 状态定义表或 nil
--
-- @example
-- local stateDef = sm:getCurrentStateObject()
-- if stateDef and stateDef.onUpdate then stateDef.onUpdate(sm, 0.16) end
function StateMachine:getCurrentStateObject()
    return self.states[self.currentState]
end

--- 设置子状态机的初始状态，覆盖构造时配置
--
-- @param name string 主状态名，对应 subMachines[name]
-- @param initial string 子状态机的初始状态名
--
-- @example
-- sm:setSubMachineInitialState("Combat", "Move")
function StateMachine:setSubMachineInitialState(name, initial)
    assert(type(name) == "string" and type(initial) == "string",
        "Invalid parameters for setSubMachineInitialState")
    self.subMachineInitialStates[name] = initial
end

--- 重置状态机并递归重置所有子状态机
--
-- 清空 currentState, previousStates, stateStack
--
-- @example
-- sm:reset()
function StateMachine:reset()
    self.currentState   = nil
    self.previousStates = {}
    self.stateStack     = {}
    for _, machine in pairs(self.subMachines) do
        machine:reset()
    end
end

--- 清除所有状态定义与转换规则，仅保留子机初始配置
--
-- 通常用于销毁或重新初始化
--
-- @example
-- sm:clear()
function StateMachine:clear()
    self.states            = {}
    self.currentState      = nil
    self.previousStates    = {}
    self.stateStack        = {}
    self.transitions       = {}
    self.globalTransitions = {}
    self.subMachines       = {}
end

--- 每帧调用以更新当前状态及子状态机
--
-- @param dt number 两帧间隔时间
--
-- @example
-- sm:update(0.016)
function StateMachine:update(dt)
    local name  = self.currentState
    local state = self.states[name]
    if state and state.onUpdate then
        state.onUpdate(self, dt)
    end
    for _, machine in pairs(self.subMachines) do
        machine:update(dt)
    end
end

--- 切换到指定状态并执行 onExit/onEnter 回调
--
-- @param to string 目标状态名
-- @param ... any 传递给回调的参数
-- @return boolean true=成功，false=无效
--
-- @example
-- if sm:changeState("Run", playerId) then
--   print("Switched to Run")
-- end
--
-- 注意事项：
-- • 调用前须通过 canChange 验证，否则返回 false。
-- • historyLimit 控制 previousStates 大小。
function StateMachine:changeState(to, ...)
    local from = self.currentState
    if not self:canChange(from, to) then return false end
    if from then
        local prev = self.states[from]
        if prev and prev.onExit then prev.onExit(self, ...) end
        table.insert(self.previousStates, from)
        if #self.previousStates > self.historyLimit then
            table.remove(self.previousStates, 1)
        end
    end
    self.currentState = to
    local nextState = self.states[to]
    if nextState and nextState.onEnter then nextState.onEnter(self, ...) end
    return true
end

--- 检查是否存在合法的状态转换规则
--
-- @param from string? 源状态名
-- @param to   string 目标状态名
-- @return boolean
--
-- @example
-- print(sm:canChange("Idle", "Run"))  -- true
function StateMachine:canChange(from, to)
    if from and self.transitions[from] and self.transitions[from][to] then return true end
    if self.globalTransitions[to] then return true end
    return false
end

--- 将当前状态压入栈并切换到新状态
--
-- 适用于临时场景，如菜单、对话框
--
-- @param state string 要切换到的状态名
-- @example
-- sm:pushState("Menu")
function StateMachine:pushState(state)
    table.insert(self.stateStack, self.currentState)
    self:changeState(state)
end

--- 从状态栈弹出并切换到弹出状态
--
-- @return boolean 成功切换与否
-- @example
-- if sm:popState() then print("Returned from Menu") end
function StateMachine:popState()
    local prev = table.remove(self.stateStack)
    if prev then return self:changeState(prev) end
    return false
end

--- 持续弹出状态栈直至满足条件
--
-- @param predicate function(string):boolean 条件为 true 时停止
-- @example
-- sm:popUntil(function(s) return s=="Idle" end)
function StateMachine:popUntil(predicate)
    for i = 1, self.maxRecursion do
        local top = self.stateStack[#self.stateStack]
        if not top or predicate(top) then break end
        table.remove(self.stateStack)
    end
    local top = self.stateStack[#self.stateStack]
    if top then self:changeState(top) end
end

--- 添加并初始化子状态机
--
-- @param name string 主状态名
-- @param machine StateMachine 子机实例
-- @example
-- sm:addSubMachine("Combat", combatFSM)
function StateMachine:addSubMachine(name, machine)
    assert(type(name) == "string" and getmetatable(machine) == StateMachine,
        "Invalid sub-machine registration")
    self.subMachines[name] = machine
    local init = self.subMachineInitialStates[name]
    if init then machine:changeState(init) end
end

--- 获取已注册的子状态机
--
-- @param name string 主状态名
-- @return StateMachine? 子机实例或 nil
-- @example
-- local combatFSM = sm:getSubMachine("Combat")
function StateMachine:getSubMachine(name)
    return self.subMachines[name]
end

return StateMachine
