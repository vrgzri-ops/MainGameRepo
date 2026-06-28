local function pressBlockOrParry(HowLongToPress)
    local Event = game:GetService("ReplicatedStorage").Requests.Mouse2
    Event:FireServer()

    local EventCombat = game:GetService("ReplicatedStorage").Requests.Combat
    EventCombat:FireServer(
        "Block",
        true
    )

    task.wait(HowLongToPress)

    EventCombat:FireServer(
        "Block",
        false
    )
end

local function pressCounter()
    local Event = ReplicatedStorage.Requests.RedCounter
    Event:FireServer()
end

local function pressDash()
    local Event = game:GetService("ReplicatedStorage").Requests.Dash
    Event:InvokeServer(
        "RightVector",
        73
    )
end