local StateMachine = require("framework.collection.StateMachine")

local function assertEq(a, b, msg)
    assert(a == b, msg or (tostring(a) .. " ~= " .. tostring(b)))
end

-- Test 1: Basic state transitions
do
    local fsm = StateMachine.new("Idle")
    local entered, exited = {}, {}
    fsm:addState("Idle", {
        onEnter = function() table.insert(entered, "Idle") end,
        onExit  = function() table.insert(exited, "Idle") end,
    })
    fsm:addState("Run", {
        onEnter = function() table.insert(entered, "Run") end,
        onExit  = function() table.insert(exited, "Run") end,
    })
    fsm:addTransition("Idle", "Run", "walk")
    fsm:addTransition("Run", "Idle", "stop")

    assertEq(fsm:peekState(), "Idle")
    fsm:dispatchEvent("walk")
    assertEq(fsm:peekState(), "Run")
    fsm:dispatchEvent("stop")
    assertEq(fsm:peekState(), "Idle")
    assert(entered[1] == "Run" and exited[1] == "Idle")
end

-- Test 2: Global transitions and guards
do
    local fsm = StateMachine.new("A")
    fsm:addState("A")
    fsm:addState("B")
    local guardCalled = false
    fsm:addGlobalTransition(nil, "B", "go", function()
        guardCalled = true; return true
    end)
    fsm:dispatchEvent("go")
    assertEq(fsm:peekState(), "B")
    assert(guardCalled)
end

-- Test 3: State stack and popState
do
    local fsm = StateMachine.new("S1")
    fsm:addState("S1")
    fsm:addState("S2")
    table.insert(fsm.stateStack, "S2")
    assertEq(fsm:peekState(), "S2")
    fsm:popState("back")
    assertEq(fsm:peekState(), "S1")
end

-- Test 4: History limit
do
    local fsm = StateMachine.new("X")
    fsm:addState("X")
    fsm:addState("Y")
    fsm:addState("Z")
    table.insert(fsm.stateStack, "Y")
    table.insert(fsm.stateStack, "Z")
    fsm:setHistoryLimit(2)
    assertEq(#fsm.stateStack, 2)
    assertEq(fsm.stateStack[1], "Y")
    assertEq(fsm.stateStack[2], "Z")
end

-- Test 5: Sub-state machines (hierarchical FSM)
do
    local parent = StateMachine.new("Main")
    local child = StateMachine.new("Sub")
    parent:addState("Main")
    parent:addState("WithSub")
    child:addState("Sub")
    child:addState("Sub2")
    parent:addSubStateMachine("WithSub", child)
    table.insert(parent.stateStack, "WithSub")
    child:dispatchEvent("toSub2") -- should do nothing (no transition)
    child:addTransition("Sub", "Sub2", "toSub2")
    child:dispatchEvent("toSub2")
    assertEq(child:peekState(), "Sub2")
    assert(parent:getCurrentState():find("WithSub%.Sub2"))
end

-- Test 6: Event queue and processQueue
do
    local fsm = StateMachine.new("A")
    fsm:addState("A")
    fsm:addState("B")
    fsm:addTransition("A", "B", "go")
    fsm:queueEvent("go")
    assertEq(fsm:peekState(), "A")
    fsm:processQueue()
    assertEq(fsm:peekState(), "B")
end

-- Test 7: popUntil and popWhile
do
    local fsm = StateMachine.new("1")
    fsm:addState("1")
    fsm:addState("2")
    fsm:addState("3")
    table.insert(fsm.stateStack, "2")
    table.insert(fsm.stateStack, "3")
    fsm:popUntil("2")
    assertEq(fsm:peekState(), "2")
    table.insert(fsm.stateStack, "3")
    fsm:popWhile(function(_, s) return s == "3" end)
    assertEq(fsm:peekState(), "2")
end

-- Test 8: onUpdate callback
do
    local updated = false
    local fsm = StateMachine.new("A")
    fsm:addState("A", { onUpdate = function() updated = true end })
    fsm:update(0.1)
    assert(updated)
end

-- Test 9: clear and reset
do
    local fsm = StateMachine.new("A")
    fsm:addState("A")
    fsm:addState("B")
    fsm:addTransition("A", "B", "go")
    fsm:dispatchEvent("go")
    assertEq(fsm:peekState(), "B")
    fsm:reset()
    assertEq(fsm:peekState(), "A")
    fsm:clear()
    assertEq(#fsm.stateStack, 0)
    assert(next(fsm.states) == nil)
end

print("All StateMachine tests passed.")
