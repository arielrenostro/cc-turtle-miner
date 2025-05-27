Queue = {
  __size = 0,
  __front = nil,
  __rear = nil,
}

function Queue:new()
  new = {}
  setmetatable(new, self)
  self.__index = self
  new.__front = nil
  new.__rear = nil
  new.__size = 0
  return new
end

function Queue:size()
  return self.__size
end

function Queue:pushFront(elem)
  self.__front = {
    data = elem,
    next = self.__front,
  }
  if self.__rear == nil then
    self.__rear = self.__front
  end
  self.__size = self.__size + 1
end

function Queue:push(elem)
  local newNode = {
    data = elem,
    next = nil,
  }

  if self.__rear == nil then
    self.__rear = newNode
    self.__front = newNode
  else
    self.__rear.next = newNode
    self.__rear = newNode
  end

  self.__size = self.__size + 1
end

function Queue:pull()
  if self.__front == nil then
    return nil
  end

  local elem = self.__front.data

  self.__front = self.__front.next
  if self.__front == nil then
    self.__rear = nil
  end
  self.__size = self.__size - 1
  
  return elem
end

function Queue:clear()
  self.__front = nil
  self.__rear = nil
  self.__size = 0
end

return Queue
