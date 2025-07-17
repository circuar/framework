---@class Queue
---@field buffer any[] 环形缓冲区存储
---@field head integer 下一个出队位置索引
---@field tail integer 下一个入队位置索引
---@field count integer 当前元素数量
local Queue = {}
Queue.__index = Queue

--- 创建一个新的队列实例
---@param capacity integer? 初始容量（可选，默认16）
---@return Queue
function Queue.new(capacity)
    local cap = capacity or 16
    -- 确保容量为2的幂次方，便于取模
    local pow = 1
    while pow < cap do pow = pow * 2 end
    local self = setmetatable({ buffer = {}, head = 1, tail = 1, count = 0, capacity = pow }, Queue)
    return self
end

--- 扩容（内部函数）
local function expand(self)
    local old = self.buffer
    local newCap = self.capacity * 2
    local newBuf = {}
    for i = 1, self.count do
        newBuf[i] = old[((self.head - 1 + i - 1) & (self.capacity - 1)) + 1]
    end
    self.buffer = newBuf
    self.head = 1
    self.tail = self.count + 1
    self.capacity = newCap
end

--- 入队元素
---@param value any 要入队的值
function Queue:enqueue(value)
    if self.count == self.capacity then
        expand(self)
    end
    self.buffer[self.tail] = value
    -- 环形递增索引
    self.tail = ((self.tail) & (self.capacity - 1)) + 1
    self.count = self.count + 1
end

--- 出队元素并返回
---@return any|nil 如果队列为空返回 nil
function Queue:dequeue()
    if self.count == 0 then
        return nil
    end
    local value = self.buffer[self.head]
    self.buffer[self.head] = nil
    self.head = ((self.head) & (self.capacity - 1)) + 1
    self.count = self.count - 1
    return value
end

--- 查看队列头部元素但不移除
---@return any|nil 如果队列为空返回 nil
function Queue:peek()
    return self.buffer[self.head]
end

--- 获取当前队列大小
---@return integer
function Queue:size()
    return self.count
end

--- 判断队列是否为空
---@return boolean
function Queue:isEmpty()
    return self.count == 0
end

--- 清空队列
function Queue:clear()
    self.buffer = {}
    self.head = 1
    self.tail = 1
    self.count = 0
    self.capacity = self.capacity or 16
end

--- 转数组（从头到尾）
---@return any[]
function Queue:toArray()
    local result = {}
    for i = 1, self.count do
        result[i] = self.buffer[((self.head - 1 + i - 1) & (self.capacity - 1)) + 1]
    end
    return result
end

--- 遍历队列元素，从头到尾，执行回调
---@param callback fun(value:any, index:integer)
function Queue:forEach(callback)
    for i = 1, self.count do
        local idx = ((self.head - 1 + i - 1) & (self.capacity - 1)) + 1
        callback(self.buffer[idx], i)
    end
end

--- 高效迭代器（从头到尾）
---@return fun():any?
function Queue:iterator()
    local i = 0
    return function()
        i = i + 1
        if i > self.count then return nil end
        return self.buffer[((self.head - 1 + i - 1) & (self.capacity - 1)) + 1]
    end
end

return Queue
