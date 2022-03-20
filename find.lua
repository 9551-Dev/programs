local block = ...
local scanSpeed = 0.5
local doHighLight = true
local findDamage =  ({...})[2]
local damage = ({...})[4]
local highlighter = colors.green
local customDisplay = ({...})[3]
if customDisplay == "nil" then customDisplay = block end
if not block or block == "" then error("use: find blockname",0) end
if type(damage) == "string" then damage = tonumber(damage) end
local findDamage = tonumber(findDamage)
if type(customDisplay) ~= "string" or customDisplay == "" then customDisplay = nil end
if not damage or damage == "" then damage = nil end
local per = peripheral.wrap("back")
if not per then error("missing modules! (glasses,scanner)",0) end
if not per.scan or not per.canvas then error("missing modules! (glasses,scanner)",0) end
local c = per.canvas()
local c3d = per.canvas3d()
local obj
c.clear()
local main = function()
    local rec = c.addRectangle(0,0,60,20)
    local text = c.addText({3,6},"")
    rec.setAlpha(122)
    rec.setColor(0,0,0)
    local function getClosest(tbl)
        local pyth = function(x,y,z) return math.sqrt(x^2+y^2+z^2)   end
        local result = {}
        for k,v in pairs(tbl) do result[k] = pyth(v.x,v.y,v.z) end
        local minv = math.min(table.unpack(result))
        local resultFinal
		local resIndex
        for k,v in pairs(tbl) do
            if pyth(v.x,v.y,v.z) == minv then
                resultFinal = v
				resIndex = k
                break
            end
        end
        return resultFinal, resIndex
	end
	local function conv(ins)
        local r,g,b = term.getPaletteColor(ins)
        return r*255,g*255,b*255
    end
    local blc,offset
	local stabilize = function()
		local x, y, z = gps.locate(0.2)
		if x then
			offset = {
				-((x%1)-0.5),
                -((y%1)-0.5),
				-((z%1)-0.5)
			}
		else offset = nil end
	end
	local scanBlocks = function() blc = per.scan() end
    while true do
        parallel.waitForAll(stabilize,scanBlocks)
		c3d.clear()
        local matches = {}
        for k,v in pairs(blc) do
			if type(findDamage) == "number" then
                if v.name == block and v.metadata == findDamage then table.insert(matches,v) end
			else
				if v.name == block then table.insert(matches,v) end
			end
        end
		if not next(matches) then matches = 'no block "'..block..'" was found' end
		do
			local v,xs,ys,zs,c,str,usedIndex
			if type(matches) ~= "string" then
                local obj = c3d.create(offset)
                v, usedIndex = getClosest(matches)
                xs,ys,zs = tostring(v.x),tostring(v.y),tostring(v.z)
                c = xs.." "..ys.." "..zs   
                str = block.." found at: "..c
				for k,v in pairs(matches) do
					if k ~= usedIndex or not doHighLight then
                        local item = obj.addItem({v.x,v.y,v.z},customDisplay or block,damage or findDamage)
                        item.setDepthTested(false)
					end
				end
				local item = obj.addItem({v.x,v.y,v.z},customDisplay or block,damage or findDamage)
				if doHighLight then
                    local highlight = obj.addBox(v.x-0.6,v.y-0.6,v.z-0.6,1.2,1.2,1.2)
                    highlight.setDepthTested(false)
                    highlight.setColor(conv(highlighter))
                    highlight.setAlpha(64)
				end
				item.setDepthTested(false)
			else str = matches end
            rec.setSize(#str*5+2,20)
            text.setText(str)
		end
        sleep(scanSpeed or 0.5)
    end
end
local ok,err = pcall(main)
local clear = function()
	if c then c.clear() end
	if c3d then c3d.clear() end
end
clear()
if not ok then
	error(err,0)
end
