Stack = {
    __size = 0,
    __array = {},
}

function Stack:new()
    new = {}
    setmetatable(new, self)
    self.__index = self
    new.__array = {}
    new.__size = 0
    return new
end

function Stack:size()
    return self.__size
end

function Stack:push(elem)
	self.__array[self.__size] = elem
	self.__size = self.__size + 1
end

function Stack:pop()
	if self.__size > 0 then
		self.__size = self.__size - 1
		return self.__array[self.__size]
	end
	return nil
end

function Stack:clear()
	self.__array = {}
	self.__size = 0
end

return Stack
