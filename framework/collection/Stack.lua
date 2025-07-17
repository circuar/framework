---@class Stack
---@field items any[] 内部存储表
---@field count integer 元素数量
local Stack = {}
Stack.__index = Stack

--- 创建一个新的堆栈实例
---@return Stack
function Stack.new()
    local self = setmetatable({ items = {}, count = 0 }, Stack)
    return self
end

--- 将元素压入堆栈顶
---@param value any 要压入的值
function Stack:push(value)
    self.count = self.count + 1
    self.items[self.count] = value
end

--- 弹出堆栈顶元素并返回
---@return any|nil 如果堆栈为空返回 nil
function Stack:pop()
    if self.count == 0 then
        return nil
    end
    local value = self.items[self.count]
    self.items[self.count] = nil
    self.count = self.count - 1
    return value
end

--- 获取堆栈顶元素但不移除
---@return any|nil 如果堆栈为空返回 nil
function Stack:peek()
    return self.items[self.count]
end

--- 获取当前堆栈大小
---@return integer
function Stack:size()
    return self.count
end

--- 判断堆栈是否为空
---@return boolean
function Stack:isEmpty()
    return self.count == 0
end

--- 清空堆栈
function Stack:clear()
    self.items = {}
    self.count = 0
end

--- 将堆栈内容转换为数组（底部到顶）
---@return any[]
function Stack:toArray()
    local result = {}
    for i = 1, self.count do
        result[i] = self.items[i]
    end
    return result
end

--- 遍历堆栈（从顶到底），对每个元素执行回调
---@param callback fun(value:any, index:integer)
function Stack:forEach(callback)
    for i = self.count, 1, -1 do
        callback(self.items[i], i)
    end
end

return Stack
