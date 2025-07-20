-- Random.lua
-- 伪随机数生成器，基于线性同余生成器（LCG）
local Random     = {}
Random.__index   = Random

-- LCG 参数
local MULTIPLIER = 0x5DEECE66D
local ADDEND     = 0xB
local MASK       = (1 << 48) - 1

--- 构造：可传入 seed（number），否则用时间+时钟自动播种
function Random.new(seed)
    local self = setmetatable({}, Random)
    seed = seed or LuaAPI.rand()
    -- Java 源码里是这样初始化 seed 的：
    self._seed = ((seed & MASK) ~ MULTIPLIER) & MASK
    return self
end

-- 内部：更新 seed，并返回高 bits 位
function Random:next(bits)
    self._seed = (self._seed * MULTIPLIER + ADDEND) & MASK
    return (self._seed >> (48 - bits)) & ((1 << bits) - 1)
end

--- 返回一个 0 <= x < n 的整数；若不传 n，则返回全范围 32 位整数
function Random:nextInt(n)
    if not n then
        local v = self:next(32)
        -- 转成有符号 32 位
        return v >= 0x80000000 and v - 0x100000000 or v
    end
    assert(n > 0, "n must be positive")
    -- 如果 n 是 2 的幂
    if (n & -n) == n then
        return (self:next(31) * n) >> 31
    end
    local bits, val
    repeat
        bits = self:next(31)
        val  = bits % n
    until bits - val + (n - 1) >= 0
    return val
end

--- 布尔值
function Random:nextBoolean()
    return self:next(1) == 1
end

--- 返回 [0,1) 的 number
function Random:nextNumber()
    -- 用 53 位随机数精度
    local high = self:next(26)
    local low  = self:next(27)
    return (high * (1 << 27) + low) / (1 << 53)
end

--- 用随机字节填充一个已分配好的表（元素值 0–255）
function Random:nextBytes(bytes)
    for i = 1, #bytes do
        bytes[i] = self:next(8)
    end
end

return Random
