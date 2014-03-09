require("helper")

W = {}

COUNT = 36
SIZE = 0
T = {}

Blob = class("Blob")

function Blob:__init(y)
    self.y = y
    self.x = 0 
    self.color = pack(hsl2rgb(self.y / love.graphics.getHeight(), 1, 0.5))
    self.age = math.random(100) / 100
    self.speed = 100
end

function Blob:update(dt)
    self.age = self.age + dt
    self.speed = self.speed + dt * 1000
    self.x = self.x + dt * self.speed
    if self.x > love.graphics.getWidth() then
        table.removeValue(W, self)
    end
end

function Blob:draw()
    love.graphics.setColor(unpack(self.color))
    s = (SIZE - 1) * math.abs(math.sin(self.age * 6)) * 1.2
    love.graphics.rectangle("fill", self.x + SIZE / 2 - s / 2, self.y + SIZE / 2 - s / 2, s, s)
end

function getN(y)
    return math.floor(y / SIZE)
end

function getT(i)
    if not T[i] then T[i] = 0 end
    return T[i]
end

function doTouchStuff()
    for i=1,love.touch.getTouchCount() do
        id,x,y = love.touch.getTouch(i)
        n = math.floor(y * love.graphics.getHeight() / SIZE)
        if getT(i) <= 0 then
            T[n] = 1
            local b = Blob(n * SIZE)
            table.insert(W, b)
        end
    end
end

function love.update(dt)
    SIZE = love.graphics.getHeight() / COUNT

    pcall(doTouchStuff)

    for i,v in pairs(T) do
        T[i] = math.max(0, T[i] - dt * 5)
    end

    for k, v in pairs(W) do
        v:update(dt)
    end
end

function love.draw()
    for i=0,COUNT do
        love.graphics.setColor(255, 255, 255, getT(i) * 50)
        love.graphics.rectangle("fill", 0, i*SIZE, love.graphics.getWidth(), SIZE - 1)
    end

    for k, v in pairs(W) do
        v:draw()
    end
end