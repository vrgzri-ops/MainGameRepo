
local Signal = require(script.Signal)
local Task = require(script.Task)
local Types = require(script.Types)
local DeepPrint = require(game.ReplicatedStorage.SharedModules.Dependencies.DeepPrint)
local remotepacketsizecounter = require(script.Parent.remotepacketsizecounter)
local v1 = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Reads = Types.Reads
local Writes = Types.Writes
local Import = Types.Import
local Export = Types.Export
local Truncate = Types.Truncate
local Ended = Types.Ended
local NumberU8 = Reads.NumberU8
local NumberU82 = Writes.NumberU8
local NumberU16 = Reads.NumberU16
local NumberU162 = Writes.NumberU16
local t = {}
local t2 = {}
local v6 = nil
local v7 = nil
local v8 = nil
local PacketNetworking_Remote = nil
local v9 = nil
local t3 = {
    BufferLength = 128,
    BufferOffset = 0,
    InstancesOffset = 0,
    Buffer = buffer.create(128),
    Instances = {}
}

local function Constructor(p1, p2, ...) --[[ Constructor | Line: 53 | Upvalues: t2 (copy), t (copy), RunService (copy), v9 (ref), Signal (copy), PacketNetworking_Remote (ref), v1 (ref) ]]
    local v12 = t2[p2]

    if v12 then
        return v12
    end

    local v3 = setmetatable({}, t)

    v3.Name = p2

    if RunService:IsServer() then
        v3.Id = v9
        v3.OnServerEvent = Signal()
        PacketNetworking_Remote:SetAttribute(p2, v9)
        t2[v9] = v3
        v9 = v9 + 1
    else
        v3.Id = PacketNetworking_Remote:GetAttribute(p2)
        v3.OnClientEvent = Signal()

        if v3.Id then
            t2[v3.Id] = v3
        end
    end

    local v4, v5 = v1(table.pack(...))

    v3.Reads = v4
    v3.Writes = v5
    t2[v3.Name] = v3

    return v3
end

t.__index = t
t.Type = "Packet"
function t.Response(p1, ...) --[[ Response | Line: 79 | Upvalues: v1 (ref) ]]
    p1.ResponseTimeout = p1.ResponseTimeout or 10

    local v12, v2 = v1(table.pack(...))

    p1.ResponseReads = v12
    p1.ResponseWrites = v2

    return p1
end
function t.Fire(p1, ...) --[[ Fire | Line: 85 | Upvalues: RunService (copy), v8 (ref), Import (copy), t3 (ref), NumberU82 (copy), Task (copy), v5 (ref), v4 (ref), Export (copy) ]]
    if not p1.ResponseReads then
        Import(t3)
        NumberU82(p1.Id)
        v4(p1.Writes, { ... })
        t3 = Export()

        return
    end

    if RunService:IsServer() then
        error("You must use FireClient(player)", 2)
    end

    local v1 = nil

    for i = 1, 128 do
        v1 = v8[v8.Index]

        if not v1 then
            break
        end

        v8.Index = (v8.Index + 1) % 128
    end

    if not v1 then
        Import(t3)
        NumberU82(p1.Id)
        NumberU82(v8.Index)
        v8[v8.Index] = {
            Yielded = coroutine.running(),
            Timeout = Task:Delay(p1.ResponseTimeout, v5, v8, v8.Index, p1.ResponseTimeoutValue)
        }
        v8.Index = (v8.Index + 1) % 128
        v4(p1.Writes, { ... })
        t3 = Export()

        return coroutine.yield()
    end

    error("Cannot have more than 128 yielded threads", 2)
end
function t.FireClient(p1, p2, ...) --[[ FireClient | Line: 110 | Upvalues: v7 (ref), Import (copy), v6 (ref), NumberU82 (copy), Task (copy), v5 (ref), v4 (ref), Export (copy) ]]
    if p2.Parent == nil then
        return
    end

    if p1.ResponseReads then
        local v1 = v7[p2]

        if v1 == nil then
            local t = {
                Index = 0
            }

            v7[p2] = t
            v1 = t
        end

        local v2 = nil

        for i = 1, 128 do
            v2 = v1[v1.Index]

            if not v2 then
                break
            end

            v1.Index = (v1.Index + 1) % 128
        end

        if v2 then
            error("Cannot have more than 128 yielded threads", 2)
        end

        Import(v6[p2] or {
            BufferLength = 128,
            BufferOffset = 0,
            InstancesOffset = 0,
            Buffer = buffer.create(128),
            Instances = {}
        })
        NumberU82(p1.Id)
        NumberU82(v1.Index)
        v1[v1.Index] = {
            Yielded = coroutine.running(),
            Timeout = Task:Delay(p1.ResponseTimeout, v5, v1, v1.Index, p1.ResponseTimeoutValue)
        }
        v1.Index = (v1.Index + 1) % 128
        v4(p1.Writes, { ... })
        v6[p2] = Export()

        return coroutine.yield()
    end

    Import(v6[p2] or {
        BufferLength = 128,
        BufferOffset = 0,
        InstancesOffset = 0,
        Buffer = buffer.create(128),
        Instances = {}
    })
    NumberU82(p1.Id)
    v4(p1.Writes, { ... })
    v6[p2] = Export()
end
function t.Serialize(p1, ...) --[[ Serialize | Line: 137 | Upvalues: Import (copy), v4 (ref), Truncate (copy) ]]
    Import({
        BufferLength = 128,
        BufferOffset = 0,
        InstancesOffset = 0,
        Buffer = buffer.create(128),
        Instances = {}
    })
    v4(p1.Writes, { ... })

    return Truncate()
end
function t.Deserialize(p1, p2, p3) --[[ Deserialize | Line: 143 | Upvalues: Import (copy), v3 (ref) ]]
    local t = {
        BufferOffset = 0,
        InstancesOffset = 0,
        Buffer = p2,
        BufferLength = buffer.len(p2)
    }

    t.Instances = if p3 then p3 else {}
    Import(t)

    return v3(p1.Reads)
end
v1 = function(p1) --[[ ParametersToFunctions | Line: 150 | Upvalues: v2 (ref), Reads (copy), Writes (copy) ]]
    local v1 = table.create(#p1)
    local v22 = table.create(#p1)
    local v3 = v1

    for i, v in ipairs(p1) do
        if type(v) == "table" then
            local v4, v5 = v2(v)

            v3[i] = v4
            v22[i] = v5

            continue
        end

        v3[i] = Reads[v]
        v22[i] = Writes[v]
    end

    return v3, v22
end
v2 = function(p1) --[[ TableToFunctions | Line: 162 | Upvalues: v2 (ref), Reads (copy), Writes (copy), NumberU16 (copy), NumberU162 (copy) ]]
    if #p1 == 1 then
        local v1 = p1[1]
        local v22, v3

        if type(v1) == "table" then
            local v4, v5 = v2(v1)

            v22 = v5
            v3 = v4
        else
            v3 = Reads[v1]
            v22 = Writes[v1]
        end

        return function() --[[ Line: 171 | Upvalues: NumberU16 (ref), v3 (ref) ]]
            local v1 = NumberU16()
            local v2 = table.create(v1)

            for i = 1, v1 do
                v2[i] = v3()
            end

            return v2
        end, function(p1) --[[ Line: 177 | Upvalues: NumberU162 (ref), v22 (ref) ]]
            NumberU162(#p1)

            for v1, v2 in p1 do
                v22(v2)
            end
        end
    end

    local t = {}

    for v6, v7 in p1 do
        table.insert(t, v6)
    end

    table.sort(t)

    local v8 = table.create(#t)
    local v9 = table.create(#t)

    for v10, v11 in t do
        local v12 = p1[v11]

        if type(v12) == "table" then
            local v13, v14 = v2(v12)

            v8[v10] = v13
            v9[v10] = v14

            continue
        end

        v8[v10] = Reads[v12]
        v9[v10] = Writes[v12]
    end

    return function() --[[ Line: 193 | Upvalues: v8 (copy), t (copy) ]]
        local t2 = {}

        for v1, v2 in v8 do
            t2[t[v1]] = v2()
        end

        return t2
    end, function(p1) --[[ Line: 198 | Upvalues: v9 (copy), t (copy) ]]
        for v1, v2 in v9 do
            v2(p1[t[v1]])
        end
    end
end
v3 = function(p1) --[[ ReadParameters | Line: 205 ]]
    return table.unpack(ReadParameters_Packed(p1))
end
function ReadParameters_Packed(p1) --[[ ReadParameters_Packed | Line: 209 ]]
    local v1 = table.create(#p1)

    for v2, v3 in p1 do
        v1[v2] = v3()
    end

    return v1
end
v4 = function(p1, p2) --[[ WriteParameters | Line: 215 ]]
    for v1, v2 in p1 do
        v2(p2[v1])
    end
end
v5 = function(p1, p2, p3) --[[ Timeout | Line: 219 ]]
    task.defer(p1[p2].Yielded, p3)
    p1[p2] = nil
end

if RunService:IsServer() then
    v6 = {}
    v7 = {}
    v9 = 0
    PacketNetworking_Remote = Instance.new("RemoteEvent", script)

    local t4 = {}
    local v10 = task.spawn(function() --[[ Line: 235 | Upvalues: t3 (ref), PacketNetworking_Remote (ref), v6 (ref), t4 (copy) ]]
        while true do
            coroutine.yield()

            if t3.BufferOffset > 0 then
                local v1 = buffer.create(t3.BufferOffset)

                buffer.copy(v1, 0, t3.Buffer, 0, t3.BufferOffset)

                if t3.InstancesOffset == 0 then
                    PacketNetworking_Remote:FireAllClients(v1)
                else
                    PacketNetworking_Remote:FireAllClients(v1, t3.Instances)
                    t3.InstancesOffset = 0
                    table.clear(t3.Instances)
                end

                t3.BufferOffset = 0
            end

            for v2, v3 in v6 do
                local v4 = buffer.create(v3.BufferOffset)

                buffer.copy(v4, 0, v3.Buffer, 0, v3.BufferOffset)

                if v3.InstancesOffset == 0 then
                    PacketNetworking_Remote:FireClient(v2, v4)

                    continue
                end

                PacketNetworking_Remote:FireClient(v2, v4, v3.Instances)
            end

            table.clear(v6)
            table.clear(t4)
        end
    end)

    local function f11(p1, p2, p3, ...) --[[ Line: 264 | Upvalues: RunService (copy), Import (copy), v6 (ref), NumberU82 (copy), v4 (ref), Export (copy) ]]
        if p1.OnServerInvoke == nil then
            if not RunService:IsStudio() then
                return
            end

            warn("OnServerInvoke not found for packet:", p1.Name, "discarding event:", ...)
        else
            local t = { p1.OnServerInvoke(p2, ...) }

            if p2.Parent == nil then
                return
            end

            Import(v6[p2] or {
                BufferLength = 128,
                BufferOffset = 0,
                InstancesOffset = 0,
                Buffer = buffer.create(128),
                Instances = {}
            })
            NumberU82(p1.Id)
            NumberU82(p3 + 128)
            v4(p1.ResponseWrites, t)
            v6[p2] = Export()
        end
    end

    local function f12(p1, p2, p3) --[[ Line: 275 | Upvalues: t4 (copy), RunService (copy), Import (copy), Ended (copy), t2 (copy), NumberU8 (copy), Task (copy), f11 (copy), v3 (ref), v7 (ref) ]]
        local v32 = (t4[p1] or 0) + math.max(buffer.len(p2), 800)

        if v32 > 8000 then
            if not RunService:IsStudio() then
                return
            end

            warn(p1.Name, "is exceeding the data/rate limit; some events may be dropped")
        else
            t4[p1] = v32

            local t = {
                BufferOffset = 0,
                InstancesOffset = 0,
                Buffer = p2,
                BufferLength = buffer.len(p2)
            }

            t.Instances = if p3 then p3 else {}
            Import(t)

            while Ended() == false do
                local v6 = t2[NumberU8()]

                if v6.ResponseReads then
                    local v72 = NumberU8()

                    if v72 < 128 then
                        Task:Defer(f11, v6, p1, v72, v3(v6.Reads))

                        continue
                    end

                    local v8 = v72 - 128
                    local v9 = v7[p1][v8]

                    if v9 then
                        task.cancel(v9.Timeout)
                        task.defer(v9.Yielded, v3(v6.ResponseReads))
                        v7[p1][v8] = nil

                        continue
                    end

                    if RunService:IsStudio() then
                        warn("Response thread not found for packet:", v6.Name, "discarding response:", v3(v6.ResponseReads))

                        continue
                    end

                    v3(v6.ResponseReads)
                else
                    v6.OnServerEvent:Fire(p1, v3(v6.Reads))
                end
            end
        end
    end

    PacketNetworking_Remote.OnServerEvent:Connect(function(p1, ...) --[[ Line: 306 | Upvalues: f12 (copy), RunService (copy) ]]
        local _, result = pcall(f12, p1, ...)

        if not (result and RunService:IsStudio()) then
            return
        end

        warn(p1.Name, result)
    end)
    Players.PlayerRemoving:Connect(function(p1) --[[ Line: 311 | Upvalues: v6 (ref), v7 (ref), t4 (copy) ]]
        v6[p1] = nil
        v7[p1] = nil
        t4[p1] = nil
    end)
    RunService.Heartbeat:Connect(function(p1) --[[ Line: 317 | Upvalues: v10 (copy) ]]
        task.defer(v10)
    end)
else
    v8 = {
        Index = 0
    }
    PacketNetworking_Remote = script:WaitForChild("RemoteEvent")
    PacketNetworking_Remote.Name = "PacketNetworking_Remote"

    local v13 = 0
    local v14 = task.spawn(function() --[[ Line: 325 | Upvalues: t3 (ref), PacketNetworking_Remote (ref) ]]
        while true do
            repeat
                coroutine.yield()
            until t3.BufferOffset > 0

            local v1 = buffer.create(t3.BufferOffset)

            buffer.copy(v1, 0, t3.Buffer, 0, t3.BufferOffset)

            if t3.InstancesOffset == 0 then
                PacketNetworking_Remote:FireServer(v1)
            else
                PacketNetworking_Remote:FireServer(v1, t3.Instances)
                t3.InstancesOffset = 0
                table.clear(t3.Instances)
            end

            t3.BufferOffset = 0
        end
    end)

    local function f15(p1, p2, ...) --[[ Line: 343 | Upvalues: Import (copy), t3 (ref), NumberU82 (copy), v4 (ref), Export (copy) ]]
        if p1.OnClientInvoke == nil then
            warn("OnClientInvoke not found for packet:", p1.Name, "discarding event:", ...)
        else
            local t = { p1.OnClientInvoke(...) }

            Import(t3)
            NumberU82(p1.Id)
            NumberU82(p2 + 128)
            v4(p1.ResponseWrites, t)
            t3 = Export()
        end
    end

    PacketNetworking_Remote.OnClientEvent:Connect(function(p1, p2) --[[ Line: 353 | Upvalues: Import (copy), Ended (copy), t2 (copy), NumberU8 (copy), Task (copy), f15 (copy), v3 (ref), v8 (ref), RunService (copy), remotepacketsizecounter (copy), DeepPrint (copy) ]]
        local t = {
            BufferOffset = 0,
            InstancesOffset = 0,
            Buffer = p1,
            BufferLength = buffer.len(p1)
        }

        t.Instances = if p2 then p2 else {}
        Import(t)

        while Ended() == false do
            local v32 = t2[NumberU8()]

            if v32 == nil then
                warn("[PacketNetworking]: packet is nil")

                return
            end

            if v32.ResponseReads then
                local v4 = NumberU8()

                if v4 < 128 then
                    Task:Defer(f15, v32, v4, v3(v32.Reads))

                    continue
                end

                local v5 = v4 - 128
                local v6 = v8[v5]

                if v6 then
                    task.cancel(v6.Timeout)
                    task.defer(v6.Yielded, v3(v32.ResponseReads))
                    v8[v5] = nil

                    continue
                end

                warn("Response thread not found for packet:", v32.Name, "discarding response:", v3(v32.ResponseReads))
            else
                xpcall(function() --[[ Line: 379 | Upvalues: v32 (copy), RunService (ref), remotepacketsizecounter (ref), p1 (copy), p2 (copy), DeepPrint (ref) ]]
                    local v1 = ReadParameters_Packed(v32.Reads)
                    local v2 = workspace:GetAttribute("Debug_ReadPacketSize")

                    if v2 ~= nil and not RunService:IsStudio() then
                        local v3 = remotepacketsizecounter.GetPacketSize({
                            RunContext = "Server",
                            RemoteType = "RemoteEvent",
                            PacketData = { p1, p2 }
                        })

                        if v2 <= v3 then
                            print("-------------------------------------------")
                            warn(v32.Name, "Size =", tostring(v3 / 1000) .. "KB", "Parameters:")

                            if v1 then
                                DeepPrint(v1)
                            end
                        end
                    end

                    v32.OnClientEvent:Fire(table.unpack(v1))
                end, function(p1) --[[ Line: 401 | Upvalues: v32 (copy) ]]
                    warn(p1)
                    warn(debug.traceback(".OnClientEvent for Event " .. v32.Name, 4))
                end)
            end
        end
    end)
    PacketNetworking_Remote.AttributeChanged:Connect(function(p1) --[[ Line: 412 | Upvalues: t2 (copy), PacketNetworking_Remote (ref) ]]
        local v1 = t2[p1]

        if not v1 then
            return
        end

        if v1.Id then
            t2[v1.Id] = nil
        end

        v1.Id = PacketNetworking_Remote:GetAttribute(p1)

        if not v1.Id then
            return
        end

        t2[v1.Id] = v1
    end)
    RunService.Heartbeat:Connect(function(p1) --[[ Line: 421 | Upvalues: v13 (ref), v14 (copy) ]]
        v13 = v13 + p1

        if not (v13 > 1 / 60) then
            return
        end

        v13 = v13 % 1 / 60
        task.defer(v14)
    end)
end

return setmetatable(Types.Types, {
    __call = Constructor
})
