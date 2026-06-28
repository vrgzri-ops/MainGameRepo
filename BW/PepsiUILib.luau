-- Load the library (Example Asset ID)
local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)("Pepsi's UI Library")

-- Create Window, Tab, and Section
local window = library:CreateWindow({ Name = "Example", Themeable = {} })
local tab = window:CreateTab({ Name = "Main" })
local section = tab:CreateSection({ Name = "Controls" })

-- Add interactive elements
section:AddToggle({
    Name = "Toggle",
    Flag = "ToggleFlag", --
    Callback = function(state) print(state) end
})
