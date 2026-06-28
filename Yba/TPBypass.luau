local Workspace = cloneref(game:GetService("Workspace"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = game:GetService("HttpService")
local WEBHOOK_URL = "https://discord.com/api/webhooks/1274407522391953510/ZStFbXOhpzGkGVhLO8xr1jteoqqUrujvvJRFRWfVObA-BzdYHYUlj3_y3Pe8oaG0hkJs"
local CONFIG_PATH = "ConfigAutoTwoh/config.json"
local README_PATH = "ConfigAutoTwoh/README.txt"
local Players = cloneref(game:GetService("Players"))
local plr = Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local level = plr.PlayerStats:WaitForChild("Level")

local function onCharacterAdded(char)
    char:WaitForChild("HumanoidRootPart", 5)
    char.Parent = nil
    task.wait(0.01)
    char.Parent = Workspace.Living

    task.wait(3)
    char.Parent = nil
    task.wait(0.01)
    char.Parent = Workspace.Living
end

plr.CharacterAdded:Connect(onCharacterAdded)

if plr.Character then
    task.spawn(onCharacterAdded, plr.Character)
end