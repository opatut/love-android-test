PARTS = {}
COLORS = {
    {100, 200, 255},
    {255, 180, 30},
    {255, 100, 255},
    {40, 255, 80},
    {255, 255, 0},
    {255, 0, 128},
    {0, 0, 255},
    {255, 255, 255}
}

function love.load()
    WIDTH = love.graphics.getWidth()
    HEIGHT = love.graphics.getHeight()
    TOUCH = false
    BELL_TIMEOUT = 0
    BELL_STREAK = 0


    t = love.graphics.newImage("blur.png")

    TEXT = ""
end

function genPart(id)
    local p = love.graphics.newParticleSystem(t, 2000)
    local c = COLORS[id%#COLORS + 1]
    p:setColors(
        c[1], c[2], c[3], 255, 
        c[1], c[2], c[3], 100, 
        255, 255, 255, 0)
    p:setEmissionRate(800)
    p:setParticleLifetime(0.8, 1)
    p:setSpread(-math.pi*2, math.pi*2)
    p:setSpeed(300, 600)
    p:setRadialAcceleration(-300)
    p:setTangentialAcceleration(100)
    p:setSizes(1, 0)
    p:pause()
    PARTS[id] = p
end

function love.update(dt)
    WIDTH = love.graphics.getWidth()
    HEIGHT = love.graphics.getHeight()
    BELL_TIMEOUT = BELL_TIMEOUT - dt

    for k, p in pairs(PARTS) do
        p:update(dt)
    end
end

function love.touchpressed(id, x, y, p)
    TOUCH = true

    if not PARTS[id] then genPart(id) end
    PARTS[id]:start()
    PARTS[id]:setPosition(x * WIDTH, y * HEIGHT)

    --pling()
end

function love.touchmoved(id, x, y, p)
    PARTS[id]:setPosition(x * WIDTH, y * HEIGHT)
end

function love.touchreleased(id, x, y, p)
    PARTS[id]:pause()
    TOUCH = false
end

function pling()
    if BELL_TIMEOUT > 0 then
        BELL_STREAK = BELL_STREAK + 1
    else
        BELL_STREAK = 0
    end

    source = love.audio.newSource(BELL)
    source:setPitch(0.5 + BELL_STREAK / 12)
    source:play()
    BELL_TIMEOUT = 1
end

function love.draw()
    love.graphics.clear()
    love.graphics.setBlendMode("alpha")

    local f = math.max(0, BELL_TIMEOUT)
    love.graphics.setColor(255 * f, 255 * f, 255 * f)
    love.graphics.rectangle("fill", WIDTH / 2 * (1-f), HEIGHT / 2 * (1-f), WIDTH * f, HEIGHT * f)

    love.graphics.setBlendMode("additive")
    for k, p in pairs(PARTS) do
        love.graphics.draw(p)
    end
    love.graphics.setBlendMode("alpha")

    love.graphics.setColor(255, 255, 255)
    love.graphics.print(TEXT, 10, 10)
end
