-- helpers for lua coding

-- simplifies OOP
--[[
function class(name, superclass)
    local cls = superclass and superclass() or {}
    cls.__name = name or ""
    cls.__super = superclass
    return setmetatable(cls, {__call = function (c, ...)
        local self = setmetatable({__class = cls}, cls)
        if cls.__init then
            cls.__init(self, ...)
        end
        for k,v in pairs(cls) do
            self[k] = v
        end
        return self
    end})
end
]]--

function pack(...)
    return {...}
end

function setLightRendering(enabled, notAdditive)
    if enabled then
        love.graphics.setCanvas(LIGHT_CANVAS)
        if not notAdditive then love.graphics.setBlendMode("additive") end
    else
        love.graphics.setCanvas()
        love.graphics.setBlendMode("alpha")
    end
end

function drawLights()
    love.graphics.setColor(255, 255, 255, 180)
    love.graphics.setBlendMode("multiplicative")
    love.graphics.draw(LIGHT_CANVAS, 0, 0)
    love.graphics.setColor(255, 255, 255, 50)
    love.graphics.setBlendMode("additive")
    love.graphics.draw(LIGHT_CANVAS, 0, 0)
    love.graphics.setBlendMode("alpha")
end

function class(name, super)
    -- main metadata
    local cls = {}

    -- copy the members of the superclass
    if super then
        for k,v in pairs(super) do
            cls[k] = v
        end
    end

    cls.__name = name
    cls.__super = super

    -- when the class object is being called,
    -- create a new object containing the class'
    -- members, calling its __init with the given
    -- params
    cls = setmetatable(cls, {__call = function(c, ...)
        local obj = {}
        for k,v in pairs(cls) do
            --if not k == "__call" then
                obj[k] = v
            --end
        end
        setmetatable(obj, cls)
        if obj.__init then obj:__init(...) end
        obj.__class = cls
        return obj
    end})
    return cls
end

function inherits(obj, name)
    local c = obj.__class
    while c do
        if c.__name == name then return true end
        c = c.__super
    end
    return false
end

function randf(from, to)
    if from then
        if to then
            return from + math.random() * (to - from)
        else
            return from * math.random()
        end
    else
        return randf(0, 1)
    end
end


-- Converts HSL to RGB (input and output range: 0 - 255)
function hsl2rgb(h, s, l)
    local r, g, b = nil, nil, nil
 
    if s == 0 then
        r, g, b = l, l ,l -- achromatic
    else
        local hue2rgb = function(p, q, t)
            if t < 0 then 
                t = t + 1 
            end
            if t > 1 then
                t = t - 1
            end
            if t < 1/6 then
                return p + (q - p) * 6 * t
            end
            if t < 1/2 then 
                return q
            end
            if t < 2/3 then 
                return p + (q - p) * (2/3 - t) * 6
            end
            return p
        end
 
        local q = nil
        if l < 0.5 then
            q = l * (1 + s)
        else 
            q = l + s - l * s
        end
        local p = 2 * l - q
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1/3)
    end
 
    return r * 255, g * 255, b * 255
end

function fadeColor(a, b, s)
    return
        a[1]*(1-s)+b[1]*s,
        a[2]*(1-s)+b[2]*s,
        a[3]*(1-s)+b[3]*s
end

function table.removeValue(table, value)
    for k,v in pairs(table) do
        if v == value then
            table[k] = nil
        end
    end
end

function math.floorTo(k, t)
    return math.floor(k / t) * t
end