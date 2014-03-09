local socket = require "socket"

function love.load()
    local ip, port, bcast = "10.1.1.100", 5667, "10.1.255.255"

    udp = socket.udp() 
    assert(udp:setoption('broadcast', true)) 
    assert(udp:setoption('dontroute', true)) 
    --assert(udp:setsockname(ip, 47808)) 
    --assert(udp:settimeout(0))
    assert(udp:sendto('this is a test', bcast, port)) 
    print("Sent client stuff")
    love.event.quit()
end
