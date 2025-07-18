# ObjectPool

**语言/Language**: Lua 5.4+  
**依赖/Dependencies**: 无外部依赖（No external dependencies）  
**兼容性/Compatibility**: 仅支持 `number` 和 `string` 类型作为键（Only `number` and `string` keys supported）

## 📦 简介 / Introduction

`ObjectPool` 是一个高性能、可扩展的 Lua 对象池管理器，适用于游戏逻辑中大量对象的复用，显著减少内存分配和垃圾回收压力。

ObjectPool is a high-performance, extensible object pooling manager for Lua. It's designed to minimize memory allocations and GC overhead in high-frequency object usage scenarios, especially in game development.

## 🚀 特性 / Features

- 支持对象获取 (`acquire`) 与回收 (`release`)
- 支持预分配、清理与裁剪空闲对象
- 提供当前池容量、活动对象数、空闲数量等统计
- 可选注入时间或帧计数器以进行效率分析（默认禁用）

## 🧱 使用示例 / Usage Example

```lua
local ObjectPool = require("ObjectPool")

-- 示例对象构造器 / Object constructor
local function createBullet()
    return { x = 0, y = 0, vx = 0, vy = 0 }
end

-- 创建对象池 / Create a pool
local pool = ObjectPool.new(createBullet, 100)

-- 获取对象 / Acquire
local bullet = pool:acquire()
bullet.x = 10

-- 回收对象 / Release
pool:release(bullet)

-- 获取统计信息 / Get stats
local utilization, efficiency = pool:stats()
print("Utilization:", utilization, "Efficiency:", efficiency)
````

## ⚙️ 接口说明 / API Reference

### `ObjectPool.new(factory: function, maxCapacity: number, timeProvider: function|nil): ObjectPool`

创建一个新的对象池。

| 参数             | 说明                                                                   |
| -------------- | -------------------------------------------------------------------- |
| `factory`      | 对象构造函数（每次需要新对象时调用）<br>Function to create new objects                 |
| `maxCapacity`  | 最大对象容量（包括已释放与在用）<br>Maximum number of pooled objects                 |
| `timeProvider` | （可选）返回时间戳或帧数的函数，默认返回0<br>Optional time/frame provider, defaults to 0 |

---

### `acquire(): any`

从池中获取一个对象。

🔁 若空闲对象池为空，则会创建新对象。

---

### `release(obj: any): boolean`

回收一个对象。

返回值：

* `true`：成功回收
* `false`：池已满，回收失败

---

### `clear(): number`

清空所有空闲对象。

返回值：被清除的空闲对象数量。

---

### `preallocate(count: number): number`

预先分配指定数量的对象填充空闲池。

返回值：实际成功创建并添加的对象数。

---

### `prune(threshold: number): number`

裁剪空闲池中未使用超过 `threshold` 时间的对象。

> 需要提供 `timeProvider` 参数，否则所有对象时间戳恒为0。

返回值：被裁剪对象数量。

---

### `freeCount(): number`

返回当前空闲对象数量。

---

### `activeCount(): number`

返回当前活跃对象数量（已获取但未回收）。

---

### `capacity(): number`

返回当前池总对象数量（空闲 + 活跃）。

---

### `stats(): (number, number)`

返回池的使用率与效率（百分比）：

* 利用率 Utilization = 活跃 / 总容量
* 效率 Efficiency = 活跃 / maxCapacity

---

## 🧪 注意事项 / Notes

* 本模块不支持 `table` 类型作为键（Lua table 仅支持 `number` 和 `string` 键的高效哈希）
* 若需时间相关功能，请显式传入帧计数器或计时函数
* 对象在回收后应被外部逻辑重置以避免状态泄露


# StateMachine


## 概览 Overview

`StateMachine` 是一个轻量、可嵌套、支持状态栈与转换历史的状态机实现，适用于游戏或业务逻辑场景。
A lightweight, nestable finite state machine with stack-based history, suitable for game or business logic.

---

## 配置表结构 Configuration Table

| 字段                        | 类型                                 | 说明（中）                                           | Description (EN)                                      |
| ------------------------- | ---------------------------------- | ----------------------------------------------- | ----------------------------------------------------- |
| `states`                  | `table<string,State>`              | 状态定义字典，键为状态名，值为含生命周期回调的 table                   | Map of state names to state-def tables with callbacks |
| `initialState`            | `string`                           | 初始状态名，必须存在于 `states`                            | Initial state name (must exist in `states`)           |
| `transitions`             | `table<string,table<string,bool>>` | 本地转换规则：`transitions[fromState][toState] = true` | Local transitions: `transitions[from][to] = true`     |
| `globalTransitions`       | `table<string,any>`                | 全局转换：键为目标状态名列表或事件，可定义跨状态通用跳转                    | Global transitions rules                              |
| `subMachines`             | `table<string,StateMachine>`       | 子状态机映射，键为状态名，值为另一个 `StateMachine` 实例            | Sub-machine mapping: state → nested `StateMachine`    |
| `subMachineInitialStates` | `table<string,string>`             | 子机初始状态：`[stateName] = initialSubStateName`      | Initial state map for sub-machines                    |
| `historyLimit` *(可选)*     | `number`                           | 保留转换历史最大长度，超出最早的被丢弃，默认 `100`                    | Max length of history stack (default `100`)           |
| `maxRecursion` *(可选)*     | `number`                           | 事件嵌套派发最大深度，防止死循环，默认 `10`                        | Max recursion depth for event dispatch (default `10`) |

---

## State 对象结构 State Object

每个状态（`states[name]`）为一个 table，可包含以下回调函数：

| 回调         | 签名                                 | 说明（中）                          | Description (EN)                                                        |
| ---------- | ---------------------------------- | ------------------------------ | ----------------------------------------------------------------------- |
| `onEnter`  | `function(self, ...): void`        | 切入状态时调用，接收 `changeState` 传入的参数 | Called when entering state; receives parameters passed to `changeState` |
| `onExit`   | `function(self, ...): void`        | 退出状态时调用，接收 `changeState` 传入的参数 | Called when exiting state; receives parameters passed to `changeState`  |
| `onUpdate` | `function(self, dt: number): void` | 每帧调用，`dt` 为两帧间隔                | Called every frame; `dt` is time delta                                  |

---

## 常用方法 API

### `StateMachine.new(config)`

* **参数**

  * `config` (`table`)

    * 必填字段见上「配置表结构」。

* **返回**

  * `StateMachine` 实例

```lua
local sm = StateMachine.new{
  states = {
    Idle = { onEnter = function() print("Enter Idle") end },
    Run  = { onEnter = function() print("Enter Run")  end },
  },
  initialState = "Idle",
  transitions = {
    Idle = { Run = true },
  },
  globalTransitions = {},
  subMachines = {},
  subMachineInitialStates = {},
  historyLimit = 50,
  maxRecursion = 5,
}
```

---

### `sm:getCurrentState() → string`

返回当前活动状态名；
Returns the name of the current active state.

```lua
print(sm:getCurrentState())  --> "Idle"
```

---

### `sm:getCurrentStateObject() → table`

返回当前状态对应的状态对象（含回调）；
Returns the state-def table of the current state.

```lua
local stateDef = sm:getCurrentStateObject()
print(stateDef.onUpdate)  -- function or nil
```

---

### `sm:setSubMachineInitialState(name, initial)`

* **参数**

  * `name` (`string`) —— 子状态机所挂载的主状态名。
  * `initial` (`string`) —— 子机器的初始状态名。

为之后的 `addSubMachine` 或 `changeState` 自动初始化子机使用；
Sets the initial state for a named sub-machine for later initialization.

---

### `sm:changeState(to, ...) → boolean`

* **参数**

  * `to` (`string`) —— 目标状态名。
  * `...` (`any`) —— 传递给 `onExit`/`onEnter` 的可变参数。

* **返回**

  * `boolean` —— 切换是否成功。

执行以下步骤：

1. 调用前一状态的 `onExit(...)`
2. 记录历史（`historyLimit` 控制长度）
3. 更新 `currentState`
4. 调用新状态的 `onEnter(...)`
5. 若目标状态挂载子机，则初始化该子机

```lua
sm:changeState("Run", "fromIdle")
```

---

### `sm:canChange(from, to) → boolean`

* **参数**

  * `from` (`string`) —— 当前状态名。
  * `to`   (`string`) —— 目标状态名。

* **返回**

  * `boolean` —— 是否存在本地或全局转换规则。

检查 `transitions[from][to]` 或 `globalTransitions[to]`。

---

### `sm:pushState(state)`

* **参数**

  * `state` (`string`) —— 新状态名。

将当前状态压入内部栈，再切换到新状态，支持临时中断场景。

---

### `sm:popState() → boolean`

* **返回**

  * `boolean` —— 是否成功回退（栈非空）。

弹出最近一次 `pushState` 的状态并切换回去。

---

### `sm:popUntil(predicate)`

* **参数**

  * `predicate` (`function(stateName: string): boolean`) —— 条件函数。

持续回退栈顶状态，直到 `predicate(top)` 为 `true`，并最终切换到该状态。

---

### `sm:update(dt)`

* **参数**

  * `dt` (`number`) —— 帧间隔时间。

执行：

1. 当前状态的 `onUpdate(self, dt)`
2. 所有子状态机的 `update(dt)`

---

### `sm:addSubMachine(name, machine)`

* **参数**

  * `name`    (`string`) —— 作为挂载点的主状态名。
  * `machine` (`StateMachine`) —— 已创建好的子状态机实例。

注册子机，并在当前挂载状态切换时自动切换至其初始状态。

---

### `sm:getSubMachine(name) → StateMachine`

* **参数**

  * `name` (`string`) —— 子状态机名称。
* **返回**

  * 对应的 `StateMachine` 实例或 `nil`。

---

## 完整示例 Complete Example

```lua
-- 定义主状态机
local sm = StateMachine.new{
  states = {
    Idle = {
      onEnter = function(self) print("Enter Idle") end,
      onExit  = function(self) print("Exit Idle")  end,
    },
    Combat = {}
  },
  initialState = "Idle",
  transitions = { Idle = { Combat = true } },
  globalTransitions = {},
  subMachines = {},
  subMachineInitialStates = { Combat = "Move" },
  historyLimit = 10,
  maxRecursion = 5,
}

-- 定义并挂载子状态机
local sub = StateMachine.new{
  states = {
    Move   = { onEnter = function() print("Move") end },
    Attack = { onEnter = function() print("Attack") end },
  },
  initialState = "Move",
  transitions = { Move = { Attack = true }, Attack = { Move = true } },
}
sm:addSubMachine("Combat", sub)

-- 切换到 Combat
sm:changeState("Combat")        -- 输出： Exit Idle  Enter Combat  Move
-- 子机切换
sm:changeState("Attack")        -- 作用于 Combat 状态机： Attack
-- 更新循环
sm:update(0.016)
```

---
