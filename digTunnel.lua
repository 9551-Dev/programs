print("how long 3x3 tunel do you want ?")
local lenght = tonumber(read()) or 1
local lDig = function()
    turtle.dig()
    turtle.turnRight()
    turtle.turnRight()
    turtle.dig()
end
local rDig = function()
    turtle.dig()
    turtle.turnLeft()
    turtle.turnLeft()
    turtle.dig()
end
local makeStep1 = function()
    turtle.dig()
    turtle.forward()
    turtle.turnLeft()
    lDig()
    turtle.digUp()
    turtle.up()
    rDig()
    turtle.digUp()
    turtle.up()
    lDig()
end
local makeStep2 = function()
    turtle.turnLeft()
    turtle.dig()
    turtle.forward()
    turtle.turnLeft()
    lDig()
    turtle.digDown()
    turtle.down()
    rDig()
    turtle.digDown()
    turtle.down()
    lDig()
end
local refuel = function()
    local fuelUp
    fuelUp = function()
        if turtle.getFuelLevel() < 40 then
            turtle.select(16)
            turtle.refuel(1)
            fuelUp()
            print("out of fuel. trying to refuel")
            sleep(0.5)
        else print("turtle fuel: " .. turtle.getFuelLevel()) end
    end
    fuelUp()
end
local goBack = function(len)
    for i = 1, len do
        refuel()
        turtle.forward()
    end
end
local returnHome = function(len)
    if len % 2 == 1 then
        turtle.down()
        turtle.down()
        turtle.turnRight()
    else turtle.turnRight() end
    goBack(len)
    for i = 1, 15 do
        turtle.select(i)
        turtle.drop(64)
    end
    turtle.turnRight()
    turtle.turnRight()
end
local countUp
for i = 1, lenght do
    countUp = i
    refuel()
    if i % 2 == 1 then
        makeStep1()
    else
        makeStep2()
        if not (i >= lenght) then turtle.turnLeft() end
    end
end
returnHome(countUp)
