-- https://lua.expert/
local t = {}
local LocalPlayer = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

game:GetService("TweenService")

local CollectionService = game:GetService("CollectionService")

game:GetService("HttpService")

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

game:GetService("TextChatService")

local SoundService = game:GetService("SoundService")
local ContextActionService = game:GetService("ContextActionService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

UserGameSettings.RotationType = Enum.RotationType.CameraRelative

local Requests = game.ReplicatedStorage:WaitForChild("Requests")
local SharedAssets = game.ReplicatedStorage:WaitForChild("SharedAssets")
local SharedModules = game.ReplicatedStorage:WaitForChild("SharedModules")
local AttackService = require(SharedModules:WaitForChild("AttackService"))
local OverheadManager = require(SharedModules:WaitForChild("OverheadManager"))
local Shared = require(SharedModules:WaitForChild("Shared"))

require(SharedModules:WaitForChild("ClientLib"))

local UI = require(SharedModules:WaitForChild("UI"))

require(game.ReplicatedStorage.SharedAssets.Info.Accessories)

local NetworkManager = require(game.ReplicatedStorage.SharedModules.NetworkManager)
local ControlsService = require(game.ReplicatedStorage.SharedModules.ControlsService)
local CooldownListener = require(game.ReplicatedStorage.SharedModules.Cooldowns.CooldownListener)

require(SharedModules.Promise)

local PlaceIds = require(SharedAssets.Info.PlaceIds)
local DashInfo = require(SharedAssets.Info.DashInfo)
local HollowTypes = require(SharedAssets.Info.HollowTypes)
local StunHandler = require(SharedModules:WaitForChild("StunHandler"))
local ClientEffects = require(SharedModules:WaitForChild("ClientEffects"))
local v1 = Random.new()
local Sensing = require(SharedModules.Sensing)
local Parties = require(game.ReplicatedStorage.SharedModules.Parties)
local v2 = RaycastParams.new()

v2.FilterType = Enum.RaycastFilterType.Exclude
v2.FilterDescendantsInstances = { workspace.Debris, workspace.Living }
v2.IgnoreWater = true

local v3 = RaycastParams.new()

v3.FilterType = Enum.RaycastFilterType.Exclude
v3.IgnoreWater = true

local PlayerData = require(SharedModules:WaitForChild("PlayerData"))

PlayerData:WaitForProfile(LocalPlayer)

local v4 = PlayerData:GetCharacterData(LocalPlayer)
local v5 = PlayerData:GetOverheadData(LocalPlayer)
local v6 = LocalPlayer:GetMouse()

LocalPlayer:WaitForChild("PlayerGui")

local v7 = SharedAssets.FootstepSounds:GetChildren()
local KnockedPrompt = script.KnockedPrompt

KnockedPrompt.ResetOnSpawn = false
KnockedPrompt.Parent = LocalPlayer.PlayerGui

local TargetCircle = script.TargetCircle

TargetCircle.ResetOnSpawn = false
TargetCircle.Parent = LocalPlayer.PlayerGui

local function FindInInstanceTbl(p1, p2) --[[ FindInInstanceTbl | Line: 71 ]]
    for v1, v2 in next, p1 do
        if v2.Name == p2 then
            return v2
        end
    end
end

local v8 = nil

local function Living_ChildAdded(p1) --[[ Living_ChildAdded | Line: 81 | Upvalues: v8 (ref), LocalPlayer (copy), Shared (copy), OverheadManager (copy) ]]
    if p1 == nil then
        return
    end

    if table.find(v8, p1) then
        return
    end

    if p1 == LocalPlayer.Character then
        return
    end

    if game.Players:GetPlayerFromCharacter(p1) == nil then
        Shared.DisableNPCStates(p1)
    end

    coroutine.wrap(OverheadManager.AddModel)(OverheadManager, p1)
    table.insert(v8, p1)
end

local function UpdateLiving(p1) --[[ UpdateLiving | Line: 94 | Upvalues: v8 (ref), Living_ChildAdded (copy) ]]
    if v8 ~= nil then
        v8 = workspace.Living:GetChildren()

        return
    end

    v8 = {}

    local v1 = next
    local v2, v3 = workspace.Living:GetChildren()

    for v4, v5 in v1, v2, v3 do
        Living_ChildAdded(v5)
    end
end

workspace.Living.ChildAdded:Connect(Living_ChildAdded)
workspace.Living.ChildRemoved:Connect(UpdateLiving)
UpdateLiving()

local v9 = nil
local v10 = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local t2 = {}
local t3 = {}
local t4 = {}
local v11 = nil
local t5 = {}

coroutine.wrap(function() --[[ Line: 131 | Upvalues: PlaceIds (copy), v9 (ref), t5 (copy) ]]
    if PlaceIds:GetPlaceInfo().PlaceName ~= "InnerWorld" then
        return
    end

    v9 = game.ReplicatedStorage.ServerStatus:WaitForChild("InnerWorldType").Value

    if v9 ~= "DefaultInnerWorld" then
        return
    end

    local function addbell(p1) --[[ addbell | Line: 136 | Upvalues: t5 (ref) ]]
        if p1.Name ~= "Bell_InnerWorld" then
            return
        end

        table.insert(t5, p1)
    end

    local v1 = next
    local v2, v3 = workspace.DialogueInteractables:GetChildren()

    for v4, v5 in v1, v2, v3 do
        if v5.Name == "Bell_InnerWorld" then
            table.insert(t5, v5)
        end
    end

    workspace.DialogueInteractables.ChildAdded:Connect(function(p1) --[[ Line: 146 | Upvalues: t5 (ref) ]]
        if p1.Name ~= "Bell_InnerWorld" then
            return
        end

        table.insert(t5, p1)
    end)
end)()
function t.AttemptDash(p1) --[[ AttemptDash | Line: 152 | Upvalues: UserInputService (copy), ControlsService (copy), DashInfo (copy) ]]
    if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
        return
    end

    local v1 = nil

    if ControlsService:GetControlMode() == "Gamepad" then
        local v2 = ControlsService:ThumbstickTo4D()

        print(v2)
        v1 = v2
    else
        local v3 = next
        local v4, v5 = UserInputService:GetKeysPressed()

        for v6, v7 in v3, v4, v5 do
            local v8 = v7.KeyCode.Name

            if DashInfo.DirectionalInfo[v8] and v8 ~= "W" then
                v1 = v8

                break
            end
        end
    end

    if v1 ~= nil and (DashInfo.DirectionalInfo[v1] and v1 ~= "W") then
        p1:Dash(v1)
    end
end
function t.SpaceActionStart(p1) --[[ SpaceActionStart | Line: 181 | Upvalues: ControlsService (copy), AttackService (copy), Shared (copy), LocalPlayer (copy), CollectionService (copy), Requests (copy), SharedAssets (copy) ]]
    local v1 = ControlsService:GetBindOfInput("Dash")

    if ControlsService:AreBindsEqual(ControlsService:GetBindOfInput("Jump"), v1) and p1.DashPrepared then
        return
    end

    p1.LastSpacePress = os.clock()
    p1.Character.Humanoid.Sit = false

    if p1.LastSpacePress and p1.Humanoid.JumpPower > 0 then
        local isNotAir = p1.Humanoid.FloorMaterial ~= Enum.Material.Air
        local v2 = p1.Humanoid:GetState()

        if v2 == Enum.HumanoidStateType.Jumping or (v2 == Enum.HumanoidStateType.Freefall or v2 == Enum.HumanoidStateType.FallingDown) then
            isNotAir = false
        end

        if isNotAir then
            p1.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    if not p1:IsHumanoid() then
        return
    end

    if not (AttackService.CanAttack(p1.Character) or AttackService.CanAdventure(p1.Character)) then
        return
    end

    if p1.Humanoid.JumpPower > 0 then
        local LastSpacePress = p1.LastSpacePress

        task.delay(0.35, function() --[[ Line: 219 | Upvalues: ControlsService (ref), AttackService (ref), p1 (copy), LastSpacePress (copy), Shared (ref), LocalPlayer (ref), CollectionService (ref), Requests (ref) ]]
            if not (ControlsService:IsActionHeld("Jump") and (AttackService.CanAttack(p1.Character) or AttackService.CanAdventure(p1.Character))) or (p1.LastSpacePress ~= LastSpacePress or not (p1.Character.Status.Reiatsu.Value >= 0)) then
                return
            end

            if not Shared.HasSkill(LocalPlayer, "Airwalk") then
                return
            end

            if p1.AirWalkController.Flying then
                return
            end

            if CollectionService:HasTag(LocalPlayer, "InCombat") then
                local _, v1 = Shared.MagHitbox(p1.Character.HumanoidRootPart.Position, 300, { p1.Character })
                local v2 = false

                for v3, v4 in next, v1 do
                    if Shared.HasEffect(v4, "FlyingDrain") then
                        v2 = true

                        break
                    end
                end

                if not v2 then
                    Requests.ZanpakutoTextClient:Fire("You are in combat...")

                    return
                end
            end

            if not p1.AirWalkController:GetCanFly() then
                Requests.ZanpakutoTextClient:Fire("You can\'t airwalk here...")

                return
            end

            if not ControlsService:IsActionHeld("Jump") then
                return
            end

            p1.Animations.Falling:Stop()
            p1.AirWalkController:ToggleFlight(true, true)
        end)
    end

    p1.Humanoid:GetState()

    if CollectionService:HasTag(LocalPlayer, "InCombat") or (p1.AirWalkController.Flying ~= false or (p1.DoubleJumped ~= false or not (os.clock() - p1.LastDoubleJump > 2.5 and (p1.InAir and p1.Character.Humanoid.Health > p1.Character.Humanoid.MaxHealth * 0.25)))) then
        return
    end

    p1.DoubleJumped = true
    p1.LastDoubleJump = os.clock()
    p1.Root.Velocity = Vector3.new(p1.Root.Velocity.X, 65, p1.Root.Velocity.Z)
    p1.InAirTime = 0
    p1:ToggleFreefall(false)
    p1.Humanoid:LoadAnimation(SharedAssets.Animations.DoubleJump):Play(0.2, 1, 1.25)
    Shared.PlaySound(SharedAssets.Sounds.DoubleJump, p1.Root)

    local v3 = SharedAssets.DoubleJump_FX:Clone()

    v3.CFrame = p1.Root.CFrame
    v3.Parent = workspace.Debris
    game.Debris:AddItem(v3, 3)
    Shared.EmitParticles(v3)
end
function t.IsHumanoid(p1) --[[ IsHumanoid | Line: 291 | Upvalues: v4 (copy) ]]
    return if v4.Race == "Hollow" then v4.HollowModel.HollowStage == "VastoLorde" else true
end
function t.SpaceActionEnd(p1) --[[ SpaceActionEnd | Line: 295 ]]
    local _ = p1.DashPrepared
end
function t.GetNextTransformationLevel(p1) --[[ GetNextTransformationLevel | Line: 300 | Upvalues: v4 (copy), Shared (copy) ]]
    local v1 = if v4.LetztProgress.Unlocked or (v4.LetztProgress.FalseUnlocked or (v4.ResAbilityData.Unlocked or v4.ZanpakutoAbilityData.Unlocked)) then 0 else nil

    for v2, v3 in next, v4.GlobalCooldowns do
        if v3.CooldownName == "FormLevel0Cooldown" then
            v1 = nil
        end
    end

    if Shared.HasEffect(p1.Character, "SecondModeProgress") then
        v1 = 2
    end

    return v1
end
function t.CreateInputListeners(p1) --[[ CreateInputListeners | Line: 323 | Upvalues: ControlsService (copy), Sensing (copy), Parties (copy), Requests (copy), UserInputService (copy), Shared (copy), LocalPlayer (copy), CollectionService (copy), v4 (copy), TweenService (copy), v5 (copy), v6 (copy), NetworkManager (copy) ]]
    local v1 = ControlsService

    table.insert(p1.Connections, v1:BindAction("Dash", function() --[[ Line: 326 | Upvalues: p1 (copy) ]]
        p1:AttemptDash()
    end))

    local v2 = ControlsService

    table.insert(p1.Connections, v2:BindAction("Jump", function() --[[ Line: 330 | Upvalues: p1 (copy) ]]
        p1:SpaceActionStart()
    end))

    local v3 = ControlsService

    local function f4() --[[ Line: 334 | Upvalues: Sensing (ref), Parties (ref) ]]
        Sensing:StartSense(Parties:GetCurrentParty())
    end

    table.insert(p1.Connections, v3:BindAction("Sense", f4))

    local v52 = ControlsService

    local function f6() --[[ Line: 337 | Upvalues: p1 (copy), Requests (ref), ControlsService (ref), UserInputService (ref) ]]
        game.ReplicatedStorage.Requests.Mouse2:FireServer()

        if p1.StatusFolder:FindFirstChild("CeroCharge") then
            return
        end

        Requests.Combat:FireServer("Feint")

        if not ControlsService:AreBindsEqual(ControlsService:GetActionInfo("Block").KeyboardBinds, { "MouseButton::MouseButton2" }) then
            Requests.Combat:FireServer("Block", true)

            return
        end

        if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
            return
        end

        if not ControlsService:IsActionHeld("Ability") then
            Requests.Combat:FireServer("Block", true)
        end
    end

    table.insert(p1.Connections, v52:BindAction("Block", f6))

    local v7 = ControlsService

    local function f8() --[[ Line: 354 | Upvalues: p1 (copy), Shared (ref), LocalPlayer (ref), Requests (ref) ]]
        if p1:IsHoldingSprint() then
            p1.LastFastMovementHold = os.clock()

            local LastFastMovementRelease = p1.LastFastMovementRelease

            task.delay(0.225, function() --[[ Line: 362 | Upvalues: LastFastMovementRelease (copy), p1 (ref), Shared (ref), LocalPlayer (ref), Requests (ref) ]]
                if LastFastMovementRelease ~= p1.LastFastMovementRelease then
                    return
                end

                local v1 = Shared.HasSkill(LocalPlayer, "Manual Rushdown")

                if not v1 then
                    return
                end

                p1.TargetInfo.Active = true
                p1.TargetInfo.Range = 49
                task.wait(0.175)

                if LastFastMovementRelease ~= p1.LastFastMovementRelease then
                    return
                end

                p1.TargetInfo.Active = false

                if Shared.GetNearestModel(49) ~= nil and v1 then
                    Requests.UseSkill:FireServer("Manual Rushdown")
                end
            end)
        else
            Requests.FlashStep:FireServer()
        end
    end

    table.insert(p1.Connections, v7:BindAction("Fast Movement", f8))

    local v9 = ControlsService

    local function f10() --[[ Line: 387 | Upvalues: CollectionService (ref), LocalPlayer (ref), p1 (copy), Shared (ref), v4 (ref), TweenService (ref) ]]
        if CollectionService:HasTag(LocalPlayer, "BossFight_TriedTransformation") then
            return
        end

        p1.LastAbilityTriggerPress = os.clock()

        local LastAbilityTriggerPress = p1.LastAbilityTriggerPress

        if p1:GetNextTransformationLevel() == nil then
            return
        end

        local v1 = Shared.HasEffect(p1.Character, "SecondModeProgress")

        p1.StatusUI.Container.TransformBar.Bar.BackgroundColor3 = v4.ReiatsuColor

        if v1 then
            p1.StatusUI.Container.TransformBar.Bar.BackgroundColor3 = Color3.new(255/255, 255/255, 255/255)
        end

        p1.StatusUI.Container.TransformBar.Bar.Size = UDim2.new(0, 0, 1, 0)
        p1.StatusUI.Container.TransformBar.Visible = true

        if not p1.StatusUI_TransformTween then
            p1.StatusUI_TransformTween = TweenService:Create(p1.StatusUI.Container.TransformBar.Bar, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {
                Size = UDim2.new(1, 0, 1, 0)
            }):Play()

            return
        end

        p1.StatusUI_TransformTween:Cancel()
        p1.StatusUI_TransformTween = nil
        p1.StatusUI_TransformTween = TweenService:Create(p1.StatusUI.Container.TransformBar.Bar, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {
            Size = UDim2.new(1, 0, 1, 0)
        }):Play()
    end

    table.insert(p1.Connections, v9:BindAction("Form Activation", f10))

    local v11 = ControlsService

    table.insert(p1.Connections, v11:BindAction("Power Up", function() --[[ Line: 419 | Upvalues: p1 (copy) ]]
        p1.CharacterRemotes.ChangeOutput:FireServer(1, true)
    end))

    local v12 = ControlsService

    table.insert(p1.Connections, v12:BindAction("Power Down", function() --[[ Line: 422 | Upvalues: p1 (copy) ]]
        p1.CharacterRemotes.ChangeOutput:FireServer(-1, true)
    end))

    local v13 = ControlsService

    local function f14() --[[ Line: 426 | Upvalues: p1 (copy), Requests (ref) ]]
        p1.LastHeavyAttackPress = os.clock()

        local LastHeavyAttackPress = p1.LastHeavyAttackPress

        task.delay(0.5, function() --[[ Line: 430 | Upvalues: LastHeavyAttackPress (copy), p1 (ref), Requests (ref) ]]
            if LastHeavyAttackPress ~= p1.LastHeavyAttackPress then
                return
            end

            Requests.Combat:FireServer("CycleStance")
        end)
    end

    table.insert(p1.Connections, v13:BindAction("Heavy Attack", f14))

    local v15 = ControlsService

    local function f16() --[[ Line: 437 | Upvalues: Requests (ref) ]]
        Requests.UseSkill:FireServer("Spiritual Pressure")
    end

    table.insert(p1.Connections, v15:BindAction("SpiritualPressure", f16))

    local v17 = ControlsService

    local function f18() --[[ Line: 441 | Upvalues: p1 (copy), Requests (ref) ]]
        local Tool = p1.Character:FindFirstChildOfClass("Tool")

        if not Tool then
            return
        end

        Requests.AttemptToolDrop:FireServer(Tool:GetAttribute("U_ID"), 1)
    end

    table.insert(p1.Connections, v17:BindAction("Drop Tool", f18))

    local v19 = ControlsService

    local function f20() --[[ Line: 448 | Upvalues: Requests (ref) ]]
        Requests.WorldPortal:FireServer()
    end

    table.insert(p1.Connections, v19:BindAction("World Portal", f20))

    local v21 = ControlsService

    local function f22() --[[ Line: 452 | Upvalues: Requests (ref) ]]
        Requests.RedCounter:FireServer()
    end

    table.insert(p1.Connections, v21:BindAction("Counter", f22))

    local v23 = ControlsService

    local function f24() --[[ Line: 456 | Upvalues: Requests (ref) ]]
        Requests.UseMask:FireServer()
    end

    table.insert(p1.Connections, v23:BindAction("Mini Form", f24))

    local v25 = ControlsService

    local function f26() --[[ Line: 460 | Upvalues: v4 (ref), Requests (ref) ]]
        if v4.Race == "Hollow" then
            Requests.AttemptEvolve:FireServer()
        else
            Requests.Meditate:FireServer()
        end
    end

    table.insert(p1.Connections, v25:BindAction("Meditate", f26))

    local v27 = ControlsService

    local function f28() --[[ Line: 468 | Upvalues: v5 (ref), Requests (ref) ]]
        Requests.UpdateSettings:InvokeServer("Lethal Blows", not v5.Settings["Lethal Blows"])
    end

    table.insert(p1.Connections, v27:BindAction("LethalBlowsToggle", f28))

    local v29 = ControlsService

    local function f30() --[[ Line: 474 | Upvalues: p1 (copy), Requests (ref) ]]
        if not p1.StatusFolder:FindFirstChild("Clashing") then
            Requests.Combat:FireServer("ToggleWeapon")
        end
    end

    table.insert(p1.Connections, v29:BindAction("Equip Weapon", f30))

    local v31 = ControlsService

    local function f32() --[[ Line: 479 | Upvalues: Requests (ref) ]]
        Requests.Grip:FireServer(SelectedGripTarget)
    end

    table.insert(p1.Connections, v31:BindAction("Execute", f32))

    local v33 = ControlsService

    local function f34() --[[ Line: 483 | Upvalues: Requests (ref) ]]
        Requests.Maim:FireServer(SelectedGripTarget)
    end

    table.insert(p1.Connections, v33:BindAction("Maim", f34))

    local v35 = ControlsService

    local function f36() --[[ Line: 487 | Upvalues: Requests (ref) ]]
        Requests.CapeThrow:FireServer()
    end

    table.insert(p1.Connections, v35:BindAction("Cape Throw", f36))

    local v37 = ControlsService

    local function f38() --[[ Line: 491 | Upvalues: p1 (copy), ControlsService (ref), v6 (ref), NetworkManager (ref) ]]
        p1.HoldingLightAttack = true

        local v1 = nil

        for v2, v3 in next, p1.StatusTbl do
            if v3.Name == "ActiveRadialPrompt" then
                v1 = v3

                break
            end
        end

        if v1 then
            return
        end

        if p1.Character:FindFirstChildOfClass("Tool") then
            return
        end

        if not (ControlsService:AreBindsEqual(ControlsService:GetActionInfo("Light Attack").KeyboardBinds, { "MouseButton::MouseButton1" }) and (v6.Target and v6.Target:FindFirstChildOfClass("ClickDetector"))) then
            NetworkManager:FireServer("LightAttack", true, p1:IsHoldingSprint())
        end
    end

    table.insert(p1.Connections, v37:BindAction("Light Attack", f38))

    local v39 = ControlsService

    local function f40() --[[ Line: 502 | Upvalues: Shared (ref), Requests (ref) ]]
        Requests.SquadPing:FireServer((Shared.GetMouseInfo()))
    end

    table.insert(p1.Connections, v39:BindAction("Squad Ping", f40))

    local v41 = ControlsService

    local function f42() --[[ Line: 507 | Upvalues: ControlsService (ref), Requests (ref) ]]
        if ControlsService:IsActionHeld("Ability") then
            Requests.UseAbility:FireServer(1)

            return "Sink"
        end
    end

    table.insert(p1.Connections, v41:BindAction("Ability1", f42))

    local v43 = ControlsService

    local function f44() --[[ Line: 515 | Upvalues: ControlsService (ref), Requests (ref) ]]
        if ControlsService:IsActionHeld("Ability") then
            Requests.UseAbility:FireServer(2)

            return "Sink"
        end
    end

    table.insert(p1.Connections, v43:BindAction("Ability2", f44))

    local v45 = ControlsService

    table.insert(p1.Connections, v45:BindInput({ "GamepadButton::ButtonB" }, function() --[[ Line: 522 | Upvalues: p1 (copy) ]]
        if p1.Character:FindFirstChildOfClass("Tool") then
            p1.Character.Humanoid:UnequipTools()

            return "Sink"
        end
    end))

    local v46 = ControlsService

    local function f47() --[[ Line: 529 | Upvalues: NetworkManager (ref), p1 (copy) ]]
        NetworkManager:FireServer("LightAttack", false)
        p1.HoldingLightAttack = false
    end

    table.insert(p1.Connections, v46:BindActionRelease("Light Attack", f47))

    local v48 = ControlsService

    table.insert(p1.Connections, v48:BindActionRelease("Power Down", function() --[[ Line: 534 | Upvalues: p1 (copy) ]]
        p1.CharacterRemotes.ChangeOutput:FireServer(-1, false)
    end))

    local v49 = ControlsService

    table.insert(p1.Connections, v49:BindActionRelease("Power Up", function() --[[ Line: 538 | Upvalues: p1 (copy) ]]
        p1.CharacterRemotes.ChangeOutput:FireServer(1, false)
    end))

    local v50 = ControlsService

    local function f51() --[[ Line: 542 | Upvalues: Requests (ref) ]]
        Requests.Combat:FireServer("Block", false)
    end

    table.insert(p1.Connections, v50:BindActionRelease("Block", f51))

    local v522 = ControlsService

    local function f53() --[[ Line: 546 | Upvalues: p1 (copy), Shared (ref), Requests (ref) ]]
        local v1

        if p1.StatusUI.Container.TransformBar.Visible then
            p1.StatusUI.Container.TransformBar.Visible = false
            v1 = true
        else
            v1 = false
        end

        if p1.StatusUI_TransformTween then
            p1.StatusUI_TransformTween:Cancel()
        end

        local v2 = os.clock() - p1.LastAbilityTriggerPress
        local v3 = if Shared.HasEffect(p1.Character, "SecondModeProgress") then 2 else 0

        if v2 < 0.15 then
            v3 = nil
        end

        if (not (v2 > 0.75) or (not v1 or v3 == nil)) and not (v2 < 0.15) then
            return
        end

        Requests.FastWeaponRelease:FireServer(nil, v3)
    end

    table.insert(p1.Connections, v522:BindActionRelease("Form Activation", f53))

    local v54 = ControlsService

    local function f55() --[[ Line: 575 | Upvalues: p1 (copy), ControlsService (ref), v6 (ref), UserInputService (ref), Shared (ref), LocalPlayer (ref), Requests (ref) ]]
        if os.clock() - 0 < 0.15 then
            return
        end

        if p1.LastHeavyAttackPress ~= nil and os.clock() - p1.LastHeavyAttackPress > 0.5 then
            return
        end

        p1.LastHeavyAttackPress = nil

        if p1.Character:FindFirstChildOfClass("Tool") then
            return
        end

        if ControlsService:GetControlMode() == "Keyboard" then
            local v1 = ControlsService:GetActionInfo("Block")
            local v2 = ControlsService:GetActionInfo("Heavy Attack")

            if ControlsService:AreBindsEqual(v1.KeyboardBinds, { "MouseButton::MouseButton2" }) and (v6.Target ~= nil and v6.Target:FindFirstChildOfClass("ClickDetector")) then
                return
            end

            if ControlsService:AreBindsEqual(v2.KeyboardBinds, { "MouseButton::MouseButton2" }) and UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
                return
            end
        end

        if p1:IsHoldingSprint() and (Shared.HasSkill(LocalPlayer, "Aerial Fighter") and (p1.LastSpacePress == nil or os.clock() - p1.LastSpacePress > 0.11)) then
            Requests.Combat:FireServer("AirLauncher", true)
        else
            Requests.Combat:FireServer("HeavyAttack", true)
        end
    end

    table.insert(p1.Connections, v54:BindActionRelease("Heavy Attack", f55))

    local v56 = ControlsService

    local function f57() --[[ Line: 598 | Upvalues: p1 (copy), Requests (ref) ]]
        if p1.LastFastMovementRelease < p1.LastFastMovementHold then
            p1.TargetInfo.Active = false
        end

        if not (os.clock() - p1.LastFastMovementHold <= 0.225) then
            p1.LastFastMovementRelease = os.clock()

            return
        end

        Requests.FlashStep:FireServer()
        p1.LastFastMovementRelease = os.clock()
    end

    table.insert(p1.Connections, v56:BindActionRelease("Fast Movement", f57))

    local v58 = ControlsService

    local function f59() --[[ Line: 609 | Upvalues: Sensing (ref) ]]
        Sensing:EndSense()
    end

    table.insert(p1.Connections, v58:BindActionRelease("Sense", f59))

    local v60 = ControlsService

    table.insert(p1.Connections, v60:BindActionRelease("Jump", function() --[[ Line: 613 | Upvalues: p1 (copy) ]]
        p1:SpaceActionEnd()
    end))

    local v61 = ControlsService

    local function f62() --[[ Line: 617 | Upvalues: ControlsService (ref), p1 (copy) ]]
        if ControlsService:GetControlMode() == "Gamepad" or p1.Sprinting then
            return
        end

        p1:StopRunning(true)
    end

    table.insert(p1.Connections, v61:BindActionRelease("Sprint", f62))
end
function t.EndSprint(p1) --[[ EndSprint | Line: 627 | Upvalues: ClientEffects (copy) ]]
    p1.Sprinting = false

    local Sprinting = p1.StatusFolder:FindFirstChild("Sprinting")

    if not Sprinting then
        return
    end

    script.SprintLoop:Stop()
    ClientEffects.SprintEffect({
        State = false,
        Character = p1.Character
    })
    p1.SprintEffect = false
    Sprinting:Destroy()
end
function t.StopRunning(p1, p2) --[[ StopRunning | Line: 644 | Upvalues: UserInputService (copy), UserGameSettings (copy) ]]
    p1.Running = false
    p1:EndSprint()

    if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
        UserGameSettings.RotationType = Enum.RotationType.CameraRelative
    end

    local v1 = if p2 then 0.35 else nil

    if p1.RunAnimations and #p1.RunAnimations > 0 then
        for v2, v3 in next, p1.RunAnimations do
            v3:Stop(v1)
        end

        p1.RunAnimations = {}
    end

    local Running = p1.StatusFolder:FindFirstChild("Running")

    if not Running then
        return
    end

    Running:Destroy()
end
function t.CleanUp(p1) --[[ CleanUp | Line: 671 ]]
    if p1.Connections ~= nil then
        for v1, v2 in next, p1.Connections do
            v2:Disconnect()
        end
    end

    if p1.Debris then
        for v3, v4 in next, p1.Debris do
            v4:Destroy()
        end
    end

    if not p1.AirWalkController then
        return
    end

    p1.AirWalkController:Destroy()
end

local t6 = {
    Passive = Color3.fromRGB(99, 221, 255),
    CombatRelated = Color3.fromRGB(255, 185, 64),
    MovementRelated = Color3.fromRGB(106, 255, 143)
}

function t.AddStatusCooldown(p1, p2, p3, p4) --[[ AddStatusCooldown | Line: 695 | Upvalues: t6 (copy), TweenService (copy), Shared (copy) ]]
    local Cooldowns = p1.StatusUI.Container.Cooldowns
    local v1 = Cooldowns.CooldownTemplate:Clone()

    v1.TextLabel.Text = table.concat(string.split(string.upper(p2)), " ")
    v1.Visible = true
    v1.Name = p2

    local v3 = if p4 then t6[p4] else nil

    if v3 then
        v1.Bar.BackgroundColor3 = v3
    end

    v1.Parent = Cooldowns
    Cooldowns.Size = UDim2.new(Cooldowns.Size.X.Scale, Cooldowns.Size.X.Offset, 0, Cooldowns.UIListLayout.AbsoluteContentSize.Y)

    local v4 = p3 or 0.45

    TweenService:Create(v1.Bar, TweenInfo.new(v4, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()
    Shared.AddItemToDebris(v1, v4)
    task.delay(v4, function() --[[ Line: 727 | Upvalues: Cooldowns (copy) ]]
        Cooldowns.Size = UDim2.new(Cooldowns.Size.X.Scale, Cooldowns.Size.X.Offset, 0, Cooldowns.UIListLayout.AbsoluteContentSize.Y)
    end)
end
function t.UpdateRunningAnimations(p1) --[[ UpdateRunningAnimations | Line: 737 | Upvalues: Shared (copy) ]]
    if not p1.Running then
        return
    end

    for v1, v2 in next, p1.RunAnimations do
        v2:Stop(0.35)
    end

    local v3, v4 = Shared.ApplyRunAnimations(p1.Character, p1.Sprinting)

    p1.RunAnimations = v3
    p1.RunAnimationSpeed = v4
end
function t.Init(p1) --[[ Init | Line: 746 | Upvalues: TargetCircle (copy), KnockedPrompt (copy), Sensing (copy), ContextActionService (copy), v4 (copy), SharedAssets (copy), Shared (copy), LocalPlayer (copy), SharedModules (copy), PlaceIds (copy), v3 (copy), CollectionService (copy), Requests (copy), CooldownListener (copy), AttackService (copy), NetworkManager (copy), RunService (copy) ]]
    print("Starting CharacterManager")
    p1.Root = p1.Character:WaitForChild("HumanoidRootPart")
    p1.Humanoid = p1.Character:WaitForChild("Humanoid")
    p1.Animator = p1.Humanoid:WaitForChild("Animator")
    p1.CharacterRemotes = p1.Character:WaitForChild("CharacterHandler"):WaitForChild("Remotes")
    p1.Torso = p1.Character:FindFirstChild("Torso")
    p1.LowerMiddle = p1.Character:FindFirstChild("LowerMiddle")
    coroutine.wrap(function() --[[ Line: 758 | Upvalues: p1 (copy) ]]
        p1.Root:WaitForChild("Running").Volume = 0
    end)()
    TargetCircle.Enabled = false
    KnockedPrompt.Enabled = false
    Sensing:Reset()
    ContextActionService:UnbindAction("jumpAction")
    p1.Connections = {}
    p1.Debris = {}
    p1.LastHollowObscureUpdate = 0
    p1.LastZoomConstraintHitboxCheck = 0
    p1.HollowObscureHighlight = {}
    p1.CanStrafe = true

    if v4.Race == "Hollow" and v4.HollowModel.HollowStage ~= "VastoLorde" then
        p1.HollowType = v4.HollowModel.BaseModel

        if v4.HollowModel.HollowStage == "Menos" then
            p1.HollowType = "Menos"
        end

        local StrafeAnimations = SharedAssets.Animations.StrafeAnimations

        if p1.HollowType and SharedAssets.Animations.HollowAnimations[p1.HollowType]:FindFirstChild("StrafeAnimations") == nil then
            p1.CanStrafe = false
            require(script.HollowAnimation)(p1.Character)
        else
            p1.CoreIdle = Shared.PlayAnim(SharedAssets.Animations.HollowAnimations[p1.HollowType].Idle, p1.Humanoid, {
                priority = "Core"
            })
        end
    end

    p1.CurrentTilt = CFrame.new()
    p1.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    p1.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    p1.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    p1.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    p1.InAir = false
    p1.InAirTime = 0
    p1.Animations = {
        KnockedIdle = p1.Humanoid.Animator:LoadAnimation(SharedAssets.Animations.KnockedIdle),
        KnockedMove = p1.Humanoid.Animator:LoadAnimation(SharedAssets.Animations.KnockedMove),
        Falling = p1.Humanoid.Animator:LoadAnimation(SharedAssets.Animations.HumanoidFalling),
        Freefalling = p1.Humanoid.Animator:LoadAnimation(SharedAssets.Animations.HumanoidFreefall)
    }
    p1.Animations.Falling.Priority = Enum.AnimationPriority.Movement

    local function checkObject(p1) --[[ checkObject | Line: 813 ]]
        if not (p1:IsA("BodyAngularVelocity") or (p1:IsA("VectorForce") or (p1:IsA("BodyThrust") or (p1:IsA("RocketPropulsion") or (p1:IsA("Torque") or (p1:IsA("HingeConstraint") or (p1:IsA("CylindricalConstraint") or p1:IsA("PrismaticConstraint")))))))) then
            return
        end

        require(game.ReplicatedStorage.SharedModules.NetworkManager):FireServer("ProcessDamage", 4)
    end

    for i, v in ipairs({ p1.Root, p1.Torso, p1.Character:FindFirstChild("Head") }) do
        if v then
            v.ChildAdded:Connect(checkObject)
        end
    end

    p1.Animations.Freefalling.Priority = Enum.AnimationPriority.Action
    p1.Character:GetAttributeChangedSignal("WeaponStance"):Connect(function() --[[ Line: 816 | Upvalues: p1 (copy) ]]
        p1:ClearIdleAnimations()
    end)
    p1.HakudaIdle = nil
    p1.StandingIdle = nil
    p1.CurrentWeaponType = nil
    p1.MouseHoverer = script:WaitForChild("MouseHoverer"):Clone()
    p1.MouseHoverer.Parent = LocalPlayer.PlayerGui
    table.insert(p1.Debris, p1.MouseHoverer)
    p1.LastRun = 0
    p1.Running = false
    p1.Moving = false
    p1.Sprinting = false
    p1.Freefalling = false
    p1.SprintEffect = nil
    p1.StrafeInfo = {
        Animations = {}
    }
    p1.RunAnimations = {}
    p1.RunAnimationSpeed = nil
    p1.DoubleJumped = false
    p1.LastDoubleJump = 0
    p1.Dashing = false
    p1.LastSpacePress = 0
    p1.LastDropCancel = 0
    p1.LastJump = 0
    p1.LastAbilityTriggerPress = 0
    p1.LastFastMovementHold = 0
    p1.LastFastMovementRelease = 0
    p1.AirWalkController = require(SharedModules:WaitForChild("AirWalkController")).new(p1.Character)
    p1.OriginalRootC0 = p1.Root:FindFirstChild("RootJoint") and p1.Root.RootJoint.C0
    p1.TargetInfo = {
        Active = false,
        Range = 0
    }
    p1.bloodStep = nil
    p1.bloodStepController = 0
    p1.cloakAnim = nil
    p1.currentCloak = nil
    p1.LastFootstep = os.clock()
    p1.FootstepDir = 1
    p1.DashPrepared = false
    p1.SprintEffectEnabled = false
    p1.LastYPosition = nil
    p1.StunIteration = 0
    p1.TargetIteration = 0
    p1.LastKnockedCheck = 0
    p1.SlopeUpdateCount = 0
    p1.InteractPromptTween = nil
    p1.MissionsVisible = false
    p1.LastStunUpdate = 0
    p1.LastGameLoop = 0
    p1.LastHoldAttackCheck = 0
    p1.LastPlayerThemeUpdate = 0
    p1.SpiritualPressureCooldowns = {}
    p1.StatusFolder = p1.Character:WaitForChild("Status")
    p1.SelectedGripTarget = nil

    local v2 = next
    local v32, v42 = game.Lighting:GetChildren()

    for v5, v6 in v2, v32, v42 do
        if v6.Name == "WoozyEffect" then
            v6:Destroy()
        end
    end

    table.insert(p1.Connections, p1.Humanoid.Running:Connect(function(p12) --[[ Line: 896 | Upvalues: p1 (copy) ]]
        p1.Moving = p12 > 1
    end))
    p1.StatusTbl = p1.StatusFolder:GetChildren()

    local t = { workspace.Living }

    if v4.InnerWorldType == "PillarSpire" and PlaceIds.Names[game.PlaceId] == "InnerWorld" then
        table.insert(t, workspace.Terrain)
    end

    v3.FilterDescendantsInstances = t

    local function CharacterChildAdded(p12) --[[ CharacterChildAdded | Line: 922 | Upvalues: p1 (copy), SharedAssets (ref) ]]
        if p12 == nil then
            return
        end

        if p12:IsA("Tool") then
            if p12:FindFirstChild("TargetRange") then
                p1.TargetInfo.Active = true
                p1.TargetInfo.Range = p12.TargetRange.Value
            end
        else
            if p12.Name ~= "_Cloak" and (p12.Name ~= "_Cape" or not p12:FindFirstChild("AnimationController")) then
                return
            end

            p1.currentCloak = p12

            if p1.cloakAnim then
                p1.cloakAnim:Stop()
                p1.cloakAnim:Destroy()
            end

            local CaptainCloakRun = SharedAssets.Animations.CaptainCloakRun

            if p12.Name == "_Cape" then
                CaptainCloakRun = SharedAssets.Animations.QuincyCapeDrag
            end

            local AnimationController = p12:FindFirstChild("AnimationController")

            if not AnimationController then
                return
            end

            p1.cloakAnim = AnimationController:LoadAnimation(CaptainCloakRun)
        end
    end

    local function CharacterChildRemoved(p12) --[[ CharacterChildRemoved | Line: 946 | Upvalues: p1 (copy) ]]
        if p1.Character:FindFirstChildOfClass("Tool") then
            return
        end

        p1.TargetInfo.Active = false
        p1.TargetInfo.Range = 0
    end

    CharacterChildAdded(p1.Character:FindFirstChild("_Cloak") or p1.Character:FindFirstChild("_Cape"))
    table.insert(p1.Connections, p1.Character.ChildAdded:Connect(CharacterChildAdded))
    table.insert(p1.Connections, p1.Character.ChildRemoved:Connect(CharacterChildRemoved))

    local function f8(p12) --[[ Line: 957 | Upvalues: p1 (copy), Shared (ref), SharedAssets (ref), CollectionService (ref), LocalPlayer (ref) ]]
        p1.LastJump = os.clock()

        if not p1.Running then
            Shared.PlayAnim(SharedAssets.Animations.HumanoidJump, p1.Humanoid, {
                priority = "Action",
                speed = 1.25
            })
        end

        if not (CollectionService:HasTag(LocalPlayer, "InCombat") and p12) then
            return
        end

        Shared.AddEffect(p1.Character, "DisableJump", 1)
    end

    table.insert(p1.Connections, p1.Humanoid.Jumping:Connect(f8))
    table.insert(p1.Connections, Requests.AirwalkController_ServerUpdate.OnClientEvent:Connect(function(p12, p2) --[[ Line: 970 | Upvalues: p1 (copy) ]]
        if p1.AirWalkController == nil then
            return
        end

        p1.AirWalkController[p12](p1.AirWalkController, p2)
    end))
    table.insert(p1.Connections, p1.Character.Destroying:Connect(function() --[[ Line: 976 | Upvalues: p1 (copy) ]]
        p1:CleanUp()
    end))
    table.insert(p1.Connections, CooldownListener:ListenForCooldown(function(p12, p2, p3, p4) --[[ Line: 980 | Upvalues: p1 (copy) ]]
        if not p3 then
            return
        end

        p1:AddStatusCooldown(p12, p2, p4)
    end))
    table.insert(p1.Connections, CooldownListener:ListenForCooldownDestroyed(function(p12) --[[ Line: 986 | Upvalues: p1 (copy) ]]
        local v1 = p1.StatusUI.Container.Cooldowns:FindFirstChild(p12)

        if not v1 then
            return
        end

        v1:Destroy()
    end))

    local function f11(p12) --[[ Line: 993 | Upvalues: p1 (copy), PlaceIds (ref), CollectionService (ref), AttackService (ref) ]]
        table.insert(p1.StatusTbl, p12)

        local v1 = if PlaceIds.Names[game.PlaceId] == "Tournament" then not CollectionService:HasTag(p1.Character, "TournamentPlayer") else false

        if not (AttackService.CanAttack(p1.Character, nil, { "AttackingRunnable" }) or (v1 or AttackService.CanAdventure(p1.Character, nil, { "AttackingRunnable" }))) then
            p1:StopRunning()
        end

        if p12.Name == "Knocked" or (p12.Name == "NoAirwalk" or p12.Name == "Ragdoll") then
            p1.AirWalkController:ToggleFlight(false)
        end

        if p12.Name == "Knocked" and (p1.Animations.KnockedIdle.IsPlaying == false and not p1.StatusFolder:FindFirstChild("Maimed")) then
            p1.Animations.KnockedIdle:Play()
        end

        if p12.Name ~= "WeaponEquipped" then
            return
        end

        p1:UpdateRunningAnimations()
    end

    table.insert(p1.Connections, p1.StatusFolder.ChildAdded:Connect(f11))
    table.insert(p1.Connections, p1.StatusFolder.ChildRemoved:Connect(function(p12) --[[ Line: 1014 | Upvalues: p1 (copy) ]]
        table.remove(p1.StatusTbl, table.find(p1.StatusTbl, p12))

        if p12.Name == "Running" then
            p1:StopRunning()
        end

        if p12.Name == "WeaponEquipped" then
            p1:UpdateRunningAnimations()
        end

        if p1.StatusFolder:FindFirstChild("Knocked") and not p1.StatusFolder:FindFirstChild("Maimed") or not p1.Animations.KnockedIdle.IsPlaying then
            return
        end

        p1.Animations.KnockedIdle:Stop(0.2)
        p1.Animations.KnockedMove:Stop()
    end))

    local OnClientEvent2 = NetworkManager:GetEvent("ClearBodyMovers").OnClientEvent

    local function f12() --[[ Line: 1037 | Upvalues: Shared (ref), p1 (copy) ]]
        Shared.ClearBodyMovers(p1.Character)
    end

    table.insert(p1.Connections, OnClientEvent2:Connect(f12))

    local OnClientEvent3 = NetworkManager:GetEvent("KnockbackUpdate").OnClientEvent

    local function f13(p1) --[[ Line: 1041 | Upvalues: Shared (ref) ]]
        Shared.KnockbackUpdate(p1)
    end

    table.insert(p1.Connections, OnClientEvent3:Connect(f13))

    local OnClientEvent4 = NetworkManager:GetEvent("DestroyKnockback").OnClientEvent

    table.insert(p1.Connections, OnClientEvent4:Connect(function(p12) --[[ Line: 1044 | Upvalues: p1 (copy) ]]
        local v1 = p1.Root:FindFirstChild("Knockback_" .. tostring(p12))

        if not v1 then
            return
        end

        v1:Destroy()
    end))
    table.insert(p1.Connections, RunService.Heartbeat:Connect(function(...) --[[ Line: 1052 | Upvalues: p1 (copy) ]]
        debug.profilebegin("CharacterManager")
        p1:Update(...)
        debug.profileend()
    end))
    p1.StatusUI = SharedAssets.CharacterStatus:Clone()
    p1.StatusUI.Parent = p1.Root
    p1:CreateInputListeners()
end
function t.Dash(p1, p2) --[[ Dash | Line: 1067 | Upvalues: v4 (copy), DashInfo (copy), Requests (copy), SharedAssets (copy), HollowTypes (copy), RunService (copy) ]]
    if v4.Race == "Hollow" and v4.HollowModel.HollowStage == "Menos" then
        return
    end

    local DashVelocity = DashInfo.DashVelocity
    local DashDuration = DashInfo.DashDuration
    local v1 = nil
    local v2 = nil
    local v3 = nil

    for v42, v5 in next, p1.StatusTbl do
        if v5.Name == "SwiftFakeout" then
            v3 = v5

            break
        end
    end

    if v3 then
        DashVelocity = DashVelocity + 32
    end

    local v6 = DashInfo.DirectionalInfo[p2]

    if v6 then
        v1 = v6.Vector
        v2 = v6.Speed * DashVelocity
    end

    if not (v1 and v2) then
        return
    end

    local v7, v8 = Requests.Dash:InvokeServer(v1, v2)

    if not v7 then
        return
    end

    if v8 ~= "Default" then
        return
    end

    if not p1.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    if p1.Root:FindFirstChildOfClass("BodyVelocity") then
        return
    end

    p1:StopRunning()

    local v9 = p1.Humanoid.Animator:LoadAnimation(SharedAssets.Animations["Dash" .. p2])
    local v10 = nil

    for v11, v12 in next, p1.StatusTbl do
        if v12.Name == "DodgeOverride" then
            v10 = v12

            break
        end
    end

    if v10 then
        v9.Priority = Enum.AnimationPriority.Movement
    end

    v9:Play(0.1, 1, 1.2)
    Dashing = true

    local v13 = HollowTypes[v4.HollowModel.BaseModel]
    local v14

    if v4.Race == "Hollow" and v4.HollowModel.HollowStage ~= "VastoLorde" then
        if v13 then
            v2 = v2 * (v13.SpeedMultiplier or 1)
        end

        v14 = v13 and v13.MaxForce or 250000
    else
        v14 = 100000
    end

    local BodyVelocity = Instance.new("BodyVelocity")

    BodyVelocity.MaxForce = Vector3.new(v14, 0, v14)
    BodyVelocity.Parent = p1.Root
    game.Debris:AddItem(BodyVelocity, DashDuration)

    local _ = workspace.CurrentCamera.CFrame
    local v16 = RunService.Stepped:Connect(function() --[[ Line: 1119 | Upvalues: BodyVelocity (copy), p1 (copy), v1 (ref), v2 (ref) ]]
        BodyVelocity.Velocity = p1.Root.CFrame[v1] * v2
    end)
    local v17 = nil

    v17 = p1.Character.Status.ChildAdded:Connect(function(p1) --[[ Line: 1123 | Upvalues: v9 (copy), v17 (ref), BodyVelocity (copy) ]]
        if p1.Name ~= "Attacking" and p1.Name ~= "Stunned" then
            return
        end

        if p1.Value == "Dash" then
            return
        end

        v9:Stop()
        v17:Disconnect()

        if not BodyVelocity then
            return
        end

        BodyVelocity:Destroy()
    end)
    delay(DashDuration, function() --[[ Line: 1136 | Upvalues: v17 (ref), v16 (ref), BodyVelocity (copy) ]]
        Dashing = false
        v17:Disconnect()
        v16:Disconnect()

        if not BodyVelocity then
            return
        end

        BodyVelocity:Destroy()
    end)
end

local v12 = nil

function t.GetSlopeJoint(p1) --[[ GetSlopeJoint | Line: 1147 | Upvalues: v12 (ref) ]]
    local UpperMiddle = p1.Root:FindFirstChild("UpperMiddle")

    if UpperMiddle == nil then
        UpperMiddle = p1.Root:FindFirstChild("FrontTorso")
    end

    if UpperMiddle == nil then
        UpperMiddle = p1.Root:FindFirstChild("LowerMiddle")
    end

    if UpperMiddle ~= nil and v12 == nil then
        v12 = UpperMiddle.C0
    end

    return UpperMiddle, v12
end
function t.SlopeUpdate(p1, p2) --[[ SlopeUpdate | Line: 1163 | Upvalues: v2 (copy) ]]
    local v1, v22 = p1:GetSlopeJoint()

    if v1 == nil then
        return
    end

    p1.SlopeUpdateCount = p1.SlopeUpdateCount + p2

    if not (p1.SlopeUpdateCount >= 0.02) then
        return
    end

    local v5 = workspace:Raycast(p1.Root.Position, Vector3.new(0, -p1.Humanoid.HipHeight - p1.Root.Size.Y / 2 - 2, 0), v2)
    local v6

    if v5 and v5.Normal.Y >= 0.78 then
        local Normal = v5.Normal
        local v9 = p1.Root.CFrame:VectorToObjectSpace((Vector3.new(Normal.X, math.clamp(Normal.Y, 0.85, 1), Normal.Z)))

        v6 = v22 * CFrame.Angles(v9.z, 0, -v9.x)
    else
        v6 = nil
    end

    if v6 == nil then
        v6 = v22
    end

    v1.C0 = v1.C0:Lerp(v6, (math.min(p1.SlopeUpdateCount * 7.25, 1)))
    p1.SlopeUpdateCount = 0
end

local function GetClosestMultiple(p1, p2) --[[ GetClosestMultiple | Line: 1197 ]]
    if p1 < p2 and p1 > 0 then
        return p2
    end

    local v1 = p1 + p2 / 2

    return v1 - v1 % p2
end

function t.DefaultInnerWorldUpdate(p1) --[[ DefaultInnerWorldUpdate | Line: 1207 | Upvalues: PlaceIds (copy), t5 (copy), t4 (copy), Shared (copy), SharedAssets (copy), TweenService (copy), v10 (copy), t2 (copy), v3 (copy), LocalPlayer (copy), v11 (ref), UI (copy), ClientEffects (copy), t3 (copy), v1 (copy) ]]
    if PlaceIds:GetPlaceInfo().PlaceName ~= "InnerWorld" then
        return
    end

    local v12 = nil
    local v2 = nil

    for v32, v4 in next, t5 do
        if v4:GetAttribute("Finished") ~= true then
            local Magnitude = (v4:GetPivot().Position - p1.Root.Position).Magnitude

            if v12 == nil or Magnitude < v2 then
                v12 = v4
                v2 = Magnitude
            end

            if v4:GetAttribute("SpawnInEffect_Played") == nil then
                v4:SetAttribute("SpawnInEffect_Played", false)
                t4[v4] = {}

                local v5 = next
                local v6, v7 = v4:GetDescendants()

                for v8, v9 in v5, v6, v7 do
                    if v9:IsA("BasePart") then
                        t4[v4][v9] = { v9.Transparency, v9.Size }
                        v9.Transparency = 1
                        v9.Size = v9.Size * 0
                    end
                end
            end

            if Magnitude < 30 and t4[v4] ~= nil then
                v4:SetAttribute("SpawnInEffect_Played", true)
                Shared.PlaySound(SharedAssets.Sounds.BellSummon, v4.PrimaryPart)

                for v102, v112 in next, t4[v4] do
                    TweenService:Create(v102, v10, {
                        Size = v112[2],
                        Transparency = v112[1]
                    }):Play()
                end

                t4[v4] = nil
            end
        end
    end

    local Position = p1.Root.Position
    local X = Position.X
    local v122

    if X < 20 and X > 0 then
        v122 = 20
    else
        local v13 = X + 10

        v122 = v13 - v13 % 20
    end

    local Z = Position.Z
    local v14

    if Z < 20 and Z > 0 then
        v14 = 20
    else
        local v15 = Z + 10

        v14 = v15 - v15 % 20
    end

    local v16 = Vector2.new(v122, v14)
    local t6 = {}

    for v17, v18 in next, {
        [Vector2.new(0, 0)] = true,
        [Vector2.new(0, 1)] = true,
        [Vector2.new(1, 0)] = true,
        [Vector2.new(0, -1)] = true,
        [Vector2.new(-1, 0)] = true
    } do
        local v19 = v16 + v17 * 20

        table.insert(t6, v19)

        local v20 = false

        for v21, v22 in next, t2 do
            if v21 == v19 then
                v20 = true

                break
            end
        end

        if v20 == false then
            local v24 = workspace:Raycast(Vector3.new(v19.X, Position.Y, v19.Y), Vector3.new(0, -25, 0), v3)

            if v24 then
                local v25 = v24.Position + Vector3.new(0, Vector3.new(-9.5, -0.5, -9.5), 0)
                local v26 = SharedAssets.InnerWorldFloatingPart:Clone()

                v26.Size = Vector3.new(15.2, 0.8, 15.2)
                v26.Position = v25 + Vector3.new(0, -15, 0)
                v26.Transparency = 1
                v26.Anchored = true
                v26.CanCollide = false
                v26.Parent = workspace.Debris
                TweenService:Create(v26, v10, {
                    Transparency = 0.5,
                    Size = Vector3.new(19, 1, 19),
                    Position = v25
                }):Play()
                t2[v19] = v26
            end
        end
    end

    for v27, v28 in next, t2 do
        local v29 = false

        for v30, v31 in next, t6 do
            if v27 == v31 then
                v29 = true
            end
        end

        if not v29 and v28 ~= nil then
            TweenService:Create(v28, v10, {
                Transparency = 1,
                Position = v28.Position - Vector3.new(0, -15, 0),
                Size = v28.Size * 0.2
            }):Play()
            game.Debris:AddItem(v28, 0.3)
            t2[v27] = nil
        end
    end

    local v32

    if v12 then
        local Position2 = v12:GetPivot().Position

        v32 = CFrame.new(p1.Root.Position, Position2 * Vector3.new(1, 0, 1) + Vector3.new(0, p1.Root.Position.Y, 0)).LookVector
    else
        v32 = nil
    end

    if LocalPlayer:GetAttribute("InnerWorld_FinishedTrials") ~= nil and v11 == nil then
        v11 = os.clock()
        Shared.PlaySound(SharedAssets.Sounds.InnerWorldLeave, workspace, nil, true)
        UI.ScreenFade(false, 99, Color3.new(255/255, 255/255, 255/255), 10, 1)
        ClientEffects.Fire({
            Type = "ScreenShakeDT",
            Duration = 10,
            Intensity = 0,
            FinalIntensity = 6
        })
    end

    for v35, v36 in next, t3 do
        local v34
        local v37 = v36[1]
        local v38 = v36[2]

        if (v37.Position - Position).Magnitude > 125 then
            TweenService:Create(v37, v10, {
                Transparency = 1,
                Size = Vector3.new(0, 0, 0)
            }):Play()
            game.Debris:AddItem(v37, 0.3)
            table.remove(t3, v35)
        end

        if v11 == nil then
            local LookVector = CFrame.new(p1.Root.Position, v37.Position * Vector3.new(1, 0, 1) + Vector3.new(0, p1.Root.Position.Y, 0)).LookVector

            v34 = if v12 then if v12 == nil then false else v32:Dot(LookVector) > 0.825 else false

            if v36[3] == nil then
                local v43 = if v34 then TweenService:Create(v37, v10, {
    Color = Color3.new(0.2, 0.505882, 1)
}) else TweenService:Create(v37, v10, {
    Color = Color3.new(255/255, 255/255, 255/255)
})

                v36[3] = v43
                v43:Play()
                v43.Completed:Connect(function() --[[ Line: 1411 | Upvalues: v36 (copy), v43 (ref) ]]
                    v36[3] = nil
                    v43:Destroy()
                end)
            end

            continue
        end

        local v45 = math.clamp(os.clock() - v11, 0, 10)
        local v46 = v45 * 0.2
        local v47 = 1 - v45 / 10

        v37.Position = v38 + Vector3.new(v1:NextNumber(-v46, v46), v1:NextNumber(-v46, v46), v1:NextNumber(-v46, v46))
        v37.Color = Color3.new(v47, v47, v47)

        if v36[3] then
            v36[3]:Cancel()
            v36[3] = nil
        end
    end

    if #t3 < 25 then
        local v51 = SharedAssets.InnerWorldFloatingPart:Clone()

        v51.Size = Vector3.new(0, 0, 0)
        v51.Shape = "Ball"

        local Angles = CFrame.Angles
        local v53 = v1:NextNumber(0, 360)

        v51.CFrame = p1.Root.CFrame * Angles(0, math.rad(v53), 0) * CFrame.new(0, v1:NextNumber(-1, 22), v1:NextNumber(-125, -15))
        v51.Transparency = 1
        v51.Anchored = true
        v51.CanCollide = false
        v51.Parent = workspace.Debris

        local v54 = v1:NextNumber(0.5, 4)

        TweenService:Create(v51, v10, {
            Transparency = 0.1,
            Size = Vector3.new(v54, v54, v54)
        }):Play()
        table.insert(t3, { v51, v51.Position })
    end

    workspace.Map.InnerWorld.BottomPart.Position = Vector3.new(p1.Root.Position.X, workspace.Map.InnerWorld.BottomPart.Position.Y, p1.Root.Position.Z)
end
function t.InnerWorldUpdate(p1, p2) --[[ InnerWorldUpdate | Line: 1447 | Upvalues: v9 (ref) ]]
    if v9 ~= "DefaultInnerWorld" then
        return
    end

    p1:DefaultInnerWorldUpdate(p2)
end
function t.StrafingUpdate(p1, p2) --[[ StrafingUpdate | Line: 1453 | Upvalues: Shared (copy) ]]
    if p1.CanStrafe then
        Shared.StrafeUpdate(p1.Character, p1)
    end
end
function t.ToggleFreefall(p1, p2) --[[ ToggleFreefall | Line: 1476 | Upvalues: SharedAssets (copy) ]]
    if p1.Freefalling == p2 then
        return
    end

    p1.Freefalling = p2

    if p2 then
        p1:StopRunning()
        p1.FreefallingFX = {}

        local v1 = SharedAssets.FallingFX:Clone()
        local Weld = Instance.new("Weld")

        Weld.Part0 = p1.Root
        Weld.Part1 = v1
        Weld.C0 = CFrame.Angles(-1.5707963267948966, 0, 0)
        Weld.Parent = v1
        v1.Anchored = false
        v1.CanCollide = false
        v1.Parent = workspace.Debris
        table.insert(p1.FreefallingFX, v1)
        p1.Animations.Falling:Stop()
        p1.Animations.Freefalling:Play(0.4)

        local FreefallEffect = require(script.FreefallEffect)

        table.insert(p1.FreefallingFX, FreefallEffect(p1.Character))

        return
    end

    p1.Animations.Freefalling:Stop()

    if not p1.FreefallingFX then
        return
    end

    for v2, v3 in next, p1.FreefallingFX do
        v3:Destroy()
    end

    p1.FreefallingFX = {}
end
function t.GetTargetFOV(p1) --[[ GetTargetFOV | Line: 1516 | Upvalues: Sensing (copy), v4 (copy) ]]
    if p1.Character == nil or p1.Character.Parent == nil then
        return 70
    end

    if workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then
        return
    end

    local sum = 70 + p1.Root.Velocity.Magnitude * 0.25

    if Sensing.sensing then
        sum = sum + 10
    end

    if v4.ClientInteractions.RemedyQuestPanic then
        sum = sum - 5
    end

    if workspace.CurrentCamera:GetAttribute("MeditationMode") then
        sum = sum - 10
    end

    if p1.UIManager then
        if p1.UIManager.OpenWindow ~= nil then
            sum = sum - 10
        end

        if p1.UIManager.MeditationModeActive then
            sum = sum - 10
        end
    end

    if p1.Sprinting then
        sum = sum + 15
    end

    for v2, v3 in p1.StatusTbl do
        if v3.Name == "FOVChange" then
            sum = sum + v3.Value
        end
    end

    return sum
end
function t.UpdateFOV(p1, p2) --[[ UpdateFOV | Line: 1564 | Upvalues: Shared (copy) ]]
    local v1 = p1:GetTargetFOV()

    if v1 ~= nil then
        workspace.CurrentCamera.FieldOfView = Shared.Lerp(workspace.CurrentCamera.FieldOfView, v1, p2 * 2)
    end
end
function t.UpdateZoomConstraints(p1, p2) --[[ UpdateZoomConstraints | Line: 1571 | Upvalues: LocalPlayer (copy), RunService (copy), v5 (copy), Shared (copy) ]]
    local v1 = 7.5
    local v2 = 25.5
    local Character = LocalPlayer.Character

    if Character and (Character:GetAttribute("HollowStage") == "Menos" or RunService:IsStudio()) then
        v2 = 200
    elseif Character and (Character:GetAttribute("HollowStage") ~= "VastoLorde" and Character:GetAttribute("Race") == "Hollow") then
        v2 = 35
    end

    for v3, v4 in p1.StatusTbl do
        if v4.Name == "SetZoomConstraint" and v2 < v4.Value then
            v1 = v4.Value
            v2 = v4.Value
        end
    end

    if os.clock() - p1.LastZoomConstraintHitboxCheck > 0.5 and v5.Settings.NPCZoom then
        p1.LastZoomConstraintHitboxCheck = os.clock()
        p1.ZoomConstraintCheck_Value = 0

        if p1.Root then
            local _, v52 = Shared.MagHitbox(p1.Root.Position, 300, { p1.Character }, {
                IgnoreIFrame = true
            })

            for v6, v7 in v52 do
                local v8 = v7:GetAttribute("ZoomDistanceHitbox")

                if v8 ~= nil and not (v8 < (p1.Root.Position - v7:GetPivot().Position).Magnitude) then
                    local v9 = v7:GetAttribute("SetZoomDistance")

                    if v9 ~= nil and not (v9 < v2) then
                        p1.ZoomConstraintCheck_Value = v9
                    end
                end
            end
        end
    end

    if p1.ZoomConstraintCheck_Value and v2 < p1.ZoomConstraintCheck_Value then
        v1 = p1.ZoomConstraintCheck_Value
        v2 = p1.ZoomConstraintCheck_Value
    end

    local CameraMinZoomDistance = LocalPlayer.CameraMinZoomDistance
    local CameraMaxZoomDistance = LocalPlayer.CameraMaxZoomDistance

    if LocalPlayer:GetAttribute("InGarganta") then
        CameraMinZoomDistance = 3
        CameraMaxZoomDistance = 11.5
    end

    LocalPlayer.CameraMinZoomDistance = Shared.Lerp(CameraMinZoomDistance, v1, p2 * 5)
    LocalPlayer.CameraMaxZoomDistance = Shared.Lerp(CameraMaxZoomDistance, v2, p2 * 5)
end
function t.SetUIManager(p1, p2) --[[ SetUIManager | Line: 1635 ]]
    p1.UIManager = p2
end
function t.Update(p1, p2) --[[ Update | Line: 1639 | Upvalues: Sensing (copy), v4 (copy), HollowTypes (copy), LocalPlayer (copy), Shared (copy), UserInputService (copy), UserGameSettings (copy), ControlsService (copy), DashInfo (copy), CollectionService (copy), TargetCircle (copy), Requests (copy), v5 (copy), NetworkManager (copy), SoundService (copy), v2 (copy), v8 (ref), KnockedPrompt (copy), SharedAssets (copy), RunService (copy), PlaceIds (copy), ClientEffects (copy), StunHandler (copy) ]]
    Sensing:Update(p2)
    p1:UpdateFOV(p2)
    p1:UpdateZoomConstraints(p2)

    if p1.Character == nil or p1.Character.Parent == nil then
        return
    end

    if p1.Root == nil or p1.Root.Parent ~= p1.Character then
        return
    end

    local Torso = p1.Torso

    if Torso == nil then
        Torso = p1.LowerMiddle
    end

    if v4.Race == "Hollow" and (v4.HollowModel.HollowStage ~= "VastoLorde" and os.clock() - p1.LastHollowObscureUpdate > 0.125) then
        p1.LastHollowObscureUpdate = os.clock()

        if LocalPlayer:HasTag("InCombat") and HollowTypes[v4.HollowModel.BaseModel].OutlineViewer then
            local _, v22 = Shared.MagHitbox(p1.Character.HumanoidRootPart.Position, 16, { p1.Character }, {
                IgnoreIFrame = true,
                AllowDead = true
            })
            local t = {}

            for v3, v42 in next, v22 do
                if #workspace.CurrentCamera:GetPartsObscuringTarget({ workspace.CurrentCamera.CFrame.Position, v42.HumanoidRootPart.Position }, { workspace.Map, workspace.Debris }) > 0 then
                    t[v42] = true

                    if p1.HollowObscureHighlight[v42] == nil then
                        local v52 = script.HollowObscureHighlight:Clone()

                        v52.Parent = v42
                        v52.Enabled = true
                        p1.HollowObscureHighlight[v42] = v52
                    end

                    continue
                end

                if p1.HollowObscureHighlight[v42] ~= nil then
                    p1.HollowObscureHighlight[v42]:Destroy()
                    p1.HollowObscureHighlight[v42] = nil
                end
            end

            for v6, v7 in next, p1.HollowObscureHighlight do
                if not t[v6] then
                    v7:destroy()
                    p1.HollowObscureHighlight[v6] = nil
                end
            end
        else
            for v82, v9 in next, p1.HollowObscureHighlight do
                v9:Destroy()
                p1.HollowObscureHighlight[v82] = nil
            end
        end
    end

    if Torso then
        local v11 = Vector3.new(0, Torso.Position.Y - p1.Character.HumanoidRootPart.Position.Y, 0)
        local v12 = nil

        for v13, v14 in next, p1.StatusTbl do
            if v14.Name == "PauseCameraTracking" then
                v12 = v14

                break
            end
        end

        if v12 then
            v11 = Vector3.new(0, 0, 0)
        end

        if p1.TrackingEffect_LastCameraOffset == nil then
            p1.TrackingEffect_LastCameraOffset = Vector3.new()
        end

        p1.Character.Humanoid.CameraOffset = p1.TrackingEffect_LastCameraOffset:Lerp(v11, p2 * 7)
        p1.TrackingEffect_LastCameraOffset = p1.Character.Humanoid.CameraOffset
    end

    p1:StrafingUpdate(p2)

    if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
        UserGameSettings.RotationType = Enum.RotationType.MovementRelative
    end

    local DashPrepared = p1.DashPrepared

    p1.DashPrepared = false

    if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
        local v15 = ControlsService:GetControlMode()

        if v15 == "Keyboard" then
            for v16, v17 in next, DashInfo.DirectionalInfo do
                if v16 ~= "W" and UserInputService:IsKeyDown(Enum.KeyCode[v16]) then
                    p1.DashPrepared = true
                end
            end
        elseif v15 == "Gamepad" then
            local v18 = ControlsService:ThumbstickTo4D()

            for v19, v20 in next, DashInfo.DirectionalInfo do
                if v19 ~= "W" and v19 == v18 then
                    p1.DashPrepared = true
                end
            end
        end
    end

    if p1.DashPrepared then
        CollectionService:AddTag(p1.Character, "DashPrepared")
    else
        CollectionService:RemoveTag(p1.Character, "DashPrepared")
    end

    if TargetCircle.Enabled then
        local ImageLabel = TargetCircle.ImageLabel

        ImageLabel.Rotation = ImageLabel.Rotation + p2 * 80
    end

    if p1.Root.Position.Y <= workspace.FallenPartsDestroyHeight + 100 and p1.Character:HasTag("Loaded") then
        Requests.RequestRespawn:FireServer()
    end

    if p1.StatusFolder.Reiatsu.Value <= 0 then
        p1.AirWalkController:ToggleFlight(false)
    elseif p1.AirWalkController.Flying then
        local v21 = nil

        for v22, v23 in next, p1.StatusTbl do
            if v23.Name == "NoAirwalk" then
                v21 = v23

                break
            end
        end

        if v21 then
            p1.AirWalkController:ToggleFlight(false)
        end
    end

    if v4.Race == "Hollow" and v4.HollowStage ~= "VastoLorde" then
        p1:SlopeUpdate(p2)
    end

    if os.clock() - p1.LastGameLoop < 1 / 60 then
        return
    end

    p1.LastGameLoop = os.clock()

    if os.clock() - p1.LastHoldAttackCheck > 0.05 then
        p1.LastHoldAttackCheck = os.clock()

        if not ControlsService:IsActionHeld("Light Attack") and v5.Settings.HoldM1 then
            p1.HoldingLightAttack = false
        end

        if p1.HoldingLightAttack then
            NetworkManager:FireServer("LightAttack", true, p1:IsHoldingSprint())
        end
    end

    p1:InnerWorldUpdate(p2)

    if os.clock() - p1.LastPlayerThemeUpdate > 0.25 then
        p1.LastPlayerThemeUpdate = os.clock()

        local _, v24 = Shared.MagHitbox(p1.Character.HumanoidRootPart.Position, 250, { p1.Character }, {
            IgnoreIFrame = true,
            AllowDead = true
        })
        local v25 = nil
        local v26 = nil

        for v27, v28 in next, v24 do
            local v30 = math.max((v28:GetPivot().Position - p1.Root.Position).Magnitude - 13, 0)

            if CollectionService:HasTag(v28, "ThemeBuffActive") and (v25 == nil or v30 < v25) then
                v25 = v30
            end

            if CollectionService:HasTag(v28, "BossThemePlaying") and (v26 == nil or v30 < v26) then
                v26 = v30
            end
        end

        local v31 = 1
        local v32 = 1

        if v25 then
            v31 = v31 * (1 - (250 - v25) / 250)
        end

        if v26 then
            local v33 = 1 - (250 - v26) / 250

            v31, v32 = v31 * v33, v33
        end

        SoundService.SoundGroup_Main.MusicGroup.Music.Volume = v31
        SoundService.SoundGroup_Main.MusicGroup.PlayerThemes.Volume = v32
    end

    local v34 = workspace:Raycast(p1.Root.Position, Vector3.new(0, -4.5, 0), v2)

    if v34 and (v34.Instance.CanCollide == false and not v34.Instance:IsA("SpawnLocation")) then
        v34 = nil
    end

    local InAir = p1.InAir
    local v35 = p1.Humanoid:GetState()

    p1.InAir = if v35 == Enum.HumanoidStateType.Freefall or v35 == Enum.HumanoidStateType.Jumping then p1.Character:HasTag("Loaded") else false

    if p1.InAir ~= InAir or p1.AirWalkController.Flying then
        p1.InAirTime = 0
    end

    if p1.InAir and p1.Root.Velocity.Y <= -0.2 then
        p1.InAirTime = p1.InAirTime + p2
    end

    if p1.InAirTime >= 12.5 then
        p1.InAirTime = 0
        Requests.RequestRespawn:FireServer()
    end

    p1:ToggleFreefall(if p1.InAirTime >= 0.37 then true else false)

    if p1.AirWalkController.Flying then
        p1.InAir = true
    elseif p1.InAir and (not p1.Freefalling and p1.Animations.Falling.IsPlaying == false) then
        local v38 = nil

        for v39, v40 in next, p1.StatusTbl do
            if v40.Name == "SpawnForcefield" then
                v38 = v40

                break
            end
        end

        if not (v38 or (p1.AirWalkController.Flying or p1.Running)) then
            p1.Animations.Falling:Play()
        end
    end

    p1:RunningUpdate(p2)

    local Magnitude = (p1.Root.Velocity * Vector3.new(1, 0, 1)).Magnitude

    if p1.Animations.KnockedIdle.IsPlaying then
        if Magnitude >= 2 then
            if p1.Animations.KnockedMove.IsPlaying == false then
                p1.Animations.KnockedMove:Play(0.05)
            end
        elseif p1.Animations.KnockedMove.IsPlaying == true then
            p1.Animations.KnockedMove:Stop(0.05)
        end
    end

    p1:UpdateIdle()

    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local v41 = nil

        for v42, v43 in next, p1.StatusTbl do
            if v43.Name == "CanFeint" then
                v41 = v43

                break
            end
        end

        if v41 then
            Requests.Combat:FireServer("Feint")
        end
    end

    if os.clock() - p1.TargetIteration > 0.05 then
        p1.TargetIteration = os.clock()

        if p1.TargetInfo.Active then
            local v44 = p1.TargetInfo.Active and Shared.GetNearestModel(p1.TargetInfo.Range)

            if v44 then
                pcall(function() --[[ Line: 1901 | Upvalues: TargetCircle (ref), v44 (copy) ]]
                    TargetCircle.Adornee = v44.PrimaryPart or v44.HumanoidRootPart
                    TargetCircle.Enabled = true
                end)
            else
                TargetCircle.Adornee = nil
                TargetCircle.Enabled = false
            end
        else
            TargetCircle.Adornee = nil
            TargetCircle.Enabled = false
        end
    end

    if os.clock() - p1.LastKnockedCheck > 0.15 then
        p1.LastKnockedCheck = os.clock()

        local v45 = (1 / 0)
        local v46 = nil

        for v47, v48 in next, v8 do
            if v48 ~= p1.Character then
                local Magnitude2 = (v48:GetPivot().Position - p1.Root.Position).Magnitude

                if Magnitude2 < v45 and (Magnitude2 < 6 and (Shared.HasEffect(v48, "Knocked") and (not Shared.HasEffect(v48, "BeingGripped") and v48.Humanoid.Health > 0))) then
                    v45 = Magnitude2
                    v46 = v48
                end
            end
        end

        if v46 and (v4.Race ~= "Hollow" or v4.HollowModel.HollowStage == "VastoLorde") then
            SelectedGripTarget = v46

            if Shared.HasEffect(v46, "Maimed") then
                KnockedPrompt.MaimPrompt.TextColor3 = Color3.fromRGB(109, 109, 109)
                KnockedPrompt.MaimDescription.TextColor3 = Color3.fromRGB(109, 109, 109)
            else
                KnockedPrompt.MaimPrompt.TextColor3 = KnockedPrompt.ExecutePrompt.TextColor3
                KnockedPrompt.MaimDescription.TextColor3 = KnockedPrompt.ExecuteDescription.TextColor3
            end

            KnockedPrompt.ExecutePrompt.Text = ControlsService:GetDisplayNameOfBind("Execute")
            KnockedPrompt.MaimPrompt.Text = ControlsService:GetDisplayNameOfBind("Maim")
            KnockedPrompt.Adornee = v46.PrimaryPart or v46.HumanoidRootPart
            KnockedPrompt.Enabled = true
        else
            SelectedGripTarget = nil
            KnockedPrompt.Enabled = false
        end
    end

    if p1.InAir and not p1.AirWalkController.Flying then
        if p1.Running and not p1.AirWalkController.Flying then
            for v51, v52 in next, p1.RunAnimations do
                v52:AdjustSpeed(p1.RunAnimationSpeed * 0.3)
            end
        end
    elseif p1.Running then
        local v53 = if p1.Sprinting then 1.4 else 1

        for v54, v55 in next, p1.RunAnimations do
            v55:AdjustSpeed(v53 * p1.RunAnimationSpeed)
        end
    end

    if p1.InAir and not p1.AirWalkController.Flying then
        if p1.Running then
            p1.Animations.Falling:Stop()
        end
    elseif p1.Animations.Falling.IsPlaying or p1.Running then
        p1.Animations.Falling:Stop()
    end

    if CollectionService:HasTag(p1.Character, "Loaded") and (v4.Race ~= "Hollow" or v4.HollowModel.HollowStage ~= "Menos") then
        if p1.LastYPosition == nil then
            p1.LastYPosition = p1.Root.Position.Y
        end

        if p1.InAir then
            if p1.Root.Position.Y > p1.LastYPosition or p1.AirWalkController.Flying then
                p1.LastYPosition = p1.Root.Position.Y
            end
        else
            local falldistance = p1.LastYPosition - p1.Root.Position.Y

            if not Shared.HasEffect(p1.Character, "FallImmunity") and (falldistance > 17.5 and p1.Root.Velocity.Y < 6) then
                local FallLanding = SharedAssets.Animations.FallLanding

                if falldistance >= 90 and p1.HollowType ~= nil then
                    FallLanding = SharedAssets.Animations.SuperheroLand
                    Shared.AddEffect(p1.Character, "Immobile", 2)
                    Shared.AddEffect(p1.Character, "NoRotate", 2)
                    Shared.AddEffect(p1.Character, "Attacking", 2)
                end

                p1.Humanoid:LoadAnimation(FallLanding):Play()

                if RunService:IsStudio() or PlaceIds:GetPlaceInfo().PlaceName == "TestPlace" then
                    print("Fall distance: ", falldistance)
                end

                local v56 = Shared.HasEffect(p1.Character, "FlashStep")

                if v56 and (Shared.HasSkill(LocalPlayer, "Drop Cancel") and (falldistance <= 60 and os.clock() - p1.LastDropCancel > 8)) then
                    p1.LastDropCancel = os.clock()
                    v56:Destroy()
                    coroutine.wrap(ClientEffects.FallDashEffect)({
                        Character = p1.Character
                    })

                    local BodyVelocity = Instance.new("BodyVelocity")

                    BodyVelocity.MaxForce = Vector3.new(300000, 300000, 300000)
                    BodyVelocity.Velocity = p1.Root.CFrame.LookVector * 160
                    BodyVelocity.Parent = p1.Root
                    game.Debris:AddItem(BodyVelocity, 0.09)
                    task.delay(0.25, function() --[[ Line: 2016 | Upvalues: p1 (copy) ]]
                        p1.Root.Velocity = Vector3.new(0, 0, 0)
                    end)
                    Requests.FX_Server:FireServer({
                        Type = "FallDashEffect",
                        Character = p1.Character
                    })
                    p1:AddStatusCooldown("Drop Cancel", 8, "MovementRelated")
                else
                    if p1.SprintEffect then
                        ClientEffects.SprintEffect({
                            State = false,
                            Character = p1.Character
                        })
                        task.delay(0.5, function() --[[ Line: 2027 | Upvalues: p1 (copy), ClientEffects (ref) ]]
                            if p1.Sprinting then
                                p1.SprintEffect = ClientEffects.SprintEffect({
                                    State = true,
                                    Character = p1.Character
                                })
                            end
                        end)
                    end

                    local t = {
                        Type = "FallFX",
                        Character = p1.Character,
                        FallDistance = falldistance,
                        Position = p1.Character:GetPivot().Position
                    }

                    ClientEffects.Fire(t)
                    Requests.FX_Server:FireServer(t)

                    if falldistance >= 68 then
                        local v57 = math.max(0, falldistance - 20) * 0.9

                        if v4.Race == "Hollow" then
                            v57 = v57 * 0.7
                        end

                        Requests.TakeDamage:FireServer(v57)
                    end

                    if p1.DoubleJumped or falldistance >= 40 then
                        Shared.AddEffect(p1.Character, "Slow2", 0.5)
                    end
                end
            end

            p1.DoubleJumped = false
            p1.LastYPosition = p1.Root.Position.Y
        end
    end

    if os.clock() - p1.LastStunUpdate > 0.022222222222222223 then
        p1.LastStunUpdate = os.clock()
        StunHandler(p1.Character, p1.StatusTbl, v4)
    end

    if p1.cloakAnim and p1.currentCloak then
        if Magnitude > 3 then
            p1.cloakAnim:AdjustSpeed((math.min(Magnitude / 22, 2)))

            if p1.cloakAnim.IsPlaying == false then
                p1.cloakAnim:Play(0.25)
            end
        elseif p1.cloakAnim.IsPlaying then
            p1.cloakAnim:Stop(0.4)
        end
    end

    if p1.OriginalRootC0 then
        local v59 = if p1.Running then 30 else 5
        local v60 = p1.Root.CFrame:VectorToObjectSpace(p1.Humanoid.MoveDirection)

        if p1.Root.Velocity.Magnitude < 1 then
            v60 = Vector3.new()
        end

        local Angles = CFrame.Angles

        p1.CurrentTilt = p1.CurrentTilt:Lerp(Angles(0, math.rad(-v60.X) * v59, 0), 0.2 ^ (1 / (p2 * 60)))
        p1.Root.RootJoint.C0 = p1.OriginalRootC0 * p1.CurrentTilt
    end

    p1:FootstepUpdate(v34)
end
function t.IsHoldingSprint(p1) --[[ IsHoldingSprint | Line: 2116 | Upvalues: ControlsService (copy) ]]
    if ControlsService:GetControlMode() == "Gamepad" then
        if p1.Running and not ControlsService:IsThumbstickIdle() then
            return true
        end

        return ControlsService:IsActionHeld("Sprint")
    end

    if p1.Sprinting and not ControlsService:IsWASDIdle() then
        return true
    end

    return ControlsService:IsActionHeld("Sprint")
end
function t.RunningUpdate(p1) --[[ RunningUpdate | Line: 2132 | Upvalues: PlaceIds (copy), CollectionService (copy), AttackService (copy), v4 (copy), Shared (copy), UserGameSettings (copy), LocalPlayer (copy), SharedAssets (copy), ClientEffects (copy) ]]
    if (p1.Root.Velocity * Vector3.new(1, 0, 1)).Magnitude < 0.75 then
        if os.clock() - p1.LastDropCancel < 0.35 then
            return
        end

        p1:StopRunning()
    else
        local v1 = if PlaceIds.Names[game.PlaceId] == "Tournament" then not CollectionService:HasTag(p1.Character, "TournamentPlayer") else false
        local v2 = not p1.Freefalling

        if v2 and p1.Running == false then
            v2 = AttackService.CanAttack(p1.Character)

            if not v2 and v1 then
                v2 = v1
            elseif not v2 then
                v2 = AttackService.CanAdventure(p1.Character)

                if v2 then
                    v2 = not (if v4.Race == "Hollow" then v4.HollowModel.HollowStage == "Menos" else false)
                end
            end
        elseif v2 then
            v2 = false
        end

        p1:IsHoldingSprint()

        if v2 and (p1:IsHoldingSprint() and p1.Running == false) then
            local v42 = nil

            for v5, v6 in next, p1.StatusTbl do
                if v6.Name == "DisableRun" then
                    v42 = v6

                    break
                end
            end

            if not (v42 or CollectionService:HasTag(p1.Character, "Emoting")) then
                p1.Running = true
                p1.LastRun = os.clock()

                local Running = Instance.new("Folder")

                Running.Name = "Running"
                Running.Parent = p1.StatusFolder

                local v7, v8 = Shared.ApplyRunAnimations(p1.Character)

                p1.RunAnimations = v7
                p1.RunAnimationSpeed = v8
                UserGameSettings.RotationType = Enum.RotationType.MovementRelative
            end
        end
    end

    if p1.Running and os.clock() - p1.LastRun > 4 then
        local v9 = nil

        for v10, v11 in next, p1.StatusTbl do
            if v11.Name == "Sprinting" then
                v9 = v11

                break
            end
        end

        if not (v9 or CollectionService:HasTag(LocalPlayer, "InCombat")) then
            p1.Sprinting = true
            script.SprintLoop:Play()
            Shared.AddEffect(p1.Character, "Sprinting")

            for v12, v13 in next, p1.RunAnimations do
                v13:Stop()
            end

            p1.RunAnimations = Shared.ApplyRunAnimations(p1.Character, true)

            local WeaponModel = p1.Character:FindFirstChild("WeaponModel")
            local v14 = "Normal"
            local v15 = nil

            for v16, v17 in next, p1.StatusTbl do
                if v17.Name == "WeaponEquipped" then
                    v15 = v17

                    break
                end
            end

            if v15 then
                local WeaponType = WeaponModel.WeaponType.Value

                v14 = "Weapon"
            end

            Shared.PlayAnim(SharedAssets.Animations.SprintAnimations["SprintStart_" .. v14], p1.Humanoid, {
                speed = 1,
                priority = "Action2"
            })
            p1.SprintEffect = ClientEffects.SprintEffect({
                State = true,
                Character = p1.Character
            })
        end
    end

    local SprintEffectEnabled = p1.SprintEffectEnabled

    p1.SprintEffectEnabled = true

    local v18 = nil

    for v19, v20 in next, p1.StatusTbl do
        if v20.Name == "Slow2" then
            v18 = v20

            break
        end
    end

    if v18 then
        p1.SprintEffectEnabled = false
    end

    if not p1.Sprinting or (p1.SprintEffect == nil or p1.SprintEffectEnabled == SprintEffectEnabled) then
        return
    end

    local v21 = next
    local v22, v23 = p1.SprintEffect:GetDescendants()

    for v24, v25 in v21, v22, v23 do
        if v25:IsA("ParticleEmitter") or v25:IsA("Beam") then
            v25.Enabled = p1.SprintEffectEnabled
        end
    end
end
function t.FootstepUpdate(p1, p2) --[[ FootstepUpdate | Line: 2200 | Upvalues: v9 (ref), SharedAssets (copy), v1 (copy), SoundService (copy), TweenService (copy), PlaceIds (copy), v7 (copy) ]]
    local Magnitude = (p1.Root.Velocity * Vector3.new(1, 0, 1)).Magnitude
    local v12 = os.clock() - p1.LastFootstep

    if not ((p1.Running and 1 / Magnitude * 16 / 2 or 1 / Magnitude * 16 / 1.9) < v12) then
        return
    end

    local v3 = nil

    for v4, v5 in next, p1.StatusTbl do
        if v5.Name == "SilentFootsteps" then
            v3 = v5

            break
        end
    end

    if v3 then
        return
    end

    if not (Magnitude > 2) or Dashing then
        return
    end

    if p2 and (p1.Humanoid.FloorMaterial ~= Enum.Material.Air and v9 ~= "DefaultInnerWorld") then
        local v6 = p2.Instance
        local v72 = p2.Material.Name

        if v6.Name == "Water" then
            local v8 = SharedAssets.Footstep.Attachment:Clone()

            v8.Parent = workspace.Terrain
            v8.WorldPosition = p1.Root.CFrame * CFrame.new(p1.FootstepDir * 0.5, -3, 0).Position
            v8.Splash:Emit(5)
            v8.Splash2:Emit(5)
            game.Debris:AddItem(v8, 3)
            v72 = "Water"
        else
            if p1.bloodStep and p1.Character:FindFirstChild("Torso") then
                local v92 = SharedAssets.Footstep:Clone()

                v92.Print.Color3 = Color3.fromRGB(170, 0, 0)
                v92.Print.Transparency = 1
                v92.Anchored = true
                v92.Parent = workspace.Debris
                v92.CFrame = p1.Character.HumanoidRootPart.CFrame * CFrame.new(p1.FootstepDir * 0.5, -2.8, 0)

                local v10 = CFrame.new(v92.Position, v92.Position + p2.Normal) * CFrame.Angles(-1.5707963267948966, 0, 0)
                local Angles = CFrame.Angles

                v92.CFrame = v10 * Angles(0, math.rad(p1.Root.Orientation.Y), 0)
                game.Debris:AddItem(v92, 3)
                v92.Attachment.BloodStep:Emit(5)

                local v11 = SharedAssets.FootstepSounds.BloodyStep:Clone()

                v11.PlaybackSpeed = v11.PlaybackSpeed * v1:NextNumber(0.92, 1.06)
                v11.SoundGroup = SoundService.SoundGroup_Main
                v11.Parent = p1.Root
                v11:Play()
                game.Debris:AddItem(v11, v11.TimeLength / v11.PlaybackSpeed)
                delay(0.65, function() --[[ Line: 2240 | Upvalues: TweenService (ref), v92 (copy) ]]
                    TweenService:Create(v92.Print, TweenInfo.new(1), {
                        Transparency = 1
                    }):Play()
                end)
            elseif v6.Name == "BloodPart" then
                p1.bloodStep = true
                p1.bloodStepController = os.clock()

                local bloodStepController = p1.bloodStepController

                delay(5, function() --[[ Line: 2248 | Upvalues: bloodStepController (copy), p1 (copy) ]]
                    if bloodStepController == p1.bloodStepController then
                        p1.bloodStep = false
                    end
                end)
            end

            if v72 == "Sand" or (v72 == "Snow" or v72 == "Grass") then
                local v122 = SharedAssets.Footstep:Clone()

                v122.Print.Color3 = v6.Color
                v122.Print.Transparency = 1
                v122.Anchored = true
                v122.Parent = workspace.Debris
                v122.CFrame = p1.Character.HumanoidRootPart.CFrame * CFrame.new(p1.FootstepDir * 0.5, -2.8, 0)

                local v13 = CFrame.new(v122.Position, v122.Position + p2.Normal) * CFrame.Angles(-1.5707963267948966, 0, 0)
                local Angles = CFrame.Angles

                v122.CFrame = v13 * Angles(0, math.rad(p1.Root.Orientation.Y), 0)
                game.Debris:AddItem(v122, 3)

                local Color = v6.Color

                if p2.Instance:IsA("Terrain") then
                    Color = workspace.Terrain:GetMaterialColor(p2.Material)
                end

                if v72 == "Grass" then
                    local PlaceName = PlaceIds:GetPlaceInfo().PlaceName

                    if PlaceName == "SoulSocietyOutskirts" or (PlaceName == "OutskirtsSwamp" or PlaceName == "SoulSociety") then
                        Color = Color3.fromRGB(78, 139, 87)
                    end

                    v122.Grass.GrassBlades.Color = ColorSequence.new(Color)
                    v122.Grass.GrassBlades:Emit(5)
                else
                    v122.Attachment.Sand.Color = ColorSequence.new(Color)
                    v122.Attachment.Sand:Emit(5)
                end
            end
        end

        for v16, v17 in next, v7 do
            if v17.Name == v72 or (v17.Name:match("/" .. v72) or v17.Name:match(v72 .. "/")) then
                local v18 = v17:Clone()

                v18.PlaybackSpeed = v18.PlaybackSpeed * v1:NextNumber(0.94, 1.06)
                v18.SoundGroup = SoundService.SoundGroup_Main
                v18.Parent = p1.Root
                v18:Play()
                game.Debris:AddItem(v18, v17.TimeLength / v17.PlaybackSpeed)

                break
            end
        end
    else
        p1.AirWalkController:Footstep(p1.FootstepDir, v9 == "DefaultInnerWorld")
    end

    p1.LastFootstep = os.clock()
    p1.FootstepDir = p1.FootstepDir * -1
end

local OverheadWeapons = Shared.OverheadWeapons

function t.ClearIdleAnimations(p1) --[[ ClearIdleAnimations | Line: 2362 ]]
    if p1.HakudaIdle ~= nil then
        p1.HakudaIdle:Stop()
    end

    if p1.StandingIdle ~= nil then
        p1.StandingIdle:Stop()
    end

    p1.HakudaIdle = nil
    p1.StandingIdle = nil
    p1.CurrentWeaponType = nil
end
function t.UpdateIdle(p1) --[[ UpdateIdle | Line: 2371 | Upvalues: SharedAssets (copy), UserInputService (copy), CollectionService (copy), LocalPlayer (copy), Shared (copy) ]]
    if p1.CoreIdle == nil then
        p1.CoreIdle = p1.Humanoid:LoadAnimation(SharedAssets.Animations.WeaponAnimations.GlobalIdle)
        p1.CoreIdle.Priority = Enum.AnimationPriority.Core
    end

    if p1.HakudaKnuckleCrackAnim ~= nil then
        return
    end

    local v1 = nil

    for v2, v3 in next, p1.StatusTbl do
        if v3.Name == "Knocked" then
            v1 = v3

            break
        end
    end

    if not v1 then
        local v4 = nil

        for v5, v6 in next, p1.StatusTbl do
            if v6.Name == "Gripping" then
                v4 = v6

                break
            end
        end

        if not v4 then
            local v7 = nil

            for v8, v9 in next, p1.StatusTbl do
                if v9.Name == "Blocking" then
                    v7 = v9

                    break
                end
            end

            if not v7 then
                local v10 = nil

                for v11, v12 in next, p1.StatusTbl do
                    if v12.Name == "PauseIdle" then
                        v10 = v12

                        break
                    end
                end

                if not v10 then
                    local v13 = nil

                    for v14, v15 in next, p1.StatusTbl do
                        if v15.Name == "Hakuda" then
                            v13 = v15

                            break
                        end
                    end

                    local v16 = if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then CollectionService:HasTag(LocalPlayer, "InCombat") else false
                    local WeaponModel = p1.Character:FindFirstChild("WeaponModel")
                    local v17 = Shared.GetWeaponType(LocalPlayer.Character, true)
                    local v18 = if WeaponModel then WeaponModel.Equipped.Value else false
                    local v19

                    if v17 == p1.CurrentWeaponType and (p1.StandingIdle ~= nil or p1.HakudaIdle ~= nil) then
                        v19 = false
                    else
                        local v20, v21, v22

                        if v13 or not v18 then
                            if v13 then
                                if v16 then
                                    v20 = p1.StatusTbl
                                    v21 = nil

                                    for v23, v24 in next, v20 do
                                        if v24.Name == "PauseIdle" then
                                            v21 = v24

                                            break
                                        end
                                    end

                                    v22 = not v21
                                else
                                    v22 = v16
                                end
                            else
                                v22 = v13
                            end
                        else
                            v20 = p1.StatusTbl
                            v21 = nil

                            for v23, v24 in next, v20 do
                                if v24.Name == "PauseIdle" then
                                    v21 = v24

                                    break
                                end
                            end

                            v22 = not v21
                        end

                        p1:ClearIdleAnimations()
                        v19 = v22
                    end

                    if p1.HakudaKnuckleCrackAnim then
                        v19 = false
                    end

                    if v19 and (p1.StandingIdle == nil and p1.HakudaIdle == nil) then
                        p1:SetIdle(WeaponModel, v17, if Shared.HasEffect(p1.Character, "Hakuda") == nil then false else true)
                    end

                    if p1.Root.Velocity.Magnitude > 0.2 then
                        if p1.StandingIdle and p1.StandingIdle.IsPlaying then
                            p1.StandingIdle:Stop()
                        end

                        if p1.HakudaIdle ~= nil and p1.HakudaIdle.IsPlaying == false then
                            p1.HakudaIdle:Play()
                        end

                        if p1.CoreIdle.IsPlaying then
                            p1.CoreIdle:Stop()
                        end
                    else
                        if p1.HakudaIdle ~= nil and p1.HakudaIdle.IsPlaying then
                            p1.HakudaIdle:Stop(0.25)
                        end

                        if p1.CoreIdle.IsPlaying == false then
                            p1.CoreIdle:Play()
                        end

                        if p1.StandingIdle and p1.StandingIdle.IsPlaying == false then
                            p1.StandingIdle:Play(0.25)
                        end
                    end

                    p1.LastMouseBehaviour = UserInputService.MouseBehavior

                    if v17 ~= "None" or v17 == p1.CurrentWeaponType then
                        return
                    end

                    p1:ClearIdleAnimations()
                    p1.CurrentWeaponType = "None"

                    return
                end
            end
        end
    end

    p1:ClearIdleAnimations()
end
function t.SetIdle(p1, p2, p3, p4) --[[ SetIdle | Line: 2446 | Upvalues: Shared (copy), UserInputService (copy), SharedAssets (copy) ]]
    p1:ClearIdleAnimations()

    if p2 and p2.Equipped.Value then
        p3 = p2.WeaponType.Value
    end

    local v1 = Shared.GetMovingIdle(p1.Character, p3)

    local function setIdle() --[[ setIdle | Line: 2454 | Upvalues: p1 (copy), v1 (copy), p3 (ref) ]]
        p1.HakudaIdle = p1.Humanoid:LoadAnimation(v1)
        p1.HakudaIdle.Priority = Enum.AnimationPriority.Idle
        p1.HakudaIdleType = p3
    end

    if p4 and not p1.Character:FindFirstChild("ExtraArmRig") then
        if p1.Running or p1.LastMouseBehaviour == UserInputService.MouseBehavior then
            p1.HakudaIdle = p1.Humanoid:LoadAnimation(v1)
            p1.HakudaIdle.Priority = Enum.AnimationPriority.Idle
            p1.HakudaIdleType = p3
        else
            if p1.HakudaKnuckleCrackAnim then
                p1.HakudaKnuckleCrackAnim:Stop()
            end

            local v2 = Shared.PlayAnim(SharedAssets.Animations.KnuckleCrack, p1.Humanoid, {
                speed = 1.3,
                priority = "Action"
            })

            p1.HakudaKnuckleCrackAnim = v2
            task.delay(0.3, function() --[[ Line: 2476 | Upvalues: v2 (copy), Shared (ref), SharedAssets (ref), p1 (copy), v1 (copy), p3 (ref) ]]
                if v2 == nil or v2.IsPlaying == false then
                    return
                end

                Shared.PlaySound(SharedAssets.Sounds.KnuckleCrack, p1.Root)
                task.wait(0.15)

                if v2 ~= nil and v2.IsPlaying ~= false then
                    p1.HakudaKnuckleCrackAnim = nil
                    p1.HakudaIdle = p1.Humanoid:LoadAnimation(v1)
                    p1.HakudaIdle.Priority = Enum.AnimationPriority.Idle
                    p1.HakudaIdleType = p3
                end
            end)
        end
    else
        p1.HakudaIdle = p1.Humanoid:LoadAnimation(v1)
        p1.HakudaIdle.Priority = Enum.AnimationPriority.Idle
        p1.HakudaIdleType = p3
    end

    if p3 ~= nil then
        local v3 = Shared.GetStandingIdle(p1.Character, p3)

        if v3 then
            p1.StandingIdle = p1.Humanoid:LoadAnimation(v3)
        end
    end

    if p1.StandingIdle then
        p1.StandingIdle.Priority = Enum.AnimationPriority.Idle
    end

    p1.CurrentWeaponType = p3
end
function t.new(p1) --[[ new | Line: 2506 | Upvalues: LocalPlayer (copy), t (copy) ]]
    local t2 = {
        Character = p1,
        Player = LocalPlayer
    }

    script.SprintLoop:Stop()
    setmetatable(t2, {
        __index = t
    })
    t2:Init()

    return t2
end

return t
