List = {}

function List:new()
    new = {}
    setmetatable(new, self)
    self.__index = self
    new.__array = {}
    new.__size = 0
    return o
end

function List:size()
    return self.__size
end

function List:add(elem)
    self.__array[self.__size] = elem
    self.__size = self.__size + 1
end

function List:get(idx)
    return self.__array[idx]
end

function List:array()
    return self.__array
end

return List
