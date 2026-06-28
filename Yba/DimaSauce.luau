task.wait(0.5)
local Teleport = loadstring(game:HttpGet("https://raw.githubusercontent.com/rinqedd/pub_rblx/main/ServerHop", true))

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
task.wait(7)

-- ===== global for hop =====
getgenv().repeatagain = 1
getgenv().times = 0
getgenv().timesvalue = 3 

player=0;name=0;pchar=0;phum=0;phumrt=0;remevent=0;remfunction=0
lvl=0;stand=0;prestige=0

function vupdate() 
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

function scall(func,st)
	task.spawn(function()
		pcall(vupdate)
	end)
	if st==1 then 
		task.spawn(function()
			local s,r=pcall(func)
			if not s then 
                warn(r)
			end 
		end)
	else 
		local s,r=pcall(func)
        if not s then 
            warn(r)
        end
	end 
end

local hook = "ADD HOOK HERE" --"https://discord.com/api/webhooks/1303344742565679124/AFby-HMP0IDehQ_a1_Xup4BZixIlR2EiWRM0OzPB2GKlzjNPInTFLwlS2wrv2ZO50rhR"
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

setup=0;startgame=0;webhook=0;farmitem=0;input=0
countitem=0;useitem=0;killnpc=0;storydialogue=0;enddialogue=0;sellitem=0;prestigecheck=0

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
			print("I FOUND IT")
			local HUD = game:GetService("ReplicatedStorage").Objects.HUD:Clone()
			HUD.Parent = player.PlayerGui
		end

		print("I DID FOUND IT, MAYBE IT WILL WORK?")
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
		local response = request(tabledata)
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
	-- УЛУЧШЕННАЯ ВЕРСИЯ killnpc ИЗ ВТОРОГО СКРИПТА
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
	local button = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("LoadingScreen"):WaitForChild("Frames"):WaitForChild("Gamemodes"):WaitForChild("MainGame"):WaitForChild("Play")	
	task.wait(10)
	scall(startgame)
	print("starting")
	scall(setup)

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