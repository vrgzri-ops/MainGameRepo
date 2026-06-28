local function protect(fn)
    return function(...)
        local ok, err = xpcall(fn, debug.traceback, ...)
        if not ok then
            warn(err)
        end
    end
end

---VARIABLES---
local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local plr = cloneref(Players.LocalPlayer)
local ModulesFolder = cloneref(ReplicatedStorage.Modules)
local VFXmoduleRef = cloneref(ModulesFolder:WaitForChild("VFXModule"))
local VFXmodule1 = require(VFXmoduleRef)
local playerAddedConnection
local characterConnections = {}
local function getCharacter()
    return cloneref(plr.Character) or cloneref(plr.CharacterAdded:Wait())
end
local function getHrp()
    return cloneref(getCharacter():WaitForChild("HumanoidRootPart"))
end
local ts = cloneref(game:GetService("TweenService"))
local RunService = cloneref(game:GetService("RunService"))
local lockflag
local Noclipping
local fishCycle = 1
local previousFishCycle = 1
local fishChestConnection
local connectionFishfarm
local autoFishTween
local mouse = cloneref(plr:GetMouse())
local camera = cloneref(Workspace.CurrentCamera)

local fishFarmPositions = {
    CFrame.new(-1384.56995, 209.548355, -2634.11182, 0.0570633821, -5.06242479e-08, 0.998370528, -1.4835938e-10, 1, 5.07153501e-08, -0.998370528, -3.04210723e-09, 0.0570633821),
    CFrame.new(-1480.03137, 204.299973, -2681.33521, -0.999897659, 5.11077049e-11, -0.0143074468, 1.44267922e-14, 1, 3.57109697e-09, 0.0143074468, 3.57073127e-09, -0.999897659),
    CFrame.new(-1522.39429, 121.299957, -2580.31152, 1, 9.23285537e-09, -0.000238370922, -9.24344956e-09, 1, -4.44458905e-08, 0.000238370922, 4.44480932e-08, 1),
    CFrame.new(-1423.59912, 121.299942, -2574.77173, 0.998339176, -2.39426812e-09, -0.0576099344, -2.19051199e-09, 1, -7.95199995e-08, 0.0576099344, 7.95141304e-08, 0.998339176),
    CFrame.new(-1462.98584, 52.8999748, -2592.99341, -0.0365962088, 2.39359341e-08, 0.999330163, -4.03178433e-08, 1, -2.54284487e-08, -0.999330163, -4.12214192e-08, -0.0365962088),
}

local fishThrowPositions = {
    vector.create(-1397.94189453125, 206.5625, -2648.1591796875),
    vector.create(-1481.340576171875, 204.12554931640625, -2671.669921875),
    vector.create(-1516.4483642578125, 125.74889373779297, -2592.0625),
    vector.create(-1423.971923828125, 129.60186767578125, -2592.0625),
    vector.create(-1481.67333984375, 56.94182586669922, -2593.157470703125),
}



---UI LIBRARY---
local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
local Wait = library.subs.Wait -- Only returns if the GUI has not been terminated. For 'while Wait() do' loops



---FUNCTIONS---
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

local function addESP(character)
	if character.Name ~= plr.Name and not character:FindFirstChild("ESPHighlight") then
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
		protect(addESP)(player.Character)
	end

	characterConnections[player] = player.CharacterAdded:Connect(function(char)
        protect(addESP)(char)
    end)
end

local function enableESP()
	for _, v in pairs(Players:GetPlayers()) do
		protect(newPlayer)(v)
	end

	playerAddedConnection = Players.PlayerAdded:Connect(protect(newPlayer))
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

local function infHorseStamina()
    local success, errorMessage = pcall(function()
        task.spawn(protect(function()
            while library.Flags["flag_Infinite_Horse_Stamina"] do
                task.wait()
                local char = getCharacter()
                if char:FindFirstChild("RidingHorse") then
                    char.RidingHorse.Value:SetAttribute("CurrentStamina", 150)
                end
            end
        end))
    end)
    if not success then warn(errorMessage) end
end

local function StartNoClipFunc()
    if Noclipping then return end

    Noclipping = RunService.Stepped:Connect(function()
        local char = plr.Character
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

local function StartLock()
    if getCharacter() ~= nil then
        local root = getCharacter():WaitForChild("HumanoidRootPart")
        local lockedCFrame = root.CFrame
        if lockflag then return end
        lockflag = true

        task.spawn(protect(function()
            while lockflag and root.Parent do
                root.CFrame = lockedCFrame
                task.wait()
            end
        end))
    end
end

local function StopLock()
    if lockflag then 
        lockflag = false
    end
end

local function enableFishChest()
    if Workspace:WaitForChild("Chests") and getCharacter() then
        if fishChestConnection then fishChestConnection:Disconnect() end
        fishChestConnection = Workspace.Chests.ChildAdded:Connect(function(inst)
            if inst:WaitForChild("Lid") then
                local distance = plr:DistanceFromCharacter(inst:FindFirstChild("Lid").CFrame.Position)
                if inst:WaitForChild("ProximityPrompt", 5) and distance < 10 then
                    local Chestprompt = inst:FindFirstChild("ProximityPrompt")
                    while Chestprompt and distance < 10 do
                        if inst then
                            distance = plr:DistanceFromCharacter(inst:WaitForChild("Lid").CFrame.Position)
                            task.wait(.1)
                            fireproximityprompt1(Chestprompt, 1, true)
                            Chestprompt = inst:FindFirstChild("ProximityPrompt")
                        end
                    end
                end
            end
        end)
    end
end 
local function disableFishChest()
    if fishChestConnection then
        fishChestConnection:Disconnect()
    end
end
local function autoBuyBaitAndSellFish()
    local args = {
        "Action",
        "Buy_Bait",
        cloneref(Workspace:WaitForChild("NPC"):WaitForChild("Daniel"))
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DialogueRemote"):FireServer(unpack(args))

    local args = {
        "Action",
        "Sell_Cod",
        cloneref(Workspace:WaitForChild("NPC"):WaitForChild("Daniel"))
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DialogueRemote"):FireServer(unpack(args))

    local args = {
        "Action",
        "Sell_Snapper",
        cloneref(Workspace:WaitForChild("NPC"):WaitForChild("Daniel"))
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DialogueRemote"):FireServer(unpack(args))

    local args = {
        "Action",
        "Sell_Bass",
        cloneref(Workspace:WaitForChild("NPC"):WaitForChild("Daniel"))
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DialogueRemote"):FireServer(unpack(args))
end

local function autoFarmFish()
    while library.Flags["flag_Auto_Farm_Fish"] do
        local fishBite
        local fishing


        if connectionFishfarm then
            connectionFishfarm:Disconnect()
        end

        --Auto pick up fish
        connectionFishfarm = Workspace.ChildAdded:Connect(function(inst)
            if inst.Name == "Part" then
                if inst:FindFirstChild("Beam") then
                    local tipFishRod = inst:FindFirstChild("Beam").Attachment0
                    local playerFishrodTip

                    if getCharacter():WaitForChild("RodModel", 25) then
                        playerFishrodTip = getCharacter():WaitForChild("RodModel", 25).Handle.Tip
                    end
                    if tipFishRod == playerFishrodTip then
                        fishing = true
                        if inst:WaitForChild("FishBite",20) then
                            local args = {
                                "FishingRod",
                                "Primary",
                                vector.create(-1397.94189453125, 206.5625, -2648.1591796875)
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseTool"):FireServer(unpack(args))

                            task.wait(1.2) -- wait to fire MashingSuccess

                            local args = {
                                "MashingSuccess"
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("QTEEvent"):FireServer(unpack(args))

                            task.wait(4) -- wait to launch next throw

                            fishBite = true
                            fishing = false
                        end
                    end
                end
            end
        end)


        task.wait()
        StartNoClipFunc()
        enableFishChest()
		if autoFishTween then
			autoFishTween:Destroy()
		end
        autoBuyBaitAndSellFish()
        if plr.Backpack:FindFirstChild("FishingRod") then 
            getCharacter().Humanoid:EquipTool(plr.Backpack.FishingRod)
        elseif not getCharacter():FindFirstChild("FishingRod") then
            local args = {
                "Action",
                "Buy_FishingRod",
                Workspace:WaitForChild("NPC"):WaitForChild("Daniel")
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DialogueRemote"):FireServer(unpack(args))
        end

        if fishCycle ~= previousFishCycle then
            StopLock()
        end
        
        if fishCycle > 5 then
            fishCycle = 1
        end

        local FinishPoint = fishFarmPositions[fishCycle]
        local distance = (getHrp().CFrame.Position - FinishPoint.Position).Magnitude

        autoFishTween = ts:Create(getHrp(), TweenInfo.new(distance/35,Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = FinishPoint})
        autoFishTween:Play()

        while autoFishTween and autoFishTween.PlaybackState == Enum.PlaybackState.Playing do
            if getCharacter():FindFirstChildWhichIsA("Humanoid") then
			    plr.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
			    task.wait(.1)
            end
        end

        if autoFishTween then
            if library.Flags["flag_Auto_Farm_Fish"] then
                print("TweenCompleted")

                StartLock()
                previousFishCycle = fishCycle
                --Throw
                local args = {
                    "FishingRod",
                    "Primary",
                    fishThrowPositions[fishCycle]
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UseTool"):FireServer(unpack(args))

                local timeout = 10
                local start = tick()

                while not fishing and tick() - start < timeout do
                    task.wait()
                end

                print("WAITED fishing: Waited ", tick() - start, ' seconds')

                if fishing then
                    print("TRUE 'fishing' is true")
                    local timeout2 = 35
                    local start2 = tick()

                    while not fishBite and tick() - start2 < timeout2 do
                        task.wait()
                    end

                    print("WAITED fishBite: Waited ", tick() - start2, ' seconds')

                    if fishBite then
                        print("TRUE 'if fishBite then' is true")
                        fishBite = false
                        fishing = false
                    else
                        print("ERROR 'if fishBite then' is false")
                        fishBite = false
                        fishing = false                
                        fishCycle+=1
                    end
                else
                    print("ERROR 'fishing' is false")
                    fishBite = false
                    fishing = false            
                    fishCycle+=1
                end
            end
        else
            task.wait(7)
        end  
    end
end
local function disableConnectionFish()
    if connectionFishfarm then connectionFishfarm:Disconnect() end
end

local function disableFarmFish()
    disableConnectionFish()
    NoClipDisableFunc()
    StopLock()
    disableFishChest()
	autoFishTween:Pause()
    autoFishTween = nil
end




local function notBehindWall(target)
    local ray = Ray.new(getCharacter().Head.Position, (target.Position - plr.Character.Head.Position).Unit * 300)
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


--HOOKFUNCTIONS---


------------------HOOK FUNCTION recoilFunc IS DETECTABLE


local LeafUiThemes = {
    '{"__Designer.Colors.topGradient":"D5D5D5","__Designer.Settings.ShowHideKey":"Enum.KeyCode.RightShift","__Designer.Colors.section":"000000","__Designer.Colors.hoveredOptionBottom":"FFFFFF","__Designer.Background.ImageAssetID":"rbxassetid://75515408979079","__Designer.Colors.selectedOption":"BAA0A0","__Designer.Colors.unselectedOption":"282828","__Designer.Files.WorkspaceFile":"Pepsis World","__Designer.Colors.unhoveredOptionTop":"323232","__Designer.Colors.outerBorder":"D5D5D5","__Designer.Background.ImageColor":"E0E0E0","__Designer.Colors.tabText":"BAA0A0","__Designer.Colors.elementBorder":"D4D4D4","__Designer.Colors.sectionBackground":"E4E4E4","__Designer.Colors.innerBorder":"D5D5D5","__Designer.Colors.background":"D5D5D5","__Designer.Colors.bottomGradient":"D5D5D5","__Designer.Background.ImageTransparency":0,"__Designer.Colors.main":"6E2E2E","__Designer.Colors.elementText":"532B2B","__Designer.Colors.hoveredOptionTop":"414141","__Designer.Colors.otherElementText":"A695A1","__Designer.Colors.unhoveredOptionBottom":"232323","__Designer.Background.UseBackgroundImage":true}',
    '{"__Designer.Colors.topGradient":"927B8C","__Designer.Settings.ShowHideKey":"Enum.KeyCode.RightShift","__Designer.Colors.section":"000000","__Designer.Colors.hoveredOptionBottom":"FFFFFF","__Designer.Background.ImageAssetID":"rbxassetid://71453977017896","__Designer.Colors.selectedOption":"BAA0A0","__Designer.Colors.unselectedOption":"282828","__Designer.Files.WorkspaceFile":"Pepsis World","__Designer.Colors.unhoveredOptionTop":"323232","__Designer.Colors.outerBorder":"927B8C","__Designer.Background.ImageColor":"FFFFFF","__Designer.Colors.tabText":"BAA0A0","__Designer.Colors.elementBorder":"000000","__Designer.Colors.sectionBackground":"927B8C","__Designer.Colors.innerBorder":"927B8C","__Designer.Colors.background":"927B8C","__Designer.Colors.bottomGradient":"464145","__Designer.Background.ImageTransparency":30,"__Designer.Colors.main":"C3D2C4","__Designer.Colors.elementText":"000000","__Designer.Colors.hoveredOptionTop":"414141","__Designer.Colors.otherElementText":"BAA0A0","__Designer.Colors.unhoveredOptionBottom":"232323","__Designer.Background.UseBackgroundImage":true}',
}
local HubName = {"Hidden Leaf Hub", "Hub Hidden In The Leaf", "The Leaf", "Leaf Hub",}
local HubSpace = {" ~ ", " | ", " / ", " \ ", " : ", " <> ", ":\\", ", "}
local HubQuote = {"One and Only", "Utterly Gutsy Ninja", "Dattebayo!"}
local LeafHub = library:CreateWindow({
	Name = HubName[math.random(1,4)] .. HubSpace[math.random(1,8)] .. HubQuote[math.random(1,3)],
	DefaultTheme = LeafUiThemes[math.random(1,2)],
	Themeable = {
		Credit = false
	},
})
local GeneralTab = LeafHub:CreateTab({
	Name = "General"
})
local GeneralSection = GeneralTab:CreateSection({
	Name = "General"
})
local ESPtoggle = GeneralSection:AddToggle({
	Name = "Toggle ESP",
	Flag = "flag_ESP",
	Callback = function(Value)
		if Value then
			enableESP()
		else
			disableESP()
		end
	end
})
local infHorseStaminaToggle = GeneralSection:AddToggle({
	Name = "Infinite Horse Stamina",
	Flag = "flag_Infinite_Horse_Stamina",
	Callback = function(Value)
		infHorseStamina()
	end
})
local recoilToggle = GeneralSection:AddToggle({
	Name = "No Recoil",
	Flag = "flag_no_recoil",
    Callback = function(Value)
        --game:GetService("Players").LocalPlayer.PlayerScripts.UIHandler.Disabled = true
        task.wait()
        if Value then
            local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
            local ModulesFolder = cloneref(ReplicatedStorage.Modules)
            local VFXmoduleRef = cloneref(ModulesFolder:WaitForChild("VFXModule"))
            local VFXmodule2 = require(VFXmoduleRef)


            local RecoilFunc
            RecoilFunc = hookfunction(VFXmodule2.RequestRecoilShake, function(self,...)
                -- VFXModule2.t2 = {
                -- startTime = 0,
                -- duration = 0,
                -- intensity = 0,
                -- isRecovering = false,
                -- recoveryStartTime = 0,
                -- recoveryDuration = 0,
                -- direction = Vector3.new(),
                -- recoilOffset = Vector3.new(),
                -- initialRecoveryOffset = Vector3.new()
                --}
                
                -- for i,v in pairs(debug.getupvalues(VFXmodule1.RequestRecoilShake)) do
                --     if type(v) == "table" then
                --         print(i)

                --         for k,val in pairs(v) do
                --             print(k, val)
                --             if tostring(k) == "startTime" then
                --                 print(k)
                --                 task.wait(10)
                --             end
                --         end
                --     end
                -- end

                

                -- VFXmodule1.t2.startTime = tick()
                -- VFXmodule1.t2.duration = 0
                -- VFXmodule1.t2.intensity = 0
                -- VFXmodule1.t2.direction = cameraPos
                -- VFXmodule1.t2.recoilOffset = Vector3.new()
                -- VFXmodule1.t2.isRecovering = false

                --RecoilFunc(self, ...)





                -- local Players = game:GetService("Players")
                -- local UserInputService = game:GetService("UserInputService")
                -- local TweenService = game:GetService("TweenService")
                -- local Debris = game:GetService("Debris")
                -- local ReplicatedStorage = game:GetService("ReplicatedStorage")
                -- local RunService = game:GetService("RunService")
                -- local CollectionService = game:GetService("CollectionService")
                -- local Wrapper = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Wrapper"):Clone()
                -- local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                -- local v1 = Wrapper(Remotes:WaitForChild("GunAction"))
                -- local v2 = Wrapper(Remotes:WaitForChild("UpdateGunState"))


                
                if library.Flags["flag_no_recoil"] then
                    print("Hooked1")
                    return RecoilFunc(self, ...)
                else
                    print("Hooked1")
                    return RecoilFunc(self, ...) --RecoilFunc(self,...)
                end
            end)
        end
        task.wait()
        --game:GetService("Players").LocalPlayer.PlayerScripts.UIHandler.Enabled = true
    end 
})
local farmFishToggle = GeneralSection:AddToggle({
	Name = "Auto Farm Fish",
	Flag = "flag_Auto_Farm_Fish",
	Callback = function(Value)
		if Value then
			autoFarmFish()
		else
			disableFarmFish()
		end
	end
})




plr.CharacterRemoving:Connect(function()
    StopLock()
    NoClipDisableFunc()
    disableFishChest()
    disableConnectionFish()
    if autoFishTween ~= nil then
        if autoFishTween.PlaybackState == Enum.PlaybackState.Playing then
            autoFishTween:Cancel()
        end
        autoFishTween:Destroy()
        autoFishTween = nil
    end
    task.wait(1)
end)