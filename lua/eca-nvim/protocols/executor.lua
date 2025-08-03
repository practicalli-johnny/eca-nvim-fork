local Executor = {}

function Executor.new()
  local instance = {
    queue = {},
    running = false,
    i = 0,
  }

  setmetatable(instance, { __index = Executor })

  return instance
end

function Executor:index()
  local i = self.i
  self.i = self.i + 1
  return i
end

function Executor:run(fn)
  table.insert(self.queue, fn)
  self:process_queue()
end

function Executor:process_queue()
  if self.running or #self.queue == 0 then
    return
  end

  self.running = true
  local fn = table.remove(self.queue, 1)

  local function done()
    self.running = false
    self:process_queue()
  end

  fn(done)
end

return Executor
