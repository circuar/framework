local LinkedList = require("framework.collection.LinkedList")

local list = LinkedList.new()
list:pushFront(1)

print(list:front())
