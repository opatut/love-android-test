require("helper")

function dist(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

Button = class("Button")
function Button:__init(x, y, r, snd, pitch)
    self.x = x
    self.y = y
    self.r = r
    self.wasDown = false
    self.source = love.audio.newSource(SOUNDS[snd])
    self.source:setLooping(true)
    self.source:pause()
    self.source:setPitch(pitch)
end

function Button:isDown()
    for i=1,love.touch.getTouchCount() do
        id,x,y = love.touch.getTouch(i)
        if dist(self.x, self.y, x*WIDTH, y*HEIGHT) <= self.r*1.2 then 
            return true 
        end
    end
    return false
end

function Button:update(dt)
    local d = self:isDown()

    if d ~= self.wasDown then
        if d then
            self.source:play()
            SDL.log("play")
        else
            self.source:pause()
            SDL.log("pause")
        end
    end

    self.wasDown = d
end

function Button:draw()
    if self:isDown() then
        love.graphics.setColor(255, 255, 255)
    else
        love.graphics.setColor(0, 0, 0)
    end

    love.graphics.circle("fill", self.x, self.y, self.r)
end

--------------------------------------------------------------------------------

BUTTONS = {}
SOUNDS = {}

function love.load()
    table.insert(SOUNDS, love.sound.newSoundData("sound/OOT_Notes_Ocarina_D_loop.wav"))
    table.insert(SOUNDS, love.sound.newSoundData("sound/OOT_Notes_Ocarina_F_loop.wav"))
    table.insert(SOUNDS, love.sound.newSoundData("sound/OOT_Notes_Ocarina_A_loop.wav"))
    table.insert(SOUNDS, love.sound.newSoundData("sound/OOT_Notes_Ocarina_B_loop.wav"))
    table.insert(SOUNDS, love.sound.newSoundData("sound/OOT_Notes_Ocarina_D2_loop.wav"))
    oc = love.graphics.newImage("ocarina.png")

    table.insert(BUTTONS, Button(218, 105, 37, 1, 1))
    table.insert(BUTTONS, Button(340, 113, 45, 2, 1))
    table.insert(BUTTONS, Button(464, 120, 35, 3, 1))
    table.insert(BUTTONS, Button(530, 210, 31, 4, 1))
    table.insert(BUTTONS, Button(650, 196, 22, 4, math.pow(2, 1/12)))
    table.insert(BUTTONS, Button(750, 180, 24, 5, 1))
    table.insert(BUTTONS, Button(850, 181, 22, 5, math.pow(2, 2/12)))
end

function love.update(dt)
    WIDTH = love.graphics.getWidth()
    HEIGHT = love.graphics.getHeight()

    for k,b in pairs(BUTTONS) do
        b:update(dt)
    end
end


function love.draw()
    love.graphics.setColor(40, 40, 40)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(oc, 0, 0)

    for k,b in pairs(BUTTONS) do
        b:draw()
    end

    for i=1,love.touch.getTouchCount() do
        id,x,y = love.touch.getTouch(i)
        love.graphics.setColor(0, 255, 0)
        love.graphics.circle("fill", x * WIDTH, y * HEIGHT, 20)
    end
end