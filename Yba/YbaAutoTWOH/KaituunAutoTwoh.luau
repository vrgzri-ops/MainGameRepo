-- USER CONFIG --
getgenv().WEBHOOK_URL = getgenv().WEBHOOK_URL or "" -- Paste webhook if you need discord message everytime you get a new twoh stand or skin



-- RokakakaAllTwohWithoutSkins = false  --"false" means you will farm for both regular and skin version of TWOH, also you will stop farming if your slots (1,2,3) are all full with TWOH stands. 
-- RokakakaAllTwohWithoutSkins = true  --"true" means that you will eat rokakaka until you get skin version of TWOH.
getgenv().RokakakaAllTwohWithoutSkins = getgenv().RokakakaAllTwohWithoutSkins or false






-- MAIN --
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

--- VARIABLES ---
local Workspace = cloneref(game:GetService("Workspace"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = game:GetService("HttpService")
local tpservice = cloneref(game:GetService("TeleportService"))


local Players = cloneref(game:GetService("Players"))
local plr = Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local level = plr.PlayerStats:WaitForChild("Level")
--local Teleport = loadstring(game:HttpGet("https://raw.githubusercontent.com/rinqedd/pub_rblx/main/ServerHop", true))
local SBRserverCount


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

-- WEBHOOKS --
-- messages: plr.DisplayName.." obtained TWOH"   " all slots are full!"
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
                        ["name"] = "Current Slots:",
                        ["value"] = string.format(
                                    "Slot1: %s\nSlot2: %s\nSlot3: %s",
                                    plr.PlayerStats.Slot1.Value,
                                    plr.PlayerStats.Slot2.Value,
                                    plr.PlayerStats.Slot3.Value
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


-- Join different SBR servers
if isfile("AutoTwohSBR.json") then
    local ReadAutoTwohSBR = tonumber(readfile("AutoTwohSBR.json"))
    SBRserverCount = ((ReadAutoTwohSBR - 1) % 2) + 1
else
    writefile("AutoTwohSBR.json", "1")
    SBRserverCount = 1
end

-- === ITEM LIMITS ===
local MaxItemAmounts = {
    ["Gold Coin"] = 45, ["Rokakaka"] = 25, ["Pure Rokakaka"] = 10,
    ["Mysterious Arrow"] = 25, ["Diamond"] = 30, ["Ancient Scroll"] = 10,
    ["Caesar's Headband"] = 10, ["Stone Mask"] = 10,
    ["Rib Cage of The Saint's Corpse"] = 20, ["Quinton's Glove"] = 10,
    ["Zeppeli's Hat"] = 10, ["Lucky Arrow"] = 10, ["Clackers"] = 10,
    ["Steel Ball"] = 10, ["Dio's Diary"] = 10
}

local function HasMaxItem(Item)
    local count = 0
    for _, tool in pairs(plr.Backpack:GetChildren()) do if tool.Name == Item then count+=1 end end
    return MaxItemAmounts[Item] and count >= MaxItemAmounts[Item]
end

-- === SETTINGS ===
local AutoSell = true
local SellItems = getgenv().SellItems or {
    ["Gold Coin"] = true,
    ["Rokakaka"] = false,
    ["Pure Rokakaka"] = true,
    ["Mysterious Arrow"] = false,
    ["Diamond"] = true,
    ["Ancient Scroll"] = true,
    ["Caesar's Headband"] = true,
    ["Stone Mask"] = true,
    ["Rib Cage of The Saint's Corpse"] = false,
    ["Quinton's Glove"] = true,
    ["Zeppeli's Hat"] = true,
    ["Lucky Arrow"] = false,
    ["Clackers"] = true,
    ["Steel Ball"] = true,
    ["Dio's Diary"] = false
}

--- FUNCTIONS ---
local function GetCharacter()
    local char = plr.Character

    if char then
        return cloneref(char)
    end

    return cloneref(plr.CharacterAdded:Wait())
end

local function join1v1()
    -- select european region
    local Event = game:GetService("Players").LocalPlayer.Character.RemoteFunction
    local ServerTable = {"America", "Euw", "Russia"}
    local Result = Event:InvokeServer(
        "Toggle1v1sRegion",
        {
            Region = ServerTable[math.random(1,3)]
        }
    )

    task.wait(.5)

    -- join 1v1 server
    local Event = game:GetService("ReplicatedStorage").SBMRemote
    Event:FireServer(
        false
    )
end

local function startgame()
    repeat task.wait(0.11) until game:IsLoaded()

    -- === UI Cleanup ===
    task.wait(1)
    if not PlayerGui:FindFirstChild("HUD") then
        local HUD = ReplicatedStorage.Objects.HUD:Clone()
        HUD.Parent = PlayerGui
    end
    task.spawn(function()
        pcall(function() PlayerGui:WaitForChild("LoadingScreen1",5):Destroy() end)
        pcall(function() PlayerGui:WaitForChild("LoadingScreen",5):Destroy() end)
        pcall(function() Workspace.LoadingScreen.Song:Destroy() end)
    end)

    -- === Initialization ===
    repeat task.wait() until GetCharacter() and GetCharacter():WaitForChild("RemoteEvent",5)
    GetCharacter():WaitForChild("RemoteEvent",5):FireServer("PressedPlay")
    local Lighting = game:GetService("Lighting")
    if Lighting:WaitForChild("DepthOfField",5) then 
        Lighting:WaitForChild("DepthOfField",5).Enabled = false
    end
end

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

local function frameclick(path)

    local X = path.AbsolutePosition.X + (path.AbsoluteSize.X / 2)
    local Y = path.AbsolutePosition.Y + (path.AbsoluteSize.Y / 2)
    Instance.new("VirtualInputManager"):SendMouseButtonEvent(X-1, Y+58, 0,true,nil,1);task.wait()
    Instance.new("VirtualInputManager"):SendMouseButtonEvent(X-1, Y+58, 0,false,nil,1);task.wait()
end


-- Really strange bypass, i prefer not to use it, but if yba will fix magnitude bypass i'll switch to this method.
-- local function onCharacterAdded(char)
--     char:WaitForChild("HumanoidRootPart", 5)
--     char.Parent = nil
--     task.wait(0.01)
--     char.Parent = Workspace.Living

--     task.wait(3)
--     char.Parent = nil
--     task.wait(0.01)
--     char.Parent = Workspace.Living
-- end

-- plr.CharacterAdded:Connect(onCharacterAdded)

-- if plr.Character then
--     task.spawn(onCharacterAdded, plr.Character)
-- end

local function M1remote()
    local Event = GetCharacter():WaitForChild("RemoteEvent",5)
    if Event then
        Event:FireServer(
            "HoldAttack",
            {
                Bool = true,
                Type = "m1"
            }
        )
    end
    task.wait()
end

local function tpBehindNPC(npc)

    local NPChrp = npc:WaitForChild("HumanoidRootPart",5)
    if not NPChrp then return end

    local char = GetCharacter()
    if not char then return end
    if not char:WaitForChild("HumanoidRootPart", 5) then return end

    local forwardNPC = NPChrp.CFrame.LookVector

    local newPosition = npc.HumanoidRootPart.Position + (forwardNPC * -4)

    local newCFrame = CFrame.new(newPosition, newPosition + forwardNPC)

    char:PivotTo(newCFrame)
end

local function ToggleStand()
    print("TOGGLE STAND FUNCTION HAS BEEN CALLED")
    task.wait()
    local char = GetCharacter()
    if not char or char.Parent == nil then return end

    if not char:FindFirstChild("StandMorph") then

        local WaitTask = task.delay(40, function()
            print("WaitTask on ToggleStand, teleporting to another server")
            tpservice:Teleport(2809202155)
            return
        end)

        repeat
            char = GetCharacter()
            char:WaitForChild("RemoteFunction"):InvokeServer("ToggleStand", "Toggle")
            print("Summoning Stand")
            task.wait(.5)
        until char:FindFirstChild("StandMorph")

        print("Canceled WaitTask")
        task.cancel(WaitTask)

        task.wait(.1)
        return
    end
end

-- === UTILITY FUNCTIONS ===
local function TeleportTo(Position)
    local hrp = GetCharacter():WaitForChild("HumanoidRootPart",20)
    if hrp and typeof(Position) == "CFrame" then hrp.CFrame = Position end
end




---------------- IMPORTANT FUNCTIONS ----------------







local function autoPrestige3()
    task.spawn(function()
        while task.wait(1) do
            if plr.PlayerStats:WaitForChild("Level").Value == 50 then
                tpservice:Teleport(2809202155)
            end
        end
    end)

    task.wait(0.5)

    GetCharacter().Humanoid:UnequipTools()


    repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
    task.wait(3)

    -- ===== global for hop =====
    getgenv().repeatagain = 1
    getgenv().times = 0
    getgenv().timesvalue = 3 

    local player=0;local name=0;local pchar=0;local phum=0;local phumrt=0;local remevent=0;local remfunction=0
    local lvl=0;local stand=0;local prestige=0

    local function vupdate() 
        player=game:GetService("Players").LocalPlayer
        name=player.Name
        pchar=player.Character
        phum=pchar:WaitForChild("Humanoid")
        phumrt=pchar:WaitForChild("HumanoidRootPart")
        remevent=pchar.RemoteEvent
        remfunction=pchar.RemoteFunction
        prestige=player.PlayerStats.Prestige.Value
        stand=player.PlayerStats.Stand.Value
        lvl=player.PlayerStats.Level.Value
    end

    local function scall(func,st)
        task.spawn(function()
            pcall(vupdate)
        end)
        if st==1 then 
            task.spawn(function()
                local s,r=pcall(func)
                if not s then 
                    --local tableinfo = debug.getinfo(func)
                    --warn("Line defined: ", tableinfo.currentline)
                    warn(r)
                end 
            end)
        else 
            local s,r=pcall(func)
            if not s then 
                --local tableinfo = debug.getinfo(func)
                --warn("Line defined: ", tableinfo.currentline)
                warn(r)
            end
        end 
    end

    local hook = "ADD HOOK HERE"
    local zeppelilocked = false
    local allowedstands = {
        ["The World"] = true,
        ["Star Platinum"] = false,
        ["Star Platinum: The World"] = false,
        ["Crazy Diamond"] = false,
        ["King Crimson"] = false,
        ["King Crimson Requiem"] = false
    }
    local tdialogues = {
        ["Prestige"] = {"Prestige", "Dialogue2", "Option1"},
        ["Merchant"] = {"Merchant", "Dialogue5", "Option2"},
        ["Vampire"] = {"William Zeppeli", "Dialogue4", "Option1"},
        ["DiavoloDefeat"] = {"Storyline #14", "Dialogue7", "Option1"}
    }

    local function frameclick(path)
        local X = path.AbsolutePosition.X + (path.AbsoluteSize.X / 2)
        local Y = path.AbsolutePosition.Y + (path.AbsoluteSize.Y / 2)
        Instance.new("VirtualInputManager"):SendMouseButtonEvent(X-1, Y+58, 0,true,nil,1);task.wait()
        Instance.new("VirtualInputManager"):SendMouseButtonEvent(X-1, Y+58, 0,false,nil,1);task.wait()
    end

    local setup=0;local startgame=0;local webhook=0;local farmitem=0;local input=0
    local countitem=0;local useitem=0;local killnpc=0;local storydialogue=0;local enddialogue=0;local sellitem=0;local prestigecheck=0

    local tfuncs={
        setup = function()
            scall(function()
                game:GetService("CoreGui").DescendantAdded:Connect(function(child)
                    if child.Name == "ErrorPrompt" then
                        local GrabError = child:FindFirstChild("ErrorMessage",true)
                        repeat task.wait() until GrabError.Text ~= "Label"
                        local Reason = GrabError.Text
                        if Reason:match("kick") or Reason:match("You") or Reason:match("conn") or Reason:match("rejoin") then
                            if Teleport then Teleport() end
                        end
                    end
                end)
            end,1)
            scall(function()
                local itemHook;
                itemHook = hookfunction(getrawmetatable(phumrt.Position).__index, function(p,i)
                    if getcallingscript().Name == "ItemSpawn" and i:lower() == "magnitude" then
                        return 0
                    end
                    return itemHook(p,i)
                end)

                local Hook;
                Hook = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
                    local args = {...}
                    local namecallmethod =  getnamecallmethod()

                    if namecallmethod == "InvokeServer" then
                        if args[1] == "idklolbrah2de" then
                            return "  ___XP DE KEY"
                        end
                    end

                    return Hook(self, ...)
                end))
                print("done")
            end,1)
            scall(function()
                local function gg()
                    local games = game:GetDescendants()
                    game.DescendantAdded:Connect(function(parts)
                        if parts:IsA("BasePart") then
                            parts.CanCollide = false
                            parts.CanQuery = false
                            parts.CanTouch = false
                        end
                    end)
                    task.wait(1)	
                    for i,parts in games do
                        if parts:IsA("BasePart") then 
                            parts.CanCollide = false
                            parts.CanQuery = false
                            parts.CanTouch = false
                        end
                    end
                end
                scall(gg,1)
                while task.wait() do
                    scall(function()
                        if not phumrt:FindFirstChild("Greed") then
                            local bv = Instance.new("BodyVelocity", phumrt)
                            bv.Name = "Greed"
                            bv.velocity = Vector3.new(0,0,0) 
                            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
                            task.wait(1)
                        end
                        task.wait()
                    end)
                end
            end,1)
        end,
        startgame = function()
            if not player.PlayerGui:FindFirstChild("HUD") then
                local HUD = game:GetService("ReplicatedStorage").Objects.HUD:Clone()
                HUD.Parent = player.PlayerGui
            end

            remevent:FireServer("PressedPlay")

            if player.PlayerGui:FindFirstChild("LoadingScreen1") then
                player.PlayerGui:FindFirstChild("LoadingScreen1"):Destroy()
            end

            if player.PlayerGui:FindFirstChild("LoadingScreen") then
                player.PlayerGui:FindFirstChild("LoadingScreen"):Destroy()
            end
            task.wait(5)
        end,
        webhook = function(str)
            local httpservice = game.HttpService
            local tabledata = {
                Url = hook,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = httpservice:JSONEncode({
                    content = str,
                    username = name,
                    avatar_url = "https://cdn.discordapp.com/attachments/826341306506543144/1262618951452459079/image.png?ex=66974108&is=6695ef88&hm=5178ad30814f543a7a863ff1a000c11ed9abee6a6773b96b4bfefcd12663d771&",
                    attachments = {}
                })
            }
            --local response = request(tabledata)
        end,
        farmitem = function(name)
            local folder = workspace.Item_Spawns.Items
            for i,item in folder:GetChildren() do
                for i,object in item:GetChildren() do
                    if object:IsA("ProximityPrompt") then
                        if object.ObjectText == name then
                            if name == "Zeppeli's Hat" then
                                zeppelilocked = true
                            end
                            scall(function()
                                phumrt.CFrame = CFrame.new(object.Parent.PrimaryPart.Position)
                                input(Enum.KeyCode.E,1)
                            end)
                            task.wait(0.01)
                            break
                        end
                    end
                end
            end
        end,
        countitem = function(name)
            local amount = 0
            scall(function()
                for _,item in pairs(player.Backpack:GetChildren()) do
                    if item.Name == name then
                        amount += 1
                    end
                end
            end)
            return amount
        end,
        input = function(keycode,st)
            if keycode =="Mouse" then
                if st==1 then
                    Instance.new("VirtualInputManager"):SendMouseButtonEvent(350, 450, 0,true,nil,1);task.wait(1.25)
                    Instance.new("VirtualInputManager"):SendMouseButtonEvent(350, 450, 0,false,nil,1);task.wait(0.05)
                else
                    Instance.new("VirtualInputManager"):SendMouseButtonEvent(350, 450, 0,true,nil,1);task.wait(0.05)
                    Instance.new("VirtualInputManager"):SendMouseButtonEvent(350, 450, 0,false,nil,1);task.wait(0.05)
                    Instance.new("VirtualInputManager"):SendMouseButtonEvent(350, 450, 0,true,nil,1);task.wait(0.05)
                    Instance.new("VirtualInputManager"):SendMouseButtonEvent(350, 450, 0,false,nil,1);task.wait(0.05)
                end
            else
                scall(function()
                    if pchar:FindFirstChild("Head") then
                        workspace.CurrentCamera.CFrame = CFrame.lookAt(
                            Vector3.new(pchar.Head.Position.X,pchar.Head.Position.Y + 15,pchar.Head.Position.Z),
                            Vector3.new(pchar.Head.Position.X,pchar.Head.Position.Y,pchar.Head.Position.Z))
                    end
                end) 
                task.wait(0.125)
                if st==1 then
                    Instance.new("VirtualInputManager"):SendKeyEvent(true,keycode,false,nil);task.wait(1.25)
                    Instance.new("VirtualInputManager"):SendKeyEvent(false,keycode,false,nil);task.wait(0.05)
                else
                    Instance.new("VirtualInputManager"):SendKeyEvent(true,keycode,false,nil);task.wait(0.05)
                    Instance.new("VirtualInputManager"):SendKeyEvent(false,keycode,false,nil);task.wait(0.05)
                    Instance.new("VirtualInputManager"):SendKeyEvent(true,keycode,false,nil);task.wait(0.05)
                    Instance.new("VirtualInputManager"):SendKeyEvent(false,keycode,false,nil);task.wait(0.05)
                end
            end
        end,
        useitem = function(name)
            local item = player.Backpack:WaitForChild(name,2)
            if item then
                phum:EquipTool(item)
                remfunction:InvokeServer("LearnSkill",{["Skill"] = "Worthiness",["SkillTreeType"] = "Character"})
                item:Activate()
                task.wait(2)
                frameclick(player.PlayerGui:WaitForChild("DialogueGui",1).Frame.ClickContinue)
                frameclick(player.PlayerGui:WaitForChild("DialogueGui",1).Frame.ClickContinue)
                frameclick(player.PlayerGui:WaitForChild("DialogueGui",1).Frame.Options:WaitForChild("Option1",1).TextButton)
                frameclick(player.PlayerGui:WaitForChild("DialogueGui",1).Frame.ClickContinue)
                frameclick(player.PlayerGui:WaitForChild("DialogueGui",1).Frame.ClickContinue)
                task.wait(2)
                frameclick(player.PlayerGui:WaitForChild("DialogueGui",1).Frame.ClickContinue)
                frameclick(player.PlayerGui:WaitForChild("DialogueGui",1).Frame.ClickContinue)
            end	
        end,

        killnpc = function(npcName, playerDistance, dontDestroyOnKill, extraParameters)
            local NPC = workspace.Living:WaitForChild(npcName, 15)
            if not NPC then
                if Teleport then Teleport() end
                return
            end

            local beingTargeted = true
            local doneKilled = false
            local deadCheck

            local function setStandMorphPosition()
                pcall(function()
                    if player.PlayerStats.Stand.Value == "None" then
                        phumrt.CFrame = NPC.HumanoidRootPart.CFrame - Vector3.new(0, 5, 0)
                        return
                    end

                    if not pchar:FindFirstChild("SummonedStand") or not pchar.SummonedStand.Value or not pchar:FindFirstChild("StandMorph") then
                        remfunction:InvokeServer("ToggleStand", "Toggle")
                        return
                    end

                    pchar.StandMorph.PrimaryPart.CFrame = NPC.HumanoidRootPart.CFrame + NPC.HumanoidRootPart.CFrame.lookVector * -1.1
                    phumrt.CFrame = pchar.StandMorph.PrimaryPart.CFrame + pchar.StandMorph.PrimaryPart.CFrame.lookVector - Vector3.new(0, playerDistance or 15, 0)

                    if not pchar:FindFirstChild("FocusCam") then
                        local FocusCam = Instance.new("ObjectValue", pchar)
                        FocusCam.Name = "FocusCam"
                        FocusCam.Value = pchar.StandMorph.PrimaryPart
                    end

                    if pchar:FindFirstChild("FocusCam") and pchar.FocusCam.Value ~= pchar.StandMorph.PrimaryPart then
                        pchar.FocusCam.Value = pchar.StandMorph.PrimaryPart
                    end
                end)
            end

            local function HamonCharge()
                if not pchar:FindFirstChild("Hamon") then
                    return
                end

                if pchar.Hamon.Value <= 10 then
                    remfunction:InvokeServer("AssignSkillKey", {["Type"] = "Spec",["Key"] = "Enum.KeyCode.L",["Skill"] = "Hamon Breathing"})
                    remevent:FireServer("InputBegan", {["Input"] = Enum.KeyCode.L})
                end
            end

            local function BlockBreaker()
                if not NPC or NPC.Parent == nil then
                    return
                end

                if game:GetService("CollectionService"):HasTag(NPC, "Blocking") then
                    remevent:FireServer("InputBegan", {["Input"] = Enum.KeyCode.R})
                elseif NPC.Humanoid.Health <= 1 then
                    task.spawn(function()
                        task.wait(1)
                        if NPC then
                            remfunction:InvokeServer("Attack", "m1")
                        end
                    end)
                    task.wait()
                elseif NPC.Humanoid.Health >= 1 then
                    remfunction:InvokeServer("Attack", "m1")
                    task.wait()
                end
            end

            deadCheck = player.PlayerGui.HUD.Main.DropMoney.Money.ChildAdded:Connect(function(child)
                local number = tonumber(string.match(child.Name,"%d+"))
                if number and NPC then
                    doneKilled = true
                    deadCheck:Disconnect()
                    if not dontDestroyOnKill then
                        NPC:Destroy()
                    end
                end
            end)

            while beingTargeted do
                task.wait()
                if not NPC:FindFirstChild("HumanoidRootPart") then
                    deadCheck:Disconnect()
                    beingTargeted = false
                    break
                end

                if extraParameters then
                    extraParameters()
                end

                task.spawn(setStandMorphPosition)
                task.spawn(HamonCharge)
                task.spawn(BlockBreaker)

                -- Прокачка скиллов
                scall(function()
                    remfunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power V",["SkillTreeType"] = "Stand"})
                    remfunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power IV",["SkillTreeType"] = "Stand"})
                    remfunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power III",["SkillTreeType"] = "Stand"})
                    remfunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power II",["SkillTreeType"] = "Stand"})
                    remfunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power I",["SkillTreeType"] = "Stand"})
                    if player.PlayerStats.Spec.Value == "Hamon (William Zeppeli)" then
                        remfunction:InvokeServer("LearnSkill", {["Skill"] = "Hamon Punch III",["SkillTreeType"] = "Spec"})
                        remfunction:InvokeServer("LearnSkill", {["Skill"] = "Lung Capacity III", ["SkillTreeType"] = "Spec"})
                        remfunction:InvokeServer("LearnSkill", {["Skill"] = "Breathing Technique III",["SkillTreeType"] = "Spec"})
                    end
                end,1)
            end

            return doneKilled
        end,
        storydialogue = function()
            local Quest =
                {
                    ["Storyline"] = {"#1", "#1", "#1", "#2", "#3", "#3", "#3", "#4", "#5", "#6", "#7", "#8", "#9", "#10", "#11", "#11", "#12", "#14"},
                    ["Dialogue"] = {"Dialogue2", "Dialogue6", "Dialogue6", "Dialogue3", "Dialogue3", "Dialogue3", "Dialogue6", "Dialogue3", "Dialogue5", "Dialogue5", "Dialogue5", "Dialogue4", "Dialogue7", "Dialogue6", "Dialogue8", "Dialogue11", "Dialogue3", "Dialogue2"}
                }
            for counter = 1, 18, 1 do
                remevent:FireServer("EndDialogue", {["NPC"] = "Storyline".. " " .. Quest["Storyline"][counter],["Dialogue"] = Quest["Dialogue"][counter],["Option"] = "Option1"})
            end
        end,
        enddialogue = function(npc, dialogue, option)
            local dialogueToEnd = {
                ["NPC"] = npc,
                ["Dialogue"] = dialogue,
                ["Option"] = option
            }
            remevent:FireServer("EndDialogue", dialogueToEnd)
        end,
        sellitem = function(item)
            scall(farmitem(item))
            if countitem(item) > 0 then
                phum:EquipTool(player.Backpack:FindFirstChild(item))
                scall(enddialogue("Merchant", "Dialogue5", "Option2"))
            end
        end,
        prestigecheck = function()
            if (lvl == 35 and prestige == 0) or (lvl == 40 and prestige == 1) or (lvl == 45 and prestige == 2) then
                scall(enddialogue("Prestige", "Dialogue2", "Option1"))
                task.wait(6)
            elseif lvl == 50 then
                scall(webhook("I'm done!!!!!"))
                if Teleport then Teleport() end
            end
        end,
    }

    setup = tfuncs.setup
    startgame = tfuncs.startgame
    webhook = tfuncs.webhook
    farmitem = tfuncs.farmitem
    countitem = tfuncs.countitem
    input = tfuncs.input
    useitem = tfuncs.useitem
    killnpc = tfuncs.killnpc
    storydialogue = tfuncs.storydialogue
    enddialogue = tfuncs.enddialogue
    sellitem = tfuncs.sellitem
    prestigecheck = tfuncs.prestigecheck

    scall(function()end)

    if game.PlaceId == 2809202155 then
        --local button = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("LoadingScreen"):WaitForChild("Frames"):WaitForChild("Gamemodes"):WaitForChild("MainGame"):WaitForChild("Play")	
        --task.wait(1)
        --scall(startgame)
        print("starting")
        GetCharacter().Humanoid:UnequipTools()
        --scall(setup)

        -- ===== ВНЕШНИЙ ЦИКЛ С ЛОГИКОЙ ХОПОВ (КАК ВО ВТОРОМ СКРИПТЕ) =====
        task.spawn(function()
            while true do
                task.wait(400)
                getgenv().repeatagain = (getgenv().repeatagain or 1) + 1
            end
        end)

        task.spawn(function()
            if game.PlaceId == 2809202155 then
                while true do
                    task.wait(10)
                    setfpscap(25)
                end
            end
        end)

        while true do
            if getgenv().repeatagain > 0 then
                task.wait(1)
                pcall(function()
                    if player.PlayerStats.Prestige.Value < 2 then getgenv().timesvalue = 2 end
                    if player.PlayerStats.Level.Value > 25 then getgenv().timesvalue = 4 end
                    print("Resuming Script")
                    getgenv().repeatagain = getgenv().repeatagain - 1
                    getgenv().times = (getgenv().times or 0) + 1
                    task.wait(15)

                    -- Основная функция выполнения квестов (внутри pcall)
                    pcall(function()
                        while task.wait(1) do
                            scall(function()	
                                scall(storydialogue)
                                scall(prestigecheck)
                                local questPanel = player.PlayerGui.HUD.Main.Frames.Quest.Quests
                                if not questPanel:FindFirstChild("Take down 3 vampires") then
                                    scall(enddialogue("William Zeppeli", "Dialogue4", "Option1"))
                                end
                                player.QuestsRemoteFunction:InvokeServer({[1] = "ReturnData"})
                                if questPanel:FindFirstChild("Help Giorno by Defeating Security Guards") then
                                    while questPanel:FindFirstChild("Help Giorno by Defeating Security Guards") do
                                        task.wait(0.01)
                                        scall(killnpc("Security Guard", 15))
                                    end
                                elseif not allowedstands[stand] and lvl >= 3 then
                                    if pchar:FindFirstChild("StandMorph") then
                                        remfunction:InvokeServer("ToggleStand", "Toggle")
                                    end
                                    if countitem("Mysterious Arrow") < 1 or countitem("Rokakaka") < 1 then
                                        while countitem("Mysterious Arrow") < 9 or countitem("Rokakaka") < 9 do
                                            scall(farmitem("Mysterious Arrow"))
                                            scall(farmitem("Rokakaka"))
                                            if not player.Backpack:FindFirstChild("Zeppeli's Hat") and not pchar:FindFirstChild("Zeppeli's Hat") then
                                                scall(farmitem("Zeppeli's Hat"))
                                            end
                                            task.wait(1)
                                        end
                                    end
                                    if not allowedstands[stand] and stand ~= "None" then
                                        scall(useitem("Rokakaka"))
                                        task.wait(6)
                                    end
                                    scall(useitem("Mysterious Arrow"))
                                    task.wait(11)

                                    local startTime = tick()
                                    local standAcquired = false
                                    while tick() - startTime < 10 do
                                        vupdate()
                                        if allowedstands[stand] then
                                            standAcquired = true
                                            break
                                        end
                                        task.wait(0.5)
                                    end
                                    if standAcquired then
                                        if Teleport then Teleport() end
                                    end
                                elseif questPanel:FindFirstChild("Defeat Leaky Eye Luca") and allowedstands[stand] then
                                    while questPanel:FindFirstChild("Defeat Leaky Eye Luca") do
                                        scall(killnpc("Leaky Eye Luca", 15))
                                        task.wait(1)
                                    end
                                elseif questPanel:FindFirstChild("Defeat Bucciarati") then
                                    while questPanel:FindFirstChild("Defeat Bucciarati") do
                                        scall(killnpc("Bucciarati", 15))
                                        task.wait(1)
                                    end
                                elseif questPanel:FindFirstChild("Collect $5,000 To Cover For Popo's Real Fortune") then	
                                    if player.PlayerStats.Money.Value < 5000 then
                                        scall(sellitem("Mysterious Arrow"))
                                        scall(sellitem("Rokakaka"))
                                    end
                                elseif questPanel:FindFirstChild("Defeat Fugo And His Purple Haze") then
                                    while questPanel:FindFirstChild("Defeat Fugo And His Purple Haze") do
                                        scall(killnpc("Fugo", 15))
                                        task.wait(1)
                                    end
                                elseif questPanel:FindFirstChild("Defeat Ghiaccio") then
                                    while questPanel:FindFirstChild("Defeat Ghiaccio") do
                                        scall(killnpc("Ghiaccio", 15))
                                        task.wait(1)
                                    end
                                elseif questPanel:FindFirstChild("Defeat Pesci") then
                                    while questPanel:FindFirstChild("Defeat Pesci") do
                                        scall(killnpc("Pesci", 15))
                                        task.wait(1)
                                    end
                                elseif questPanel:FindFirstChild("Defeat Diavolo") then
                                    while questPanel:FindFirstChild("Defeat Diavolo") do
                                        scall(killnpc("Diavolo", 15))
                                        task.wait(1)
                                    end
                                    scall(enddialogue("Storyline #14", "Dialogue7", "Option1"))
                                    task.wait(3)
                                    pchar.Head:Destroy()
                                    phumrt.Position = Vector3.new(0,0,0)
                                    task.wait(15)
                                elseif questPanel:FindFirstChild("Take down 3 vampires") and (zeppelilocked == false or player.PlayerStats.Spec.Value ~= "None") then
                                    while questPanel:FindFirstChild("Take down 3 vampires") do
                                        scall(killnpc("Vampire", 15))
                                        task.wait(0.01)
                                    end
                                end
                                if player.PlayerStats.Spec.Value == "None" and player.PlayerStats.Level.Value >= 25 then
                                    if not player.Backpack:FindFirstChild("Zeppeli's Hat") and not pchar:FindFirstChild("Zeppeli's Hat") then
                                        scall(farmitem("Zeppeli's Hat"))
                                    end
                                    if (player.Backpack:FindFirstChild("Zeppeli's Hat") or pchar:FindFirstChild("Zeppeli's Hat")) and player.PlayerStats.Money.Value > 10000 then
                                        pchar.Head:Destroy()
                                        phumrt.Position = Vector3.new(0,0,0)
                                        task.wait(15)
                                        phum:EquipTool(player.Backpack:FindFirstChild("Zeppeli's Hat"))
                                        local count = 20
                                        while task.wait(1) do
                                            count-=1
                                            if count <= 0 then break end
                                            phum:EquipTool(player.Backpack:FindFirstChild("Zeppeli's Hat"))
                                            if player.PlayerStats.Spec.Value ~= "None" then
                                                zeppelilocked = false
                                                break
                                            end
                                            scall(function()
                                                pchar.RemoteEvent:FireServer("PromptTriggered", game.ReplicatedStorage.NewDialogue:FindFirstChild("Lisa Lisa"))
                                                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,8,0, true, nil, 1)
                                                task.wait(0.5)
                                                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,8,0, true, nil, 1)
                                                task.wait(0.5)
                                                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,8,0, true, nil, 1)
                                                task.wait(0.5)
                                                if player.PlayerGui:FindFirstChild("DialogueGui") then
                                                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,8,0, true, nil, 1)
                                                    task.wait(0.5)
                                                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,8,0, true, nil, 1)
                                                    task.wait(0.5)
                                                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,8,0, true, nil, 1)
                                                    task.wait(0.5)
                                                end
                                                frameclick(player.PlayerGui:FindFirstChild("DialogueGui").Frame.Options.Option1.TextButton)
                                                frameclick(player.PlayerGui:FindFirstChild("DialogueGui").Frame.ClickContinue)
                                                task.wait(0.5)
                                                frameclick(player.PlayerGui:FindFirstChild("DialogueGui").Frame.ClickContinue)
                                                task.wait(0.5)
                                                frameclick(player.PlayerGui:FindFirstChild("DialogueGui").Frame.ClickContinue)
                                                task.wait(0.5)
                                                if player.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1") then
                                                    frameclick(player.PlayerGui:FindFirstChild("DialogueGui").Frame.Options.Option1.TextButton)
                                                end
                                                frameclick(player.PlayerGui:FindFirstChild("DialogueGui").Frame.ClickContinue)
                                                task.wait(0.5)
                                                frameclick(player.PlayerGui:FindFirstChild("DialogueGui").Frame.ClickContinue)
                                                task.wait(0.5)
                                                frameclick(player.PlayerGui:FindFirstChild("DialogueGui").Frame.ClickContinue)
                                                task.wait(0.5)
                                                if player.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1") then
                                                    frameclick(player.PlayerGui:FindFirstChild("DialogueGui").Frame.Options.Option1.TextButton)
                                                end
                                            end)
                                        end
                                    end
                                end
                            end)
                        end
                    end)

                    if getgenv().times > getgenv().timesvalue then
                        if Teleport then Teleport() end
                    end
                end)
            end
            task.wait(12)
        end
    end
end



local function learnTheWorldSkills()
    betterPcall(function()
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Vitality X",["SkillTreeType"] = "Character"})
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Health Regen VI",["SkillTreeType"] = "Character"})
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Destructive Power IV",["SkillTreeType"] = "Stand"})
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Destructive Power III",["SkillTreeType"] = "Stand"})
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Destructive Power II",["SkillTreeType"] = "Stand"})
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Destructive Power I",["SkillTreeType"] = "Stand"})

        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Time Stop Mastery I",["SkillTreeType"] = "Stand"})
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Time Stop Mastery II",["SkillTreeType"] = "Stand"})
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Time Stop Mastery III",["SkillTreeType"] = "Stand"})

        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Road Sign Slam",["SkillTreeType"] = "Stand"})
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Kick Barrage",["SkillTreeType"] = "Stand"})
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Shinei",["SkillTreeType"] = "Stand"})
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Road Roller",["SkillTreeType"] = "Stand"})
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Bloodlust III",["SkillTreeType"] = "Stand"})
        GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Megalomania III",["SkillTreeType"] = "Stand"})

        if plr.PlayerStats.Spec.Value == "Hamon (William Zeppeli)" then
            GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Hamon Punch III",["SkillTreeType"] = "Spec"})
            GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Lung Capacity III", ["SkillTreeType"] = "Spec"})
            GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("LearnSkill", {["Skill"] = "Breathing Technique III",["SkillTreeType"] = "Spec"})
        end
    end,1)
end



local function killnpc(npcName, playerDistance, dontDestroyOnKill, extraParameters)
    local char = GetCharacter()
    if not char or char.Parent == nil then return end

    local NPC = Workspace.Living:WaitForChild(npcName, 10)

    if not NPC then
        --if Teleport then Teleport() end
        return
    end

    if not NPC:FindFirstChild("HumanoidRootPart") then
        return
    end

    local beingTargeted = true

    local function setStandMorphPosition()
        if not char or char.Parent == nil then return end
        if beingTargeted then
            if NPC then
                if plr.PlayerStats.Stand.Value == "None" then
                    if NPC:FindFirstChild("HumanoidRootPart") then
                        GetCharacter():WaitForChild("HumanoidRootPart").CFrame = NPC:FindFirstChild("HumanoidRootPart").CFrame - Vector3.new(0, 5, 0)
                        return
                    end
                end

                if not char:FindFirstChild("SummonedStand") or not char.SummonedStand.Value or not char:FindFirstChild("StandMorph") then
                    --char:WaitForChild("RemoteFunction"):InvokeServer("ToggleStand", "Toggle")
                    print("NPC tp")
                    --char:WaitForChild("HumanoidRootPart").CFrame = NPC.PrimaryPart.CFrame + NPC.PrimaryPart.CFrame.lookVector - Vector3.new(15, 15, 0)
                    return
                end

                if NPC then
                    if NPC:FindFirstChild("HumanoidRootPart") then

                        local npcHRP = NPC:FindFirstChild("HumanoidRootPart")
                        local stand = char:FindFirstChild("StandMorph")

                        if npcHRP and stand and stand.PrimaryPart then
                            local pos = npcHRP.Position
                            local velocity = npcHRP.AssemblyLinearVelocity
                            local ping = plr:GetNetworkPing()

                            local predictedPos = pos + ((velocity * (ping * math.random(1,3))) / math.random(1,2))

                            local predictedCFrame = CFrame.lookAt(
                                predictedPos,
                                predictedPos + npcHRP.CFrame.LookVector
                            )

                            stand:PivotTo(predictedCFrame)
                        end

                        if not char:FindFirstChild("SummonedStand") or not char.SummonedStand.Value or not char:FindFirstChild("StandMorph") then
                            --print("NPC tp")
                            char:WaitForChild("HumanoidRootPart").CFrame = NPC.PrimaryPart.CFrame + NPC.PrimaryPart.CFrame.lookVector - Vector3.new(15, 15, 0)
                        else
                            --print("StandMorph tp")
                            char:WaitForChild("HumanoidRootPart").CFrame = char.StandMorph.PrimaryPart.CFrame + char.StandMorph.PrimaryPart.CFrame.lookVector - Vector3.new(15, playerDistance or 15, 0)
                        end



                        if not char:FindFirstChild("FocusCam") then
                            local FocusCam = Instance.new("ObjectValue", char)
                            FocusCam.Name = "FocusCam"
                            FocusCam.Value = char.StandMorph.PrimaryPart
                        end

                        if char:FindFirstChild("FocusCam") and char.FocusCam.Value ~= char.StandMorph.PrimaryPart then
                            char.FocusCam.Value = char.StandMorph.PrimaryPart
                        end
                    else
                        beingTargeted = false
                    end
                else
                    beingTargeted = false
                end
            end
        end
    end

    local function BlockBreaker()
        if not char or char.Parent == nil then return end

        if beingTargeted then
            if not NPC or NPC.Parent == nil then
                return
            end

            if not char:FindFirstChild("SummonedStand") or not char.SummonedStand.Value or not char:FindFirstChild("StandMorph") then
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

    task.spawn(setStandMorphPosition)

    NPC = Workspace.Living:FindFirstChild(npcName)

    
    local TaskWait = task.delay(80, function()
        beingTargeted = false
        print("KillNPC timeout returned")
        return true
    end)

    local BlockBreakerTask = task.defer(function()
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
                if not char:FindFirstChild("StandMorph") then
                    betterPcall(ToggleStand)
                end

                task.spawn(setStandMorphPosition)

                --BlockBreaker()
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








local function setup()
    betterPcall(function()
        game:GetService("CoreGui").DescendantAdded:Connect(function(child)
            if child.Name == "ErrorPrompt" then
                local GrabError = child:FindFirstChild("ErrorMessage",true)
                repeat task.wait() until GrabError.Text ~= "Label"
                local Reason = GrabError.Text
                if Reason:match("kick") or Reason:match("You") or Reason:match("conn") or Reason:match("rejoin") then
                    if Teleport then Teleport() end
                end
            end
        end)
    end,1)
    betterPcall(function()
        local itemHook;
        itemHook = hookfunction(getrawmetatable(GetCharacter().HumanoidRootPart.Position).__index, function(p,i)
            if getcallingscript().Name == "ItemSpawn" and i:lower() == "magnitude" then
                return 0
            end
            return itemHook(p,i)
        end)

        local Hook;
        Hook = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
            local args = {...}
            local namecallmethod = getnamecallmethod()

            if namecallmethod == "InvokeServer" then
                if args[1] == "idklolbrah2de" then
                    return "  ___XP DE KEY"
                end
            end

            return Hook(self, ...)
        end))
    end,1)
    betterPcall(function()
        while task.wait() do
            betterPcall(function()
                if GetCharacter():WaitForChild("HumanoidRootPart",5) then
                    if not GetCharacter():WaitForChild("HumanoidRootPart",5):FindFirstChild("Greed") then
                        local bv = Instance.new("BodyVelocity", GetCharacter().HumanoidRootPart)
                        bv.Name = "Greed"
                        bv.velocity = Vector3.new(0,0,0) 
                        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
                        task.wait(1)
                    end
                    task.wait()
                end
                task.wait()
            end)
        end
    end,1)
end

local function AutoUnlockWorthiness()
    betterPcall(function()
        local Event = GetCharacter():WaitForChild("RemoteFunction",5)
        if Event then
            task.spawn(function()
                Event:InvokeServer(
                    "LearnSkill",
                    {
                        Skill = "Worthiness",
                        SkillTreeType = "Character",
                    }
                )            
            end)
        end
    end, 1)

    task.wait(.5)

    local worthiness = plr.CharacterSkillTree.Worthiness.Value

    while level.Value < 3 or not worthiness do
        worthiness = plr.CharacterSkillTree.Worthiness.Value
        
        
        betterPcall(function()
            local Event = GetCharacter():WaitForChild("RemoteEvent",5)
            if Event then
                Event:FireServer(
                    "EndDialogue",
                    {
                        Option = "Option1",
                        Dialogue = "Dialogue2",
                        NPC = "Storyline #1"
                    }
                )
            end
        end, 1)

        betterPcall(function()
            local Event = GetCharacter():WaitForChild("RemoteFunction",5)
            if Event then
                task.spawn(function()
                    Event:InvokeServer(
                        "LearnSkill",
                        {
                            Skill = "Worthiness",
                            SkillTreeType = "Character",
                        }
                    )            
                end)
            end
        end, 1)
        
        task.wait(.01)
        
        local PoliceNPC = false
        for i, v in pairs(Workspace.Living:GetChildren()) do
            if v.Name == "Security Guard" then
                if v.Humanoid then
                    if v.Humanoid.Health > 0.2 then
                        print("Ayo")
                        PoliceNPC = v
                        break
                    end
                end
            end
        end

        if PoliceNPC and PoliceNPC.Humanoid.Health > 0.2  then
            while task.wait() do
                if PoliceNPC:FindFirstChild("Humanoid") then
                    if PoliceNPC.Humanoid.Health > 0.2 then
                        task.wait(.01)
                        tpBehindNPC(PoliceNPC)
                        M1remote()
                    else
                        tpBehindNPC(PoliceNPC)
                        M1remote()
                        task.wait(.1)
                        break
                    end
                else
                    M1remote()
                    task.wait(.1)
                    break
                end
            end
        end
    end
end

local function farmItems()
    task.wait(5)

    -- === AFK TIMER ===
    local AFK_TIMEOUT = 180
    local lastActionTime = tick()
    local function UpdateActivity() lastActionTime = tick() end
    task.spawn(function()
        while true do
            task.wait(10)
            if tick() - lastActionTime > AFK_TIMEOUT then
                task.wait(1)
                Teleport()
                UpdateActivity()
            end
        end
    end)

    -- === ITEMS FARM LOOP ===
    repeat
        task.wait()

        local snapshot = {}

        for Model, ItemInfo in pairs(getgenv().SpawnedItems) do
            snapshot[Model] = ItemInfo
        end

        for Model, ItemInfo in pairs(snapshot) do
            local hrp = GetCharacter():WaitForChild("HumanoidRootPart", 20)
            if not hrp then break end

            if not Model or not Model.Parent then
                getgenv().SpawnedItems[Model] = nil

            elseif HasMaxItem(ItemInfo.Name) then
                getgenv().SpawnedItems[Model] = nil

            else
                getgenv().SpawnedItems[Model] = nil

                TeleportTo(CFrame.new(ItemInfo.Position))
                task.wait(0.5)

                if ItemInfo.ProximityPrompt and ItemInfo.ProximityPrompt.Parent then
                    fireproximityprompt(ItemInfo.ProximityPrompt)
                end

                UpdateActivity()
                task.wait(0.5)
                UpdateActivity()
            end
        end

        task.wait(3)

    until next(getgenv().SpawnedItems) == nil

    if AutoSell then
        local sold = {}
        for Item, Sell in pairs(SellItems) do
            if Sell and plr.Backpack:FindFirstChild(Item) then
                local humanoid = GetCharacter():WaitForChild("Humanoid",20)
                if humanoid then
                    humanoid:EquipTool(plr.Backpack[Item])
                    GetCharacter():WaitForChild("RemoteEvent",20):FireServer("EndDialogue", {NPC="Merchant", Dialogue="Dialogue5", Option="Option2"})
                    sold[Item] = (sold[Item] or 0)+1
                    UpdateActivity()
                    task.wait(0.1)
                end
            end
        end
    end

    task.wait(2)
    Teleport()
end

local function useitem(name)
    --betterPcall(function()
        local item = plr.Backpack:WaitForChild(name,2)
        
        if item then
            repeat
                print("Repeating")
                if item then 
                    if GetCharacter():WaitForChild("Humanoid",20) then
                        GetCharacter():WaitForChild("Humanoid",20):EquipTool(item)
                        task.wait(.1)
                        item:Activate()
                    end
                else
                    
                end
            until plr.PlayerGui:FindFirstChild("DialogueGui")

            task.wait(1)


            repeat
                print("Repeating 2")
                if plr.PlayerGui:FindFirstChild("DialogueGui") then
                    betterPcall(function()
                        frameclick(plr.PlayerGui:WaitForChild("DialogueGui",1).Frame.ClickContinue)
                        frameclick(plr.PlayerGui:WaitForChild("DialogueGui",1).Frame.ClickContinue)

                        frameclick(plr.PlayerGui:WaitForChild("DialogueGui",1).Frame.Options:WaitForChild("Option1",1).TextButton)
                        frameclick(plr.PlayerGui:WaitForChild("DialogueGui",1).Frame.ClickContinue)
                        frameclick(plr.PlayerGui:WaitForChild("DialogueGui",1).Frame.ClickContinue)
                    end)

                    task.wait(1)
                    betterPcall(function()
                        frameclick(plr.PlayerGui:WaitForChild("DialogueGui",1).Frame.ClickContinue)
                        frameclick(plr.PlayerGui:WaitForChild("DialogueGui",1).Frame.ClickContinue)
                    end)
                else
                    return  
                end
                task.wait()
            until not plr.PlayerGui:FindFirstChild("DialogueGui")
        end	
    --end)
end




-- INIT --
if game.PlaceId == 5290796989 then
    task.wait(300)
    --if waiting 300 secs for 1v1 match then rejoin
    tpservice:Teleport(2809202155)
elseif game.PlaceId == 5290908008 then
    -- Auto 1v1
    while Workspace:FindFirstChild("Message") do
        task.wait()
    end

    task.wait(1)
    local pvpOpponent
    local pvpPlayer

    for i, v in pairs(Workspace.Living:GetChildren()) do
        if v.Name ~= plr.Name then
            pvpOpponent = v
            pvpPlayer = game:GetService("Players"):GetPlayerFromCharacter(v)
        end
    end

    print("pvpOpponent: ",pvpOpponent)

    task.spawn(function()
        task.wait(120); tpservice:Teleport(2809202155)
    end)

    task.spawn(function()
        while task.wait(.1) do 
            if #game:GetService("Players"):GetPlayers() < 2 then    
                task.wait(5)
                tpservice:Teleport(2809202155)
            end

            if pvpPlayer:FindFirstChild("Lives") then
                if pvpPlayer:FindFirstChild("Lives").Value == 0 then
                    task.wait(5)
                    tpservice:Teleport(2809202155)
                end
            end
        end
    end)

    while #game:GetService("Players"):GetPlayers() == 2 do
        print("Starting killing player in 1v1 match")
        killnpc(tostring(pvpOpponent.Name),15)
        print("Killed player in 1v1 match")
        task.wait(5)
    end
    
    task.wait(15)

    print("1v1 match is completed, teleporting to main game")
    tpservice:Teleport(2809202155)

elseif game.PlaceId ~= 2809202155 and game.PlaceId ~= 5290908008 then
    -- Auto SBR --
    task.spawn(function()
        while true do 
            --if waiting 120 secs for SBR match then rejoin
            task.wait(120)

            if #Workspace:WaitForChild("Living",5):GetChildren() < 6 then

                if SBRserverCount then
                    SBRserverCount += 1
                    SBRserverCount = (((SBRserverCount - 1) % 2) + 1)
                else
                    SBRserverCount = 1
                end

                writefile("AutoTwohSBR.json", tostring(SBRserverCount))
            
                tpservice:Teleport(2809202155)
            end
        end
    end)

    

    if workspace:WaitForChild("Barriers",15) then
        startgame()
        setup()

        TeleportTo(CFrame.new(-1837.40588, 212.120865, 780.186951, -0.983434081, 1.70256254e-08, 0.18126601, 1.62632041e-08, 1, -5.69239234e-09, -0.18126601, -2.65012678e-09, -0.983434081))

        --raknet.add_send_hook(rakhook)

        repeat task.wait() until plr:WaitForChild("Backpack",5):FindFirstChild("Revolver")

        task.wait(1)

        -- wait 50 secs to give players a fresh start, therefore lowering the chances of players leaving before killing them
        task.wait(50)

        local EconomySafeTask = task.spawn(function()
            --if we killed almost everyone, then spare other 6 people so they can finish the race and presumably join in the next match
            while task.wait(1) do
                if #Workspace:WaitForChild("Living",5):GetChildren() < 8 then
                    tpservice:Teleport(2809202155)
                end

                if not GetCharacter():FindFirstChild("HumanoidRootPart") then
                    tpservice:Teleport(2809202155)
                end

                if Workspace:FindFirstChild("WinnerHint") then
                    tpservice:Teleport(2809202155)
                end
            end
        end)


        --task.spawn(function()
            --while task.wait(1) do 
                -- if plr:FindFirstChild("PlayerGui") then
                --     if plr.PlayerGui:FindFirstChild("SBR_Blessings") then
                --         if plr.PlayerGui.SBR_Blessings:FindFirstChild("Frames") then
                --             if plr.PlayerGui.SBR_Blessings.Frames:FindFirstChild("Blessings") then
                --                 if plr.PlayerGui.SBR_Blessings.Frames.Blessings:FindFirstChild("Blessing_1") then
                --                     if plr.PlayerGui.SBR_Blessings.Frames.Blessings.Blessing_1:FindFirstChild("Frame") then

            --end
        --end)

        task.spawn(function()
            while task.wait(1) do
                betterPcall(function() 
                    if plr:FindFirstChild("PlayerGui") then
                        if plr.PlayerGui:FindFirstChild("SBR_Blessings") then
                            if plr.PlayerGui.SBR_Blessings:FindFirstChild("Frames") then
                                if plr.PlayerGui.SBR_Blessings.Frames:FindFirstChild("Blessings") then
                                    if plr.PlayerGui.SBR_Blessings.Frames.Blessings:FindFirstChild("Blessing_1") then
                                        if plr.PlayerGui.SBR_Blessings.Frames.Blessings.Blessing_1:FindFirstChild("Frame") then
                                            print("Clicking on SBR Blessing")
                                            frameclick(plr.PlayerGui.SBR_Blessings.Frames.Blessings.Blessing_1.Frame) 
                                        end
                                    end
                                end
                            end
                        end
                    end
                end, 1)
            end
        end)



        while #Workspace:WaitForChild("Living",5):GetChildren() > 6 do
            task.wait(.1)
            for i,v in pairs(Workspace:WaitForChild("Living",5):GetChildren()) do
                if v.Name ~= plr.Name then
                    if Workspace.Living:FindFirstChild(tostring(v)) then
                        print("Starting killing: ", v.Name)
                        killnpc(v.Name, 15)
                        print("Killed: ", v.Name)
                        task.wait(.5)
                    else
                        print("Havent found this player, moving on to next")
                    end
                end
            end
        end

        -- complete 50 sinners quest, but dont finish SBR race to save economy and player count

        -- while Workspace:WaitForChild("Barriers",5):FindFirstChild("4") do
        --     for i,v in pairs(Workspace:WaitForChild("Barriers",5):GetChildren()) do
        --         TeleportTo(v.CFrame)
        --     end
        --     task.wait()
        -- end

        -- while not Workspace:FindFirstChild("WinnerHint") do
        --     TeleportTo(Workspace.Finish.CFrame)
        --     task.wait(.1)
        --     TeleportTo(CFrame.new(-1302.77991, 353.842743, 9272.06348, 1, 0, 0, 0, 1, 0, 0, 0, 1))
        -- end

        --repeat TeleportTo(CFrame.new(-1338.35339, 333.843231, 9615.93848, 0, 0, 1, 0, 1, -0, -1, 0, 0))
        --until workspace:FindFirstChild("WinnerHint")
    end
end



-- === Item Tracking ===
local ItemSpawnFolder = Workspace:WaitForChild("Item_Spawns"):WaitForChild("Items")
getgenv().SpawnedItems = {}
local function GetItemInfo(Model)
    if Model and Model:IsA("Model") and Model.Parent and Model.Parent.Name == "Items" then
        local prompt
        for _, obj in pairs(Model:GetChildren()) do
            if obj:IsA("ProximityPrompt") and obj.MaxActivationDistance == 8 then prompt = obj end
        end
        if prompt then return {Name = prompt.ObjectText, ProximityPrompt = prompt, Position = Model.PrimaryPart.Position} end
    end
end
for _, model in pairs(ItemSpawnFolder:GetChildren()) do
    local info = GetItemInfo(model)
    if info then getgenv().SpawnedItems[model] = info end
end
ItemSpawnFolder.ChildAdded:Connect(function(Model)
    task.wait(0.5)
    local info = GetItemInfo(Model)
    if info then getgenv().SpawnedItems[Model] = info end
end)
ItemSpawnFolder.ChildRemoved:Connect(function(Model) getgenv().SpawnedItems[Model] = nil end)


--- FARM ARROWS, ROKAS AND THE WORLD TILL ALL FINISHED ---
local function FarmUntilTheWorld()
    if plr.PlayerStats.Stand.Value ~= "The World" then
        while plr.PlayerStats.Stand.Value ~= "The World" do
            task.wait()

            if Players.LocalPlayer:WaitForChild("Backpack", 20):WaitForChild("Mysterious Arrow",2) and Players.LocalPlayer:WaitForChild("Backpack", 20):WaitForChild("Rokakaka",2) then
                if plr.PlayerStats.Stand.Value == "None" then
                    if not plr.CharacterSkillTree.Worthiness.Value then
                        task.spawn(function()
                            local Event = GetCharacter():WaitForChild("RemoteFunction",5)
                            if Event then
                                task.spawn(function()
                                    Event:InvokeServer(
                                        "LearnSkill",
                                        {
                                            Skill = "Worthiness",
                                            SkillTreeType = "Character",
                                        }
                                    )            
                                end)
                            end    
                        end)
                    end
                    task.wait(.1)
                    if plr.CharacterSkillTree.Worthiness.Value then
                        useitem("Mysterious Arrow")
                    else
                        tpservice:Teleport(2809202155)
                    end

                elseif plr.PlayerStats.Stand.Value ~= "The World" then
                    useitem("Rokakaka")
                    --GetCharacter()
                    --print("Waited for character")
                end
            else
                farmItems()
            end
        end
    end
end



------ MAIN -------
startgame()
setup()

--- AUTO UNLOCK WORTHINESS ---
if not plr.CharacterSkillTree.Worthiness.Value then
    task.spawn(function()
        local Event = GetCharacter():WaitForChild("RemoteFunction",5)
        if Event then
            task.spawn(function()
                Event:InvokeServer(
                    "LearnSkill",
                    {
                        Skill = "Worthiness",
                        SkillTreeType = "Character",
                    }
                )            
            end)
        end    
    end)

    task.wait(1)
    
    if not plr.CharacterSkillTree.Worthiness.Value then
        AutoUnlockWorthiness()
    end
end































if plr.PlayerStats:WaitForChild("Stand",5).Value == "The World Over Heaven" then
    ToggleStand()
    local char = GetCharacter()
    local Event = plr.Character.RemoteEvent

    if getgenv().RokakakaAllTwohWithoutSkins == true then
        if char:WaitForChild("StandMorph",5) then
            if char.StandMorph:WaitForChild("StandSkin",5) then
                if char.StandMorph.StandSkin.Value == "" then
                    repeat
                        useitem("Rokakaka")
                    until plr.PlayerStats:WaitForChild("Stand",5).Value == "None"

                    FarmUntilTheWorld()
                else
                    local counter = 0
                    repeat
                        if counter == 4 then SendWebhook(plr.DisplayName.." All slots are full with SKIN TWOH."); task.wait(99999999); break end
                        task.wait(1)
                        local CurrentSlot = 1

                        local NewSlot
                        repeat
                            NewSlot = math.random(1, 3)
                        until NewSlot ~= CurrentSlot


                        Event:FireServer(
                            "SwapStand",
                            "Slot" .. NewSlot
                        ) 
                        tpservice:Teleport(2809202155) 

                        counter += 1
                        
                    until plr:WaitForChild("PlayerStats",20):WaitForChild("Stand", 20).Value ~= "The World Over Heaven" and char.StandMorph.StandSkin.Value == ""
                end
            end
        end
    else
        if plr.PlayerStats.Slot1.Value ~= "The World Over Heaven" then
            Event:FireServer(
                "SwapStand",
                "Slot1"
            ) 
            tpservice:Teleport(2809202155) 
        elseif plr.PlayerStats.Slot2.Value ~= "The World Over Heaven" then
            Event:FireServer(
                "SwapStand",
                "Slot2"
            ) 
            tpservice:Teleport(2809202155) 
        elseif plr.PlayerStats.Slot3.Value ~= "The World Over Heaven" then
            Event:FireServer(
                "SwapStand",
                "Slot3"
            )
            tpservice:Teleport(2809202155) 
        else
            SendWebhook(plr.DisplayName.." All slots are full with TWOH.")
        end
    end
else
    FarmUntilTheWorld()
end































GetCharacter().Humanoid:UnequipTools()

-- AUTO PRESTIGE III ---
if plr.PlayerStats:WaitForChild("Level").Value ~= 50 then
    GetCharacter().Humanoid:UnequipTools()
    autoPrestige3()
end

learnTheWorldSkills()

--- AUTO USE DIARY ---
if plr.PlayerStats:WaitForChild("Level").Value == 50 then
    if plr.PlayerStats.Stand.Value == "The World" then
        if plr.PlayerStats.Quest.Value == "Win against a sinner (Player) 25 times in the \"1v1's Gamemode\" (Dio's DIARY)" 
        or plr.PlayerStats.Quest.Value == "Kill 50 sinners (Players) in the \"Metal Ball Run\" (Gamemode) (Dio's DIARY)" 
        or plr.PlayerStats.Quest.Value == "Obtain \"Dio's BONE\" (Dio's DIARY)"
        or plr.PlayerStats.Quest.Value == "Talk to Jotaro once you obtain the \"Saint's Corpse Parts\"" then
            print("Quest already given, resuming TWOH farm.")
        else
            repeat
                task.wait()
                print("Quest is not given, reading diary")
                if plr:WaitForChild("Backpack",5):FindFirstChild("Dio's Diary") then
                    useitem("Dio's Diary")
                else
                    local Event = game:GetService("Players").LocalPlayer.Character.RemoteEvent
                    Event:FireServer(
                        "PurchaseShopItem",
                        {
                            ItemName = "1x DIO's Diary"
                        }
                    )
                end
            until plr.PlayerStats.Quest.Value == "Win against a sinner (Player) 25 times in the \"1v1's Gamemode\" (Dio's DIARY)"
            or plr.PlayerStats.Quest.Value == "Kill 50 sinners (Players) in the \"Metal Ball Run\" (Gamemode) (Dio's DIARY)"
            or plr.PlayerStats.Quest.Value == "Obtain \"Dio's BONE\" (Dio's DIARY)"
        end
    else
        print("Auto Use Diary didn't work, rejoining")
        tpservice:Teleport(2809202155)
    end
else
    print("Auto Use Diary didn't work, rejoining")
    tpservice:Teleport(2809202155)
end

local function joinSBR()
    local Event = GetCharacter():WaitForChild("RemoteEvent",5)
    Event:FireServer(
        "EndDialogue",
        {
            Option = "Option1",
            Dialogue = "Dialogue2",
            NPC = "Metal Ball Run"
        }
    )

    task.wait(2)

    --local SBRserver = plr:WaitForChild("PlayerGui",5):WaitForChild("Metal Ball Run Servers",5):WaitForChild("Frame",5):WaitForChild("ScrollingFrame",5)[2].Text
    local SBRserverLocal = plr:WaitForChild("PlayerGui",10):WaitForChild("Metal Ball Run Servers",10):WaitForChild("Frame",10):WaitForChild("ScrollingFrame",10):GetChildren()[SBRserverCount].Text
    print("Joining ", SBRserverCount, "SBR server.", "\nName: ", SBRserverLocal)

    local Event = GetCharacter():WaitForChild("RemoteEvent",5)
    Event:FireServer(
        "JoinMetalBallRun",
        {
            Competitive = false,
            Code = SBRserverLocal
        }  
    )
end

--- Auto 25 pvp kills ---
if plr.PlayerStats.Quest.Value == "Win against a sinner (Player) 25 times in the \"1v1's Gamemode\" (Dio's DIARY)" then
    if plr.PlayerStats.QuestProgress.Value == 25 then
        useitem("Dio's Diary")
    else
        join1v1()
    end
end

if plr.PlayerStats.Quest.Value == "Kill 50 sinners (Players) in the \"Metal Ball Run\" (Gamemode) (Dio's DIARY)" then
    if plr.PlayerStats.QuestProgress.Value == 50 then
        useitem("Dio's Diary")
    else
        joinSBR()
    end
end

useitem("Dio's Diary")

if plr.PlayerStats.Quest.Value == "Win against a sinner (Player) 25 times in the \"1v1's Gamemode\" (Dio's DIARY)" then
    if plr.PlayerStats.QuestProgress.Value == 25 then
        useitem("Dio's Diary")
    else
        join1v1()
    end
end

if plr.PlayerStats.Quest.Value == "Kill 50 sinners (Players) in the \"Metal Ball Run\" (Gamemode) (Dio's DIARY)" then
    if plr.PlayerStats.QuestProgress.Value == 50 then
        useitem("Dio's Diary")
    else
        joinSBR()
    end
end




GetCharacter().Humanoid:UnequipTools()

-- Auto farm all saint's corpse parts
if not plr.Backpack:FindFirstChild("Rib Cage of The Saint's Corpse") then
    if plr.PlayerStats.Money.Value > 3500 then
        local Event = GetCharacter().RemoteEvent
        Event:FireServer("PurchaseShopItem",{ItemName = "1x Rib Cage of the Saint's Corpse"})
    else
        farmItems()
    end
end

if not plr.Backpack:FindFirstChild("Left Arm of The Saint's Corpse") then
    print(plr.PlayerStats.Money.Value)
    if plr.PlayerStats.Money.Value > 15000 then
        local Event = GetCharacter().RemoteEvent
        Event:FireServer("PurchaseShopItem",{ItemName = "1x Left Arm of the Saint's Corpse"})
    else
        farmItems()
    end
end

if not plr.Backpack:FindFirstChild("Heart of The Saint's Corpse") then
    if plr.PlayerStats.Money.Value > 45000 then
        local Event = GetCharacter().RemoteEvent
        Event:FireServer("PurchaseShopItem",{ItemName = "1x Heart of The Saint's Corpse"})
    else
        farmItems()
    end
end

if not plr.Backpack:FindFirstChild("Pelvis of The Saint's Corpse") then
    if plr.PlayerStats.Money.Value > 45000 then
        local Event = GetCharacter().RemoteEvent
        Event:FireServer("PurchaseShopItem",{ItemName = "1x Pelvis of The Saint's Corpse"})
    else
        farmItems()
    end
end

TeleportTo(workspace.Dialogues["Jotaro."].HumanoidRootPart)

if plr.PlayerStats.Quest.Value == "Talk to Jotaro once you obtain the \"Saint's Corpse Parts\""
or plr.PlayerGui.HUD.Main.Frames.Quest.Quests:FindFirstChild("Obtain \"Dio's BONE\" (Dio's DIARY)") then
    repeat 
        local Event = game:GetService("Players").LocalPlayer.Character.RemoteEvent
        Event:FireServer("DialogueInteracted",{DialogueName = "Path to Heaven",Speaker = "Jotaro."})
        task.wait(.1)
        betterPcall(function()
            frameclick(plr.PlayerGui:WaitForChild("Dialogue",5):WaitForChild("Interact",5):WaitForChild("Option1",5):WaitForChild("TextButton",5))
        end)
    until not plr.PlayerGui:FindFirstChild("Dialogue")
end

GetCharacter().Humanoid:UnequipTools()

while not plr.Backpack:FindFirstChild("Dio's Bone") do
    task.wait()
    print("Starting killing")
    killnpc("Heaven Ascension Dio", 15)
    print("Done killing")
end


if plr.Backpack:FindFirstChild("Dio's Bone") then
    if plr.PlayerStats.Stand.Value == "The World" then
        repeat
            TeleportTo(CFrame.new(-230.649704, 284.198181, 352.44873, -0.714287519, -1.29201192e-08, 0.699852407, -2.14293259e-08, 1, -3.41011841e-09, -0.699852407, -1.74331696e-08, -0.714287519))

            local Event = game:GetService("Players").LocalPlayer.Character.RemoteEvent
            Event:FireServer(
                "UpdateWeatherTemperature",
                {
                    WeatherTemperatureType = "None",
                    Location = workspace.Locations["The Tallest Peak"]
                }
            )

            task.spawn(function()
                while task.wait() do
                    GetCharacter().Location.Value = workspace.Locations["The Tallest Peak"]
                end
            end)
            
            task.spawn(function()
                while task.wait() do
                    GetCharacter().Location.Value = workspace.Locations["The Tallest Peak"]
                end
            end)

            task.spawn(function()
                while task.wait() do
                    GetCharacter().Location.Value = workspace.Locations["The Tallest Peak"]
                end
            end)

            if plr.Backpack:FindFirstChild("Dio's Bone") then
                GetCharacter():WaitForChild("Humanoid",5):EquipTool(plr.Backpack["Dio's Bone"])
            end
            task.wait(1)
            

            GetCharacter():WaitForChild("RemoteFunction"):InvokeServer("ToggleStand", "Toggle")

            task.wait(1)

            ToggleStand()
        until plr.PlayerStats.Stand.Value == "The World Over Heaven"

        SendWebhook(plr.DisplayName.." obtained TWOH")
        tpservice:Teleport(2809202155)
    end
end