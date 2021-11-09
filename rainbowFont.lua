--rainbow font!--
--program by 9551Dev--
--you can use this if you dont claim you made it--
--made for making computer colors rainbow !--
--default: white. this program also adds--
--colors.rainbow color--
--this program is reccomended--
--to be a startup file--
----CONFIG---------------------------------
local ColorToObliterate = {colors.white}
local ColorSpeed = 0.5
local smoothing = 0.5
local RainbowOffset = true
local OffSetFirst = true
local offsetR = 0.2
local offsetG = 0
local offsetB = 0.2
local colorsRainbow = "random"
local terms = {term}
local offSetTerms = true
local loadConfigFromFile = "filename.clr"
--------------------------------------------
local MAIN = function()
end
local startups = function()
    if fs.exists("startup") and fs.isDir("startup") then
        for k, v in ipairs(fs.list("startup")) do
            shell.run("./startup/" .. v)
        end
    end
end
local backs = MAIN
if loadConfigFromFile:match("/?.+%.(.-)$") ~= "clr" then
    error("loadConfigFromFile needs to be .clr file", 0)
end
if loadConfigFromFile and fs.exists(loadConfigFromFile) then
    lines = {}
    for l in io.lines(loadConfigFromFile) do
        lines[#lines + 1] = l
    end
    ColorToObliterate = loadstring("return " .. "{" .. lines[1] .. "}")()
    ColorSpeed = tonumber(lines[2])
    smoothing = tonumber(lines[3])
    RainbowOffset = loadstring("return " .. lines[4])()
    OffSetFirst = loadstring("return " .. lines[5])()
    offsetR = tonumber(lines[6])
    offsetG = tonumber(lines[7])
    offsetB = tonumber(lines[8])
    colorsRainbow = lines[9]
    terms = loadstring("return " .. "{" .. (lines[10] or "") .. "}")()
	offSetTerms = loadstring("return "..(lines[12] or ""))()
    if ColorToObliterate == "" or not ColorToObliterate then ColorToObliterate = colors.white end
    if ColorSpeed == "" or not ColorSpeed then ColorSpeed = 0.5 end
    if smoothing == "" or not smoothing then smoothing = 0.5 end
    if RainbowOffset == "" then RainbowOffset = true end
    if OffSetFirst == "" then OffSetFirst = true end
    if offsetR == "" or not offsetR then offsetR = 0.2 end
    if offsetG == "" or not offsetG then offsetG = 0 end
    if offsetB == "" or not offsetB then offsetB = 0.2 end
    if colorsRainbow == "" or not colorsRainbow then colorsRainbow = "random" end
    if terms == {""} or not terms then terms = {term} end
    if lines[11] ~= "" and lines[11] then
        MAIN = loadstring("return function() " .. lines[11] .. " end")()
        if type(MAIN) ~= "function" then MAIN = function() end end
    end
	if offSetTerms == "" then offSetTerms = true end
end
local selects = 1
if colorsRainbow == "random" then selects = math.random(1, #ColorToObliterate) end
if colorsRainbow == "max" then selects = #ColorToObliterate end
if tonumber(colorsRainbow) then selects = tonumber(colorsRainbow) end
if not next(ColorToObliterate) then ColorToObliterate = {colors.white} end
_G.colors.rainbow = ColorToObliterate[selects]
_G.colours.rainbow = ColorToObliterate[selects]
local function HSVToRGB(hue, saturation, value)
    if saturation == 0 then return value, value, value end
    local hue_sector = math.floor(hue / 60)
    local hue_sector_offset = (hue / 60) - hue_sector
    local p = value * (1 - saturation)
    local q = value * (1 - saturation * hue_sector_offset)
    local t = value * (1 - saturation * (1 - hue_sector_offset))
    if hue_sector == 0 then return value, t, p
    elseif hue_sector == 1 then return q, value, p
    elseif hue_sector == 2 then return p, value, t
    elseif hue_sector == 3 then return p, q, value
    elseif hue_sector == 4 then return t, p, value
    elseif hue_sector == 5 then return value, p, q end
end
local function rgbgen()
    while true do
        for i = 1, 360 * smoothing do
            local counterR = 0
            local counterG = 0
            local counterB = 0
            local r, g, b = HSVToRGB(i / smoothing, 1, 1)
            for k, v in ipairs(ColorToObliterate) do
                if RainbowOffset then
                    r, b, g = (r or 1), (g or 0), (b or 0)
                    r, b, g = r + counterR, b + counterB, g + counterG
                    if r > 1 then r = 1 end
                    if b > 1 then b = 1 end
                    if g > 1 then g = 1 end
                    if OffSetFirst and not offSetTerms then
                        counterR = counterR + offsetR
                        counterG = counterG + offsetG
                        counterB = counterB + offsetB
                    end
					if OffSetFirst and offSetTerms then
						counterR = counterR + offsetR/10
                        counterG = counterG + offsetG/10
                        counterB = counterB + offsetB/10
						r, b, g = (r or 1), (g or 0), (b or 0)
                    	r, b, g = r + counterR, b + counterB, g + counterG
						if r > 1 then r = 1 end
                    	if b > 1 then b = 1 end
                    	if g > 1 then g = 1 end
					end
                    for ka, va in ipairs(terms) do
						if offSetTerms and OffSetFirst then
							counterR = counterR + offsetR/10
                        	counterG = counterG + offsetG/10
                        	counterB = counterB + offsetB/10
							r, b, g = (r or 1), (g or 0), (b or 0)
                    		r, b, g = r + counterR, b + counterB, g + counterG
							if r > 1 then r = 1 end
                    		if b > 1 then b = 1 end
                    		if g > 1 then g = 1 end
						end
						va.setPaletteColor(v, r, g, b)
						if offSetTerms and not OffSetFirst then
							counterR = counterR + offsetR/10
                        	counterG = counterG + offsetG/10
                        	counterB = counterB + offsetB/10
							r, b, g = (r or 1), (g or 0), (b or 0)
                    		r, b, g = r + counterR, b + counterB, g + counterG
							if r > 1 then r = 1 end
                    		if b > 1 then b = 1 end
                    		if g > 1 then g = 1 end
						end
					end
					if not OffSetFirst and not offSetTerms then
					    counterR = counterR + offsetR
                        counterG = counterG + offsetG
                        counterB = counterB + offsetB
					end
					if not OffSetFirst and offSetTerms then
						counterR = counterR + offsetR/10
                        counterG = counterG + offsetG/10
                        counterB = counterB + offsetB/10
						r, b, g = (r or 1), (g or 0), (b or 0)
                    	r, b, g = r + counterR, b + counterB, g + counterG
						if r > 1 then r = 1 end
                    	if b > 1 then b = 1 end
                    	if g > 1 then g = 1 end
                    end
                else
                    for ka, va in ipairs(terms) do va.terms.setPaletteColor(v, (r or 1), (g or 0), (b or 0)) end
                end
            end sleep(ColorSpeed / 5)
        end
    end
end
local sh = function()
    local sShell
    if term.isColour() and settings.get("bios.use_multishell") then sShell = "/rom/programs/advanced/multishell.lua"
    else sShell = "/rom/programs/shell.lua" end
    shell.run(sShell)
    shell.run("/rom/programs/shutdown.lua")
end
do
	pcall(parallel.waitForAll, rgbgen, sh, MAIN, startups)
	term.setTextColor(colors.yellow) print("\nGoodbye")
	sleep(.5) os.shutdown()
end
