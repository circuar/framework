-- 状态机模块
local StateMachine = {}
StateMachine.__index = StateMachine

-- 创建一个新的状态机实例
function StateMachine.new()
    local self = setmetatable({}, StateMachine)
    self.states = {}      -- 存储所有状态 (key: 状态名称, value: {onEnter, onExit, onUpdate, submachine})
    self.transitions = {} -- 存储所有转换 {from, to, event, guard}
    self.current = nil    -- 当前状态名称
    self.initial = nil    -- 初始状态名称
    return self
end

-- 添加状态，config 包含 onEnter、onExit、onUpdate、submachine 等可选字段
function StateMachine:addState(name, config)
    config = config or {}
    self.states[name] = {
        onEnter    = config.onEnter,
        onExit     = config.onExit,
        onUpdate   = config.onUpdate,
        submachine = config.submachine
    }
end

-- 设定初始状态 (并执行该状态的 onEnter，如果有子状态机则启动子状态机)
function StateMachine:setInitial(stateName)
    assert(self.states[stateName], "StateMachine:setInitial - Unknown state: " .. tostring(stateName))
    self.initial = stateName
    self.current = stateName
    local state = self.states[stateName]
    -- 执行入口回调
    if state.onEnter then state.onEnter(self) end
    -- 启动子状态机（如果存在）
    if state.submachine then
        state.submachine:start()
    end
end

-- 启动（或重启）状态机，从初始状态开始
function StateMachine:start()
    assert(self.initial, "StateMachine:start - initial state not set")
    self.current = self.initial
    local state = self.states[self.current]
    if state.onEnter then state.onEnter(self) end
    if state.submachine then state.submachine:start() end
end

-- 添加状态转换，参数：源状态、目标状态、触发事件（可选）、守卫条件（可选）
-- 如果第三个参数是函数，则视作 guard；否则为事件名
function StateMachine:addTransition(from, to, eventOrGuard, guard)
    assert(self.states[from], "StateMachine:addTransition - Unknown from state: " .. tostring(from))
    assert(self.states[to], "StateMachine:addTransition - Unknown to state: " .. tostring(to))
    if type(eventOrGuard) == "function" then
        guard = eventOrGuard
        eventOrGuard = nil
    end
    local trans = { from = from, to = to, event = eventOrGuard, guard = guard }
    table.insert(self.transitions, trans)
end

-- 内部方法：退出当前状态，包括递归退出子状态机
function StateMachine:_exitCurrent()
    if not self.current then return end
    local state = self.states[self.current]
    -- 先递归退出子状态机
    if state.submachine then
        state.submachine:_exitCurrent()
    end
    -- 调用当前状态的 onExit 钩子
    if state.onExit then state.onExit(self) end
    self.current = nil
end

-- 触发事件转换，返回 true 表示状态已切换
function StateMachine:trigger(event, ...)
    local currentState = self.current
    local state = self.states[currentState]
    -- 如果当前状态有子状态机，尝试先由子状态机处理事件
    if state and state.submachine then
        local handled = state.submachine:trigger(event, ...)
        if handled then return true end
    end
    -- 查找当前状态下匹配事件的转换
    for _, trans in ipairs(self.transitions) do
        if trans.from == currentState and trans.event == event then
            local ok = true
            if trans.guard then ok = trans.guard(self, ...) end
            if ok then
                -- 执行退出回调
                self:_exitCurrent()
                -- 切换状态并执行 onEnter
                self.current = trans.to
                local newState = self.states[self.current]
                if newState.onEnter then newState.onEnter(self, ...) end
                -- 启动子状态机（如果有）
                if newState.submachine then newState.submachine:start() end
                return true
            end
        end
    end
    return false
end

-- 直接转换到指定状态（无事件触发），返回 true 表示状态已切换
function StateMachine:transition(toState, ...)
    local currentState = self.current
    local state = self.states[currentState]
    -- 如果当前状态有子状态机，尝试在子状态机执行相同转换
    if state and state.submachine then
        local handled = state.submachine:transition(toState, ...)
        if handled then return true end
    end
    -- 查找匹配目标状态且无事件的转换
    for _, trans in ipairs(self.transitions) do
        if trans.from == currentState and trans.to == toState and not trans.event then
            local ok = true
            if trans.guard then ok = trans.guard(self, ...) end
            if ok then
                self:_exitCurrent()
                self.current = toState
                local newState = self.states[self.current]
                if newState.onEnter then newState.onEnter(self, ...) end
                if newState.submachine then newState.submachine:start() end
                return true
            end
        end
    end
    return false
end

-- 每帧更新状态机：更新子状态机、执行当前状态的 onUpdate，并检查无事件转换
function StateMachine:update(dt)
    if not self.current then return end
    local state = self.states[self.current]
    -- 更新子状态机
    if state.submachine then
        state.submachine:update(dt)
    end
    -- 执行当前状态的 onUpdate
    if state.onUpdate then state.onUpdate(self, dt) end
    -- 检查无事件守卫转换
    for _, trans in ipairs(self.transitions) do
        if trans.from == self.current and not trans.event then
            local ok = true
            if trans.guard then ok = trans.guard(self) end
            if ok then
                self:_exitCurrent()
                self.current = trans.to
                local newState = self.states[self.current]
                if newState.onEnter then newState.onEnter(self) end
                if newState.submachine then newState.submachine:start() end
                break -- 只执行首个符合条件的转换
            end
        end
    end
end

return StateMachine
