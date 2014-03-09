local socket = require "socket"

function love.load()
    local ip, port, bcast = "10.1.1.100", 5667, "10.1.255.255"

    udp = socket.udp() 
    assert(udp:settimeout(0))
    assert(udp:setsockname(ip, port))
    assert(udp:setoption("ip-add-membership" , {multiaddr = ip, interface = ip}))
    print("Starting server")
end

function love.update()
    local data, ip, port = udp:receivefrom()
    if data then
        print(string.format("Received %s from %s:%s", data, ip, port))
    end
end
