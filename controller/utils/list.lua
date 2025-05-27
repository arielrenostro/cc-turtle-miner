List = {
    __size = 0,
    __array = {},
}

function List:new()
    list = {}
    setmetatable(list, self)
    self.__index = self
    list.__array = {}
    list.__size = 0
    return list
end

function List:size()
    return self.__size
end

function List:add(elem)
    self.__size = self.__size + 1
    self.__array[self.__size] = elem
end

function List:get(idx)
    return self.__array[idx]
end

function List:array()
    return self.__array
end

return List
