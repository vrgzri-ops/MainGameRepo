-- https://lua.expert/
local t = {}

require(game.ReplicatedStorage.SharedModules.Shared)

local PacketNetworking = require(game.ReplicatedStorage.SharedModules.Dependencies.PacketNetworking)
local Requests = game.ReplicatedStorage.Requests
local RunService = game:GetService("RunService")
local v1 = 0
local t2 = {}
local t3 = {}
local t4 = {}

t.PacketNetworking = PacketNetworking
function t.GetFXEvents(p1) --[[ GetFXEvents | Line: 22 | Upvalues: t4 (copy) ]]
    return t4
end
function t.CreateFXEvent(p1, p2, ...) --[[ CreateFXEvent | Line: 26 | Upvalues: t (copy), t4 (copy) ]]
    local v1 = t:CreateEvent(p2, ...)

    table.insert(t4, v1)

    return v1
end
function t.CreateEvent(p1, p2, ...) --[[ CreateEvent | Line: 33 | Upvalues: PacketNetworking (copy), t3 (copy) ]]
    local v1 = PacketNetworking(p2, ...)

    t3[p2] = v1

    return v1
end
function t.GetEvent(p1, p2) --[[ GetEvent | Line: 41 | Upvalues: t3 (copy) ]]
    if t3[p2] == nil then
        warn("Event not found", p2)
    end

    return t3[p2]
end
function t.LogEvent(p1, p2, p3) --[[ LogEvent | Line: 51 ]] end
function _protectedCall(p1) --[[ _protectedCall | Line: 58 ]]
    local _, _2 = xpcall(function() --[[ Line: 59 | Upvalues: p1 (copy) ]]
        p1()
    end, function(p1) --[[ Line: 61 ]]
        warn(p1)
        warn(debug.traceback("NetworkError occured: ", 4))
    end)
end
function t.FireServer(p1, p2, ...) --[[ FireServer | Line: 70 | Upvalues: t (copy) ]]
    local t2 = { ... }
    local v1 = nil

    _protectedCall(function() --[[ Line: 73 | Upvalues: v1 (ref), t (ref), p2 (copy), t2 (copy) ]]
        v1 = table.pack(t:GetEvent(p2):Fire(unpack(t2)))
    end)
    t:LogEvent(p2, ...)

    local v2 = v1

    return table.unpack(v2)
end
function t.FireClient(p1, p2, p3, ...) --[[ FireClient | Line: 82 | Upvalues: t (copy) ]]
    local t2 = { ... }
    local v1 = nil

    _protectedCall(function() --[[ Line: 85 | Upvalues: v1 (ref), t (ref), p3 (copy), p2 (copy), t2 (copy) ]]
        v1 = t:GetEvent(p3):FireClient(p2, unpack(t2))
    end)
    t:LogEvent(p3, ...)

    return v1
end
function t.FireAllClients(p1, p2, ...) --[[ FireAllClients | Line: 94 | Upvalues: t (copy) ]]
    local t2 = { ... }

    _protectedCall(function() --[[ Line: 96 | Upvalues: t (ref), p2 (copy), t2 (copy) ]]
        t:GetEvent(p2):Fire(unpack(t2))
    end)
    t:LogEvent(p2, ...)
end
function t.FireAllClientsInRange(p1, p2, p3, p4, ...) --[[ FireAllClientsInRange | Line: 104 | Upvalues: t (copy) ]]
    local v1 = p4 or 400
    local v2 = t:GetEvent(p2)

    if v2 == nil then
        warn("[NetworkManager]: No event found for ", p2)

        return
    end

    local v3 = next
    local v4, v5 = game.Players:GetPlayers()

    for v6, v7 in v3, v4, v5 do
        local v8 = nil

        if v7:HasTag("Spectating") then
            if v7.ReplicationFocus ~= nil then
                v8 = (v7.ReplicationFocus.Position - p3).Magnitude
            end

            if v8 and v8 <= v1 then
                v2:FireClient(v7, ...)
            end
        else
            local Character = v7.Character

            if Character ~= nil then
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

                if HumanoidRootPart ~= nil then
                    v8 = (HumanoidRootPart.Position - p3).Magnitude

                    if v8 and v8 <= v1 then
                        v2:FireClient(v7, ...)
                    end
                end
            end
        end
    end

    t:LogEvent(p2, ...)
end
coroutine.create(function() --[[ Line: 146 | Upvalues: v1 (ref), t2 (ref) ]]
    while task.wait(1) do
        print("-----------------------------------------")
        print("RECENT EVENT COUNT: ", v1)

        for v12, v2 in t2 do
            print(v2[1], v2[2], v2[3], v2, if typeof(v2) == "table" then v2.Type else nil)
        end

        v1 = 0
        t2 = {}
    end
end)
RunService:IsServer()
require(script.DefinePackets)(t)

return t
