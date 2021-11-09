---simple tunneler by 9551Dev---
print("how long do you want the tunnel to be ? ")
local ins = tonumber(read())
for i = 1, ins do
    turtle.dig()
    turtle.forward()
    turtle.digUp()
end
turtle.turnRight()
turtle.turnRight()
for i = 1, ins do
    turtle.forward()
end
print("mining completed")
