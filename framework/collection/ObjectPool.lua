---
--- @class ObjectPool
--- @description
---   en: A simple object pool implementation that minimizes allocations by recycling objects.
---   zh: 简易对象池实现，通过重用对象减少内存分配。
--- @field private factory fun():any                     Function to create new objects / 创建新对象的函数
--- @field private reset fun(any)                        Optional function to reset object state on return / 可选的对象重置函数
--- @field private maxCapacity integer                   Maximum number of free objects in the pool / 池中最大空闲对象数
--- @field private freePool any[]                        Stack of available objects / 可用对象栈
--- @field private totalObjectsCreated integer           Total number of objects ever created / 已创建对象总数
--- @field private activeCount integer                   Number of objects currently borrowed / 当前借出对象数
local ObjectPool = {}
ObjectPool.__index = ObjectPool

--- Create a new ObjectPool instance
--- @param factory fun():any                            Function to instantiate new objects / 创建新对象的工厂函数
--- @param reset fun(any)?                              Function to reset object state when returned (optional) / 对象归还时重置函数（可选）
--- @param maxCapacity integer?                         Maximum free-object capacity (default infinite) / 最大空闲对象容量（默认无限）
--- @return ObjectPool pool                             New ObjectPool instance / 新的对象池实例
function ObjectPool.new(factory, reset, maxCapacity)
    assert(type(factory) == "function", "factory must be a function")
    local pool = setmetatable({
        factory             = factory,
        reset               = reset or function() end,
        maxCapacity         = maxCapacity or math.huge,
        freePool            = {},
        totalObjectsCreated = 0,
        activeCount         = 0,
    }, ObjectPool)
    return pool
end

--- Acquire an object from the pool
--- @return any obj                                    Retrieved object / 获取的对象
--- @description
---   en: Retrieves an object from the pool, creating a new one if necessary.
---   zh: 从对象池获取一个对象；如无空闲则新建。
function ObjectPool:acquire()
    local pool = self.freePool
    local obj
    if #pool > 0 then
        obj = pool[#pool]
        pool[#pool] = nil
    else
        obj = self.factory()
        self.totalObjectsCreated = self.totalObjectsCreated + 1
    end
    self.activeCount = self.activeCount + 1
    return obj
end

--- Release an object back to the pool
--- @param obj any                                     Object to return / 要返还的对象
--- @description
---   en: Returns an object to the pool, resets its state, and drops it if at capacity.
---   zh: 将对象返还到池中，重置状态；若已达容量则丢弃。
function ObjectPool:release(obj)
    self.reset(obj)
    if #self.freePool < self.maxCapacity then
        self.freePool[#self.freePool + 1] = obj
    end
    self.activeCount = self.activeCount - 1
end

--- Clear all free objects
--- @description
---   en: Empties the pool of free objects and resets active count.
---   zh: 清空所有空闲对象，重置活动计数。
function ObjectPool:clear()
    self.freePool = {}
    self.activeCount = 0
end

--- Preallocate new objects
--- @param n integer                                   Number of objects to preallocate / 预分配对象数量
--- @description
---   en: Instantiates up to n objects into the pool, respecting maxCapacity.
---   zh: 预先创建 n 个对象至池中，遵循最大容量限制。
function ObjectPool:preallocate(n)
    local pool = self.freePool
    for i = 1, n do
        if #pool >= self.maxCapacity then break end
        local obj = self.factory()
        self.totalObjectsCreated = self.totalObjectsCreated + 1
        pool[#pool + 1] = obj
    end
end

--- Get number of free objects
--- @return integer count                               Count of available objects / 当前空闲对象数
function ObjectPool:freeCount()
    return #self.freePool
end

--- Get pool capacity
--- @return integer capacity                            Maximum free-object capacity / 最大空闲容量
function ObjectPool:capacity()
    return self.maxCapacity
end

--- Resize pool capacity
--- @param newCapacity integer                          New maximum capacity / 新的最大容量
function ObjectPool:resize(newCapacity)
    self.maxCapacity = newCapacity
    local pool = self.freePool
    for i = #pool, newCapacity + 1, -1 do pool[i] = nil end
end

--- Retrieve total objects created
--- @return integer total                                Total objects created / 创建对象总数
function ObjectPool:totalCreated()
    return self.totalObjectsCreated
end

--- Retrieve count of currently active (borrowed) objects
--- @return integer active                                Count of borrowed objects / 当前借出对象数
function ObjectPool:activeBorrowed()
    return self.activeCount
end

--- Estimate approximate memory usage
--- @return number bytes                                 Approximate bytes / 估算字节数
function ObjectPool:estimateMemory()
    local sample = self.factory()
    local size = (type(sample) == "table") and 64 or 16
    return (#self.freePool + self.activeCount) * size
end

--- Get utilization percentage
--- @return number utilizationPercent                    Utilization percentage / 利用率百分比
function ObjectPool:utilization()
    local total = #self.freePool + self.activeCount
    return total > 0 and (self.activeCount / total) * 100 or 0
end

return ObjectPool
