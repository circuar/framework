--- 优先级队列实现
---@class PriorityQueue
---@field heap any[] 堆数组存储，从索引1开始，元素为 {priority:number, value:any}
---@field count integer 当前元素数量
---@field cmp fun(a:table, b:table):boolean 比较函数，返回 true 表示 a 优先级 < b 优先级
local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

--- 创建一个新的优先级队列实例
---@param comparator fun(a:table, b:table):boolean? 可选比较函数，默认基于 priority 字段升序
---@return PriorityQueue
function PriorityQueue.new(comparator)
    local cmpFunc = comparator or function(a, b) return a.priority < b.priority end
    return setmetatable({ heap = {}, count = 0, cmp = cmpFunc }, PriorityQueue)
end

-- 内部：交换两个索引元素
local function swap(t, i, j)
    t[i], t[j] = t[j], t[i]
end

-- 内部：上浮
local function siftUp(self, idx)
    local heap, cmp = self.heap, self.cmp
    while idx > 1 do
        local parent = idx // 2
        if not cmp(heap[idx], heap[parent]) then
            break
        end
        swap(heap, idx, parent)
        idx = parent
    end
end

-- 内部：下沉
local function siftDown(self, idx)
    local heap, cnt, cmp = self.heap, self.count, self.cmp
    while true do
        local left = idx * 2
        local right = left + 1
        local smallest = idx
        if left <= cnt and cmp(heap[left], heap[smallest]) then
            smallest = left
        end
        if right <= cnt and cmp(heap[right], heap[smallest]) then
            smallest = right
        end
        if smallest == idx then break end
        swap(heap, idx, smallest)
        idx = smallest
    end
end

--- 入队（带优先级）
---@param value any
---@param priority number 优先级，值越小优先级越高
function PriorityQueue:enqueue(value, priority)
    local entry = { priority = priority, value = value }
    self.count = self.count + 1
    self.heap[self.count] = entry
    siftUp(self, self.count)
end

--- 出队并返回最高优先级的值
---@return any|nil 当队列为空返回nil
function PriorityQueue:dequeue()
    if self.count == 0 then return nil end
    local top = self.heap[1]
    if self.count > 1 then
        self.heap[1] = self.heap[self.count]
    end
    self.heap[self.count] = nil
    self.count = self.count - 1
    if self.count > 0 then
        siftDown(self, 1)
    end
    return top.value
end

--- 查看最高优先级值但不移除
---@return any|nil
function PriorityQueue:peek()
    return self.count > 0 and self.heap[1].value or nil
end

--- 返回当前大小
---@return integer
function PriorityQueue:size()
    return self.count
end

--- 判断是否为空
---@return boolean
function PriorityQueue:isEmpty()
    return self.count == 0
end

--- 清空队列
function PriorityQueue:clear()
    self.heap = {}
    self.count = 0
end

--- 转数组（按内部层次顺序）
---@return any[] 返回value列表
function PriorityQueue:toArray()
    local result = {}
    for i = 1, self.count do
        result[i] = self.heap[i].value
    end
    return result
end

--- 遍历队列（层次顺序）执行回调
---@param callback fun(value:any, index:integer)
function PriorityQueue:forEach(callback)
    for i = 1, self.count do
        callback(self.heap[i].value, i)
    end
end

--- 迭代器（层次顺序）
---@return fun():any?
function PriorityQueue:iterator()
    local i = 0
    return function()
        i = i + 1
        if i > self.count then return nil end
        return self.heap[i].value
    end
end

return PriorityQueue
