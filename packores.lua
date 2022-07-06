local input = peripheral.wrap("")
local output = peripheral.wrap("")
local output_other = peripheral.wrap("")
local temp = peripheral.wrap("")
local grid = {1,2,5,6}

for k,v in pairs(grid) do
    turtle.select(v)
    turtle.drop()
end

for k,v in pairs(temp.list()) do
    temp.pushItems(peripheral.getName(input),k)
end

while true do
    local items = {}
    local slots = {}
    for k,v in pairs(input.list()) do
        if not items[v.name] then items[v.name] = 0 end
        if not slots[v.name] then slots[v.name] = {} end
        items[v.name] = items[v.name] + v.count
        table.insert(slots[v.name],{slot=k,count=v.count})
    end
    for k,v in pairs(items) do
        if v < 4 then items[k] = nil end
    end
    for _k,_v in pairs(items) do
        local moved = 0
        local containers = slots[_k]
        local take = math.min(math.floor(_v/4)*4,64*4)
        for k,v in pairs(containers) do
            local limit = take - moved
            if limit == 0 then break end
            if limit > 64 then limit = 64 end
            moved = moved + temp.pullItems(peripheral.getName(input),v.slot,limit)
        end
        local n = moved/4
        for k,v in pairs(grid) do
            turtle.select(v)
            turtle.suck(n)
        end
        local success = turtle.craft()
        if not success then
            for k,v in pairs(grid) do
                turtle.select(v)
                turtle.drop()
            end
            local items_misc = temp.list()
            for k,v in pairs(items_misc) do
                temp.pushItems(peripheral.getName(output_other),k)
            end
        else
            turtle.drop()
            temp.pushItems(peripheral.getName(output),1)
        end
    end
    sleep()
end
