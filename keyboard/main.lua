function love.load()
    love.keyboard.setTextInput(true)
    FONT = love.graphics.newFont("press.ttf", love.graphics.getWidth() / 10)
    love.graphics.setFont(FONT) 
    TEXT = ""
end

function love.textinput(k)
    TEXT = TEXT .. k
end

function love.keypressed(k)
    if k == "backspace" and TEXT then
        TEXT = TEXT:sub(1, #TEXT-1)
    end

    if k == "return" then
        love.keyboard.setTextInput(false)
    end

    if k == "escape" then
        love.keyboard.setTextInput(true)
    end

    SDL.log("Key: " .. k)
end

function love.update(dt)
    WIDTH = love.graphics.getWidth()
    HEIGHT = love.graphics.getHeight()
end

function love.draw()
    t = "Please enter your name:"
    love.graphics.print(t, WIDTH / 2 - FONT:getWidth(t) / 2, 50)
    love.graphics.print(TEXT, WIDTH / 2 - FONT:getWidth(TEXT) / 2, 50 + FONT:getHeight() * 1.2)
end