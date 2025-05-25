Stack = {
  __size = 0,
  __array = {},
}

function Stack:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.__array = {}
  self.__size = 0
  return o
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
