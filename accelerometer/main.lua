require "vector"

joy = nil

objects = {}

function love.load()
    local joysticks = love.joystick.getJoysticks()
    for i, joystick in ipairs(joysticks) do
        if joystick:getName()=="Android Accelerometer" then
            joy = joystick
            break
        end
    end

    WIDTH = love.graphics.getWidth()
    HEIGHT = love.graphics.getHeight()

    meter = HEIGHT / 4
    love.physics.setMeter(meter)
    world = love.physics.newWorld(0, 9.81 * meter, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

    walls = {}
    walls.ground  = make_rect(WIDTH / 2, HEIGHT + 50, WIDTH, 100)
    walls.ceiling = make_rect(WIDTH / 2,        - 50, WIDTH, 100)
    walls.left    = make_rect(      - 50, HEIGHT / 2, 100, HEIGHT)
    walls.right   = make_rect(WIDTH + 50, HEIGHT / 2, 100, HEIGHT)

    MAKE_OFFSET = Vector(WIDTH / 2, HEIGHT / 2)
    MAKE_SCALE = 2

    body = make_bone(0, 0, 0, 30, 50)
    arm_u_r = make_bone(-20, -10, -55, -10, 20, body)
    arm_u_l = make_bone( 20, -10,  55, -10, 20, body)
    arm_l_r = make_bone(-55, -10, -85, -10, 20, arm_u_r)
    arm_l_l = make_bone( 55, -10,  85, -10, 20, arm_u_l)
    leg_u_r = make_bone(-18,  50, -18,  90, 20, body)
    leg_u_l = make_bone( 18,  50,  18,  90, 20, body)
    leg_l_r = make_bone(-18,  90, -18, 140, 20, leg_u_r)
    leg_l_l = make_bone( 18,  90,  18, 140, 20, leg_u_l)
    neck    = make_bone(  0, -25,   0, -35, 20, body, true)
    head    = make_bone(  0, -35,   0, -65, 30, neck, true)
end

function make_bone(x1, y1, x2, y2, thickness, parent, cap) 
    p1 = Vector(x1, y1)
    p2 = Vector(x2, y2)
    if MAKE_SCALE then
        p1 = p1 * MAKE_SCALE
        p2 = p2 * MAKE_SCALE
        thickness = thickness * MAKE_SCALE
    end
    if MAKE_OFFSET then 
        p1 = p1 + MAKE_OFFSET
        p2 = p2 + MAKE_OFFSET
    end
    dir = p2 - p1
    mid = p1 + dir * 0.5
    angle = dir:angleTo(Vector(0, 1))
    len = dir:len()
    if not cap then len = len + thickness end

    local obj = {}
    obj.body = love.physics.newBody(world, mid.x, mid.y, "dynamic")
    obj.shape = love.physics.newRectangleShape(thickness, len)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, 1)
    obj.body:setSleepingAllowed(false)
    obj.body:setAngle(angle)
    obj.color = {255, 255, 255}
    table.insert(objects, obj)

    if parent then 
        love.physics.newRevoluteJoint(parent.body, obj.body, p1.x, p1.y, false)
    end

    return obj
end

function make_rect(x, y, w, h)
    local obj = {}
    obj.body = love.physics.newBody(world, x, y)
    obj.shape = love.physics.newRectangleShape(w, h)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape, 1)
    return obj
end

joints = {}

function love.touchpressed(id, x, y, p)
    x = x * love.graphics.getWidth()
    y = y * love.graphics.getHeight()

    for k, v in pairs(objects) do
        if v.fixture:testPoint(x, y) then
            joints[id] = {v, love.physics.newMouseJoint(v.body, x, y)}
            v.color = {0, 255, 0}
            break
        end
    end
end

function love.touchreleased(id, x, y, p)
    if joints[id] then
        joints[id][2]:destroy()
        joints[id][1].color = {255, 255, 255}
        joints[id] = nil
    end
end

function love.update(dt)
    for i, j in pairs(joints) do
        t = getTouch(i)
        if t then
            j[2]:setTarget(getTouch(i).x, getTouch(i).y)
        end
    end

    x, y, _ = joy:getAxes()
    s = meter * 9.81
    world:setGravity(x * s, y * s)

    world:update(dt)
end

function love.draw()
    love.graphics.setBackgroundColor(104, 136, 248)
    love.graphics.clear()

    x, y, z = joy:getAxes()
    love.graphics.print(string.format("%.3f %.3f %.3f", x, y, z), 10, 10)

    for k, v in pairs(objects) do
        love.graphics.setColor(unpack(v.color))
        if v.shape:typeOf("CircleShape") then
            love.graphics.circle("fill", v.body:getX(), v.body:getY(), v.shape:getRadius())
        elseif v.shape:typeOf("PolygonShape") then
            love.graphics.push()
            love.graphics.translate(v.body:getPosition())
            love.graphics.rotate(v.body:getAngle())
            love.graphics.polygon("fill", v.shape:getPoints())
            love.graphics.pop()
        end
    end
end
