Profiler = {}
Profiler.__index = Profiler

function Profiler.new()
    local self = setmetatable({}, Profiler)
    self:reset()
    return self
end

function Profiler:dealWithStoppingPrevious()
    if self.current then
        self:stop(self.current, true)
        self.current = nil  -- reset current label after stopping
    end
end

function Profiler:start(label, stopThisNext, category)
    if not studentSoftware then return end

    self:dealWithStoppingPrevious()

    category = category or "uncategorized"

    if not self.data[category] then
        self.data[category] = {}
    end

    if not self.data[category][label] then
        self.data[category][label] = { total = 0, count = 0, start = 0 }
    end
    self.data[category][label].start = timer.getMilliSecCounter()

    if stopThisNext then
        self.current = { label = label, category = category }
    end
end

function Profiler:stop(label, fromDealWithStoppingPrevious)
    if not studentSoftware then return end

    if not fromDealWithStoppingPrevious then
        self:dealWithStoppingPrevious()
    end

    -- find the label in the current or any category
    local entry
    if self.current and self.current.label == label then
        local cat = self.current.category
        entry = self.data[cat][label]
    else
        -- fallback: search categories for label (slow path)
        for cat, catData in pairs(self.data) do
            if catData[label] then
                entry = catData[label]
                break
            end
        end
    end
    if not entry then return end -- label not found

    local duration = timer.getMilliSecCounter() - entry.start
    entry.total = entry.total + duration
    entry.count = entry.count + 1
    entry.start = 0
end

function Profiler:report()
    if not studentSoftware then return end

    local timeTaken = timer.getMilliSecCounter() - self.lastTime
    print("=== PROFILER REPORT ===", collectgarbage("count"), "kb", timeTaken, "ms")

    for category, catData in pairs(self.data) do
        --add up all calls and total time for the category
        local totalCalls = 0
        local totalTime = 0
        for label, stat in pairs(catData) do
            totalCalls = totalCalls + stat.count
            totalTime = totalTime + stat.total
        end
        print("### Category:", category, "Total Calls:", totalCalls, "Total Time:", totalTime, "ms")
        for label, stat in pairs(catData) do
            local avg = stat.total / math.max(stat.count, 1)
            print(string.format("  %s: %d calls, total = %d ms, avg = %.2f ms",
                label, stat.count, stat.total, avg))
        end
    end

    self:reset()
end

function Profiler:reset()
    self.data = {}
    self.current = nil
    self.lastTime = timer.getMilliSecCounter()
end

function Profiler:wrap(label, func, category)
    if not studentSoftware then return func end

    category = category or "wrapped"
    return function(...)
        self:start(label, false, category)
        local result = {func(...)}
        self:stop(label)
        -- if label == "string.match" then --crash to show debugger
        --     error("Debugging call")
        -- end
        return unpack(result)
    end
end

Profiler = Profiler.new()