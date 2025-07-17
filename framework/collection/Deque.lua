---@class Deque
---@field buffer any[] 环形缓冲区存储
---@field head integer 下一个出队头部位置
---@field tail integer 下一个入队尾部位置
---@field count integer 当前元素数量
local Deque = {}
Deque.__index = Deque

--- 创建一个新的双端队列实例
---@param capacity integer? 初始容量，默认16
---@return Deque
function Deque.new(capacity)
    local cap = capacity or 16
    local pow = 1
    while pow < cap do pow = pow * 2 end
    local self = setmetatable({ buffer = {}, head = 1, tail = 1, count = 0, capacity = pow }, Deque)
    return self
end

--- 内部：扩容为原来的两倍
local function expandBuffer(self)
    local old = self.buffer
    local newCap = self.capacity * 2
    local newBuf = {}
    for i = 1, self.count do
        local idx = ((self.head - 1 + i - 1) & (self.capacity - 1)) + 1
        newBuf[i] = old[idx]
    end
    self.buffer = newBuf
    self.head = 1
    self.tail = self.count + 1
    self.capacity = newCap
end

--- 从尾部插入元素
---@param value any
function Deque:pushBack(value)
    if self.count == self.capacity then
        expandBuffer(self)
    end
    self.buffer[self.tail] = value
    self.tail = ((self.tail) & (self.capacity - 1)) + 1
    self.count = self.count + 1
end

--- 从头部插入元素
---@param value any
function Deque:pushFront(value)
    if self.count == self.capacity then
        expandBuffer(self)
    end
    self.head = ((self.head - 2) & (self.capacity - 1)) + 1
    self.buffer[self.head] = value
    self.count = self.count + 1
end

--- 从头部弹出元素并返回
---@return any|nil
function Deque:popFront()
    if self.count == 0 then
        return nil
    end
    local value = self.buffer[self.head]
    self.buffer[self.head] = nil
    self.head = ((self.head) & (self.capacity - 1)) + 1
    self.count = self.count - 1
    return value
end

--- 从尾部弹出元素并返回
---@return any|nil
function Deque:popBack()
    if self.count == 0 then
        return nil
    end
    self.tail = ((self.tail - 2) & (self.capacity - 1)) + 1
    local value = self.buffer[self.tail]
    self.buffer[self.tail] = nil
    self.count = self.count - 1
    return value
end

--- 查看头部元素但不移除
---@return any|nil
function Deque:peekFront()
    return self.count > 0 and self.buffer[self.head] or nil
end

--- 查看尾部元素但不移除
---@return any|nil
function Deque:peekBack()
    if self.count == 0 then
        return nil
    end
    local idx = ((self.tail - 2) & (self.capacity - 1)) + 1
    return self.buffer[idx]
end

--- 获取元素数量
---@return integer
function Deque:size()
    return self.count
end

--- 判断是否为空
---@return boolean
function Deque:isEmpty()
    return self.count == 0
end

--- 清空双端队列
function Deque:clear()
    self.buffer = {}
    self.head = 1
    self.tail = 1
    self.count = 0
    self.capacity = self.capacity or 16
end

--- 转数组（从头到尾）
---@return any[]
function Deque:toArray()
    local result = {}
    for i = 1, self.count do
        local idx = ((self.head - 1 + i - 1) & (self.capacity - 1)) + 1
        result[i] = self.buffer[idx]
    end
    return result
end

--- 遍历队列元素，从头到尾，执行回调
---@param callback fun(value:any, index:integer)
function Deque:forEach(callback)
    for i = 1, self.count do
        local idx = ((self.head - 1 + i - 1) & (self.capacity - 1)) + 1
        callback(self.buffer[idx], i)
    end
end

--- 迭代器（从头到尾）
---@return fun():any?
function Deque:iterator()
    local i = 0
    return function()
        i = i + 1
        if i > self.count then return nil end
        return self.buffer[((self.head - 1 + i - 1) & (self.capacity - 1)) + 1]
    end
end

--- 反向迭代器（从尾到头）
---@return fun():any?
function Deque:reverseIterator()
    local i = 0
    return function()
        i = i + 1
        if i > self.count then return nil end
        local idx = ((self.tail - 2 - (i - 1)) & (self.capacity - 1)) + 1
        return self.buffer[idx]
    end
end

return Deque
