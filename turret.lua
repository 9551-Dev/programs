--pastebin get VKEcYuGy
--auto turret by 9551--
local kill = {
    --examples:
    --"Creeper",
    --"Spider",
    --"Skeleton",
    --"Zombie"
    }
local noKill = {
	--examples:
	--"Wolf",
	--"Pig"
}
local defRange = 5
local defPower = 2
local wrap = "back"
local mobs,queue,cord,deg,num
local abs = {}
local degCalc = function(entity)
    local x, y, z = entity.x, entity.y, entity.z
    local pitch = -math.atan2(y, math.sqrt(x * x + z * z))
    local yaw = math.atan2(-x, z)
    return math.deg(yaw), math.deg(pitch)
end
local check = function()
	return (cord[1] < num) and
	(cord[1] > num - num * 2) and
    (cord[2] < num) and
    (cord[2] > num - num * 2) and
	(cord[3] < num / 4) and
    (cord[3] > num / 4 - num / 2 * 2)
end
local x = peripheral.wrap(wrap)
if not x then error("Must have a neural interface", 0) end
if not x.hasModule("plethora:sensor") then error("Must have an entity sensor", 0) end
if not x.hasModule("plethora:laser", 0) then error("Must have a laser", 0) end
local arg = {...}
num = tonumber((arg[1] or defRange))
local powah = tonumber((arg[2] or defPower))
local function shot()
    if check() then
		local ya,pi = degCalc(mobs[queue])
        x.fire(ya, pi, powah)
    end
end
while true do
    mobs = x.sense()
    queue = math.random(1, #mobs)
    cord = {mobs[queue].x, mobs[queue].z, mobs[queue].y}
    local abs = {math.abs(cord[1]),math.abs(cord[2])}
    for i = 1, math.max(#kill,#noKill) do
		if abs[1] > 0 and abs[2] > 0 then
        	if mobs[queue].name == kill[i] and mobs[queue].name ~= noKill[i] then shot() end
		end
    end
end
