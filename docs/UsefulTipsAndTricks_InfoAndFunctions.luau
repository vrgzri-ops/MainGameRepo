-- This file is a container for all useful information that me and Codex were able to discover.

-- Instructions for Codex: try to explain every information deeply, and in good details. Main idea of that file is that even after 1 year, i could look inside of it and remember all useful info we collected so i can use it in multiple projects.



-- notes:










-- Variables
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = cloneref(Players.LocalPlayer)
local Workspace = cloneref(game:GetService("Workspace"))
local vim = Instance.new("VirtualInputManager")
local playerAddedConnection
local characterConnections = {}

local Noclipping


-- LUARMOR function -- USE IN EVERY SCRIPT, it can disable virtualization in some chunks of code that you want to imrove
loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();




-- utility functions
local function GetCharacter()
    local char = LocalPlayer.Character

    if char then
        return cloneref(char)
    end

    return cloneref(LocalPlayer.CharacterAdded:Wait())
end

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local function betterPcall(func,taskSpawn)
    if taskSpawn == 1 then 
        task.spawn(function()
            local s,r=pcall(func)
            if not s then 
                local tableinfo = debug.getinfo(func)
                warn("Line defined: ", tableinfo.currentline)
                warn(r)
            end 
        end)
    else 
        local s,r=pcall(func)
        if not s then 
            local tableinfo = debug.getinfo(func)
            warn("Line defined: ", tableinfo.currentline)
            warn(r)
        end
    end 
end




-- Touch Interest function
local function fireproximityprompt1(Obj, Amount, Skip) 
    if Obj:IsA("ProximityPrompt") then 
        Obj.RequiresLineOfSight = false
        Obj.MaxActivationDistance = 40
        Amount = Amount or 1 
        local PromptTime = Obj.HoldDuration 
        if Skip then 
            Obj.HoldDuration = 0 
        end 
        for i = 1, Amount do 
            Obj:InputHoldBegin()
            print("Chest Collected")
            if not Skip then 
                task.wait(Obj.HoldDuration)
            end 
            Obj:InputHoldEnd() 
        end 
        Obj.HoldDuration = PromptTime 
    else error("userdata<ProximityPrompt> expected")
    end 
end








-- ESP functions
local function addESP(character)
	if character.Name ~= LocalPlayer.Name and not character:FindFirstChild("ESPHighlight") then
		local highlight = Instance.new("Highlight", character)
		highlight.Name = "ESPHighlight"
		highlight.FillColor = Color3.fromRGB(0,0,0)

		print(character, "ESP - true")
	end
end

local function newPlayer(player)

    if characterConnections[player] then
        characterConnections[player]:Disconnect()
    end

	if player.Character then
		addESP(player.Character)
	end

	characterConnections[player] = player.CharacterAdded:Connect(function(char)
        addESP(char)
    end)
end

local function enableESP()
	for _, v in pairs(Players:GetPlayers()) do
		newPlayer(v)
	end

	playerAddedConnection = Players.PlayerAdded:Connect(function()
        newPlayer()
    end)
end

local function disableESP()
	for _, v in pairs(Players:GetPlayers()) do
		if v.Character then
			local esp = v.Character:FindFirstChild("ESPHighlight")
			if esp then esp:Destroy() end
		end
	end

	if playerAddedConnection then
		playerAddedConnection:Disconnect()
	end

	for _, connection in pairs(characterConnections) do
		connection:Disconnect()
	end

	characterConnections = {}
end




-- NoClip functions
local function StartNoClipFunc()
    if Noclipping then return end

    Noclipping = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function NoClipDisableFunc()
	if Noclipping then
		Noclipping:Disconnect()
        Noclipping = nil
	end
end







-- Lock Player CFrame functions
local function StartLock()
    if getCharacter() ~= nil then
        local root = getCharacter():WaitForChild("HumanoidRootPart")
        local lockedCFrame = root.CFrame
        if lockflag then return end
        lockflag = true

        task.spawn(function()
            while lockflag and root.Parent do
                root.CFrame = lockedCFrame
                task.wait()
            end
        end)
    end
end

local function StopLock()
    if lockflag then 
        lockflag = false
    end
end







-- Aim Bot functions
local function notBehindWall(target)
    local ray = Ray.new(getCharacter().Head.Position, (target.Position - LocalPlayer.Character.Head.Position).Unit * 300)
    local part, position = Workspace:FindPartOnRayWithIgnoreList(ray, {getCharacter()}, false, true)
    if part then
        local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            humanoid = part.Parent.Parent:FindFirstChildOfClass("Humanoid")
        end
        if humanoid and target and humanoid.Parent == target.Parent then
            local pos, visible = camera:WorldToScreenPoint(target.Position)
            if visible then
                return true
            end
        end
    end
end

local function getPlayerClosestToMouse()
    local target = nil
    local maxDist = 250
    for _,v in pairs(Players:GetPlayers()) do
        if v.Character then
            if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild("HumanoidRootPart") then
                local pos, visible = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local dist = (Vector2.new(mouse.X,mouse.Y) - Vector2.new(pos.X,pos.Y)).Magnitude
                if dist < maxDist and visible then
                    local torsoPos = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                    local torsoDist = (Vector2.new(mouse.X,mouse.Y) - Vector2.new(torsoPos.X,torsoPos.Y)).Magnitude
                    local headPos = camera:WorldToViewportPoint(v.Character.Head.Position)
                    local headDist = (Vector2.new(mouse.X,mouse.Y) - Vector2.new(headPos.X,headPos.Y)).Magnitude
                    if torsoDist > headDist then
                        if notBehindWall(v.Character.Head) then
                            target = v.Character.Head
                        elseif notBehindWall(v.Character.HumanoidRootPart) then
                            target = v.Character.HumanoidRootPart
                        end
                    else
                        if notBehindWall(v.Character.HumanoidRootPart) then
                            target = v.Character.HumanoidRootPart
                        elseif notBehindWall(v.Character.Head) then
                            target = v.Character.Head
                        end
                    end
                    maxDist = dist
                end
            end
        end
    end
    return target
end





-- Webhook, user config
getgenv().WEBHOOK_URL = "" -- Paste webhook if you need discord message everytime you get a new twoh stand or skin

local function SendWebhook(message)
    local response = request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            ["content"] = "",
            ["embeds"] = {{
                ["title"] ="**Hello user!**",
                ["description"] = message,
                ["type"] = "rich",
                ["color"] = tonumber(0xF0F0A1),
                ["fields"] = {
                    {
                        ["name"] = "Info:",
                        ["value"] = string.format(
                                    "Info1: %s\nInfo2: %s\nInfo3: %s",
                                    --plr.PlayerStats.Slot1.Value,
                                    --plr.PlayerStats.Slot2.Value,
                                    --plr.PlayerStats.Slot3.Value
                                ),
                        ["inline"] = true
                    }
                }
            }}
        })
    })

    if response.Success then
        if response.Body ~= "" then
            local data = HttpService:JSONDecode(response.Body)
            print(data)
        else
            print("Webhook sent successfully.")
        end
    end
end





-- Server Hop --
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local File = pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end
function TPReturner()
    local Site;
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    local num = 0;
    for i,v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _,Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                task.wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    task.wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                task.wait(4)
            end
        end
    end
end

function Teleport()
    while task.wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end



-- NPC functions
local function tpBehindNPC(npc, distance)

    local NPChrp = npc:WaitForChild("HumanoidRootPart",5)
    if not NPChrp then return end

    local char = GetCharacter()
    if not char then return end
    if not char:WaitForChild("HumanoidRootPart", 5) then return end

    local forwardNPC = NPChrp.CFrame.LookVector

    local newPosition = npc.HumanoidRootPart.Position + (forwardNPC * distance or -4)

    local newCFrame = CFrame.new(newPosition, newPosition + forwardNPC)

    char:PivotTo(newCFrame)
end


local function killnpc(npcName, playerDistance)
    local char = GetCharacter()
    if not char or char.Parent == nil then return end

    local NPC = Workspace.Living:WaitForChild(npcName, 10) -- Path to npc

    if not NPC then
        return
    end

    if not NPC:FindFirstChild("HumanoidRootPart") then
        return
    end

    local beingTargeted = true

    local function SetPlayerPos()
        if not char or char.Parent == nil then return end
        if beingTargeted then
            if NPC then
                if NPC:FindFirstChild("HumanoidRootPart") then

                    local npcHRP = NPC:FindFirstChild("HumanoidRootPart")
                    local stand = char:FindFirstChild("StandMorph")

                    if npcHRP then
                        local pos = npcHRP.Position
                        local velocity = npcHRP.AssemblyLinearVelocity
                        local ping = LocalPlayer:GetNetworkPing()

                        local predictedPos = pos + ((velocity * (ping * math.random(1,3))) / math.random(1,2))

                        local predictedCFrame = CFrame.lookAt(
                            predictedPos,
                            predictedPos + npcHRP.CFrame.LookVector
                        )

                        stand:PivotTo(predictedCFrame)

                        -- ADD KILL LOGIC HERE
                    end
                else
                    beingTargeted = false
                end
            else
                beingTargeted = false
            end
        end
    end

    local function BlockBreaker() -- Auto break NPC block
        if not char or char.Parent == nil then return end

        if beingTargeted then
            if not NPC or NPC.Parent == nil then
                return
            end

            local Event = char:WaitForChild("RemoteEvent",5)
            local RemoteFunction = char:WaitForChild("RemoteFunction",5)

            local randomNumber = math.random(1, 3)

            if game:GetService("CollectionService"):HasTag(NPC, "Blocking") then
                if randomNumber == 1 then
                    Event:FireServer("InputBegan", {["Input"] = Enum.KeyCode.R})
                    Event:FireServer("InputEnded",{Input = Enum.KeyCode.R})
                elseif randomNumber == 2 then
                    RemoteFunction:InvokeServer("Attack", "m2")
                elseif randomNumber == 3 then
                    Event:FireServer("InputBegan", {["Input"] = Enum.KeyCode.X})
                    Event:FireServer("InputEnded",{Input = Enum.KeyCode.X})
                end
            elseif NPC.Humanoid.Health <= 1 then
                task.wait(1)
                if NPC then
                    if randomNumber == 1 then
                        RemoteFunction:InvokeServer("Attack", "m1")
                    elseif randomNumber == 2 or randomNumber == 3 then
                        Event:FireServer("InputBegan", {["Input"] = Enum.KeyCode.X})
                        Event:FireServer("InputEnded",{Input = Enum.KeyCode.X})
                    end
                end
                task.wait()
            elseif NPC.Humanoid.Health >= 1 then
                if randomNumber == 1 then
                    RemoteFunction:InvokeServer("Attack", "m1")
                elseif randomNumber == 2 then
                    Event:FireServer("InputBegan", {["Input"] = Enum.KeyCode.X})
                    Event:FireServer("InputEnded",{Input = Enum.KeyCode.X})
                elseif randomNumber == 3 then
                    Event:FireServer("InputBegan", {["Input"] = Enum.KeyCode.U})
                    Event:FireServer("InputEnded",{Input = Enum.KeyCode.U})
                end
                task.wait()
            end
        end
    end

    
    local TaskWait = task.delay(80, function() -- if NPC is not killed in 80 secs, return function
        beingTargeted = false
        print("KillNPC timeout returned")
        return
    end)

    local BlockBreakerTask = task.defer(function() -- use BlockBreaker in its own task, because otherwise it will lag very bad
        while beingTargeted do
            task.wait()
            BlockBreaker()
        end
    end)

    while beingTargeted do
        task.wait()
        char = GetCharacter()
        if not char or char.Parent == nil then print("No character in loop 'BeingTargeted'"); beingTargeted = false; return end

        if NPC then
            if NPC:FindFirstChild("HumanoidRootPart") then
                task.spawn(SetPlayerPos)
            else
                task.cancel(TaskWait)
                task.cancel(BlockBreakerTask)
                beingTargeted = false
                print("No HumanoidRootPart in ", npcName)
                return
            end
        else
            print("No NPC in ", npcName)
            task.cancel(TaskWait)
            task.cancel(BlockBreakerTask)
            beingTargeted = false
            return
        end
    end

    print("KillNPC returned")
    task.cancel(TaskWait)
    task.cancel(BlockBreakerTask)
    return true
end





-- frameclick function
local function frameclick(path)
    local inset = GuiService:GetGuiInset()
    print("FRAMECLICK POS: ", inset.X, inset.Y)

    local X = path.AbsolutePosition.X + (path.AbsoluteSize.X / 2)
    local Y = path.AbsolutePosition.Y + (path.AbsoluteSize.Y / 2)

    vim:SendMouseButtonEvent(X, Y + inset.Y, 0, true, nil, 1)
    task.wait()
    vim:SendMouseButtonEvent(X, Y + inset.Y, 0, false, nil, 1)
    task.wait()
end