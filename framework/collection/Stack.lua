--[[
Stack 模块
提供一个高性能的堆栈（后进先出）数据结构，支持迭代器访问。

示例：
```lua
local Stack = require "Stack"

-- 创建并使用
local st = Stack.new()
st:push(1)
st:push(2)
print(st:pop())        -- 输出 2
print(st:peek())       -- 输出 1
print(st:size())       -- 输出 1

-- 遍历 (从栈顶到底)
for value, idx in st:iterator() do
  print(idx, value)
end

```
]]

---@class Stack
---@field items any[] 内部存储表
---@field count integer 元素数量
local Stack = {}
Stack.__index = Stack

-- Stack.__call = function(self) return self:iterator() end

--- 创建一个新的堆栈实例
---@return Stack 新的堆栈对象
function Stack.new()
    local self = setmetatable({ items = {}, count = 0 }, Stack)
    return self
end

--- 将元素压入堆栈顶
---@param value any 要压入的值
---@usage
-- local st = Stack.new()
-- st:push("hello")
function Stack:push(value)
    local n = self.count + 1
    self.count = n
    self.items[n] = value
end

--- 弹出堆栈顶元素并返回
---@return any|nil value 如果堆栈为空返回 nil
---@usage
-- local val = st:pop()
function Stack:pop()
    local n = self.count
    if n == 0 then return nil end
    local v = self.items[n]
    self.items[n] = nil -- 清除引用，防止内存泄漏
    self.count = n - 1
    return v
end

--- 获取堆栈顶元素但不移除
---@return any|nil value 如果堆栈为空返回 nil
---@usage
-- local top = st:peek()
function Stack:peek()
    return self.items[self.count]
end

--- 获取当前堆栈大小
---@return integer 元素数量
---@usage
-- print(st:size())
function Stack:size()
    return self.count
end

--- 判断堆栈是否为空
---@return boolean true 如果为空
---@usage
-- if st:isEmpty() then print("空栈") end
function Stack:isEmpty()
    return self.count == 0
end

--- 清空堆栈 (保留表对象，避免频繁分配)
---@usage
-- st:clear()
function Stack:clear()
    for i = 1, self.count do
        self.items[i] = nil
    end
    self.count = 0
end

--- 将堆栈内容转换为数组（从底部到顶）
---@return any[] 数组（底->顶）
---@usage
-- local arr = st:toArray()
function Stack:toArray()
    local result = {}
    if self.count > 0 then
        -- 使用 table.move 提高复制效率
        table.move(self.items, 1, self.count, 1, result)
    end
    return result
end

--- 遍历堆栈（从顶到底），返回迭代器
---@return function 迭代器，每次调用返回 value, index
---@usage
-- for value, idx in st:iterator() do print(idx, value) end
function Stack:iterator()
    local i = self.count
    return function()
        if i > 0 then
            local v = self.items[i]
            local idx = i
            i = i - 1
            return v, idx
        end
    end
end

return Stack
