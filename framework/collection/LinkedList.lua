---@diagnostic disable: need-check-nil

---@class LinkedList
---@field head Node|nil  头节点
---@field tail Node|nil  尾节点
---@field size integer   链表大小
---@field version integer 结构版本号
---@field cmp fun(a:any, b:any):boolean?  可选比较函数
local LinkedList = {}
LinkedList.__index = LinkedList

--- 创建新链表
---@param comparator fun(a:any,b:any):boolean? 可选的比较函数，返回 true 表示相等，默认使用 `==`
---@return LinkedList
function LinkedList.new(comparator)
    return setmetatable({
        head = nil,  -- 头节点
        tail = nil,  -- 尾节点
        size = 0,    -- 元素数量
        version = 0, -- 结构版本号
        cmp = comparator or function(a, b) return a == b end
    }, LinkedList)
end

--- 双向链表节点
---@class Node
---@field value any 节点的值
---@field prev Node|nil 前驱节点
---@field next Node|nil 后继节点
local Node = {}
Node.__index = Node

function Node.new(value)
    return setmetatable({ value = value, prev = nil, next = nil }, Node)
end

-- 内部：更新版本号
local function bumpVersion(linkedList)
    linkedList.version = linkedList.version + 1
end

--- 在链表头部添加元素
---@param value any
---@return Node
function LinkedList:pushFront(value)
    local node = Node.new(value)
    if self.head then
        node.next = self.head
        self.head.prev = node
        self.head = node
    else
        self.head = node
        self.tail = node
    end
    self.size = self.size + 1
    bumpVersion(self)
    return node
end

--- 在链表尾部添加元素
---@param value any
---@return Node
function LinkedList:pushBack(value)
    local node = Node.new(value)
    if self.tail then
        node.prev = self.tail
        self.tail.next = node
        self.tail = node
    else
        self.head = node
        self.tail = node
    end
    self.size = self.size + 1
    bumpVersion(self)
    return node
end

--- 从头部移除元素
---@return any?|nil 被移除的值
function LinkedList:popFront()
    if not self.head then return nil end
    local node = self.head
    self.head = node.next
    if self.head then self.head.prev = nil else self.tail = nil end
    self.size = self.size - 1
    bumpVersion(self)
    return node.value
end

--- 从尾部移除元素
---@return any?|nil 被移除的值
function LinkedList:popBack()
    if not self.tail then return nil end
    local node = self.tail
    self.tail = node.prev
    if self.tail then self.tail.next = nil else self.head = nil end
    self.size = self.size - 1
    bumpVersion(self)
    return node.value
end

--- 在指定节点前插入元素（node 为 nil 则等同于 pushFront）
---@param node Node|nil
---@param value any
---@return Node
function LinkedList:insertBefore(node, value)
    if not node then return self:pushFront(value) end
    local newNode = Node.new(value)
    newNode.prev = node.prev
    newNode.next = node
    if node.prev then node.prev.next = newNode else self.head = newNode end
    node.prev = newNode
    self.size = self.size + 1
    bumpVersion(self)
    return newNode
end

--- 在指定节点后插入元素（node 为 nil 则等同于 pushBack）
---@param node Node|nil
---@param value any
---@return Node
function LinkedList:insertAfter(node, value)
    if not node then return self:pushBack(value) end
    local newNode = Node.new(value)
    newNode.prev = node
    newNode.next = node.next
    if node.next then node.next.prev = newNode else self.tail = newNode end
    node.next = newNode
    self.size = self.size + 1
    bumpVersion(self)
    return newNode
end

--- 移除指定节点
---@param node Node|nil
---@return boolean
function LinkedList:remove(node)
    if not node then return false end
    if node.prev then node.prev.next = node.next else self.head = node.next end
    if node.next then node.next.prev = node.prev else self.tail = node.prev end
    self.size = self.size - 1
    bumpVersion(self)
    return true
end

--- 查找第一个匹配值的节点
---@param value any
---@return Node|nil
function LinkedList:find(value)
    local cur = self.head
    while cur do
        if self.cmp(cur.value, value) then return cur end
        cur = cur.next
    end
    return nil
end

--- 清空链表
function LinkedList:clear()
    self.head = nil
    self.tail = nil
    self.size = 0
    bumpVersion(self)
end

--- 返回链表大小
---@return integer
function LinkedList:length()
    return self.size
end

--- 是否为空
---@return boolean
function LinkedList:isEmpty()
    return self.size == 0
end

--- 获取头部元素值
---@return any|nil
function LinkedList:front()
    return self.head and self.head.value or nil
end

--- 获取尾部元素值
---@return any|nil
function LinkedList:back()
    return self.tail and self.tail.value or nil
end

--- 遍历链表，执行回调函数（不检查修改）
---@param callback fun(value:any)
function LinkedList:forEach(callback)
    local current = self.head
    while current do
        callback(self.head.value)
        current = current.next
    end
end

--- 安全正向迭代器
---@return fun():any?
function LinkedList:safeIterator()
    local current = self.head
    local version = self.version
    return function()
        if version ~= self.version then
            error("LinkedList modified during iteration")
        end
        if not current then return nil end
        local v = current.value
        current = current.next
        return v
    end
end

--- 高效正向迭代器（不检查修改）
---@return fun():any?
function LinkedList:iterator()
    local current = self.head
    return function()
        if not current then return nil end
        local v = current.value
        current = current.next
        return v
    end
end

--- 安全反向迭代器
---@return fun():any?
function LinkedList:safeReverseIterator()
    local current = self.tail
    local version = self.version
    return function()
        if version ~= self.version then
            error("LinkedList modified during reverse iteration")
        end
        if not current then return nil end
        local v = current.value
        current = current.prev
        return v
    end
end

--- 高效反向迭代器（不检查修改）
---@return fun():any?
function LinkedList:reverseIterator()
    local current = self.tail
    return function()
        if not current then return nil end
        local v = current.value
        current = current.prev
        return v
    end
end

--- 转数组（正序）
---@return any[]
function LinkedList:toArray()
    local t = {}
    local cur = self.head
    while cur do
        t[#t + 1] = cur.value
        cur = cur.next
    end
    return t
end

--- 转数组（逆序）
---@return any[]
function LinkedList:toReverseArray()
    local t = {}
    local cur = self.tail
    while cur do
        t[#t + 1] = cur.value
        cur = cur.prev
    end
    return t
end

return LinkedList
