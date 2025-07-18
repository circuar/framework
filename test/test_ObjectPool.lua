-- test_ObjectPool.lua
-- 单元测试：ObjectPool
local ObjectPool = require("framework.collection.ObjectPool")

local function simpleFactory()
    return { value = 0 }
end

local function resetFunc(obj)
    obj.value = 0
end

-- 创建对象池
local pool = ObjectPool.new(simpleFactory, resetFunc, 3)

-- 测试 acquire 和 release
local obj1 = pool:acquire()
obj1.value = 42
assert(obj1.value == 42, "acquire: 对象属性赋值失败")
pool:release(obj1)
assert(pool:freeCount() == 1, "release: 释放后空闲数应为1")

-- 再次获取应为同一对象且已重置
local obj2 = pool:acquire()
assert(obj2 == obj1, "acquire: 应复用同一对象")
assert(obj2.value == 0, "reset: 释放后应重置对象")

-- 测试容量限制
local o2 = pool:acquire()
local o3 = pool:acquire()
pool:release(obj2)
pool:release(o2)
pool:release(o3)
assert(pool:freeCount() == 3, "容量限制: 空闲数应为最大容量3")

-- 超出容量的对象应被丢弃
local o4 = pool:acquire()
pool:release(o4)
assert(pool:freeCount() == 3, "容量限制: 超出容量对象应被丢弃")

-- 测试统计信息
assert(pool:totalCreated() >= 3, "统计: 创建对象总数应>=3")
assert(pool:capacity() == 3, "统计: 最大容量应为3")

-- 测试预分配
pool:clear()
pool:preallocate(2)
assert(pool:freeCount() == 2, "预分配: 空闲数应为2")

print("ObjectPool 所有基础测试通过！")
