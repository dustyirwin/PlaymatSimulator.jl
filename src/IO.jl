module IO
module Client
    using HTTP
    using DataStructures

    function ws_msg(msg="Hello!", wss="ws://164.90.144.33:8080")
        HTTP.WebSockets.open(wss) do ws
            write(ws, msg)
            x = readavailable(ws)
            println(String(x))
        end;
    end
end # module

module Server
    using HTTP

    @async HTTP.WebSockets.listen("164.90.144.33", UInt16(8080)) do ws
        while !eof(ws)
            data = readavailable(ws)
            write(ws, data)
        end
    end
end # module

end # module