-- VEXYLION HUB by ......
repeat task.wait(0.11) until game:IsLoaded()

-- === FPS CAP  ===
local FPSCap = getgenv().FPSCap or 60 
if FPSCap and FPSCap > 0 then
    if type(setfpscap) == "function" then
        setfpscap(FPSCap)
    else
        local RunService = game:GetService("RunService")
        local lastTime = tick()
        local frameTime = 1 / FPSCap
        RunService.RenderStepped:Connect(function()
            local now = tick()
            if now - lastTime < frameTime then
                wait(frameTime - (now - lastTime))
            end
            lastTime = tick()
        end)
    end
end

-- === SETTINGS ===
local BuyLucky = getgenv().BuyLucky or true
local AutoSell = getgenv().AutoSell or true
local SellItems = getgenv().SellItems or {
    ["Gold Coin"] = true,
    ["Rokakaka"] = true,
    ["Pure Rokakaka"] = true,
    ["Mysterious Arrow"] = true,
    ["Diamond"] = true,
    ["Ancient Scroll"] = true,
    ["Caesar's Headband"] = true,
    ["Stone Mask"] = true,
    ["Rib Cage of The Saint's Corpse"] = true,
    ["Quinton's Glove"] = true,
    ["Zeppeli's Hat"] = true,
    ["Lucky Arrow"] = false,
    ["Clackers"] = true,
    ["Steel Ball"] = true,
    ["Dio's Diary"] = true
}

-- === Webhook ===
local Webhook = {
    Enabled = getgenv().WebhookEnabled or true,
    URL = getgenv().WebhookURL,
    PingEveryone = getgenv().WebhookPingEveryone or false,
    SendOnFarmComplete = getgenv().WebhookSendOnFarmComplete or true,
    SendOnSell = getgenv().WebhookSendOnSell or false,
    SendOnPurchase = getgenv().WebhookSendOnPurchase or true,
    SendOnServerHop = getgenv().WebhookSendOnServerHop or false,
    ImageURL = getgenv().WebhookImageURL or "https://i.imgur.com/xJ0rHpg.png",
    HubName = getgenv().WebhookHubName or "Halal Hub",
    EmbedColor = getgenv().WebhookEmbedColor or 0x9B59B6
}

-- === SERVICES ===
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- === GAMEPASS (INVENTORY X2) ===
local Has2x = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 14597778)

-- === BYPASS ANTI-CHEATS ===
local oldMagnitude
oldMagnitude = hookmetamethod(Vector3.new(), "__index", newcclosure(function(self, index)
    local CallingScript = tostring(getcallingscript())
    if not checkcaller() and index == "magnitude" and CallingScript == "ItemSpawn" then
        return 0
    end
    return oldMagnitude(self, index)
end))

local UzuKey = "  ___XP DE KEY"
local oldNc
oldNc = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if not checkcaller() and rawequal(self.Name, "Returner") and rawequal(Args[1], "idklolbrah2de") then
        return UzuKey
    end
    return oldNc(self, ...)
end))

-- === UTILITY FUNCTIONS ===
local function GetCharacter(Part)
    if Player.Character then
        if not Part then return Player.Character end
        if typeof(Part) == "string" then return Player.Character:FindFirstChild(Part) end
    end
    return nil
end

local function TeleportTo(Position)
    local hrp = GetCharacter("HumanoidRootPart")
    if hrp and typeof(Position) == "CFrame" then hrp.CFrame = Position end
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
if Has2x then for k,v in pairs(MaxItemAmounts) do MaxItemAmounts[k] = v*2 end end

local function HasMaxItem(Item)
    local count = 0
    for _, tool in pairs(Player.Backpack:GetChildren()) do if tool.Name == Item then count+=1 end end
    return MaxItemAmounts[Item] and count >= MaxItemAmounts[Item]
end

-- === Webhook Sender ===
local function SendWebhook(eventType, extraData)
    if not Webhook.Enabled or Webhook.URL == "" then return end
    local money = Player.PlayerStats.Money.Value
    local playerName = Player.Name
    local inventory = {}
    for _, tool in ipairs(Player.Backpack:GetChildren()) do
        local name = tool.Name
        if SellItems[name] ~= nil or MaxItemAmounts[name] then inventory[name] = (inventory[name] or 0)+1 end
    end
    local title, descriptionLines = "", {}
    if eventType == "FarmCompleted" then title = "🌾 Farm Completed"
    elseif eventType == "Sell" then
        title = "💰 Items Sold"
        if extraData and extraData.soldItems and next(extraData.soldItems) then
            table.insert(descriptionLines, "**Sold:**")
            for item, count in pairs(extraData.soldItems) do table.insert(descriptionLines, "• "..item.." x"..count) end
        end
    elseif eventType == "Purchase" then title = "🛒 Lucky Arrow Purchase"
        if extraData and extraData.amount then table.insert(descriptionLines, "**Purchased:** "..extraData.amount) end
    elseif eventType == "ServerHop" then title = "🔄 Server Hop"
    else title = "📦 YBA Auto Farm" end
    table.insert(descriptionLines, 1, "**Player:** ||`"..playerName.."`||")
    table.insert(descriptionLines, 2, "**Money:** `"..money.."`")
    if next(inventory) then
        table.insert(descriptionLines, "\n**📦 Inventory:**")
        for name, count in pairs(inventory) do
            local max = MaxItemAmounts[name] or "∞"
            table.insert(descriptionLines, "• "..name..": "..count.." / "..tostring(max))
        end
    else table.insert(descriptionLines, "\n**📦 Inventory:** *empty*") end
    local embed = {title = title, description = table.concat(descriptionLines,"\n"), color = Webhook.EmbedColor,
        author = {name = Webhook.HubName}, thumbnail = {url = Webhook.ImageURL},
        footer = {text = "YBA Auto Farm • "..os.date("%Y-%m-%d %H:%M:%S")}}
    local payload = {content = Webhook.PingEveryone and "@everyone" or "", embeds = {embed}}
    pcall(function()
        if syn and syn.request then syn.request({Url=Webhook.URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=HttpService:JSONEncode(payload)})
        elseif request then request({Url=Webhook.URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=HttpService:JSONEncode(payload)})
        elseif http_request then http_request({Url=Webhook.URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=HttpService:JSONEncode(payload)})
        else HttpService:PostAsync(Webhook.URL, HttpService:JSONEncode(payload)) end
    end)
end

-- === Server Hop ===
local Teleport = loadstring(game:HttpGet("https://raw.githubusercontent.com/rinqedd/pub_rblx/main/ServerHop", true))

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

-- =====================================================
-- ===  GUI ===
-- =====================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.Name = "VexylionOverlay"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Background = Instance.new("Frame")
Background.Parent = ScreenGui
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.new(0, 0, 0)
Background.BackgroundTransparency = 0.85
Background.BorderSizePixel = 0
Background.ZIndex = 1

local MainStatus = Instance.new("TextLabel")
MainStatus.Parent = Background
MainStatus.Size = UDim2.new(0.8, 0, 0.2, 0)
MainStatus.Position = UDim2.new(0.1, 0, 0.4, 0)
MainStatus.BackgroundTransparency = 1
MainStatus.TextColor3 = Color3.new(1, 1, 1)
MainStatus.Font = Enum.Font.GothamBold
MainStatus.TextSize = 36
MainStatus.TextStrokeTransparency = 0.5
MainStatus.TextStrokeColor3 = Color3.new(0, 0, 0)
MainStatus.Text = "⚡ Initializing Vexylion Hub..."
MainStatus.TextXAlignment = Enum.TextXAlignment.Center
MainStatus.TextYAlignment = Enum.TextYAlignment.Center
MainStatus.ZIndex = 2

local InfoPanel = Instance.new("Frame")
InfoPanel.Parent = Background
InfoPanel.Size = UDim2.new(1, -40, 0.12, 0)
InfoPanel.Position = UDim2.new(0, 20, 0.85, -10)
InfoPanel.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
InfoPanel.BackgroundTransparency = 0.4
InfoPanel.BorderSizePixel = 0
InfoPanel.ZIndex = 2
Instance.new("UICorner", InfoPanel).CornerRadius = UDim.new(0, 12)

local MoneyLabel = Instance.new("TextLabel")
MoneyLabel.Parent = InfoPanel
MoneyLabel.Size = UDim2.new(0.33, 0, 1, 0)
MoneyLabel.BackgroundTransparency = 1
MoneyLabel.TextColor3 = Color3.new(0.9, 0.9, 0.2)
MoneyLabel.Font = Enum.Font.GothamSemibold
MoneyLabel.TextSize = 22
MoneyLabel.Text = "💰 $0"
MoneyLabel.TextXAlignment = Enum.TextXAlignment.Center
MoneyLabel.ZIndex = 3

local ItemsLabel = Instance.new("TextLabel")
ItemsLabel.Parent = InfoPanel
ItemsLabel.Size = UDim2.new(0.34, 0, 1, 0)
ItemsLabel.Position = UDim2.new(0.33, 0, 0, 0)
ItemsLabel.BackgroundTransparency = 1
ItemsLabel.TextColor3 = Color3.new(0.6, 0.8, 1)
ItemsLabel.Font = Enum.Font.GothamSemibold
ItemsLabel.TextSize = 22
ItemsLabel.Text = "📦 Items: 0"
ItemsLabel.TextXAlignment = Enum.TextXAlignment.Center
ItemsLabel.ZIndex = 3

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Parent = InfoPanel
TimeLabel.Size = UDim2.new(0.33, 0, 1, 0)
TimeLabel.Position = UDim2.new(0.67, 0, 0, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
TimeLabel.Font = Enum.Font.GothamSemibold
TimeLabel.TextSize = 22
TimeLabel.Text = "⏱️ 00:00"
TimeLabel.TextXAlignment = Enum.TextXAlignment.Center
TimeLabel.ZIndex = 3

local Div1 = Instance.new("Frame")
Div1.Parent = InfoPanel
Div1.Size = UDim2.new(0.002, 0, 0.6, 0)
Div1.Position = UDim2.new(0.33, 0, 0.2, 0)
Div1.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
Div1.BorderSizePixel = 0
Div1.ZIndex = 3

local Div2 = Instance.new("Frame")
Div2.Parent = InfoPanel
Div2.Size = UDim2.new(0.002, 0, 0.6, 0)
Div2.Position = UDim2.new(0.67, 0, 0.2, 0)
Div2.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
Div2.BorderSizePixel = 0
Div2.ZIndex = 3

local HubTitle = Instance.new("TextLabel")
HubTitle.Parent = Background
HubTitle.Size = UDim2.new(1, 0, 0.08, 0)
HubTitle.Position = UDim2.new(0, 0, 0.02, 0)
HubTitle.BackgroundTransparency = 1
HubTitle.TextColor3 = Color3.new(0.10, 0.5, 1)
HubTitle.Font = Enum.Font.GothamBlack
HubTitle.TextSize = 28
HubTitle.Text = "VEXYLION HUB"
HubTitle.TextXAlignment = Enum.TextXAlignment.Center
HubTitle.TextStrokeTransparency = 0.7
HubTitle.TextStrokeColor3 = Color3.new(0, 0, 0)
HubTitle.ZIndex = 2

local function SetStatus(text) pcall(function() MainStatus.Text = text end) end
local function UpdateInfoPanel(money, itemCount)
    pcall(function() MoneyLabel.Text = "💰 $" .. tostring(money) end)
    pcall(function() ItemsLabel.Text = "📦 Items: " .. tostring(itemCount) end)
end
local startTime = tick()
local function UpdateTimer()
    local elapsed = tick() - startTime
    local minutes = math.floor(elapsed / 60)
    local seconds = math.floor(elapsed % 60)
    pcall(function() TimeLabel.Text = string.format("⏱️ %02d:%02d", minutes, seconds) end)
end
task.spawn(function()
    while true do
        task.wait(1)
        UpdateTimer()
        local money = Player.PlayerStats.Money.Value
        local itemCount = 0
        for _, tool in pairs(Player.Backpack:GetChildren()) do
            if SellItems[tool.Name] ~= nil or MaxItemAmounts[tool.Name] then itemCount += 1 end
        end
        UpdateInfoPanel(money, itemCount)
    end
end)

-- === UI Cleanup ===
task.wait(1)
if not PlayerGui:FindFirstChild("HUD") then
    local HUD = ReplicatedStorage.Objects.HUD:Clone()
    HUD.Parent = PlayerGui
end
task.spawn(function()
    pcall(function() PlayerGui:WaitForChild("LoadingScreen1"):Destroy() end)
    pcall(function() PlayerGui:WaitForChild("LoadingScreen"):Destroy() end)
    pcall(function() Workspace.LoadingScreen.Song:Destroy() end)
end)

-- === Initialization ===
repeat task.wait() until GetCharacter() and GetCharacter("RemoteEvent")
GetCharacter("RemoteEvent"):FireServer("PressedPlay")
local FARM_HUB = CFrame.new(978, -42, -49)
TeleportTo(FARM_HUB)
task.wait(5)
SetStatus("Teleported to farm hub, waiting for items...")

-- === AFK TIMER ===
local AFK_TIMEOUT = 180
local lastActionTime = tick()
local function UpdateActivity() lastActionTime = tick() end
task.spawn(function()
    while true do
        task.wait(10)
        if tick() - lastActionTime > AFK_TIMEOUT then
            SetStatus("No activity for 3 minutes, server hopping...")
            task.wait(1)
            if Webhook.SendOnServerHop then SendWebhook("ServerHop") end
            Teleport()
            UpdateActivity()
        end
    end
end)

-- === MAIN FARM LOOP ===
repeat
    if #getgenv().SpawnedItems == 0 then
        SetStatus("No items spawned, waiting for respawn...")
    else
        SetStatus("Farming items (" .. #getgenv().SpawnedItems .. " available)")
    end
    for Index, ItemInfo in pairs(getgenv().SpawnedItems) do
        local hrp = GetCharacter("HumanoidRootPart")
        if not hrp then break end
        if not Index or not Index.Parent then getgenv().SpawnedItems[Index] = nil
        elseif HasMaxItem(ItemInfo.Name) then getgenv().SpawnedItems[Index] = nil
        else
            table.remove(getgenv().SpawnedItems, table.find(getgenv().SpawnedItems, ItemInfo))
            SetStatus("Looting " .. ItemInfo.Name .. "...")
            TeleportTo(CFrame.new(ItemInfo.Position))
            task.wait(0.5)
            fireproximityprompt(ItemInfo.ProximityPrompt)
            UpdateActivity()
            task.wait(0.5)
            TeleportTo(FARM_HUB)
            UpdateActivity()
            SetStatus("Returned to hub, continuing farm...")
        end
    end
    task.wait(3)
until #getgenv().SpawnedItems == 0

SetStatus("Farm completed! Processing sell and purchase...")
if Webhook.SendOnFarmComplete then SendWebhook("FarmCompleted") end

if AutoSell then
    SetStatus("Selling items...")
    local sold = {}
    for Item, Sell in pairs(SellItems) do
        if Sell and Player.Backpack:FindFirstChild(Item) then
            local humanoid = GetCharacter("Humanoid")
            if humanoid then
                humanoid:EquipTool(Player.Backpack[Item])
                GetCharacter("RemoteEvent"):FireServer("EndDialogue", {NPC="Merchant", Dialogue="Dialogue5", Option="Option2"})
                sold[Item] = (sold[Item] or 0)+1
                UpdateActivity()
                task.wait(0.1)
            end
        end
    end
    if Webhook.SendOnSell and next(sold) then SendWebhook("Sell", {soldItems=sold}) end
    SetStatus("Selling finished.")
end

if BuyLucky then
    SetStatus("Purchasing Lucky Arrows...")
    local Money = Player.PlayerStats.Money
    local limit = MaxItemAmounts["Lucky Arrow"]
    local function CountLucky() local c=0 for _,t in pairs(Player.Backpack:GetChildren()) do if t.Name=="Lucky Arrow" then c+=1 end end return c end
    local purchased, failCount = 0,0
    while Money.Value >= 75000 and CountLucky() < limit and failCount < 3 do
        local before = CountLucky()
        pcall(function() Player.Character.RemoteEvent:FireServer("PurchaseShopItem", {ItemName="1x Lucky Arrow"}) end)
        task.wait(0.5)
        if CountLucky() > before then purchased+=1; failCount=0; UpdateActivity(); SetStatus("Purchased Lucky Arrow ("..purchased.." total)")
        else failCount+=1 end
        task.wait(0.2)
    end
    if Webhook.SendOnPurchase and purchased>0 then SendWebhook("Purchase", {amount=purchased}) end
    SetStatus("Lucky Arrow purchase finished.")
end

SetStatus("All tasks done, hopping to new server...")
task.wait(2)
if Webhook.SendOnServerHop then SendWebhook("ServerHop") end
Teleport()