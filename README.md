## StateMachine
``` lua
--[[ 用法示例 ]] --

-- 创建状态机实例
local fsm = StateMachine.new()

-- 定义状态及其回调
fsm:addState("Idle", {
    onEnter = function(self) print("Enter Idle") end,
    onUpdate = function(self, dt) print("Update Idle: dt=", dt) end,
})
fsm:addState("Run", {
    onEnter = function(self) print("Enter Run") end,
    onUpdate = function(self, dt) print("Update Run: dt=", dt) end,
})

-- 定义事件触发的转换（从 Idle 到 Run 由事件 "startRun" 触发）
fsm:addTransition("Idle", "Run", "startRun")
-- 定义从 Run 回到 Idle 的事件转换
fsm:addTransition("Run", "Idle", "stopRun")

-- 设定初始状态并触发 onEnter
fsm:setInitial("Idle")

-- 模拟游戏循环：每帧调用 update
fsm:update(0.016) -- 输出: Enter Idle; Update Idle: dt= 0.016

-- 触发事件进行状态切换
fsm:trigger("startRun") -- 输出: Enter Run
fsm:update(0.032)       -- 输出: Update Run: dt= 0.032

fsm:trigger("stopRun")  -- 输出: Enter Idle
fsm:update(0.016)       -- 输出: Update Idle: dt= 0.016

-- 嵌套状态机示例
local subSM = StateMachine.new()
subSM:addState("Walk", {
    onEnter = function(self) print("  Submachine: Walk") end
})
subSM:addState("Sprint", {
    onEnter = function(self) print("  Submachine: Sprint") end
})
subSM:setInitial("Walk")

fsm:addState("Move", {
    onEnter = function(self) print("Enter Move (parent state)") end,
    onUpdate = function(self, dt) print("Update Move (parent)") end,
    submachine = subSM
})
fsm:addTransition("Idle", "Move", "goMove")

fsm:trigger("goMove")
-- 输出:
-- Enter Move (parent state)
--   Submachine: Walk
fsm:update(0.016)
-- 输出:
-- Update Move (parent)
--   Submachine: Walk (子状态更新，假设Walk没有onUpdate内容)
```