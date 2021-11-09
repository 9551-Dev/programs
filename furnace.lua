local b = require("button").monitor
local m = peripheral.find("monitor")
local fur = peripheral.find("minecraft:furnace")
local updaterate = 1
m.setTextScale(0.5)
m.clear()
while true do
    sleep(updaterate)
    local itemTempI = fur.getItemMeta(1) or {count=0,displayName="empty"}
	local ItemTempII = fur.getItemMeta(2) or {count=0,displayName="empty"}
	local ItemTempIII = fur.getItemMeta(3) or {count=0,displayName="empty"}
    itemI = itemTempI.count
    itemNI = itemTempI.displayName
    itemII = ItemTempII.count or 0
    itemNII = ItemTempII.displayName
    itemIII = ItemTempIII.count
    itemNIII = ItemTempIII.displayName
    m.setCursorPos(8, 23)
    m.write("input")
    m.setCursorPos(27, 23)
    m.write("fuel")
    m.setCursorPos(46, 23)
    m.write("output")
    b.bar(peripheral.getName(m), 3, 12, 16, 10, itemI, 64, "gray", "red", "white", true, true, itemNI, true,true,false)
    b.bar(peripheral.getName(m), 22, 12, 16, 10, itemII, 64, "gray", "red", "white", true, true, itemNII, true,true,false)
    b.bar(peripheral.getName(m), 41, 12, 16, 10, itemIII, 64, "gray", "red", "white", true, true, itemNIII, true,true,false)
end
