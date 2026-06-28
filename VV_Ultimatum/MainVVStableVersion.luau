local VVExecutionGuard = type(getgenv) == "function" and getgenv() or _G
VVExecutionGuard.VVUltimatum = VVExecutionGuard.VVUltimatum or {}
local VVHotReload = VVExecutionGuard.VVUltimatum

local function installVVHotReloadValues()
	VVHotReload.Debug = VVHotReload.Debug or {}
	VVHotReload.Debug.Enabled = VVHotReload.Debug.Enabled == true
	VVHotReload.Debug.Scope = VVHotReload.Debug.Scope or {}
	VVHotReload.Debug.Scope.ServerHop = VVHotReload.Debug.Scope.ServerHop ~= false
	VVHotReload.Debug.Scope.AutoQuest = VVHotReload.Debug.Scope.AutoQuest ~= false
	VVHotReload.Debug.Scope.AutoKill = VVHotReload.Debug.Scope.AutoKill == true
	VVHotReload.Debug.Scope.Animation = VVHotReload.Debug.Scope.Animation == true

	VVHotReload.UltraDebug = VVHotReload.UltraDebug or {}
	VVHotReload.UltraDebug.Enabled = VVHotReload.UltraDebug.Enabled == true
	VVHotReload.UltraDebug.Scope = VVHotReload.UltraDebug.Scope or {}
	VVHotReload.UltraDebug.Scope.ServerHop = VVHotReload.UltraDebug.Scope.ServerHop ~= false
	VVHotReload.UltraDebug.Scope.AutoQuest = VVHotReload.UltraDebug.Scope.AutoQuest ~= false
	VVHotReload.UltraDebug.Scope.AutoKill = VVHotReload.UltraDebug.Scope.AutoKill == true
	VVHotReload.UltraDebug.Scope.Animation = VVHotReload.UltraDebug.Scope.Animation == true

	VVHotReload.FormatDebugValue = function(value)
		local valueType = typeof(value)
		if valueType == "Instance" then
			return value:GetFullName()
		end
		if type(value) == "table" then
			local pieces = {}
			local count = 0
			for key, nestedValue in pairs(value) do
				count += 1
				if count <= 8 then
					table.insert(pieces, tostring(key) .. "=" .. tostring(nestedValue))
				end
			end
			local suffix = count > 8 and ", ..." or ""
			return "{" .. table.concat(pieces, ", ") .. suffix .. "}"
		end
		return tostring(value)
	end

	VVHotReload.IsDebugScopeEnabled = function(debugConfig, scope)
		return type(debugConfig) == "table"
			and debugConfig.Enabled == true
			and type(debugConfig.Scope) == "table"
			and debugConfig.Scope[scope] == true
	end

	VVHotReload.DebugStep = function(scope, step, details)
		if not VVHotReload.IsDebugScopeEnabled(VVHotReload.Debug, scope) then
			return
		end

		if details ~= nil then
			print("LEAF_DEBUG:", tostring(scope), tostring(step), VVHotReload.FormatDebugValue(details))
		else
			print("LEAF_DEBUG:", tostring(scope), tostring(step))
		end
	end

	VVHotReload.DebugWarn = function(scope, route, desc, details)
		if not VVHotReload.IsDebugScopeEnabled(VVHotReload.Debug, scope) then
			return
		end

		if details ~= nil then
			warn("LEAF_WARN:", tostring(scope), tostring(route), tostring(desc), VVHotReload.FormatDebugValue(details))
		else
			warn("LEAF_WARN:", tostring(scope), tostring(route), tostring(desc))
		end
	end

	VVHotReload.UltraStep = function(scope, step, details)
		if not VVHotReload.IsDebugScopeEnabled(VVHotReload.UltraDebug, scope) then
			return
		end

		if details ~= nil then
			print("LEAF_ULTRA:", tostring(scope), tostring(step), VVHotReload.FormatDebugValue(details))
		else
			print("LEAF_ULTRA:", tostring(scope), tostring(step))
		end
	end

	VVHotReload.UltraWarn = function(scope, route, desc, details)
		if not VVHotReload.IsDebugScopeEnabled(VVHotReload.UltraDebug, scope) then
			return
		end

		if details ~= nil then
			warn("LEAF_ULTRA_WARN:", tostring(scope), tostring(route), tostring(desc), VVHotReload.FormatDebugValue(details))
		else
			warn("LEAF_ULTRA_WARN:", tostring(scope), tostring(route), tostring(desc))
		end
	end

	VVHotReload.VelocityTeleportLift = 5
	VVHotReload.VelocityTeleportWallOffset = VVHotReload.VelocityTeleportWallOffset or 3
	VVHotReload.VelocityTeleport = function(distance)
		if type(distance) ~= "number" or distance == 0 then
			warn("VelocityTeleport: distance must be a non-zero number")
			return false
		end

		local players = game:GetService("Players")
		local localPlayer = players.LocalPlayer
		local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
		if not character or character.Parent == nil then
			warn("VelocityTeleport: character was not found")
			return false
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
		if not root then
			warn("VelocityTeleport: HumanoidRootPart was not found")
			return false
		end

		local direction
		if humanoid and humanoid.MoveDirection.Magnitude > 0.05 then
			direction = humanoid.MoveDirection.Unit
		elseif root.AssemblyLinearVelocity.Magnitude > 0.05 then
			direction = root.AssemblyLinearVelocity.Unit
		else
			direction = root.CFrame.LookVector
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {character}
		raycastParams.IgnoreWater = true

		local rayDirection = direction.Unit * distance
		local result = workspace:Raycast(root.Position, rayDirection, raycastParams)
		local targetPosition
		if result then
			local wallOffset = math.max(1, tonumber(VVHotReload.VelocityTeleportWallOffset) or 3)
			targetPosition = result.Position + (result.Normal * wallOffset)
		else
			targetPosition = root.Position + rayDirection
		end

		local currentPivot = character:GetPivot()
		character:PivotTo(CFrame.new(targetPosition) * (currentPivot - currentPivot.Position))
		return true
	end

	VVHotReload.AnimationVisualizer = VVHotReload.AnimationVisualizer or {}
	VVHotReload.AnimationVisualizer.State = VVHotReload.AnimationVisualizer.State or {}
	VVHotReload.AnimationVisualizer.AutoUseTimeEnabled = false
	VVHotReload.AnimationVisualizer.AutoUseTimeInterval = 0.1
	VVHotReload.AnimationVisualizer.NormalizeResponseTime = function(timePosition)
		local numericTime = tonumber(timePosition)
		if not numericTime then
			return nil
		end

		return math.clamp(math.floor(numericTime * 1000 + 0.5) / 1000, 0, 10)
	end
	VVHotReload.AnimationVisualizer.UseCurrentTimeAsResponseTime = function()
		local visualizer = VVHotReload.AnimationVisualizer
		local state = visualizer.State
		local track = type(state.GetMainTrack) == "function" and state.GetMainTrack() or nil
		local profile = type(state.GetSelectedProfile) == "function" and state.GetSelectedProfile() or nil
		if not track or not profile then
			return false
		end

		local responseTime = visualizer.NormalizeResponseTime(track.TimePosition)
		if not responseTime then
			return false
		end

		profile.WaitBeforeResponse = responseTime
		profile.Enabled = true
		if type(state.SetProfileWaitText) == "function" then
			state.SetProfileWaitText(responseTime)
		end
		if type(state.SetProfileEnabled) == "function" then
			state.SetProfileEnabled(true)
		end
		if type(state.SyncResponseSettings) == "function" then
			state.SyncResponseSettings(profile)
		end
		if type(state.ScheduleSave) == "function" then
			state.ScheduleSave()
		end
		return true
	end

	VVHotReload.ServerHop = VVHotReload.ServerHop or {}
	VVHotReload.ServerHop.GamePlaceId = 14219489601
	VVHotReload.ServerHop.PlaceIds = {
		["Human World"] = 14219489601,
		["Soul Society Outskirts"] = 14218523102,
		["Soul Society"] = 12337012844,
		["Hueco Mundo"] = 11131834995,
		["Las Noches"] = 11127942816,
		["Wandenreich"] = 11780443293,
		["The Marsh"] = 95787471190312,
		["Arctic Plains"] = 15079707729,
		["Trade Port"] = 102123868363969,
		["Dangai"] = 17083682617,
		["Menos Forest"] = 16914874220,
	}

	VVHotReload.ServerHop.PlaceKeys = {
		["Human World"] = "HumanWorld",
		["Soul Society Outskirts"] = "SoulSocietyOutskirts",
		["Soul Society"] = "SoulSociety",
		["Hueco Mundo"] = "HuecoMundo",
		["Las Noches"] = "LasNoches",
		["Wandenreich"] = "Wandenreich",
		["The Marsh"] = "OutskirtsSwamp",
		["Arctic Plains"] = "ArcticPlains",
		["Trade Port"] = "TradeRealm",
		["Dangai"] = "Dangai",
		["Menos Forest"] = "MenosForest",
	}

	VVHotReload.ServerHop.RaceSpawnPlaceIds = {
		Quincy = 11780443293,
		SoulReaper = 12337012844,
		Hollow = 11127942816,
		Arrancar = 11127942816,
	}

	VVHotReload.ServerHop.RaceSpawnNames = {
		Quincy = "Wandenreich",
		SoulReaper = "Soul Society",
		Hollow = "Las Noches",
		Arrancar = "Las Noches",
	}

	VVHotReload.ServerHop.GetPlayerGui = function()
		local player = game:GetService("Players").LocalPlayer
		return player and player:FindFirstChild("PlayerGui") or nil
	end

	VVHotReload.ServerHop.GetMenu = function()
		local playerGui = VVHotReload.ServerHop.GetPlayerGui()
		return playerGui and playerGui:FindFirstChild("Menu") or nil
	end

	VVHotReload.ServerHop.GetMainUI = function()
		local playerGui = VVHotReload.ServerHop.GetPlayerGui()
		return playerGui and playerGui:FindFirstChild("MainUI") or nil
	end

	VVHotReload.ServerHop.GetInGameServerListObject = function()
		local mainUI = VVHotReload.ServerHop.GetMainUI()
		local hudContainer = mainUI and mainUI:FindFirstChild("HUDContainer")
		return hudContainer and hudContainer:FindFirstChild("ServerList") or nil
	end

	VVHotReload.ServerHop.GetInGameServerListButton = function()
		local mainUI = VVHotReload.ServerHop.GetMainUI()
		local hudContainer = mainUI and mainUI:FindFirstChild("HUDContainer")
		local topLeftDetails = hudContainer and hudContainer:FindFirstChild("TopLeftDetailsContainer")
		local buttons = topLeftDetails and topLeftDetails:FindFirstChild("Buttons")
		return buttons and buttons:FindFirstChild("ServerList") or nil
	end

	VVHotReload.ServerHop.GetServerListObjects = function()
		local playerGui = VVHotReload.ServerHop.GetPlayerGui()
		local objects = {}
		if not playerGui then
			VVHotReload.DebugWarn("ServerHop", "GetServerListObjects", "PlayerGui was not found")
			return objects
		end

		local mainUI = playerGui:FindFirstChild("MainUI")
		local mainServerList = mainUI
			and mainUI:FindFirstChild("HUDContainer")
			and mainUI.HUDContainer:FindFirstChild("ServerList")
		if mainServerList then
			table.insert(objects, mainServerList)
		end

		local menu = playerGui:FindFirstChild("Menu")
		local menuServerList = menu
			and menu:FindFirstChild("Windows")
			and menu.Windows:FindFirstChild("ServerList")
		if menuServerList then
			table.insert(objects, menuServerList)
		end

		for _, descendant in ipairs(playerGui:GetDescendants()) do
			if descendant.Name == "ServerList"
				and descendant:IsA("GuiObject")
				and descendant:FindFirstChild("ScrollingFrame")
				and descendant.ScrollingFrame:FindFirstChild("Frame")
			then
				local alreadyAdded = false
				for _, existing in ipairs(objects) do
					if existing == descendant then
						alreadyAdded = true
						break
					end
				end
				if not alreadyAdded then
					table.insert(objects, descendant)
				end
			end
		end

		VVHotReload.UltraStep("ServerHop", "GetServerListObjects", {
			Count = #objects,
		})
		return objects
	end

	VVHotReload.ServerHop.GetServerListFrame = function(serverList)
		return serverList
			and serverList:FindFirstChild("ScrollingFrame")
			and serverList.ScrollingFrame:FindFirstChild("Frame")
			or nil
	end

	VVHotReload.ServerHop.CountServerRows = function(serverList)
		local frame = VVHotReload.ServerHop.GetServerListFrame(serverList)
		local count = 0
		if not frame then
			return count
		end

		for _, entry in ipairs(frame:GetChildren()) do
			if entry:IsA("Frame") and entry.Name ~= "Template" then
				count += 1
			end
		end

		VVHotReload.UltraStep("ServerHop", "CountServerRows", {
			Path = serverList and serverList:GetFullName() or "nil",
			Rows = count,
		})
		return count
	end

	VVHotReload.ServerHop.FindBestServerListObject = function()
		local bestServerList
		local bestCount = 0
		for _, serverList in ipairs(VVHotReload.ServerHop.GetServerListObjects()) do
			local count = VVHotReload.ServerHop.CountServerRows(serverList)
			if count > bestCount then
				bestServerList = serverList
				bestCount = count
			end
		end

		VVHotReload.DebugStep("ServerHop", "FindBestServerListObject", {
			Path = bestServerList and bestServerList:GetFullName() or "nil",
			Rows = bestCount,
		})
		return bestServerList, bestCount
	end

	VVHotReload.ServerHop.ShowServerListObject = function(serverList)
		if not serverList or not serverList:IsA("GuiObject") then
			return false
		end

		serverList.Visible = true
		local parent = serverList.Parent
		while parent and parent:IsA("GuiObject") do
			parent.Visible = true
			parent = parent.Parent
		end

		VVHotReload.DebugStep("ServerHop", "ShowServerListObject", serverList:GetFullName())
		return true
	end

	VVHotReload.ServerHop.GetMenuTargetPlaceId = function()
		local serverList = select(1, VVHotReload.ServerHop.FindBestServerListObject())
		if not serverList then
			local menu = VVHotReload.ServerHop.GetMenu()
			serverList = menu
				and menu:FindFirstChild("Windows")
				and menu.Windows:FindFirstChild("ServerList")
		end
		local indicator = serverList
			and serverList:FindFirstChild("Selectors")
			and serverList.Selectors:FindFirstChild("Character")
			and serverList.Selectors.Character:FindFirstChild("AreaIndicator")
		local text = indicator and tostring(indicator.Text or "") or ""

		for displayName, placeId in pairs(VVHotReload.ServerHop.PlaceIds) do
			if text:find(displayName, 1, true) then
				VVHotReload.DebugStep("ServerHop", "TargetFromAreaIndicator", {
					Text = text,
					DisplayName = displayName,
					PlaceId = placeId,
					PlaceKey = VVHotReload.ServerHop.PlaceKeys[displayName],
				})
				return placeId, displayName, VVHotReload.ServerHop.PlaceKeys[displayName]
			end
		end

		local racePlaceId, race = VVHotReload.ServerHop.GetSelectedRacePlaceId()
		local racePlaceName = race and VVHotReload.ServerHop.RaceSpawnNames[race]
		if racePlaceId and racePlaceName then
			VVHotReload.DebugStep("ServerHop", "TargetFromRaceFallback", {
				Race = race,
				DisplayName = racePlaceName,
				PlaceId = racePlaceId,
				PlaceKey = VVHotReload.ServerHop.PlaceKeys[racePlaceName],
			})
			return racePlaceId, racePlaceName, VVHotReload.ServerHop.PlaceKeys[racePlaceName]
		end

		VVHotReload.DebugWarn("ServerHop", "GetMenuTargetPlaceId", "Falling back to Human World", {AreaText = text})
		return VVHotReload.ServerHop.GamePlaceId, "Human World", "HumanWorld"
	end

	VVHotReload.ServerHop.GetSelectedRacePlaceId = function()
		if type(getgc) ~= "function" then
			return nil
		end

		for _, obj in ipairs(getgc(true)) do
			if type(obj) == "table" and type(rawget(obj, "Race")) == "string" then
				local placeId = VVHotReload.ServerHop.RaceSpawnPlaceIds[obj.Race]
				if placeId then
					return placeId, obj.Race
				end
			end
		end

		return nil
	end

	VVHotReload.ServerHop.DetectCharacterSlot = function()
		local menu = VVHotReload.ServerHop.GetMenu()
		local slots = menu
			and menu:FindFirstChild("Windows")
			and menu.Windows:FindFirstChild("SlotSelector")
			and menu.Windows.SlotSelector:FindFirstChild("Slots")
		if not slots then
			return 1
		end

		local orderedSlots = {}
		for _, slotFrame in ipairs(slots:GetChildren()) do
			if slotFrame:IsA("Frame") then
				table.insert(orderedSlots, slotFrame)
			end
		end
		table.sort(orderedSlots, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)

		for index, slotFrame in ipairs(orderedSlots) do
			local characterName
			for _, descendant in ipairs(slotFrame:GetDescendants()) do
				if descendant:IsA("TextLabel") and descendant.Name == "CharacterName" then
					local text = tostring(descendant.Text or "")
					local lowerText = text:lower()
					if text ~= ""
						and not lowerText:find("empty", 1, true)
						and not lowerText:find("locked", 1, true)
						and not lowerText:find("purchase", 1, true)
					then
						characterName = text
						break
					end
				end
			end

			if characterName then
				local slotNumber = tonumber(slotFrame.Name:match("%d+")) or index
				return slotNumber, characterName
			end
		end

		return 1
	end

	VVHotReload.ServerHop.EnsureCharacterSelected = function(slotNumber)
		local requests = game:GetService("ReplicatedStorage"):FindFirstChild("Requests")
		if not requests then
			VVHotReload.DebugWarn("ServerHop", "EnsureCharacterSelected", "Requests folder was not found")
			warn("Server hop: Requests folder was not found")
			return false
		end

		local selectSlot = requests:FindFirstChild("SelectCharacterSlot")
		local generateCharacter = requests:FindFirstChild("GenerateLoadingCharacter")
		if not selectSlot or not selectSlot:IsA("RemoteFunction") then
			VVHotReload.DebugWarn("ServerHop", "EnsureCharacterSelected", "SelectCharacterSlot remote was not found")
			warn("Server hop: SelectCharacterSlot remote was not found")
			return false
		end

		slotNumber = tonumber(slotNumber) or select(1, VVHotReload.ServerHop.DetectCharacterSlot()) or 1
		VVHotReload.DebugStep("ServerHop", "SelectCharacterSlot", {Slot = slotNumber})
		local ok, result = pcall(function()
			return selectSlot:InvokeServer(slotNumber)
		end)
		if not ok or result ~= true then
			VVHotReload.DebugWarn("ServerHop", "EnsureCharacterSelected", "Failed to select character slot", {
				Slot = slotNumber,
				Result = result,
			})
			warn("Server hop: failed to select character slot " .. tostring(slotNumber) .. " | " .. tostring(result))
			return false
		end

		if generateCharacter and generateCharacter:IsA("RemoteFunction") then
			VVHotReload.UltraStep("ServerHop", "GenerateLoadingCharacter", {Slot = slotNumber})
			pcall(function()
				generateCharacter:InvokeServer(slotNumber)
			end)
		end

		task.wait(0.35)
		return true
	end
	VVHotReload.ServerHop.HttpGet = function(url)
		local requestFunction = (type(syn) == "table" and syn.request)
			or (type(http) == "table" and http.request)
			or http_request
			or request

		if type(requestFunction) == "function" then
			local success, response = pcall(requestFunction, {
				Url = url,
				Method = "GET",
			})
			if success and type(response) == "table" and type(response.Body) == "string" then
				return response.Body
			end
		end

		local success, body = pcall(function()
			return game:HttpGet(url)
		end)
		if success and type(body) == "string" then
			return body
		end

		success, body = pcall(function()
			return game:HttpGetAsync(url, true)
		end)
		if success and type(body) == "string" then
			return body
		end

		return nil
	end

	VVHotReload.ServerHop.FetchPublicServers = function(placeId, maxPages)
		local httpService = game:GetService("HttpService")
		local servers = {}
		local cursor = nil
		local pageCount = 0
		placeId = tonumber(placeId) or VVHotReload.ServerHop.GamePlaceId

		repeat
			pageCount += 1
			local url = "https://games.roblox.com/v1/games/"
				.. tostring(placeId)
				.. "/servers/Public?sortOrder=Asc&limit=100"
			if cursor then
				url ..= "&cursor=" .. httpService:UrlEncode(cursor)
			end

			local body = VVHotReload.ServerHop.HttpGet(url)
			if not body then
				warn("Server hop: failed to read Roblox server list for place " .. tostring(placeId))
				break
			end

			local decodeSuccess, decoded = pcall(httpService.JSONDecode, httpService, body)
			if not decodeSuccess or type(decoded) ~= "table" then
				warn("Server hop: failed to decode Roblox server list for place " .. tostring(placeId))
				break
			end

			if type(decoded.data) == "table" then
				for _, server in ipairs(decoded.data) do
					if type(server) == "table"
						and type(server.id) == "string"
						and server.id ~= game.JobId
						and (tonumber(server.playing) or math.huge) < (tonumber(server.maxPlayers) or 0)
					then
						server.placeId = placeId
						server.source = "RobloxPublicServers"
						table.insert(servers, server)
					end
				end
			end

			cursor = decoded.nextPageCursor
		until not cursor or pageCount >= (tonumber(maxPages) or 10)

		return servers
	end

	VVHotReload.ServerHop.GetPublicPingByServerId = function(placeId)
		local pingByServerId = {}
		for _, server in ipairs(VVHotReload.ServerHop.FetchPublicServers(placeId, 10)) do
			local ping = tonumber(server.ping or server.Ping)
			if type(server.id) == "string" and ping then
				pingByServerId[server.id] = ping
			end
		end
		return pingByServerId
	end

	VVHotReload.ServerHop.GetMenuServerRows = function(placeId)
		local serverList, rowCount = VVHotReload.ServerHop.FindBestServerListObject()
		if serverList and rowCount > 0 then
			VVHotReload.ServerHop.ShowServerListObject(serverList)
		end

		local frame = VVHotReload.ServerHop.GetServerListFrame(serverList)
		if not frame then
			return {}
		end

		local pingByServerId = VVHotReload.ServerHop.GetPublicPingByServerId(placeId)
		local servers = {}
		for _, entry in ipairs(frame:GetChildren()) do
			if entry:IsA("Frame") and entry.Name ~= "Template" then
				local container = entry:FindFirstChild("Container")
				local button = entry:FindFirstChild("Button")
				local playerCountText = container and container:FindFirstChild("PlayerCount")
				local locationText = container and container:FindFirstChild("ServerLocation")
				local missionText = container and container:FindFirstChild("MissionName")
				local players = tonumber(tostring(playerCountText and playerCountText.Text or ""):match("(%d+)%s+players?"))
				if type(entry.Name) == "string" and entry.Name ~= "" and players then
					table.insert(servers, {
						id = entry.Name,
						playing = players,
						maxPlayers = 15,
						ping = pingByServerId[entry.Name],
						placeId = placeId,
						serverName = missionText and missionText.Text or nil,
						location = locationText and locationText.Text or nil,
						button = button,
						source = "GameServerList",
					})
				end
			end
		end

		VVHotReload.DebugStep("ServerHop", "GetMenuServerRows", {
			Rows = #servers,
			PlaceId = placeId,
			ServerList = serverList and serverList:GetFullName() or "nil",
		})
		return servers
	end

	VVHotReload.ServerHop.ClickGuiButton = function(button)
		if not button or not button:IsA("GuiButton") then
			VVHotReload.DebugWarn("ServerHop", "ClickGuiButton", "Button was not found")
			return false, "button was not found"
		end

		VVHotReload.UltraStep("ServerHop", "ClickGuiButton", button:GetFullName())
		if type(firesignal) == "function" then
			local firedConnection = false
			if type(getconnections) == "function" then
				local clickOk, clickConnections = pcall(getconnections, button.MouseButton1Click)
				if clickOk and type(clickConnections) == "table" and #clickConnections > 0 then
					pcall(firesignal, button.MouseButton1Click)
					firedConnection = true
				end

				local activatedOk, activatedConnections = pcall(getconnections, button.Activated)
				if activatedOk and type(activatedConnections) == "table" and #activatedConnections > 0 then
					pcall(firesignal, button.Activated)
					firedConnection = true
				end
			else
				pcall(firesignal, button.MouseButton1Click)
				pcall(firesignal, button.Activated)
				firedConnection = true
			end

			if firedConnection then
				VVHotReload.UltraStep("ServerHop", "ClickGuiButtonFiredSignal", button:GetFullName())
				return true
			end
		end

		local virtualInputManager = game:GetService("VirtualInputManager")
		local center = button.AbsolutePosition + (button.AbsoluteSize / 2)
		virtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
		task.wait()
		virtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
		VVHotReload.UltraStep("ServerHop", "ClickGuiButtonVIM", {
			Path = button:GetFullName(),
			X = center.X,
			Y = center.Y,
		})
		return true
	end

	VVHotReload.ServerHop.SendMouseClickAt = function(position, buttonIndex)
		local virtualInputManager = game:GetService("VirtualInputManager")
		virtualInputManager:SendMouseButtonEvent(position.X, position.Y, buttonIndex or 0, true, game, 0)
		task.wait()
		virtualInputManager:SendMouseButtonEvent(position.X, position.Y, buttonIndex or 0, false, game, 0)
	end

	VVHotReload.ServerHop.GetMenuButton = function(path)
		local menu = VVHotReload.ServerHop.GetMenu()
		local current = menu
		for _, name in ipairs(path) do
			current = current and current:FindFirstChild(name)
		end
		return current
	end

	VVHotReload.ServerHop.GetFirstCharacterSlotButton = function()
		local slots = VVHotReload.ServerHop.GetMenuButton({"Windows", "SlotSelector", "Slots"})
		if not slots then
			return nil
		end

		local orderedSlots = {}
		for _, slotFrame in ipairs(slots:GetChildren()) do
			if slotFrame:IsA("Frame") then
				table.insert(orderedSlots, slotFrame)
			end
		end
		table.sort(orderedSlots, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)

		for _, slotFrame in ipairs(orderedSlots) do
			local slotButton = slotFrame:FindFirstChild("Container")
				and slotFrame.Container:FindFirstChild("TextButton")
			local characterName
			for _, descendant in ipairs(slotFrame:GetDescendants()) do
				if descendant:IsA("TextLabel") and descendant.Name == "CharacterName" then
					local text = tostring(descendant.Text or "")
					local lowerText = text:lower()
					if text ~= ""
						and not lowerText:find("empty", 1, true)
						and not lowerText:find("locked", 1, true)
						and not lowerText:find("purchase", 1, true)
					then
						characterName = text
						break
					end
				end
			end

			if slotButton and characterName then
				return slotButton
			end
		end

		return nil
	end

	VVHotReload.ServerHop.WaitForServerRows = function(timeout)
		local startedAt = os.clock()
		while os.clock() - startedAt < (tonumber(timeout) or 8) do
			local serverList, count = VVHotReload.ServerHop.FindBestServerListObject()
			if serverList and count > 0 then
				return serverList, count
			end
			task.wait(0.25)
		end

		return VVHotReload.ServerHop.FindBestServerListObject()
	end

	VVHotReload.ServerHop.PrepareServerListGui = function()
		local existingServerList, existingCount = VVHotReload.ServerHop.FindBestServerListObject()
		if existingServerList and existingCount > 0 then
			VVHotReload.DebugStep("ServerHop", "PrepareServerListGuiExistingRows", {
				Path = existingServerList:GetFullName(),
				Rows = existingCount,
			})
			VVHotReload.ServerHop.ShowServerListObject(existingServerList)
			return existingServerList, existingCount
		end

		local inGameServerList = VVHotReload.ServerHop.GetInGameServerListObject()
		if inGameServerList and inGameServerList:IsA("GuiObject") then
			VVHotReload.DebugStep("ServerHop", "PrepareServerListGuiInGame", inGameServerList:GetFullName())
			local openButton = VVHotReload.ServerHop.GetInGameServerListButton()
			if openButton then
				VVHotReload.DebugStep("ServerHop", "ClickInGameServerListButton")
				VVHotReload.ServerHop.ClickGuiButton(openButton)
				task.wait(0.5)
			else
				VVHotReload.DebugWarn("ServerHop", "PrepareServerListGuiInGame", "In-game server list button was not found")
			end

			VVHotReload.ServerHop.ShowServerListObject(inGameServerList)
			local bottomButtons = inGameServerList:FindFirstChild("BottomButtons")
			local refreshButton = bottomButtons and bottomButtons:FindFirstChild("Refresh")
			if refreshButton then
				VVHotReload.DebugStep("ServerHop", "ClickInGameRefreshButton")
				VVHotReload.ServerHop.ClickGuiButton(refreshButton)
			else
				VVHotReload.DebugWarn("ServerHop", "PrepareServerListGuiInGame", "In-game refresh button was not found")
			end

			local preparedServerList, preparedCount = VVHotReload.ServerHop.WaitForServerRows(8)
			if not preparedServerList or preparedCount <= 0 then
				VVHotReload.DebugWarn("ServerHop", "PrepareServerListGuiInGame", "Rows did not appear after opening in-game GUI")
			end
			return preparedServerList, preparedCount
		end

		local menu = VVHotReload.ServerHop.GetMenu()
		if not menu then
			VVHotReload.DebugWarn("ServerHop", "PrepareServerListGui", "Menu was not found")
			return existingServerList, existingCount
		end

		VVHotReload.DebugStep("ServerHop", "PrepareServerListGuiBootstrap", menu:GetFullName())
		local buttonPrompt = menu:FindFirstChild("ButtonPrompt")
		if buttonPrompt and buttonPrompt:IsA("GuiObject") and buttonPrompt.Visible then
			local camera = workspace.CurrentCamera
			local viewportSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)
			VVHotReload.DebugStep("ServerHop", "ClickButtonPromptRMB")
			VVHotReload.ServerHop.SendMouseClickAt(viewportSize / 2, 1)
			task.wait(0.35)
		end

		local continueButton = VVHotReload.ServerHop.GetMenuButton({"Buttons", "Continue", "TextButton"})
		if continueButton then
			VVHotReload.DebugStep("ServerHop", "ClickContinueButton")
			VVHotReload.ServerHop.ClickGuiButton(continueButton)
			task.wait(0.5)
		end

		VVHotReload.ServerHop.EnsureCharacterSelected()
		local slotButton = VVHotReload.ServerHop.GetFirstCharacterSlotButton()
		if slotButton then
			VVHotReload.DebugStep("ServerHop", "ClickFirstCharacterSlot")
			VVHotReload.ServerHop.ClickGuiButton(slotButton)
			task.wait(0.75)
		end

		local serverList = VVHotReload.ServerHop.GetMenuButton({"Windows", "ServerList"})
		if serverList and serverList:IsA("GuiObject") then
			VVHotReload.DebugStep("ServerHop", "ShowMenuServerList")
			VVHotReload.ServerHop.ShowServerListObject(serverList)
		end

		local refreshButton = VVHotReload.ServerHop.GetMenuButton({"Windows", "ServerList", "BottomButtons", "Refresh"})
		if refreshButton then
			VVHotReload.DebugStep("ServerHop", "ClickRefreshButton")
			VVHotReload.ServerHop.ClickGuiButton(refreshButton)
		end

		return VVHotReload.ServerHop.WaitForServerRows(8)
	end

	VVHotReload.ServerHop.FetchGameServers = function(placeKey, placeId)
		local requests = game:GetService("ReplicatedStorage"):FindFirstChild("Requests")
		local getServerList = requests and requests:FindFirstChild("GetServerList")
		if not getServerList or not getServerList:IsA("RemoteFunction") then
			warn("Server hop: GetServerList remote was not found")
			return {}
		end

		placeKey = placeKey or "HumanWorld"
		local success, serverList = pcall(function()
			return getServerList:InvokeServer({
				TargetPlace = placeKey,
				AllowRaidServers = false,
			})
		end)
		if not success or type(serverList) ~= "table" then
			VVHotReload.DebugWarn("ServerHop", "FetchGameServers", "Game GetServerList failed", {
				PlaceKey = placeKey,
				Result = serverList,
			})
			warn("Server hop: game GetServerList failed: " .. tostring(serverList))
			return {}
		end

		local pingByServerId = VVHotReload.ServerHop.GetPublicPingByServerId(placeId)
		local servers = {}
		for _, entry in ipairs(serverList) do
			local serverId = type(entry) == "table" and entry.key
			local data = type(entry) == "table" and entry.value
			if type(serverId) == "string" and type(data) == "table" then
				local playing = tonumber(data.PCount or data.PlayerCount or data.playing) or 0
				local maxPlayers = tonumber(data.MaxPlayers or data.maxPlayers) or 15
				if serverId ~= game.JobId and playing < maxPlayers then
					table.insert(servers, {
						id = serverId,
						playing = playing,
						maxPlayers = maxPlayers,
						ping = pingByServerId[serverId],
						placeId = tonumber(data.PlaceId) or placeId,
						serverName = data.ServerName,
						location = data.Location,
						source = "GameServerList",
					})
				end
			end
		end

		VVHotReload.DebugStep("ServerHop", "FetchGameServers", {
			PlaceKey = placeKey,
			PlaceId = placeId,
			Rows = #servers,
		})
		return servers
	end

	VVHotReload.ServerHop.IsRetryableTeleportError = function(err)
		local message = tostring(err or ""):lower()
		return message:find("restricted", 1, true)
			or message:find("full", 1, true)
			or message:find("not available", 1, true)
			or message:find("unauthorized", 1, true)
			or message:find("closed", 1, true)
			or message:find("does not exist", 1, true)
			or message:find("did not start", 1, true)
			or message:find("timed out", 1, true)
	end

	VVHotReload.ServerHop.CreateTeleportMonitor = function(player)
		local monitor = {
			Started = false,
			FailedError = nil,
			Connections = {},
		}

		local onTeleportSuccess, onTeleportConnection = pcall(function()
			return player.OnTeleport:Connect(function(teleportState)
				local stateText = tostring(teleportState)
				if stateText:lower():find("failed", 1, true) then
					monitor.FailedError = "OnTeleport failed: " .. stateText
					return
				end

				monitor.Started = true
			end)
		end)
		if onTeleportSuccess and onTeleportConnection then
			table.insert(monitor.Connections, onTeleportConnection)
		end

		local teleportService = game:GetService("TeleportService")
		local initFailedSuccess, initFailedConnection = pcall(function()
			return teleportService.TeleportInitFailed:Connect(function(failedPlayer, teleportResult, errorMessage)
				if failedPlayer ~= player then
					return
				end

				monitor.FailedError = tostring(errorMessage or teleportResult or "TeleportInitFailed")
			end)
		end)
		if initFailedSuccess and initFailedConnection then
			table.insert(monitor.Connections, initFailedConnection)
		end

		monitor.Disconnect = function()
			for _, connection in ipairs(monitor.Connections) do
				connection:Disconnect()
			end
			table.clear(monitor.Connections)
		end

		monitor.Wait = function(timeout)
			local startedAt = os.clock()
			while os.clock() - startedAt < (tonumber(timeout) or 4) do
				if monitor.FailedError then
					monitor.Disconnect()
					return false, monitor.FailedError
				end
				if monitor.Started then
					monitor.Disconnect()
					return true
				end
				task.wait(0.1)
			end

			monitor.Disconnect()
			return false, "teleport did not start before timeout"
		end

		return monitor
	end

	VVHotReload.ServerHop.Teleport = function(server, reason)
		if type(server) ~= "table" or type(server.id) ~= "string" then
			warn("Server hop: server was not found")
			return false, "server was not found"
		end

		local player = game:GetService("Players").LocalPlayer
		local teleportService = game:GetService("TeleportService")
		local replicatedStorage = game:GetService("ReplicatedStorage")
		local placeId = tonumber(server.placeId or server.PlaceId) or VVHotReload.ServerHop.GamePlaceId
		warn(string.format(
			"Server hop: teleporting to %s | place %s | players %s/%s | ping %s",
			tostring(reason or server.id),
			tostring(placeId),
			tostring(server.playing or "?"),
			tostring(server.maxPlayers or "?"),
			tostring(server.ping or server.Ping or "?")
		))
		VVHotReload.DebugStep("ServerHop", "TeleportAttempt", {
			Reason = reason,
			Id = server.id,
			PlaceId = placeId,
			Players = tostring(server.playing) .. "/" .. tostring(server.maxPlayers),
			Ping = server.ping or server.Ping,
			ServerName = server.serverName,
			Location = server.location,
			Source = server.source,
			HasButton = server.button ~= nil,
		})

		local monitor = VVHotReload.ServerHop.CreateTeleportMonitor(player)
		if server.button and server.button.Parent then
			VVHotReload.DebugStep("ServerHop", "TeleportViaOriginalButton", {
				Button = server.button:GetFullName(),
				ServerName = server.serverName,
			})
			local clicked, clickErr = VVHotReload.ServerHop.ClickGuiButton(server.button)
			if clicked then
				return monitor.Wait(5)
			end
			VVHotReload.DebugWarn("ServerHop", "TeleportViaOriginalButton", "Original row click failed", clickErr)
			warn("Server hop: original server row click failed, falling back to remote: " .. tostring(clickErr))
		end

		local shouldUseGameTeleportRemote = server.source == "MenuServerList" or server.source == "GameServerList"
		local teleportRemote = shouldUseGameTeleportRemote
			and replicatedStorage:FindFirstChild("Requests")
			and replicatedStorage.Requests:FindFirstChild("TeleportToServer")
		if teleportRemote and teleportRemote:IsA("RemoteFunction") then
			local success, result = pcall(function()
				return teleportRemote:InvokeServer(server.id)
			end)
			if success then
				VVHotReload.DebugStep("ServerHop", "TeleportViaGameRemote", {ServerId = server.id})
				return monitor.Wait(4)
			end
			VVHotReload.DebugWarn("ServerHop", "TeleportViaGameRemote", "Game TeleportToServer failed", result)
			warn("Server hop: game TeleportToServer failed, falling back to TeleportService: " .. tostring(result))
		end

		local success, err = pcall(function()
			teleportService:TeleportToPlaceInstance(placeId, server.id, player)
		end)
		if not success then
			VVHotReload.DebugWarn("ServerHop", "TeleportService", "Teleport failed", err)
			warn("Server hop: teleport failed: " .. tostring(err))
			return false, tostring(err)
		end

		return monitor.Wait(4)
	end

	VVHotReload.ServerHop.JoinServersInOrder = function(servers, reasonPrefix)
		if type(servers) ~= "table" or #servers == 0 then
			warn("Server hop: no playable game servers were found")
			return false
		end

		local lastError
		for index, server in ipairs(servers) do
			VVHotReload.UltraStep("ServerHop", "JoinServersInOrderCandidate", {
				Index = index,
				Id = server.id,
				ServerName = server.serverName,
				Players = server.playing,
				Ping = server.ping or server.Ping,
				Source = server.source,
			})
			local success, err = VVHotReload.ServerHop.Teleport(
				server,
				tostring(reasonPrefix) .. " #" .. tostring(index)
			)
			if success then
				return true
			end

			lastError = err
			if VVHotReload.ServerHop.IsRetryableTeleportError(err) then
				VVHotReload.DebugWarn("ServerHop", "JoinServersInOrder", "Retryable teleport error; trying next server", err)
				warn("Server hop: skipped dead/restricted server, trying next one")
				task.wait(0.25)
				continue
			end

			VVHotReload.DebugWarn("ServerHop", "JoinServersInOrder", "Non-retryable teleport error", err)
			warn("Server hop: stopping retry loop because teleport failed with non-retryable error: " .. tostring(err))
			return false
		end

		VVHotReload.DebugWarn("ServerHop", "JoinServersInOrder", "All candidate servers failed", lastError)
		warn("Server hop: all candidate servers failed" .. (lastError and (" | last error: " .. tostring(lastError)) or ""))
		return false
	end

	VVHotReload.ServerHop.JoinLowestPlayer = function()
		if not VVHotReload.ServerHop.EnsureCharacterSelected() then
			return false
		end
		VVHotReload.ServerHop.PrepareServerListGui()

		local targetPlaceId, targetPlaceName, targetPlaceKey = VVHotReload.ServerHop.GetMenuTargetPlaceId()
		local servers = VVHotReload.ServerHop.GetMenuServerRows(targetPlaceId)
		if #servers > 0 then
			VVHotReload.DebugStep("ServerHop", "JoinLowestPlayerUsingVisibleRows", {Rows = #servers, Target = targetPlaceName})
			warn("Server hop: using visible game server list rows: " .. tostring(#servers))
		else
			servers = VVHotReload.ServerHop.FetchGameServers(targetPlaceKey, targetPlaceId)
			VVHotReload.DebugStep("ServerHop", "JoinLowestPlayerUsingBackendRows", {Rows = #servers, Target = targetPlaceName})
			warn("Server hop: using game backend server list rows: " .. tostring(#servers))
		end
		table.sort(servers, function(a, b)
			local aPlayers = tonumber(a.playing) or math.huge
			local bPlayers = tonumber(b.playing) or math.huge
			if aPlayers == bPlayers then
				return (tonumber(a.ping or a.Ping) or math.huge) < (tonumber(b.ping or b.Ping) or math.huge)
			end
			return aPlayers < bPlayers
		end)

		return VVHotReload.ServerHop.JoinServersInOrder(
			servers,
			"lowest player " .. tostring(targetPlaceName) .. " server"
		)
	end

	VVHotReload.ServerHop.JoinLowestPing = function()
		if not VVHotReload.ServerHop.EnsureCharacterSelected() then
			return false
		end
		VVHotReload.ServerHop.PrepareServerListGui()

		local targetPlaceId, targetPlaceName, targetPlaceKey = VVHotReload.ServerHop.GetMenuTargetPlaceId()
		local servers = VVHotReload.ServerHop.GetMenuServerRows(targetPlaceId)
		if #servers > 0 then
			VVHotReload.DebugStep("ServerHop", "JoinLowestPingUsingVisibleRows", {Rows = #servers, Target = targetPlaceName})
			warn("Server hop: using visible game server list rows: " .. tostring(#servers))
		else
			servers = VVHotReload.ServerHop.FetchGameServers(targetPlaceKey, targetPlaceId)
			VVHotReload.DebugStep("ServerHop", "JoinLowestPingUsingBackendRows", {Rows = #servers, Target = targetPlaceName})
			warn("Server hop: using game backend server list rows: " .. tostring(#servers))
		end
		local sawPing = false
		for _, server in ipairs(servers) do
			if tonumber(server.ping or server.Ping) then
				sawPing = true
				break
			end
		end

		if sawPing then
			table.sort(servers, function(a, b)
				local aPing = tonumber(a.ping or a.Ping) or math.huge
				local bPing = tonumber(b.ping or b.Ping) or math.huge
				if aPing == bPing then
					return (tonumber(a.playing) or math.huge) < (tonumber(b.playing) or math.huge)
				end
				return aPing < bPing
			end)
		else
			warn("Server hop: Roblox server list did not include ping; joining lowest player game server instead")
			table.sort(servers, function(a, b)
				return (tonumber(a.playing) or math.huge) < (tonumber(b.playing) or math.huge)
			end)
		end

		return VVHotReload.ServerHop.JoinServersInOrder(
			servers,
			"lowest ping " .. tostring(targetPlaceName) .. " server"
		)
	end

	VVHotReload.ServerHop.PatchedButtons = VVHotReload.ServerHop.PatchedButtons or {}
	VVHotReload.ServerHop.GetGuiButtonText = function(guiObject)
		if guiObject:IsA("TextButton") or guiObject:IsA("TextLabel") then
			return guiObject.Text
		end

		for _, descendant in ipairs(guiObject:GetDescendants()) do
			if descendant:IsA("TextButton") or descendant:IsA("TextLabel") then
				local text = tostring(descendant.Text or "")
				if text:find("Join Lowest Player Server", 1, true)
					or text:find("Join Lowest Ping Server", 1, true)
				then
					return text
				end
			end
		end

		return ""
	end

	VVHotReload.ServerHop.PatchExistingButtons = function()
		local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
		if not playerGui then
			return
		end

		for _, descendant in ipairs(playerGui:GetDescendants()) do
			if descendant:IsA("GuiButton") and not VVHotReload.ServerHop.PatchedButtons[descendant] then
				local text = VVHotReload.ServerHop.GetGuiButtonText(descendant)
				if tostring(text):find("Join Lowest Player Server", 1, true) then
					VVHotReload.ServerHop.PatchedButtons[descendant] = true
					descendant.MouseButton1Click:Connect(function()
						task.spawn(VVHotReload.ServerHop.JoinLowestPlayer)
					end)
				elseif tostring(text):find("Join Lowest Ping Server", 1, true) then
					VVHotReload.ServerHop.PatchedButtons[descendant] = true
					descendant.MouseButton1Click:Connect(function()
						task.spawn(VVHotReload.ServerHop.JoinLowestPing)
					end)
				end
			end
		end
	end

	task.defer(VVHotReload.ServerHop.PatchExistingButtons)
end

installVVHotReloadValues()

if VVExecutionGuard.__VVUltimatumExecuted == true then
	warn("LEAF HUB: Your script is already executed; getgenv hot reload values were updated")
	return
end
VVExecutionGuard.__VVUltimatumExecuted = true

-------- UI LIBRARY
local library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Pepsied-5229/Pepsi-UI-Library/refs/heads/main/Pepsi-UI-Library.lua", true))()
local Wait = library.subs.Wait -- Only returns if the GUI has not been terminated. For 'while Wait() do' loops

function leafDebugStep(scope, step, details)
	local hotReload = type(getgenv) == "function" and getgenv().VVUltimatum or _G.VVUltimatum
	if hotReload and type(hotReload.DebugStep) == "function" then
		return hotReload.DebugStep(scope, step, details)
	end
end

function leafDebugWarn(scope, route, desc, details)
	local hotReload = type(getgenv) == "function" and getgenv().VVUltimatum or _G.VVUltimatum
	if hotReload and type(hotReload.DebugWarn) == "function" then
		return hotReload.DebugWarn(scope, route, desc, details)
	end
end

function leafUltraStep(scope, step, details)
	local hotReload = type(getgenv) == "function" and getgenv().VVUltimatum or _G.VVUltimatum
	if hotReload and type(hotReload.UltraStep) == "function" then
		return hotReload.UltraStep(scope, step, details)
	end
end

function leafUltraWarn(scope, route, desc, details)
	local hotReload = type(getgenv) == "function" and getgenv().VVUltimatum or _G.VVUltimatum
	if hotReload and type(hotReload.UltraWarn) == "function" then
		return hotReload.UltraWarn(scope, route, desc, details)
	end
end




-------- VARIABLES
-- GetService, Plr and other default variables
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = cloneref(Players.LocalPlayer)
local Workspace = cloneref(game:GetService("Workspace"))
local TweenService = cloneref(game:GetService("TweenService"))
local RunService = cloneref(game:GetService("RunService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local KeyframeSequenceProvider = cloneref(game:GetService("KeyframeSequenceProvider"))
local Stats = cloneref(game:GetService("Stats"))
local VirtualInputManager = game:GetService("VirtualInputManager")




-- Important logic, function variables, game specific variables
local NetworkManager = require(ReplicatedStorage.SharedModules.NetworkManager)

VVHotReload.Invisibility = VVHotReload.Invisibility or {}
local DesiredWalkSpeed
local TeleportState = {
	InstaBlitzDistance = 50,
	BlitzEnemyRadius = 30,
	SoruRadius = 100,
	WallOffset = 3,
}
local IsWalkspeedAlreadyBeingUsed = false
local WalkSpeedToggle
local WalkSpeedPressedKeybind
local WalkSpeedPressedKeyHeld = false

local whoToKillTable = nil

local NpcTypes = {
	"BatHollow",
	"CentipedeHollow",
	"DragonflyHollow",
	"FloatingHollow",
	"LizardHollow",
	"MantisHollow",
	"ScorpionHollow",
	"TurtleHollow",
}
local NpcTypeSet = {}
local AutoFarmNpcTypes = {"All"}
for _, npcType in ipairs(NpcTypes) do
	NpcTypeSet[npcType] = true
	table.insert(AutoFarmNpcTypes, npcType)
end

local DefaultNpcKillOffset = {X = 0, Y = 0, Z = 8.3}
local NpcKillOffsets = {}
local SelectedNpcOffsetType = NpcTypes[1]
local IsLoadingNpcOffsetProfile = false
local NpcOffsetSaveTask
local NpcOffsetFileWarningShown = false
local NpcOffsetConfigFile = "VV_Ultimatum_NpcKillOffsets.json"

local whoToKillBossTable = nil
local BossNames = {
	"Giant Dragonfly",
}
local AutoFarmBossNames = {"All"}
local BossNameSet = {}
for _, bossName in ipairs(BossNames) do
	table.insert(AutoFarmBossNames, bossName)
	BossNameSet[bossName] = true
end

local DefaultBossKillOffset = {X = 0, Y = 0, Z = 8.3}
local BossKillOffsets = {}
local SelectedBossOffsetName = BossNames[1]
local IsLoadingBossOffsetProfile = false
local BossOffsetSaveTask
local BossOffsetFileWarningShown = false
local BossOffsetConfigFile = "VV_Ultimatum_BossKillOffsets.json"
local AutoKillDynamicState = {
	ScanStarted = false,
	ScanInterval = 5,
	Mode = "NPC",
	UI = {},
	Connections = {},
	NpcRows = {},
	BossRows = {},
	LoadingControls = false,
}

local AutoQuestState = {
	Profiles = {},
	ProfileOrder = {},
	ProfileSet = {},
	PlayerData = require(ReplicatedStorage.SharedModules.PlayerData),
	QuestCache = require(ReplicatedStorage.SharedAssets.Info.QuestCache),
	UpdateMainQuestRemote = ReplicatedStorage.Requests:WaitForChild("UpdateMainQuest"),
	File = "VV_Ultimatum_QuestProfiles.json",
	SaveTask = nil,
	FileWarningShown = false,
	Settings = {
		AutoDetect = true,
		AutoAccept = false,
		AutoComplete = false,
		AvailableOnly = false,
		ScanInterval = 5,
		AcceptRadius = 10000,
	},
	ScanStarted = false,
	SelectedQuestKey = nil,
	Status = "Idle",
	Busy = false,
	ExecutorTask = nil,
	Gui = nil,
	UI = {},
	Connections = {},
	Rows = {},
	SearchText = "",
	LastAcceptedQuestKey = nil,
	LastScanAt = 0,
	AcceptCooldowns = {},
	ReturnCooldowns = {},
	QuestRules = {
		["Primal Urges"] = {
			ObjectivePattern = "any hollow",
			Type = "KillCategory",
			Category = "AnyHollow",
		},
		["The Start of Your Training"] = {
			ObjectivePattern = "complete 3 quests",
			Type = "SwitchQuest",
			RequireObjectivePattern = true,
		},
		["Uncover the statue's mystery"] = {
			ObjectivePattern = "uncover the statue s mystery",
			Type = "SwitchQuest",
			RequireObjectivePattern = true,
		},
		["Primal Urges Pt. 2"] = {
			ObjectivePattern = "gain progress",
			Type = "KillCategory",
			Category = "AnyHollow",
		},
	},
	SwitchQuestBlacklist = {
		["Statue Mystery"] = true,
	},
	KnownQuestGivers = {
		{
			ModelName = "SweetwaterLeader",
			DisplayName = "Kiwa",
			SpeakerName = "Kiwa",
		},
	},
}

local AutoConfigState = {
	Persistence = nil,
	SaveTask = nil,
	LastJson = nil,
	Loading = false,
	FileWarningShown = false,
	File = "VV_Ultimatum_AutoConfig.json",
}

local AnimationProfiles = {}
local AnimationProfilesFile = "VV_Ultimatum_AnimationProfiles.json"
local AnimationProfilesSaveTask
local AnimationProfilesFileWarningShown = false
local SourcePreviewTemplates = {}
local AnalysisEnabled = false
local CaptureRadius = 100
local ResponseDistance = 40
local ResponseHoldTime = 0.08
local PingMultiplier = 0.5
local UseReplicatorPing = false
local ReplicatorPingWarningShown = false
local AnimationSettingsLoadedFromFile = false
local SelectedAnimationSourceKey
local SelectedAnimationId
local IsLoadingAnimationProfile = false
local AnimationObserverActive = false
local AnimationObserverConnections = {}
local BoundAnimationModels = {}
local BoundAnimators = {}
local PendingResponseTracks = {}
local ResponseHeartbeatConnection
local ActiveResponse
local AnimationEntryToProfile = {}
local AnimationProfileToEntry = {}

local VisualizerGui
local VisualizerUpdateConnection
local VisualizerTracks = {}
local VisualizerRigs = {}
local VisualizerKeyframes = {}
local VisualizerPaused = false
local VisualizerMode = "Source"
local VisualizerKeyframeSequence
local VisualizerUI = {}
local VisualizerConnections = {}
local VisualizerListConnections = {}
local VisualizerPreviewGeneration = 0
local VisualizerSearchText = ""
local VisualizerExpandedSources = {}

local AnimationVisualizerHotReload = VVExecutionGuard.VVUltimatum.AnimationVisualizer
AnimationVisualizerHotReload.State.AnimationProfiles = AnimationProfiles
AnimationVisualizerHotReload.State.SourcePreviewTemplates = SourcePreviewTemplates
AnimationVisualizerHotReload.State.VisualizerUI = VisualizerUI

local FlyState = {
	Tween = nil,
	TweenId = 0,
	Speed = 60,
	Flying = false,
	Connection = nil,
	Attachment = nil,
	Velocity = nil,
	Orientation = nil,
	Humanoid = nil,
	PreviousAutoRotate = nil,
}

local IsKilling = false
local AutoRespawnState = {
	Enabled = false,
	DiedConnection = nil,
	CharacterAddedConnection = nil,
	CharacterRemovingConnection = nil,
	CharacterAncestryConnection = nil,
	Task = nil,
}
local PriorityState = {
	Name = nil,
	Priority = math.huge,
	Token = 0,
	AllowMovement = false,
	AutoEatTask = nil,
}
local ESPState = {
	ShowNames = true,
	ShowDistance = true,
	UpdateConnection = nil,
}
local AutoRainbowState = {
	Task = nil,
}
local AutoRainbowHighlightState = {
	Task = nil,
	Tween = nil,
	Highlight = nil,
	Preset = "Slow Rainbow",
}
local AutoRainbowHighlightPresets = {
	"CamokeyRed",
	"U...good?",
	"Slow Rainbow",
}

local playerAddedConnection
local characterConnections = {}

local Noclipping

local TakeFallDamageHookEnabled = false -- makes player ignore all fall damage




-------- FUNCTIONS
-- LUARMOR FUNCTION
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

local function getHumanoid()
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	return character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
end

local function isLocalPlayerMenos()
	local character = LocalPlayer.Character
	if not character then
		return false
	end

	local status = character:FindFirstChild("Status")
	local values = {
		character:GetAttribute("Race"),
		character:GetAttribute("HollowType"),
		character:GetAttribute("RaceType"),
		character:GetAttribute("CharacterType"),
		character:GetAttribute("Form"),
	}

	for _, valueName in ipairs({"Race", "HollowType", "RaceType", "CharacterType", "Form", "HollowForm"}) do
		local valueObject = status and status:FindFirstChild(valueName)
		if valueObject and valueObject:IsA("StringValue") then
			table.insert(values, valueObject.Value)
		end
	end

	for _, value in ipairs(values) do
		if string.find(string.lower(tostring(value or "")), "menos", 1, true) then
			return true
		end
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local raceValue = status and status:FindFirstChild("Race")
	local raceText = raceValue and raceValue:IsA("StringValue") and string.lower(raceValue.Value) or ""
	return raceText == "hollow" and humanoid ~= nil and humanoid.HipHeight >= 60
end

local function getEffectiveKillOffset(offset)
	local effectiveOffset = offset or DefaultNpcKillOffset
	if isLocalPlayerMenos() then
		return {
			X = effectiveOffset.X,
			Y = effectiveOffset.Y + 60,
			Z = effectiveOffset.Z,
		}
	end

	return effectiveOffset
end

local function pressBlockOrParry(HowLongToPress)
    local Event = ReplicatedStorage.Requests.Mouse2
    Event:FireServer()

	local EventCombat = ReplicatedStorage.Requests.Combat
	EventCombat:FireServer(
		"Feint"
	)

    EventCombat:FireServer(
        "Block",
        true
    )

    task.wait(.15)

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
    local Event = ReplicatedStorage.Requests.Mouse2
    Event:FireServer()

	local EventCombat = ReplicatedStorage.Requests.Combat
	EventCombat:FireServer(
		"Feint"
	)

    local EventRedCounter = ReplicatedStorage.Requests.RedCounter
    EventRedCounter:FireServer()

	task.wait(.15)

    EventRedCounter:FireServer()
end

local function pressDash()
    local Event = ReplicatedStorage.Requests.Mouse2
    Event:FireServer()

	local EventCombat = ReplicatedStorage.Requests.Combat
	EventCombat:FireServer(
		"Feint"
	)

    local EventDash = ReplicatedStorage.Requests.Dash
    EventDash:InvokeServer(
        "LookVector",
        -73
    )

	task.wait(.15)

	EventDash:InvokeServer(
        "LookVector",
        -73
    )
end

local function VelocityTeleport(distance)
	local hotReload = VVExecutionGuard.VVUltimatum
	if hotReload and type(hotReload.VelocityTeleport) == "function" then
		hotReload.VelocityTeleportWallOffset = TeleportState.WallOffset
		return hotReload.VelocityTeleport(distance)
	end

	warn("VelocityTeleport: getgenv implementation is missing")
	return false
end

function getInvisibilityHook()
	VVHotReload.Invisibility.RakHook = VVHotReload.Invisibility.RakHook or function(packet)
		if not packet or packet.PacketId ~= 0x1B then
			return
		end

		if type(buffer) ~= "table" or type(buffer.writeu32) ~= "function" then
			return
		end

		local packetBuffer = packet.AsBuffer
		if not packetBuffer or type(packet.SetData) ~= "function" then
			return
		end

		buffer.writeu32(packetBuffer, 1, 0xFFFFFFFF)
		packet:SetData(packetBuffer)
	end

	return VVHotReload.Invisibility.RakHook
end

function setInvisibilityEnabled(value)
	if type(raknet) ~= "table"
		or type(raknet.add_send_hook) ~= "function"
		or type(raknet.remove_send_hook) ~= "function"
	then
		warn("Invisibility: raknet send hooks are unavailable")
		library.Flags["flag_Invisibility"] = false
		return false
	end

	local hook = getInvisibilityHook()
	if value then
		if VVHotReload.Invisibility.Hooked then
			return true
		end

		local success, err = pcall(raknet.add_send_hook, hook)
		if not success then
			warn("Invisibility: failed to add raknet hook: " .. tostring(err))
			library.Flags["flag_Invisibility"] = false
			return false
		end

		VVHotReload.Invisibility.Hooked = true
		return true
	end

	if not VVHotReload.Invisibility.Hooked then
		return true
	end

	local success, err = pcall(raknet.remove_send_hook, hook)
	if not success then
		warn("Invisibility: failed to remove raknet hook: " .. tostring(err))
		return false
	end

	VVHotReload.Invisibility.Hooked = false
	return true
end

function BlitzTeleportToNearestEnemy()
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local localRoot = character and character:FindFirstChild("HumanoidRootPart")
	local living = Workspace:FindFirstChild("Living")

	if not character or not localRoot then
		warn("Blitz Teleport To Enemy: local HumanoidRootPart was not found")
		return false
	end

	if not living then
		warn("Blitz Teleport To Enemy: Workspace.Living was not found")
		return false
	end

	local nearestPart
	local nearestDistance = TeleportState.BlitzEnemyRadius
	for _, object in living:GetChildren() do
		if object ~= character then
			local targetPart
			if object:IsA("Model") then
				local humanoid = object:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health <= 0 then
					continue
				end
				targetPart = object:FindFirstChild("HumanoidRootPart")
					or object.PrimaryPart
					or object:FindFirstChildWhichIsA("BasePart", true)
			elseif object:IsA("BasePart") then
				targetPart = object
			end

			if targetPart and targetPart.Parent then
				local distance = (localRoot.Position - targetPart.Position).Magnitude
				if distance <= nearestDistance then
					nearestPart = targetPart
					nearestDistance = distance
				end
			end
		end
	end

	if not nearestPart then
		warn("Blitz Teleport To Enemy: no Workspace.Living target was found within " .. tostring(TeleportState.BlitzEnemyRadius) .. " studs")
		return false
	end

	character:PivotTo(nearestPart.CFrame * CFrame.new(0, 0, 1))
	return true
end

function SoruTeleportToMouse()
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local camera = Workspace.CurrentCamera

	if not character or not root then
		warn("Soru Teleport: local HumanoidRootPart was not found")
		return false
	end

	if not camera then
		warn("Soru Teleport: CurrentCamera was not found")
		return false
	end

	local radius = math.max(1, tonumber(TeleportState.SoruRadius) or 100)
	local mousePosition = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local rayDirection = ray.Direction.Unit * radius
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.IgnoreWater = true

	local result = Workspace:Raycast(ray.Origin, rayDirection, raycastParams)
	local targetPosition
	if result then
		targetPosition = result.Position + (result.Normal * TeleportState.WallOffset)
	else
		targetPosition = ray.Origin + rayDirection
	end

	local currentPivot = character:GetPivot()
	character:PivotTo(CFrame.new(targetPosition) * (currentPivot - currentPivot.Position))
	return true
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

local function beginPriorityTask(taskName, priority)
	priority = tonumber(priority) or math.huge
	if PriorityState.Name and PriorityState.Priority < priority then
		return nil
	end

	PriorityState.Token += 1
	PriorityState.Name = tostring(taskName or "Task")
	PriorityState.Priority = priority
	return PriorityState.Token
end

local function isPriorityTaskActive(token)
	return token ~= nil and PriorityState.Token == token
end

local function finishPriorityTask(token)
	if isPriorityTaskActive(token) then
		PriorityState.Name = nil
		PriorityState.Priority = math.huge
		PriorityState.AllowMovement = false
	end
end

local function interruptMovementAndKilling()
	IsKilling = false

	if FlyState.Tween then
		pcall(function()
			FlyState.Tween:Cancel()
		end)
	end

	local startedAt = os.clock()
	while FlyState.Tween and os.clock() - startedAt < 2 do
		task.wait()
	end

	if FlyState.Tween then
		FlyState.Tween = nil
		if Noclipping then
			Noclipping:Disconnect()
			Noclipping = nil
		end
	end
end

local function sendVimKeyPress(keyCode, holdTime)
	VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
	task.wait(holdTime or 0.03)
	VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

local function getNearestHollowRemains(maxDistance)
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local debris = Workspace:FindFirstChild("Debris")
	if not root or not debris then
		return nil
	end

	local nearest
	local nearestDistance = maxDistance or 30
	for _, child in debris:GetChildren() do
		if child.Name == "HollowRemains" then
			local part
			if child:IsA("BasePart") then
				part = child
			elseif child:IsA("Model") then
				part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
			end

			if part and part.Parent then
				local distance = (root.Position - part.Position).Magnitude
				if distance <= nearestDistance then
					nearest = part
					nearestDistance = distance
				end
			end
		end
	end

	return nearest, nearestDistance
end

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

local function getCharacterMovementPart(character)
	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.RootPart then
		return humanoid.RootPart
	end

	if character.PrimaryPart and character.PrimaryPart:IsA("BasePart") then
		return character.PrimaryPart
	end

	local preferredNames = {
		"HumanoidRootPart",
		"RootPart",
		"Torso",
		"UpperTorso",
		"LowerTorso",
		"Body",
		"Head",
	}

	for _, partName in ipairs(preferredNames) do
		local part = character:FindFirstChild(partName, true)
		if part and part:IsA("BasePart") then
			return part
		end
	end

	local biggestPart
	local biggestVolume = -math.huge
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local size = descendant.Size
			local volume = size.X * size.Y * size.Z
			if volume > biggestVolume then
				biggestVolume = volume
				biggestPart = descendant
			end
		end
	end

	return biggestPart
end

local function flyTo(objectCFrame, speedOfFly)
	TakeFallDamageHookEnabled = true -- TakeFallDamageHookEnabled needs to be "true" all the time, dont change it

	if typeof(objectCFrame) ~= "CFrame" or type(speedOfFly) ~= "number" or speedOfFly <= 0 then
		print("Wrong arguments")
		return false
	end

	if PriorityState.Name and PriorityState.Priority <= 1 and not PriorityState.AllowMovement then
		print("flyTo blocked by priority task: ", PriorityState.Name)
		return false
	end

	local character = GetCharacter()
	local root = getCharacterMovementPart(character)
	if not root then
		return false
	end

	if FlyState.Tween then
		print("FlyTween, cancel.")
		return false
	end

	local distance = (root.Position - objectCFrame.Position).Magnitude
	if distance <= 0.1 then
		return true
	end

	local debris = Workspace:FindFirstChild("Debris")
	local marshTeleporters = debris and debris:FindFirstChild("MarshTeleporters")
	if marshTeleporters then
		for i, v in marshTeleporters:GetChildren() do -- makes certain zones in game untouchable, so player wouldnt accidentally touch certain objects and get teleported while flying to desired object
			v.CanTouch = false
		end
	end

	StartNoClipFunc()

	local flyTime = distance / speedOfFly
	FlyState.TweenId += 1
	local currentFlyTweenId = FlyState.TweenId
	local finishedEvent = Instance.new("BindableEvent")
	local finished = false
	local playbackState
	local currentPivot = character:GetPivot()
	local rootOffset = currentPivot:ToObjectSpace(root.CFrame)
	local targetPivot = objectCFrame * rootOffset:Inverse()
	local pivotValue = Instance.new("CFrameValue")
	pivotValue.Value = currentPivot
	local pivotConnection = pivotValue:GetPropertyChangedSignal("Value"):Connect(function()
		if currentFlyTweenId == FlyState.TweenId and character and character.Parent then
			character:PivotTo(pivotValue.Value)
		end
	end)

	FlyState.Tween = TweenService:Create(
		pivotValue,
		TweenInfo.new(flyTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{Value = targetPivot}
	)

	FlyState.Tween:Play()
	FlyState.Tween.Completed:Once(function(state)
		if currentFlyTweenId ~= FlyState.TweenId or finished then
			return
		end

		finished = true
		playbackState = state
		finishedEvent:Fire()
	end)

	task.delay(150, function()
		if currentFlyTweenId ~= FlyState.TweenId or finished then
			return
		end

		finished = true
		playbackState = Enum.PlaybackState.Cancelled
		if FlyState.Tween then
			FlyState.Tween:Cancel()
		end
		finishedEvent:Fire()
	end)

	finishedEvent.Event:Wait()
	finishedEvent:Destroy()
	pivotConnection:Disconnect()
	pivotValue:Destroy()

	if currentFlyTweenId == FlyState.TweenId then
		FlyState.Tween = nil
		NoClipDisableFunc()

		if marshTeleporters and marshTeleporters.Parent then
			for i, v in marshTeleporters:GetChildren() do -- reverts the changes that were made by this function at the very start
				v.CanTouch = true
			end
		end
	end

	if playbackState == Enum.PlaybackState.Completed then
		print("flyTo Tween completed")
		return true
	end

	print("flyTo timed out")
	return false
end

local function eatHollowRemains(remains)
	if not remains or not remains.Parent then
		return false
	end

	local token = beginPriorityTask("AutoEatHollowParts", 1)
	if not token then
		return false
	end

	interruptMovementAndKilling()

	local success = false
	if remains and remains.Parent then
		PriorityState.AllowMovement = true
		success = flyTo(remains.CFrame * CFrame.new(0, 2, 0), 150)
		PriorityState.AllowMovement = false

		if remains and remains.Parent then
			for _ = 1, 3 do
				sendVimKeyPress(Enum.KeyCode.T, 0.04)
				task.wait(0.08)
			end
		end
	end

	finishPriorityTask(token)
	return success
end

local function resetNpcKillOffsets()
	for _, npcType in ipairs(NpcTypes) do
		NpcKillOffsets[npcType] = {
			X = DefaultNpcKillOffset.X,
			Y = DefaultNpcKillOffset.Y,
			Z = DefaultNpcKillOffset.Z,
		}
	end
end

local function hasNpcOffsetFileFunctions()
	local available = type(isfile) == "function"
		and type(readfile) == "function"
		and type(writefile) == "function"

	if not available and not NpcOffsetFileWarningShown then
		NpcOffsetFileWarningShown = true
		warn("NPC offset profiles: isfile/readfile/writefile are unavailable; profiles will only last for this session")
	end

	return available
end

local function sanitizeNpcOffsetCoordinate(value, fallback)
	local numberValue = tonumber(value)
	if not numberValue or numberValue ~= numberValue then
		return fallback
	end

	return math.clamp(numberValue, -50, 50)
end

local function loadNpcKillOffsets()
	resetNpcKillOffsets()

	if not hasNpcOffsetFileFunctions() then
		return false
	end

	local isFileSuccess, configExists = pcall(isfile, NpcOffsetConfigFile)
	if not isFileSuccess then
		warn("NPC offset profiles: failed to check config file: " .. tostring(configExists))
		return false
	end

	if not configExists then
		return true
	end

	local readSuccess, content = pcall(readfile, NpcOffsetConfigFile)
	if not readSuccess then
		warn("NPC offset profiles: failed to read config file: " .. tostring(content))
		return false
	end

	local decodeSuccess, decoded = pcall(function()
		return HttpService:JSONDecode(content)
	end)

	if not decodeSuccess or type(decoded) ~= "table" or type(decoded.Offsets) ~= "table" then
		warn("NPC offset profiles: config is damaged; default coordinates will be used")
		return false
	end

	if type(decoded.Types) == "table" then
		for _, npcType in decoded.Types do
			if type(npcType) == "string" and npcType ~= "" then
				registerDiscoveredNpcType(npcType, true, true)
			end
		end
	end

	for npcType, savedOffset in decoded.Offsets do
		if type(npcType) == "string" and npcType ~= "" and type(savedOffset) == "table" then
			registerDiscoveredNpcType(npcType, true, true)
			NpcKillOffsets[npcType] = {
				X = sanitizeNpcOffsetCoordinate(savedOffset.X, DefaultNpcKillOffset.X),
				Y = sanitizeNpcOffsetCoordinate(savedOffset.Y, DefaultNpcKillOffset.Y),
				Z = sanitizeNpcOffsetCoordinate(savedOffset.Z, DefaultNpcKillOffset.Z),
			}
		end
	end

	return true
end

local function saveNpcKillOffsets()
	if not hasNpcOffsetFileFunctions() then
		return false
	end

	local encodeSuccess, encoded = pcall(function()
		return HttpService:JSONEncode({
			Version = 2,
			Types = NpcTypes,
			Offsets = NpcKillOffsets,
		})
	end)

	if not encodeSuccess then
		warn("NPC offset profiles: failed to encode config: " .. tostring(encoded))
		return false
	end

	local writeSuccess, writeError = pcall(writefile, NpcOffsetConfigFile, encoded)
	if not writeSuccess then
		warn("NPC offset profiles: failed to save config: " .. tostring(writeError))
		return false
	end

	return true
end

local function scheduleNpcKillOffsetsSave()
	if not hasNpcOffsetFileFunctions() then
		return
	end

	if NpcOffsetSaveTask then
		task.cancel(NpcOffsetSaveTask)
	end

	NpcOffsetSaveTask = task.delay(0.35, function()
		NpcOffsetSaveTask = nil
		saveNpcKillOffsets()
	end)
end

local function resetBossKillOffsets()
	for _, bossName in ipairs(BossNames) do
		BossKillOffsets[bossName] = {
			X = DefaultBossKillOffset.X,
			Y = DefaultBossKillOffset.Y,
			Z = DefaultBossKillOffset.Z,
		}
	end
end

local function hasBossOffsetFileFunctions()
	local available = type(isfile) == "function"
		and type(readfile) == "function"
		and type(writefile) == "function"

	if not available and not BossOffsetFileWarningShown then
		BossOffsetFileWarningShown = true
		warn("Boss offset profiles: isfile/readfile/writefile are unavailable; profiles will only last for this session")
	end

	return available
end

local function sanitizeBossOffsetCoordinate(value, fallback)
	local numberValue = tonumber(value)
	if not numberValue or numberValue ~= numberValue then
		return fallback
	end

	return math.clamp(numberValue, -50, 50)
end

local function loadBossKillOffsets()
	resetBossKillOffsets()

	if not hasBossOffsetFileFunctions() then
		return false
	end

	local isFileSuccess, configExists = pcall(isfile, BossOffsetConfigFile)
	if not isFileSuccess then
		warn("Boss offset profiles: failed to check config file: " .. tostring(configExists))
		return false
	end

	if not configExists then
		return true
	end

	local readSuccess, content = pcall(readfile, BossOffsetConfigFile)
	if not readSuccess then
		warn("Boss offset profiles: failed to read config file: " .. tostring(content))
		return false
	end

	local decodeSuccess, decoded = pcall(function()
		return HttpService:JSONDecode(content)
	end)

	if not decodeSuccess or type(decoded) ~= "table" or type(decoded.Offsets) ~= "table" then
		warn("Boss offset profiles: config is damaged; default coordinates will be used")
		return false
	end

	if type(decoded.BossNames) == "table" then
		for _, bossName in decoded.BossNames do
			if type(bossName) == "string" and bossName ~= "" then
				registerDiscoveredBossName(bossName, true, true)
			end
		end
	end

	for bossName, savedOffset in decoded.Offsets do
		if type(bossName) == "string" and bossName ~= "" and type(savedOffset) == "table" then
			registerDiscoveredBossName(bossName, true, true)
			BossKillOffsets[bossName] = {
				X = sanitizeBossOffsetCoordinate(savedOffset.X, DefaultBossKillOffset.X),
				Y = sanitizeBossOffsetCoordinate(savedOffset.Y, DefaultBossKillOffset.Y),
				Z = sanitizeBossOffsetCoordinate(savedOffset.Z, DefaultBossKillOffset.Z),
			}
		end
	end

	return true
end

local function saveBossKillOffsets()
	if not hasBossOffsetFileFunctions() then
		return false
	end

	local encodeSuccess, encoded = pcall(function()
		return HttpService:JSONEncode({
			Version = 2,
			BossNames = BossNames,
			Offsets = BossKillOffsets,
		})
	end)

	if not encodeSuccess then
		warn("Boss offset profiles: failed to encode config: " .. tostring(encoded))
		return false
	end

	local writeSuccess, writeError = pcall(writefile, BossOffsetConfigFile, encoded)
	if not writeSuccess then
		warn("Boss offset profiles: failed to save config: " .. tostring(writeError))
		return false
	end

	return true
end

local function scheduleBossKillOffsetsSave()
	if not hasBossOffsetFileFunctions() then
		return
	end

	if BossOffsetSaveTask then
		task.cancel(BossOffsetSaveTask)
	end

	BossOffsetSaveTask = task.delay(0.35, function()
		BossOffsetSaveTask = nil
		saveBossKillOffsets()
	end)
end

function normalizeDynamicListName(value)
	local text = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
	return text ~= "" and text or nil
end

function ensureNpcKillOffsetProfile(npcType)
	if NpcKillOffsets[npcType] then
		return
	end

	NpcKillOffsets[npcType] = {
		X = DefaultNpcKillOffset.X,
		Y = DefaultNpcKillOffset.Y,
		Z = DefaultNpcKillOffset.Z,
	}
end

function ensureBossKillOffsetProfile(bossName)
	if BossKillOffsets[bossName] then
		return
	end

	BossKillOffsets[bossName] = {
		X = DefaultBossKillOffset.X,
		Y = DefaultBossKillOffset.Y,
		Z = DefaultBossKillOffset.Z,
	}
end

function rebuildAutoFarmNpcTypes()
	table.clear(AutoFarmNpcTypes)
	table.insert(AutoFarmNpcTypes, "All")
	for _, npcType in ipairs(NpcTypes) do
		table.insert(AutoFarmNpcTypes, npcType)
	end
end

function rebuildAutoFarmBossNames()
	table.clear(AutoFarmBossNames)
	table.insert(AutoFarmBossNames, "All")
	for _, bossName in ipairs(BossNames) do
		table.insert(AutoFarmBossNames, bossName)
	end
end

function refreshAutoKillTargetDropdowns()
	if VVNpcTypesDropdown then
		VVNpcTypesDropdown:UpdateList(AutoFarmNpcTypes, false)
	end
	if VVNpcOffsetProfileDropdown then
		VVNpcOffsetProfileDropdown:UpdateList(NpcTypes, false)
	end
	if VVBossesDropdown then
		VVBossesDropdown:UpdateList(AutoFarmBossNames, false)
	end
	if VVBossOffsetProfileDropdown then
		VVBossOffsetProfileDropdown:UpdateList(BossNames, false)
	end
	if type(refreshAutoKillMenuLists) == "function" then
		refreshAutoKillMenuLists()
	end
end

function registerDiscoveredNpcType(npcType, skipDropdownRefresh, skipSave)
	npcType = normalizeDynamicListName(npcType)
	if not npcType or NpcTypeSet[npcType] then
		return false
	end

	NpcTypeSet[npcType] = true
	table.insert(NpcTypes, npcType)
	ensureNpcKillOffsetProfile(npcType)
	rebuildAutoFarmNpcTypes()

	if not skipDropdownRefresh then
		refreshAutoKillTargetDropdowns()
	end

	if not skipSave then
		scheduleNpcKillOffsetsSave()
	end

	return true
end

function registerDiscoveredBossName(bossName, skipDropdownRefresh, skipSave)
	bossName = normalizeDynamicListName(bossName)
	if not bossName or BossNameSet[bossName] then
		return false
	end

	BossNameSet[bossName] = true
	table.insert(BossNames, bossName)
	ensureBossKillOffsetProfile(bossName)
	rebuildAutoFarmBossNames()

	if not skipDropdownRefresh then
		refreshAutoKillTargetDropdowns()
	end

	if not skipSave then
		scheduleBossKillOffsetsSave()
	end

	return true
end

function getStatusValueObject(model, childName)
	local status = model and model:FindFirstChild("Status")
	return status and status:FindFirstChild(childName)
end

function getStatusString(model, childName)
	local child = getStatusValueObject(model, childName)
	if child and child:IsA("StringValue") and child.Value ~= "" then
		return child.Value
	end
	return nil
end

function getLivingHollowType(model)
	return normalizeDynamicListName(model and model:GetAttribute("HollowType"))
		or normalizeDynamicListName(getStatusString(model, "HollowType"))
end

function getLivingNpcType(model)
	local hollowType = getLivingHollowType(model)
	if hollowType then
		return hollowType
	end

	local team = normalizeDynamicListName(model and model:GetAttribute("Team"))
	if team then
		return team
	end

	if model and model:GetAttribute("TrainingDummy") == true then
		return normalizeDynamicListName(model.Name) or "Training Dummy"
	end

	return normalizeDynamicListName(model and model.Name)
		or normalizeDynamicListName(model and model:GetAttribute("DialogueTag"))
end

function hasLivingBossMarker(model)
	if not model then
		return false
	end

	if model:GetAttribute("IsBoss") == true then
		return true
	end

	return getStatusValueObject(model, "IsBoss") ~= nil
end

function getLivingBossName(model)
	if not model then
		return nil
	end

	return normalizeDynamicListName(model.Name)
		or normalizeDynamicListName(model:GetAttribute("BossName"))
		or normalizeDynamicListName(model:GetAttribute("BossTitle"))
		or normalizeDynamicListName(getStatusString(model, "BossName"))
		or normalizeDynamicListName(getStatusString(model, "BossTitle"))
		or getLivingHollowType(model)
end

function isLivingNonPlayerCombatModel(model)
	if not model or not model:IsA("Model") then
		return false
	end

	if Players:GetPlayerFromCharacter(model) then
		return false
	end

	return model:FindFirstChildOfClass("Humanoid") ~= nil
		and model:FindFirstChild("HumanoidRootPart") ~= nil
end

function isLivingBossModel(model)
	return isLivingNonPlayerCombatModel(model) and hasLivingBossMarker(model) and getLivingBossName(model) ~= nil
end

function isLivingNpcModel(model)
	return isLivingNonPlayerCombatModel(model) and not hasLivingBossMarker(model) and getLivingNpcType(model) ~= nil
end

function scanLivingForAutoKillTargets()
	local living = Workspace:FindFirstChild("Living")
	if not living then
		return false
	end

	local changed = false
	for _, model in living:GetChildren() do
		if isLivingBossModel(model) then
			changed = registerDiscoveredBossName(getLivingBossName(model), true) or changed
		elseif isLivingNpcModel(model) then
			changed = registerDiscoveredNpcType(getLivingNpcType(model), true) or changed
		end
	end

	if changed then
		refreshAutoKillTargetDropdowns()
	end

	return changed
end

function startDynamicLivingListScan()
	if AutoKillDynamicState.ScanStarted then
		return
	end

	AutoKillDynamicState.ScanStarted = true
	task.spawn(function()
		while Wait() do
			scanLivingForAutoKillTargets()
			task.wait(AutoKillDynamicState.ScanInterval)
		end
	end)
end

function hasQuestProfileFileFunctions()
	local available = type(isfile) == "function"
		and type(readfile) == "function"
		and type(writefile) == "function"

	if not available and not AutoQuestState.FileWarningShown then
		AutoQuestState.FileWarningShown = true
		warn("Quest profiles: isfile/readfile/writefile are unavailable; profiles will only last for this session")
	end

	return available
end

function rebuildQuestProfileOrder()
	table.clear(AutoQuestState.ProfileOrder)
	table.clear(AutoQuestState.ProfileSet)

	for key in AutoQuestState.Profiles do
		table.insert(AutoQuestState.ProfileOrder, key)
		AutoQuestState.ProfileSet[key] = true
	end

	table.sort(AutoQuestState.ProfileOrder, function(a, b)
		local left = AutoQuestState.Profiles[a]
		local right = AutoQuestState.Profiles[b]
		local leftName = (left and (left.DisplayName or left.ModelName or left.DialogueTag)) or a
		local rightName = (right and (right.DisplayName or right.ModelName or right.DialogueTag)) or b
		return tostring(leftName) < tostring(rightName)
	end)
end

function vector3ToQuestTable(vector)
	if typeof(vector) ~= "Vector3" then
		return nil
	end

	return {
		X = vector.X,
		Y = vector.Y,
		Z = vector.Z,
	}
end

function questTableToVector3(value)
	if type(value) ~= "table" then
		return nil
	end

	local x = tonumber(value.X)
	local y = tonumber(value.Y)
	local z = tonumber(value.Z)
	if not x or not y or not z then
		return nil
	end

	return Vector3.new(x, y, z)
end

function normalizeQuestId(value)
	if value == nil then
		return nil
	end

	local numeric = tonumber(value)
	if numeric then
		return numeric
	end

	local text = normalizeDynamicListName(value)
	return text
end

function sanitizeQuestConfigValue(value, depth, seen)
	depth = depth or 0
	seen = seen or {}
	local valueType = typeof(value)
	if valueType == "Vector3" then
		return vector3ToQuestTable(value)
	end
	if valueType == "CFrame" then
		return vector3ToQuestTable(value.Position)
	end
	if valueType == "EnumItem" then
		return tostring(value)
	end
	if valueType == "Instance" or valueType == "function" or valueType == "thread" or valueType == "userdata" then
		return nil
	end
	if type(value) ~= "table" then
		return value
	end
	if depth > 5 or seen[value] then
		return nil
	end

	seen[value] = true
	local result = {}
	for key, child in value do
		local cleanChild = sanitizeQuestConfigValue(child, depth + 1, seen)
		if cleanChild ~= nil then
			result[tostring(key)] = cleanChild
		end
	end
	seen[value] = nil
	return result
end

function getQuestLevelRequirement(questInfo, fallbackText)
	local requirements = questInfo and questInfo.Requirements
	local level = type(requirements) == "table" and tonumber(requirements.Level) or nil
	if level then
		return level
	end

	local textLevel = tostring(fallbackText or ""):match("LVL%s*(%d+)")
	return tonumber(textLevel)
end

function readQuestBillboardText(model)
	if not model then
		return nil
	end

	local questGiver = model:FindFirstChild("QuestGiver", true)
	if not questGiver then
		return nil
	end

	local texts = {}
	for _, descendant in questGiver:GetDescendants() do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			local text = normalizeDynamicListName(stripQuestRichText(descendant.Text))
			if text then
				table.insert(texts, text)
			end
		end
	end

	return #texts > 0 and table.concat(texts, " | ") or nil
end

function getQuestMarkerDetails(questInfo, originPosition)
	local details = {}
	local character = LocalPlayer.Character
	local root = character and (
		character:FindFirstChild("HumanoidRootPart")
		or character.PrimaryPart
		or character:FindFirstChildWhichIsA("BasePart", true)
	)
	local origin = typeof(originPosition) == "Vector3" and originPosition or (root and root.Position)
	local objectives = questInfo and questInfo.Objectives
	if type(objectives) ~= "table" then
		return details
	end

	for objectiveIndex, objective in objectives do
		local markers = objective and objective.Markers
		if type(markers) == "table" then
			for markerIndex, marker in markers do
				local detail = {
					ObjectiveIndex = tostring(objectiveIndex),
					MarkerIndex = tostring(markerIndex),
					PlaceName = normalizeDynamicListName(marker and marker.PlaceName),
				}

				if marker and type(marker.GetPosition) == "function" then
					local ok, position = pcall(marker.GetPosition)
					detail.GetPositionOk = ok == true
					if ok then
						local positionType = typeof(position)
						if positionType == "Vector3" then
							detail.Position = vector3ToQuestTable(position)
							detail.DistanceStuds = origin and math.floor((origin - position).Magnitude + 0.5) or nil
						elseif positionType == "CFrame" then
							detail.Position = vector3ToQuestTable(position.Position)
							detail.DistanceStuds = origin and math.floor((origin - position.Position).Magnitude + 0.5) or nil
						else
							detail.ValueType = positionType
							detail.Value = normalizeDynamicListName(position)
						end
					else
						detail.Error = normalizeDynamicListName(position)
					end
				end

				table.insert(details, detail)
			end
		end
	end

	table.sort(details, function(a, b)
		return (tonumber(a.DistanceStuds) or math.huge) < (tonumber(b.DistanceStuds) or math.huge)
	end)
	return details
end

function getNearestQuestMarkerDistance(markerDetails)
	local nearest = type(markerDetails) == "table" and markerDetails[1] or nil
	return nearest and tonumber(nearest.DistanceStuds) or nil
end

function getQuestModelRoot(model)
	return model and (
		model:FindFirstChild("HumanoidRootPart")
		or model.PrimaryPart
		or model:FindFirstChildWhichIsA("BasePart", true)
	)
end

function getQuestModelCFrame(model)
	local root = getQuestModelRoot(model)
	return root and root.CFrame or nil
end

function findQuestPrompt(model)
	if not model then
		return nil
	end

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("ProximityPrompt") then
			return descendant
		end
	end

	return nil
end

function getQuestGiverInfo(model)
	if not model or not model:IsA("Model") then
		return nil
	end

	local dialogueTag = normalizeDynamicListName(model:GetAttribute("DialogueTag"))
	local questId = normalizeDynamicListName(model:GetAttribute("QuestId"))
	local prompt = findQuestPrompt(model)
	if not prompt then
		return nil
	end

	local modelName = normalizeDynamicListName(model.Name)
	local hasQuestLine = model:FindFirstChild("QuestLine") ~= nil
	local hasQuestBillboard = model:FindFirstChild("QuestGiver", true) ~= nil
	if not dialogueTag and not questId and not hasQuestLine and not hasQuestBillboard then
		return nil
	end

	local root = getQuestModelRoot(model)
	local position = root and root.Position or nil
	local questIdValue = normalizeQuestId(questId)
	local questInfo = questIdValue and getAutoQuestInfo(questIdValue) or nil
	local billboardText = readQuestBillboardText(model)
	local markerDetails = getQuestMarkerDetails(questInfo, position)
	local displayName = modelName
		or dialogueTag
		or questId

	return {
		Key = dialogueTag or questId or modelName,
		DisplayName = displayName,
		ModelName = modelName,
		DialogueTag = dialogueTag,
		QuestId = questId,
		QuestTitle = normalizeDynamicListName(questInfo and questInfo.QuestTitle),
		QuestDescription = normalizeDynamicListName(questInfo and questInfo.Description),
		QuestStartArea = normalizeDynamicListName(questInfo and questInfo.StartArea),
		LevelRequirement = getQuestLevelRequirement(questInfo, billboardText),
		QuestRequirements = sanitizeQuestConfigValue(questInfo and questInfo.Requirements),
		QuestRewards = sanitizeQuestConfigValue(questInfo and questInfo.Rewards),
		QuestObjectives = sanitizeQuestConfigValue(questInfo and questInfo.Objectives),
		QuestMarkerDetails = markerDetails,
		NearestMarkerDistanceStuds = getNearestQuestMarkerDistance(markerDetails),
		BillboardText = billboardText,
		QuestAvailable = model:GetAttribute("QuestAvailable") == true,
		SpeakToHollows = model:GetAttribute("SpeakToHollows") == true or model:GetAttribute("CanSpeakToHollows") == true,
		LastPosition = vector3ToQuestTable(position),
		LastSeen = os.time(),
		PromptPath = prompt:GetFullName(),
	}
end

function mergeQuestProfile(key, info, skipSave)
	key = normalizeDynamicListName(key)
	if not key or type(info) ~= "table" then
		return false
	end

	local profile = AutoQuestState.Profiles[key]
	local isNew = profile == nil
	if not profile then
		profile = {}
		AutoQuestState.Profiles[key] = profile
	end
	local changed = isNew
	local function assign(field, value)
		if value ~= nil and profile[field] ~= value then
			profile[field] = value
			changed = true
		end
	end
	local function assignTable(field, value)
		if type(value) ~= "table" then
			return
		end

		local encodedNew = HttpService:JSONEncode(value)
		local encodedOld = type(profile[field]) == "table" and HttpService:JSONEncode(profile[field]) or nil
		if encodedNew ~= encodedOld then
			profile[field] = value
			changed = true
		end
	end

	assign("DisplayName", normalizeDynamicListName(info.DisplayName) or profile.DisplayName or key)
	assign("ModelName", normalizeDynamicListName(info.ModelName) or profile.ModelName)
	assign("DialogueTag", normalizeDynamicListName(info.DialogueTag) or profile.DialogueTag)
	assign("QuestId", normalizeDynamicListName(info.QuestId) or profile.QuestId)
	assign("QuestTitle", normalizeDynamicListName(info.QuestTitle) or profile.QuestTitle)
	assign("QuestDescription", normalizeDynamicListName(info.QuestDescription) or profile.QuestDescription)
	assign("QuestStartArea", normalizeDynamicListName(info.QuestStartArea) or profile.QuestStartArea)
	assign("LevelRequirement", tonumber(info.LevelRequirement) or profile.LevelRequirement)
	assign("NearestMarkerDistanceStuds", tonumber(info.NearestMarkerDistanceStuds) or profile.NearestMarkerDistanceStuds)
	assign("BillboardText", normalizeDynamicListName(info.BillboardText) or profile.BillboardText)
	assign("QuestAvailable", info.QuestAvailable == true)
	assign("SpeakToHollows", info.SpeakToHollows == true)
	assign("PromptPath", normalizeDynamicListName(info.PromptPath) or profile.PromptPath)
	assignTable("QuestRequirements", sanitizeQuestConfigValue(info.QuestRequirements))
	assignTable("QuestRewards", sanitizeQuestConfigValue(info.QuestRewards))
	assignTable("QuestObjectives", sanitizeQuestConfigValue(info.QuestObjectives))
	assignTable("QuestMarkerDetails", sanitizeQuestConfigValue(info.QuestMarkerDetails))
	assignTable("DialogueOptions", sanitizeQuestConfigValue(info.DialogueOptions))
	assignTable("DialogueSnapshots", sanitizeQuestConfigValue(info.DialogueSnapshots))
	profile.LastSeen = tonumber(info.LastSeen) or os.time()

	if type(info.LastPosition) == "table" and questTableToVector3(info.LastPosition) then
		local position = {
			X = tonumber(info.LastPosition.X),
			Y = tonumber(info.LastPosition.Y),
			Z = tonumber(info.LastPosition.Z),
		}
		local oldPosition = profile.LastPosition
		if type(oldPosition) ~= "table"
			or oldPosition.X ~= position.X
			or oldPosition.Y ~= position.Y
			or oldPosition.Z ~= position.Z
		then
			profile.LastPosition = position
			changed = true
		end
	end

	assign("LastQuestName", normalizeDynamicListName(info.LastQuestName))
	assign("LastObjective", normalizeDynamicListName(info.LastObjective))
	assign("TargetType", normalizeDynamicListName(info.TargetType))
	assign("SpeakerName", normalizeDynamicListName(info.SpeakerName))
	assign("ResolvedRule", normalizeDynamicListName(info.ResolvedRule))
	assign("ResolvedRuleSource", normalizeDynamicListName(info.ResolvedRuleSource))

	if changed then
		rebuildQuestProfileOrder()
		if not AutoQuestState.SelectedQuestKey then
			AutoQuestState.SelectedQuestKey = key
		end

		if not skipSave and type(refreshAutoQuestMenuLists) == "function" then
			refreshAutoQuestMenuLists()
		end

		if not skipSave then
			scheduleQuestProfilesSave()
		end
	end

	if not AutoQuestState.SelectedQuestKey then
		AutoQuestState.SelectedQuestKey = key
	end

	return changed
end

function seedKnownQuestGiverProfiles()
	local folder = Workspace:FindFirstChild("DialogueInteractables")
	local changed = false

	for _, known in ipairs(AutoQuestState.KnownQuestGivers) do
		local modelName = normalizeDynamicListName(known.ModelName)
		local speakerName = normalizeDynamicListName(known.SpeakerName)
		if modelName and speakerName then
			local model = folder and folder:FindFirstChild(modelName)
			local info = model and getQuestGiverInfo(model) or {
				Key = modelName,
				DisplayName = normalizeDynamicListName(known.DisplayName) or speakerName,
				ModelName = modelName,
				QuestAvailable = false,
				LastSeen = os.time(),
			}

			info.Key = normalizeDynamicListName(info.Key) or modelName
			info.DisplayName = normalizeDynamicListName(known.DisplayName) or normalizeDynamicListName(info.DisplayName) or speakerName
			info.ModelName = normalizeDynamicListName(info.ModelName) or modelName
			info.SpeakerName = speakerName
			changed = mergeQuestProfile(info.Key, info, true) or changed
		end
	end

	return changed
end

function saveQuestProfiles()
	if not hasQuestProfileFileFunctions() then
		return false
	end

	local encodeSuccess, encoded = pcall(function()
		return HttpService:JSONEncode({
			Version = 2,
			Settings = AutoQuestState.Settings,
			QuestGivers = AutoQuestState.Profiles,
			QuestRules = AutoQuestState.QuestRules,
		})
	end)

	if not encodeSuccess then
		warn("Quest profiles: failed to encode config: " .. tostring(encoded))
		return false
	end

	local writeSuccess, writeError = pcall(writefile, AutoQuestState.File, encoded)
	if not writeSuccess then
		warn("Quest profiles: failed to save config: " .. tostring(writeError))
		return false
	end

	return true
end

function scheduleQuestProfilesSave()
	if not hasQuestProfileFileFunctions() then
		return
	end

	if AutoQuestState.SaveTask then
		task.cancel(AutoQuestState.SaveTask)
	end

	AutoQuestState.SaveTask = task.delay(0.35, function()
		AutoQuestState.SaveTask = nil
		saveQuestProfiles()
	end)
end

function loadQuestProfiles()
	table.clear(AutoQuestState.Profiles)
	rebuildQuestProfileOrder()

	if not hasQuestProfileFileFunctions() then
		return false
	end

	local isFileSuccess, configExists = pcall(isfile, AutoQuestState.File)
	if not isFileSuccess then
		warn("Quest profiles: failed to check config file: " .. tostring(configExists))
		return false
	end

	if not configExists then
		return true
	end

	local readSuccess, content = pcall(readfile, AutoQuestState.File)
	if not readSuccess then
		warn("Quest profiles: failed to read config file: " .. tostring(content))
		return false
	end

	local decodeSuccess, decoded = pcall(function()
		return HttpService:JSONDecode(content)
	end)

	if not decodeSuccess or type(decoded) ~= "table" then
		warn("Quest profiles: config is damaged; discovered quests will be rebuilt from this session")
		return false
	end

	if type(decoded.Settings) == "table" then
		AutoQuestState.Settings.AutoAccept = decoded.Settings.AutoAccept == true
		AutoQuestState.Settings.AutoComplete = decoded.Settings.AutoComplete == true
		AutoQuestState.Settings.AvailableOnly = decoded.Settings.AvailableOnly == true
	end
	AutoQuestState.Settings.AutoDetect = true
	AutoQuestState.Settings.ScanInterval = 5
	AutoQuestState.Settings.AcceptRadius = 10000

	if type(decoded.QuestGivers) == "table" then
		for key, profile in decoded.QuestGivers do
			if type(profile) == "table" then
				mergeQuestProfile(key, profile, true)
			end
		end
	end

	if type(decoded.QuestRules) == "table" then
		for key, rule in decoded.QuestRules do
			if normalizeDynamicListName(key) and type(rule) == "table" then
				AutoQuestState.QuestRules[key] = rule
			end
		end
	end

	rebuildQuestProfileOrder()
	return true
end

function scanDialogueInteractablesForQuests(force)
	if not force and os.clock() - AutoQuestState.LastScanAt < AutoQuestState.Settings.ScanInterval then
		return false
	end
	AutoQuestState.LastScanAt = os.clock()

	local folder = Workspace:FindFirstChild("DialogueInteractables")
	if not folder then
		return false
	end

	local changed = false
	for _, model in folder:GetChildren() do
		local info = getQuestGiverInfo(model)
		if info then
			changed = mergeQuestProfile(info.Key, info, true) or changed
		end
	end
	changed = seedKnownQuestGiverProfiles() or changed

	if changed then
		refreshAutoQuestMenuLists()
		scheduleQuestProfilesSave()
	end

	return changed
end

function startQuestScanner()
	if AutoQuestState.ScanStarted then
		return
	end

	AutoQuestState.ScanStarted = true
	task.spawn(function()
		while Wait() do
			scanDialogueInteractablesForQuests()
			task.wait(5)
		end
	end)
end

function stripQuestRichText(text)
	local clean = tostring(text or "")
	clean = clean:gsub("<br%s*/?>", " ")
	clean = clean:gsub("<[^>]->", "")
	clean = clean:gsub("&quot;", "\"")
	clean = clean:gsub("%s+", " ")
	return clean:gsub("^%s+", ""):gsub("%s+$", "")
end

function readQuestTracker()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	local mainUI = playerGui and playerGui:FindFirstChild("MainUI")
	local hud = mainUI and mainUI:FindFirstChild("HUDContainer")
	local tracker = hud and hud:FindFirstChild("QuestTracker")
	local questName, objective
	if tracker and tracker.Visible then
		local questNameLabel = tracker:FindFirstChild("QuestName")
		local objectiveLabel = tracker:FindFirstChild("CurrentObjective")
		questName = questNameLabel and stripQuestRichText(questNameLabel.Text) or nil
		objective = objectiveLabel and stripQuestRichText(objectiveLabel.Text) or nil
	end

	local characterData = getAutoQuestCharacterData()
	local currentQuestId = normalizeQuestId(characterData and characterData.CurrentQuestID)
	local questInfo = currentQuestId and getAutoQuestInfo(currentQuestId) or nil
	local dataObjective = questInfo and getAutoQuestCurrentObjective(characterData, currentQuestId, questInfo) or nil
	questName = normalizeDynamicListName(questInfo and questInfo.QuestTitle) or questName
	objective = (dataObjective and not dataObjective.IsComplete and dataObjective.Text) or objective
	if dataObjective and dataObjective.IsComplete then
		objective = "Completed"
	end

	if not normalizeDynamicListName(questName) and not normalizeDynamicListName(objective) then
		return nil
	end

	local current, required = nil, nil
	if objective then
		current, required = objective:match("%((%d+)%s*/%s*(%d+)%)")
	end

	return {
		Id = currentQuestId and tostring(currentQuestId) or nil,
		RawId = currentQuestId,
		Name = normalizeDynamicListName((questName or ""):gsub("%s*%(%d+%%%%%)%s*$", "")),
		Objective = normalizeDynamicListName(objective),
		Progress = dataObjective and dataObjective.Progress or tonumber(current),
		Required = dataObjective and dataObjective.Required or tonumber(required),
		ObjectiveIndex = dataObjective and dataObjective.Index or nil,
		QuestInfo = questInfo,
		IsComplete = (dataObjective and dataObjective.IsComplete == true)
			or (tonumber(current) ~= nil and tonumber(required) ~= nil and tonumber(current) >= tonumber(required)),
	}
end

function getAutoQuestDataPlayer()
	local rawPlayers = game:GetService("Players")
	return rawPlayers and rawPlayers.LocalPlayer or LocalPlayer
end

function getAutoQuestCharacterData()
	local dataPlayer = getAutoQuestDataPlayer()
	local playerData = AutoQuestState.PlayerData
	local success, data = pcall(function()
		if dataPlayer and not playerData:GetProfile(dataPlayer) then
			playerData:WaitForProfile(dataPlayer, 2)
		end

		local characterData = dataPlayer and playerData:GetCharacterData(dataPlayer) or nil
		if type(characterData) == "table" then
			return characterData
		end

		if LocalPlayer and LocalPlayer ~= dataPlayer then
			if not playerData:GetProfile(LocalPlayer) then
				playerData:WaitForProfile(LocalPlayer, 1)
			end
			return playerData:GetCharacterData(LocalPlayer)
		end

		return nil
	end)

	if success and type(data) == "table" then
		return data
	end

	return nil
end

function getAutoQuestInfo(questId)
	local success, info = pcall(function()
		return AutoQuestState.QuestCache:GetInfoFromId(questId)
	end)

	if success and type(info) == "table" then
		return info
	end

	return nil
end

function formatAutoQuestObjective(objective)
	local success, text = pcall(function()
		return AutoQuestState.QuestCache:FormatQuestObjective(objective)
	end)

	text = success and normalizeDynamicListName(text) or nil
	if text then
		return text
	end

	return normalizeDynamicListName(objective and (objective.AppearAs or objective.Target or objective.Type)) or "Unknown objective"
end

function getAutoQuestObjectiveProgress(characterData, questId, objectiveIndex)
	local questData = characterData and characterData.QuestData
	local objectiveProgress = questData and questData.ObjectiveProgress
	local progress = objectiveProgress and (
		objectiveProgress[tostring(questId)]
		or objectiveProgress[tonumber(questId)]
		or objectiveProgress[questId]
	)
	return tonumber(progress and (progress[objectiveIndex] or progress[tostring(objectiveIndex)] or progress[tonumber(objectiveIndex)])) or 0
end

function getAutoQuestProgressPercent(characterData, questId, questInfo)
	local objectives = questInfo and questInfo.Objectives
	if type(objectives) ~= "table" then
		return 0
	end

	local total = 0
	local completed = 0
	for index, objective in ipairs(objectives) do
		if objective.Type ~= "ReturnTo" then
			total += 1
			local goal = tonumber(objective.Goal) or 1
			if getAutoQuestObjectiveProgress(characterData, questId, index) >= goal then
				completed += 1
			end
		end
	end

	return math.clamp(math.floor(completed / math.max(0.1, total) * 100), 0, 100)
end

function getAutoQuestCurrentObjective(characterData, questId, questInfo)
	local objectives = questInfo and questInfo.Objectives
	if type(objectives) ~= "table" then
		return nil
	end

	local previousCompleted = true
	for index, objective in ipairs(objectives) do
		if objective.HideUntilPreviousCompleted and not previousCompleted then
			break
		end

		local goal = tonumber(objective.Goal) or 1
		local progress = getAutoQuestObjectiveProgress(characterData, questId, index)
		local objectiveText = formatAutoQuestObjective(objective)
		if progress < goal then
			return {
				Text = string.format("%s (%d/%d)", objectiveText, progress, goal),
				Progress = progress,
				Required = goal,
				Index = index,
				Raw = objective,
			}
		end

		previousCompleted = progress >= goal
	end

	return {
		Text = "Completed",
		Progress = 1,
		Required = 1,
		IsComplete = true,
	}
end

function readOwnedAutoQuests()
	local characterData = getAutoQuestCharacterData()
	local questData = characterData and characterData.QuestData
	local activeQuests = questData and questData.ActiveQuests
	local currentQuestId = normalizeQuestId(characterData and characterData.CurrentQuestID)
	if type(activeQuests) ~= "table" then
		local tracker = readQuestTracker()
		if tracker then
			return {
				{
					Id = tracker.Id or "tracker",
					RawId = tracker.RawId,
					Name = tracker.Name or "Current quest",
					Objective = tracker.Objective or "Unknown objective",
					ProgressPercent = 0,
					IsCurrent = true,
					IsComplete = tracker.IsComplete == true,
					Resolved = resolveQuestObjective(tracker),
				},
			}
		end

		return {}
	end

	local seenQuestIds = {}
	local quests = {}
	local function addOwnedQuest(questKey, questValue)
		local questId
		if type(questValue) == "string" or type(questValue) == "number" then
			questId = normalizeQuestId(questValue)
		elseif type(questValue) == "table" then
			questId = normalizeQuestId(questValue.QuestId or questValue.QuestID or questValue.Id or questValue.ID or questKey)
		else
			questId = normalizeQuestId(questKey)
		end

		if not questId or seenQuestIds[tostring(questId)] then
			return
		end
		seenQuestIds[tostring(questId)] = true

		local questInfo = getAutoQuestInfo(questId)
		if questInfo then
			local objective = getAutoQuestCurrentObjective(characterData, questId, questInfo)
			local markerDetails = getQuestMarkerDetails(questInfo)
			local quest = {
				Id = tostring(questId),
				RawId = questId,
				Name = normalizeDynamicListName(questInfo.QuestTitle) or tostring(questId),
				Objective = objective and objective.Text or "Unknown objective",
				ProgressPercent = getAutoQuestProgressPercent(characterData, questId, questInfo),
				IsCurrent = tostring(questId) == tostring(currentQuestId),
				IsComplete = objective and objective.IsComplete == true,
				LevelRequirement = getQuestLevelRequirement(questInfo),
				NearestMarkerDistanceStuds = getNearestQuestMarkerDistance(markerDetails),
				QuestInfo = questInfo,
				QuestMarkerDetails = markerDetails,
				ObjectiveIndex = objective and objective.Index or nil,
				RawObjective = objective and objective.Raw or nil,
			}
			quest.Resolved = resolveQuestObjective({
				Name = quest.Name,
				Objective = quest.Objective,
			})
			table.insert(quests, quest)
		end
	end

	for questKey, questValue in activeQuests do
		addOwnedQuest(questKey, questValue)
	end
	if currentQuestId then
		addOwnedQuest(currentQuestId, currentQuestId)
	end

	if #quests == 0 then
		local tracker = readQuestTracker()
		if tracker then
			table.insert(quests, {
				Id = tracker.Id or "tracker",
				RawId = tracker.RawId,
				Name = tracker.Name or "Current quest",
				Objective = tracker.Objective or "Unknown objective",
				ProgressPercent = 0,
				IsCurrent = true,
				IsComplete = tracker.IsComplete == true,
				Resolved = resolveQuestObjective(tracker),
			})
		end
	end

	table.sort(quests, function(a, b)
		if a.IsCurrent ~= b.IsCurrent then
			return a.IsCurrent
		end

		return tostring(a.Name) < tostring(b.Name)
	end)

	return quests
end

function normalizeQuestTargetType(targetText)
	local target = stripQuestRichText(targetText)
	target = target:gsub("%b()", "")
	target = target:gsub("^%d+%s+of%s+", "")
	target = target:gsub("^any%s+", "")
	target = target:gsub("[^%w%s_]", "")
	target = target:gsub("^%s+", ""):gsub("%s+$", "")
	if target == "" then
		return nil
	end

	local squashed = target:gsub("%s+", "")
	for _, npcType in ipairs(NpcTypes) do
		if string.lower(npcType) == string.lower(squashed) then
			return npcType
		end
	end

	return squashed
end

function normalizeQuestText(text)
	local clean = string.lower(stripQuestRichText(text))
	clean = clean:gsub("%s+%(%d+%s*/%s*%d+%)$", "")
	clean = clean:gsub("[^%w%s_]", " ")
	clean = clean:gsub("%s+", " ")
	return clean:gsub("^%s+", ""):gsub("%s+$", "")
end

function buildQuestResolvedObjective(resolvedType, fields)
	fields = fields or {}
	fields.Type = resolvedType
	return fields
end

function resolveQuestObjectiveFromRules(tracker, cleanObjective)
	local questName = tracker and tracker.Name or nil
	local normalizedQuestName = normalizeQuestText(questName)
	local normalizedObjective = normalizeQuestText(cleanObjective)

	for ruleKey, rule in AutoQuestState.QuestRules do
		if type(rule) == "table" then
			local normalizedRuleKey = normalizeQuestText(ruleKey)
			local normalizedPattern = normalizeQuestText(rule.ObjectivePattern)
			local questMatches = normalizedRuleKey ~= "" and normalizedRuleKey == normalizedQuestName
			local objectiveMatches = normalizedPattern ~= "" and normalizedObjective:find(normalizedPattern, 1, true) ~= nil
			if objectiveMatches or (questMatches and rule.RequireObjectivePattern ~= true) then
				return buildQuestResolvedObjective(rule.Type or "Unknown", {
					Category = normalizeDynamicListName(rule.Category),
					TargetType = normalizeDynamicListName(rule.TargetType),
					TargetText = normalizeDynamicListName(rule.TargetText or cleanObjective),
					RuleSource = "QuestRules",
					RuleKey = tostring(ruleKey),
				})
			end
		end
	end

	return nil
end

function resolveQuestObjectiveV2(tracker)
	local clean = stripQuestRichText(type(tracker) == "table" and tracker.Objective or tracker)
	if clean == "" then
		return nil
	end

	local noProgress = clean:gsub("%s+%(%d+%s*/%s*%d+%)$", "")
	local action, returnTarget = noProgress:match("^(%S+)%s+to%s+(.+)$")
	local actionLower = string.lower(tostring(action or ""))
	if returnTarget and (actionLower == "return" or actionLower == "talk" or actionLower == "speak") then
		return buildQuestResolvedObjective("Return", {
			TargetText = normalizeDynamicListName(returnTarget),
			RuleSource = "dynamic",
		})
	end

	local verb, amount, categoryText = noProgress:match("^(%S+)%s+(%d+)%s+of%s+(.+)$")
	local verbLower = string.lower(tostring(verb or ""))
	local normalizedCategory = normalizeQuestText(categoryText)
	if amount and (verbLower == "kill" or verbLower == "defeat" or verbLower == "eliminate") then
		if normalizedCategory == "any hollow" or normalizedCategory == "any hollows"
			or normalizedCategory == "hollow" or normalizedCategory == "hollows"
		then
			return buildQuestResolvedObjective("KillCategory", {
				TargetText = normalizeDynamicListName(categoryText),
				Category = "AnyHollow",
				Required = tonumber(amount),
				RuleSource = "dynamic",
			})
		end
	end

	local targetText = clean:match("^Defeat%s+(.+)%s+%(%d+%s*/%s*%d+%)$")
		or clean:match("^Kill%s+(.+)%s+%(%d+%s*/%s*%d+%)$")
		or clean:match("^Eliminate%s+(.+)%s+%(%d+%s*/%s*%d+%)$")
		or clean:match("^Defeat%s+(.+)$")
		or clean:match("^Kill%s+(.+)$")
		or clean:match("^Eliminate%s+(.+)$")

	local normalizedTargetText = normalizeQuestText(targetText)
	if normalizedTargetText == "hollow" or normalizedTargetText == "hollows"
		or normalizedTargetText == "any hollow" or normalizedTargetText == "any hollows"
	then
		return buildQuestResolvedObjective("KillCategory", {
			TargetText = normalizeDynamicListName(targetText),
			Category = "AnyHollow",
			RuleSource = "dynamic",
		})
	end

	local targetType = normalizeQuestTargetType(targetText)
	if targetType then
		registerDiscoveredNpcType(targetType)
		return buildQuestResolvedObjective("KillSpecific", {
			TargetText = normalizeDynamicListName(targetText),
			TargetType = targetType,
			RuleSource = "dynamic",
		})
	end

	return resolveQuestObjectiveFromRules(type(tracker) == "table" and tracker or nil, clean)
end

function resolveQuestObjective(objective)
	return resolveQuestObjectiveV2(objective)
end

function normalizeAnimationId(animationId)
	local value = tostring(animationId or ""):gsub("%s+", "")
	local numericId = value:match("[?&]id=(%d+)") or value:match("(%d+)$")
	return numericId
end

function normalizeAnimationSourceSegment(value, fallback)
	local text = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
	text = text:gsub("[:|]", "")
	if text == "" then
		return fallback
	end
	return text
end

function getStringValue(parent, childName)
	local child = parent and parent:FindFirstChild(childName)
	if child and child:IsA("StringValue") and child.Value ~= "" then
		return child.Value
	end
	return nil
end

function splitAnimationSourceKey(sourceKey)
	local parts = {}
	for part in string.gmatch(tostring(sourceKey or ""), "[^:]+") do
		table.insert(parts, part)
	end
	return parts
end

function isRegularPlayerSourceKey(sourceKey)
	return sourceKey == "RegularPlayer" or string.sub(tostring(sourceKey or ""), 1, 14) == "RegularPlayer:"
end

function isLegacyRegularPlayerRaceSegment(segment)
	return segment == "SoulReaper"
		or segment == "Arrancar"
		or segment == "Quincy"
		or segment == "Hollow"
		or segment == "UnknownRace"
end

function simplifyRegularPlayerSourceKey(sourceKey)
	if not isRegularPlayerSourceKey(sourceKey) or sourceKey == "RegularPlayer" then
		return sourceKey
	end

	local parts = splitAnimationSourceKey(sourceKey)
	if not isLegacyRegularPlayerRaceSegment(parts[2]) then
		return sourceKey
	end

	if parts[2] == "Hollow" then
		if parts[4] and parts[5] then
			return table.concat({parts[1], parts[4], parts[5]}, ":")
		end
		if parts[4] then
			return table.concat({parts[1], parts[4]}, ":")
		end
		return "RegularPlayer"
	end

	if parts[3] and parts[4] then
		return table.concat({parts[1], parts[3], parts[4]}, ":")
	end
	if parts[3] then
		return table.concat({parts[1], parts[3]}, ":")
	end
	return "RegularPlayer"
end

function getRegularPlayerAnimationSourceData(character)
	local weaponModel = character and character:FindFirstChild("WeaponModel")
	local weaponType = normalizeAnimationSourceSegment(getStringValue(weaponModel, "WeaponType"), "Unarmed")
	local weaponModelName = weaponModel
		and normalizeAnimationSourceSegment(weaponModel:GetAttribute("WeaponModelName") or getStringValue(weaponModel, "WeaponName"), nil)
		or nil

	if weaponType ~= "Unarmed" and not weaponModelName then
		weaponModelName = weaponType
	end

	local sharedKey = "RegularPlayer:" .. weaponType
	local exactKey = weaponModelName and (sharedKey .. ":" .. weaponModelName) or sharedKey
	return {
		ExactKey = exactKey,
		SharedWeaponKey = sharedKey,
		LegacyKey = "RegularPlayer",
	}
end

function getAnimationSourceKey(model)
	if not model then
		return "Manual"
	end

	if Players:GetPlayerFromCharacter(model) then
		return getRegularPlayerAnimationSourceData(model).ExactKey
	end

	if model.Name ~= "" then
		return model.Name
	end

	local hollowType = model:GetAttribute("HollowType")
	if hollowType and hollowType ~= "" then
		return tostring(hollowType)
	end

	local status = model:FindFirstChild("Status")
	local statusHollowType = status and status:FindFirstChild("HollowType")
	if statusHollowType and statusHollowType:IsA("StringValue") and statusHollowType.Value ~= "" then
		return statusHollowType.Value
	end

	local bossTitle = model:FindFirstChild("BossTitle")
	if bossTitle and bossTitle:IsA("StringValue") and bossTitle.Value ~= "" then
		return bossTitle.Value
	end

	return tostring(model:GetAttribute("Race") or "Unknown NPC")
end

function getAnimationSourceFallbackKeys(sourceKey)
	local keys = {}
	local seen = {}
	local function add(key)
		if type(key) == "string" and key ~= "" and not seen[key] then
			seen[key] = true
			table.insert(keys, key)
		end
	end

	add(sourceKey)
	if not isRegularPlayerSourceKey(sourceKey) or sourceKey == "RegularPlayer" then
		return keys
	end

	local simplifiedSourceKey = simplifyRegularPlayerSourceKey(sourceKey)
	if simplifiedSourceKey ~= sourceKey then
		add(simplifiedSourceKey)
	end

	local parts = splitAnimationSourceKey(simplifiedSourceKey)
	if parts[2] and parts[3] then
		add(table.concat({parts[1], parts[2]}, ":"))
	end

	add("RegularPlayer")
	return keys
end

function getRelativeInstancePath(instance, ancestor)
	local path = {}
	local current = instance

	while current and current ~= ancestor do
		table.insert(path, 1, current.Name)
		current = current.Parent
	end

	if current ~= ancestor then
		return ""
	end

	return table.concat(path, ".")
end

function resolveRelativeInstancePath(root, path)
	local current = root
	for segment in string.gmatch(path or "", "[^%.]+") do
		current = current and current:FindFirstChild(segment)
		if not current then
			return nil
		end
	end
	return current
end

function getAnimationProfile(sourceKey, animationId, create)
	local sourceProfiles = AnimationProfiles[sourceKey]
	if not sourceProfiles and create then
		sourceProfiles = {}
		AnimationProfiles[sourceKey] = sourceProfiles
	end

	local profile = sourceProfiles and sourceProfiles[animationId]
	if not profile and create then
		profile = {
			Enabled = false,
			WaitBeforeResponse = 0,
			ResponseAction = "Press Right Mouse Click",
			BlockHoldTime = ResponseHoldTime,
			AnimatorPath = "",
			Length = 0,
			Speed = 1,
			Priority = "Unknown",
		}
		sourceProfiles[animationId] = profile
	end

	return profile
end

function copyAnimationProfileValues(fromProfile, toProfile)
	if not fromProfile or not toProfile then
		return false
	end

	toProfile.Enabled = fromProfile.Enabled == true
	toProfile.WaitBeforeResponse = math.clamp(tonumber(fromProfile.WaitBeforeResponse) or 0, 0, 10)
	toProfile.ResponseAction = fromProfile.ResponseAction or "Press Right Mouse Click"
	toProfile.BlockHoldTime = math.clamp(tonumber(fromProfile.BlockHoldTime) or ResponseHoldTime, 0.02, 0.3)
	toProfile.AnimatorPath = fromProfile.AnimatorPath or ""
	toProfile.Length = math.max(0, tonumber(fromProfile.Length) or 0)
	toProfile.Speed = tonumber(fromProfile.Speed) or 1
	toProfile.Priority = fromProfile.Priority or "Unknown"
	return true
end

function copyAnimationResponseSettings(fromProfile, toProfile)
	if not fromProfile or not toProfile then
		return false
	end

	toProfile.Enabled = fromProfile.Enabled == true
	toProfile.WaitBeforeResponse = math.clamp(tonumber(fromProfile.WaitBeforeResponse) or 0, 0, 10)
	toProfile.ResponseAction = fromProfile.ResponseAction or "Press Right Mouse Click"
	toProfile.BlockHoldTime = math.clamp(tonumber(fromProfile.BlockHoldTime) or ResponseHoldTime, 0.02, 0.3)
	return true
end

function isAnimationResponseConfigured(profile)
	if not profile then
		return false
	end

	return profile.Enabled == true
		or math.abs((tonumber(profile.WaitBeforeResponse) or 0)) > 0.0005
		or (profile.ResponseAction and profile.ResponseAction ~= "Press Right Mouse Click")
		or math.abs((tonumber(profile.BlockHoldTime) or ResponseHoldTime) - ResponseHoldTime) > 0.0005
end

function findAnimationProfileById(animationId, onlyEnabled, preferredSourceKey, skippedProfile)
	if not animationId then
		return nil
	end

	local preferredProfile = preferredSourceKey and getAnimationProfile(preferredSourceKey, animationId, false)
	if preferredProfile and preferredProfile ~= skippedProfile and (not onlyEnabled or preferredProfile.Enabled) then
		return preferredProfile, preferredSourceKey
	end

	local bestProfile, bestSourceKey, bestScore = nil, nil, -1
	for sourceKey, sourceProfiles in AnimationProfiles do
		local profile = sourceProfiles and sourceProfiles[animationId]
		if profile and profile ~= skippedProfile and (not onlyEnabled or profile.Enabled) then
			local score = 0
			if profile.Enabled == true then score += 4 end
			if isAnimationResponseConfigured(profile) then score += 2 end
			if sourceKey == "Manual" then score += 1 end
			if not bestProfile or score > bestScore or (score == bestScore and tostring(sourceKey) < tostring(bestSourceKey)) then
				bestProfile, bestSourceKey, bestScore = profile, sourceKey, score
			end
		end
	end

	return bestProfile, bestSourceKey
end

function syncAnimationIdResponseSettings(animationId, sourceProfile)
	if not animationId or not sourceProfile then
		return false
	end

	local changed = false
	for _, sourceProfiles in AnimationProfiles do
		local profile = sourceProfiles and sourceProfiles[animationId]
		if profile and profile ~= sourceProfile then
			copyAnimationResponseSettings(sourceProfile, profile)
			changed = true
		end
	end
	return changed
end

function forgetAnimationProfileById(animationId)
	animationId = normalizeAnimationId(animationId)
	if not animationId then
		return false
	end

	local removed = false
	local emptySources = {}
	for sourceKey, sourceProfiles in AnimationProfiles do
		if sourceProfiles and sourceProfiles[animationId] then
			sourceProfiles[animationId] = nil
			removed = true
			if next(sourceProfiles) == nil then
				table.insert(emptySources, sourceKey)
			end
		end
	end

	for _, sourceKey in emptySources do
		AnimationProfiles[sourceKey] = nil
	end

	if not removed then
		return false
	end

	if SelectedAnimationId == animationId then
		SelectedAnimationSourceKey = nil
		SelectedAnimationId = nil
	end

	for track, pending in PendingResponseTracks do
		if pending and pending.AnimationId == animationId then
			PendingResponseTracks[track] = nil
		end
	end

	rebuildAnimationEntryList()
	refreshAnimationObserver()
	scheduleAnimationProfilesSave()
	if VisualizerGui then
		showVisualizerEmptyState("Animation forgotten Capture it again with Animation Analysis")
	end
	return true
end

function getSharedAnimationSourceKey(sourceKey)
	if not isRegularPlayerSourceKey(sourceKey) or sourceKey == "RegularPlayer" then
		return nil
	end

	local parts = splitAnimationSourceKey(simplifyRegularPlayerSourceKey(sourceKey))

	if parts[2] and parts[3] then
		return table.concat({parts[1], parts[2]}, ":")
	end
	return nil
end

function getAnimationProfileMatchLevel(originalSourceKey, matchedSourceKey)
	if matchedSourceKey == originalSourceKey then
		return "Exact"
	end
	if matchedSourceKey == "RegularPlayer" then
		return "Legacy"
	end
	if not isRegularPlayerSourceKey(matchedSourceKey) then
		return "Exact"
	end

	local parts = splitAnimationSourceKey(simplifyRegularPlayerSourceKey(matchedSourceKey))
	if parts[2] and not parts[3] then
		return "Shared Weapon"
	end
	return "Exact"
end

function resolveAnimationProfile(sourceKey, animationId, onlyEnabled)
	if not animationId then
		return nil
	end

	for _, candidateSourceKey in getAnimationSourceFallbackKeys(sourceKey) do
		local profile = getAnimationProfile(candidateSourceKey, animationId, false)
		if profile and (not onlyEnabled or profile.Enabled) then
			return profile, candidateSourceKey, getAnimationProfileMatchLevel(sourceKey, candidateSourceKey)
		end
	end

	local sharedProfile, sharedSourceKey = findAnimationProfileById(animationId, onlyEnabled, sourceKey)
	if sharedProfile then
		return sharedProfile, sharedSourceKey, "Same Animation ID"
	end
	return nil
end

function formatAnimationSourceName(sourceKey)
	if isRegularPlayerSourceKey(sourceKey) then
		return table.concat(splitAnimationSourceKey(sourceKey), " / ")
	end

	if sourceKey == "RegularPlayer" then
		return sourceKey
	end

	local formatted = tostring(sourceKey or "Unknown NPC"):gsub("(%l)(%u)", "%1 %2")
	return formatted
end

function hasAnimationProfileFileFunctions()
	local available = type(isfile) == "function"
		and type(readfile) == "function"
		and type(writefile) == "function"

	if not available and not AnimationProfilesFileWarningShown then
		AnimationProfilesFileWarningShown = true
		warn("Animation profiles: isfile/readfile/writefile are unavailable; profiles will only last for this session")
	end

	return available
end

function saveAnimationProfiles()
	if not hasAnimationProfileFileFunctions() then
		return false
	end

	local encodeSuccess, encoded = pcall(function()
		return HttpService:JSONEncode({
			Version = 2,
			Settings = {
				CaptureRadius = CaptureRadius,
				ResponseDistance = ResponseDistance,
				ResponseHoldTime = ResponseHoldTime,
				PingMultiplier = PingMultiplier,
				UseReplicatorPing = UseReplicatorPing,
				LastSourceKey = SelectedAnimationSourceKey,
				LastAnimationId = SelectedAnimationId,
			},
			Profiles = AnimationProfiles,
		})
	end)
	if not encodeSuccess then
		warn("Animation profiles: failed to encode config: " .. tostring(encoded))
		return false
	end

	local writeSuccess, writeError = pcall(writefile, AnimationProfilesFile, encoded)
	if not writeSuccess then
		warn("Animation profiles: failed to save config: " .. tostring(writeError))
		return false
	end

	return true
end

function scheduleAnimationProfilesSave()
	if not hasAnimationProfileFileFunctions() then
		return
	end

	if AnimationProfilesSaveTask then
		task.cancel(AnimationProfilesSaveTask)
	end

	AnimationProfilesSaveTask = task.delay(0.35, function()
		AnimationProfilesSaveTask = nil
		saveAnimationProfiles()
	end)
end

function loadAnimationProfiles()
	AnimationProfiles = {}
	AnimationSettingsLoadedFromFile = false
	if not hasAnimationProfileFileFunctions() then
		return false
	end

	local existsSuccess, exists = pcall(isfile, AnimationProfilesFile)
	if not existsSuccess or not exists then
		return existsSuccess
	end

	local readSuccess, content = pcall(readfile, AnimationProfilesFile)
	if not readSuccess then
		warn("Animation profiles: failed to read config: " .. tostring(content))
		return false
	end

	local decodeSuccess, decoded = pcall(function()
		return HttpService:JSONDecode(content)
	end)
	if not decodeSuccess or type(decoded) ~= "table" or type(decoded.Profiles) ~= "table" then
		warn("Animation profiles: config is damaged; an empty profile list will be used")
		return false
	end

	if type(decoded.Settings) == "table" then
		local settings = decoded.Settings
		CaptureRadius = math.clamp(tonumber(settings.CaptureRadius) or CaptureRadius, 10, 300)
		ResponseDistance = math.clamp(tonumber(settings.ResponseDistance) or ResponseDistance, 5, 150)
		ResponseHoldTime = math.clamp(tonumber(settings.ResponseHoldTime) or ResponseHoldTime, 0.02, 0.3)
		PingMultiplier = math.clamp(tonumber(settings.PingMultiplier) or PingMultiplier, 0, 1)
		UseReplicatorPing = settings.UseReplicatorPing == true
		SelectedAnimationSourceKey = type(settings.LastSourceKey) == "string" and settings.LastSourceKey or nil
		SelectedAnimationId = normalizeAnimationId(settings.LastAnimationId)
		AnimationSettingsLoadedFromFile = true
	end

	for sourceKey, sourceProfiles in decoded.Profiles do
		if type(sourceKey) == "string" and type(sourceProfiles) == "table" then
			sourceKey = simplifyRegularPlayerSourceKey(sourceKey)
			for savedId, savedProfile in sourceProfiles do
				local animationId = normalizeAnimationId(savedId)
				if animationId and type(savedProfile) == "table" then
					local profile = getAnimationProfile(sourceKey, animationId, true)
					profile.Enabled = savedProfile.Enabled == true
					profile.WaitBeforeResponse = math.clamp(tonumber(savedProfile.WaitBeforeResponse) or 0, 0, 10)
					profile.ResponseAction = table.find({"Press F", "Press Right Mouse Click", "Press Q (Dash)"}, savedProfile.ResponseAction) and savedProfile.ResponseAction or "Press Right Mouse Click"
					profile.BlockHoldTime = math.clamp(tonumber(savedProfile.BlockHoldTime) or ResponseHoldTime, 0.02, 0.3)
					profile.AnimatorPath = type(savedProfile.AnimatorPath) == "string" and savedProfile.AnimatorPath or ""
					profile.Length = math.max(0, tonumber(savedProfile.Length) or 0)
					profile.Speed = tonumber(savedProfile.Speed) or 1
					profile.Priority = type(savedProfile.Priority) == "string" and savedProfile.Priority or "Unknown"
				end
			end
		end
	end

	if SelectedAnimationSourceKey and SelectedAnimationId
		and not getAnimationProfile(SelectedAnimationSourceKey, SelectedAnimationId, false) then
		SelectedAnimationSourceKey = nil
		SelectedAnimationId = nil
	end

	return true
end

function cacheSourcePreviewTemplate(model, sourceKey)
	if not model or SourcePreviewTemplates[sourceKey] then
		return
	end

	local wasArchivable = model.Archivable
	model.Archivable = true
	local cloneSuccess, template = pcall(function()
		return model:Clone()
	end)
	model.Archivable = wasArchivable

	if not cloneSuccess or not template then
		return
	end

	for _, item in template:GetDescendants() do
		if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("ModuleScript")
			or item:IsA("Sound") or item:IsA("ParticleEmitter") or item:IsA("Trail")
			or item:IsA("Beam") or item:IsA("Light") or item:IsA("Smoke")
			or item:IsA("Fire") or item:IsA("Sparkles") or item:IsA("Highlight")
			or item:IsA("BodyMover") or item:IsA("LinearVelocity") or item:IsA("AngularVelocity")
			or item:IsA("VectorForce") or item:IsA("Torque") or item:IsA("AlignPosition")
			or item:IsA("AlignOrientation") or item:IsA("LayerCollector") then
			item:Destroy()
		end
	end

	template.Name = sourceKey .. "PreviewTemplate"
	template.Parent = nil
	SourcePreviewTemplates[sourceKey] = template
end

function rebuildAnimationEntryList()
	local entries = {}
	table.clear(AnimationEntryToProfile)
	table.clear(AnimationProfileToEntry)

	for sourceKey, sourceProfiles in AnimationProfiles do
		for animationId, profile in sourceProfiles do
			local entry = string.format("%s | %s | %s", formatAnimationSourceName(sourceKey), animationId, profile.Priority or "Unknown")
			table.insert(entries, entry)
			AnimationEntryToProfile[entry] = {SourceKey = sourceKey, AnimationId = animationId}
			AnimationProfileToEntry[sourceKey .. "\31" .. animationId] = entry
		end
	end

	table.sort(entries)
	if VisualizerGui and refreshVisualizerAnimationList then
		refreshVisualizerAnimationList()
	end
	return entries
end

loadNpcKillOffsets()
loadBossKillOffsets()
loadAnimationProfiles()

local function stopFly()
	FlyState.Flying = false

	if FlyState.Connection then
		FlyState.Connection:Disconnect()
		FlyState.Connection = nil
	end

	if FlyState.Velocity then
		FlyState.Velocity:Destroy()
		FlyState.Velocity = nil
	end

	if FlyState.Orientation then
		FlyState.Orientation:Destroy()
		FlyState.Orientation = nil
	end

	if FlyState.Attachment then
		FlyState.Attachment:Destroy()
		FlyState.Attachment = nil
	end

	if FlyState.Humanoid and FlyState.Humanoid.Parent then
		FlyState.Humanoid.AutoRotate = FlyState.PreviousAutoRotate
	end

	FlyState.Humanoid = nil
	FlyState.PreviousAutoRotate = nil
end

local function fly()
	if FlyState.Flying then
		return true
	end

	local character = GetCharacter()
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and (character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5))

	if not character or character.Parent == nil or not humanoid or not root then
		warn("fly: character, Humanoid, or HumanoidRootPart was not found")
		return false
	end

	stopFly()

	FlyState.Attachment = Instance.new("Attachment")
	FlyState.Attachment.Name = "VVFlyAttachment"
	FlyState.Attachment.Parent = root

	FlyState.Velocity = Instance.new("LinearVelocity")
	FlyState.Velocity.Name = "VVFlyVelocity"
	FlyState.Velocity.Attachment0 = FlyState.Attachment
	FlyState.Velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	FlyState.Velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	FlyState.Velocity.MaxForce = math.huge
	FlyState.Velocity.VectorVelocity = Vector3.zero
	FlyState.Velocity.Parent = root

	FlyState.Orientation = Instance.new("AlignOrientation")
	FlyState.Orientation.Name = "VVFlyOrientation"
	FlyState.Orientation.Attachment0 = FlyState.Attachment
	FlyState.Orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	FlyState.Orientation.RigidityEnabled = true
	FlyState.Orientation.MaxTorque = math.huge
	FlyState.Orientation.CFrame = root.CFrame.Rotation
	FlyState.Orientation.Parent = root

	FlyState.Humanoid = humanoid
	FlyState.PreviousAutoRotate = humanoid.AutoRotate
	humanoid.AutoRotate = false

	root.AssemblyLinearVelocity = Vector3.zero
	FlyState.Flying = true

	FlyState.Connection = RunService.Heartbeat:Connect(function()
		if not FlyState.Flying or character.Parent == nil or root.Parent == nil or not FlyState.Velocity or FlyState.Velocity.Parent == nil or not FlyState.Orientation or FlyState.Orientation.Parent == nil or humanoid.Health <= 0 then
			stopFly()
			return
		end

		local camera = Workspace.CurrentCamera
		if not camera then
			FlyState.Velocity.VectorVelocity = Vector3.zero
			return
		end

		local direction = Vector3.zero
		if not UserInputService:GetFocusedTextBox() then
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				direction += camera.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				direction -= camera.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				direction += camera.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				direction -= camera.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				direction += Vector3.yAxis
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				direction -= Vector3.yAxis
			end
		end

		if direction.Magnitude > 0 then
			FlyState.Velocity.VectorVelocity = direction.Unit * FlyState.Speed
		else
			FlyState.Velocity.VectorVelocity = Vector3.zero
		end

		FlyState.Orientation.CFrame = camera.CFrame.Rotation
		root.AssemblyAngularVelocity = Vector3.zero
	end)

	return true
end

function isModelWithinDistance(model, maxDistance)
	local character = LocalPlayer.Character
	local localRoot = character and character:FindFirstChild("HumanoidRootPart")
	local targetRoot = model and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true))
	return localRoot ~= nil and targetRoot ~= nil and (localRoot.Position - targetRoot.Position).Magnitude <= maxDistance
end

function releaseActiveResponse()
	local active = ActiveResponse
	if not active then
		return
	end

	ActiveResponse = nil
	if active.ResponseTask then
		task.cancel(active.ResponseTask)
		active.ResponseTask = nil
	end
	if active.Action == "Press Right Mouse Click" then
		ReplicatedStorage.Requests.Combat:FireServer("Block", false)
	end
end

function performConfiguredResponse(action, blockHoldTime)
	if ActiveResponse then
		return false
	end

	local active = {
		Action = action,
	}
	ActiveResponse = active
	active.ResponseTask = task.spawn(function()
		local success, responseError = pcall(function()
			if action == "Press F" then
				pressCounter()
			elseif action == "Press Q (Dash)" then
				pressDash()
			elseif action == "Press Right Mouse Click" then
				pressBlockOrParry(math.clamp(tonumber(blockHoldTime) or ResponseHoldTime, 0.02, 0.3))
			else
				error("Unknown animation response action: " .. tostring(action))
			end
		end)

		if not success then
			warn("Animation response failed: " .. tostring(responseError))
			if action == "Press Right Mouse Click" then
				ReplicatedStorage.Requests.Combat:FireServer("Block", false)
			end
		end

		if ActiveResponse == active then
			ActiveResponse = nil
			active.ResponseTask = nil
		end
	end)

	return true
end

function registerObservedAnimation(model, animator, track)
	local animationId = track.Animation and normalizeAnimationId(track.Animation.AnimationId)
	if not animationId then
		return nil
	end

	local sourceKey = getAnimationSourceKey(model)
	local profile = getAnimationProfile(sourceKey, animationId, false)
	local wasNew = profile == nil
	profile = profile or getAnimationProfile(sourceKey, animationId, true)
	local sharedProfile = wasNew and findAnimationProfileById(animationId, false, nil, profile) or nil
	if sharedProfile and isAnimationResponseConfigured(sharedProfile) then
		copyAnimationResponseSettings(sharedProfile, profile)
	end
	local oldAnimatorPath = profile.AnimatorPath
	local oldLength = profile.Length
	local oldSpeed = profile.Speed
	local oldPriority = profile.Priority
	profile.AnimatorPath = getRelativeInstancePath(animator, model)
	profile.Length = math.max(profile.Length or 0, tonumber(track.Length) or 0)
	profile.Speed = tonumber(track.Speed) or 1
	profile.Priority = tostring(track.Priority):gsub("Enum.AnimationPriority.", "")
	cacheSourcePreviewTemplate(model, sourceKey)

	if wasNew or oldPriority ~= profile.Priority then
		rebuildAnimationEntryList()
	end
	if wasNew or oldAnimatorPath ~= profile.AnimatorPath or oldLength ~= profile.Length
		or oldSpeed ~= profile.Speed or oldPriority ~= profile.Priority then
		scheduleAnimationProfilesSave()
	end

	return profile, sourceKey, animationId
end

function queueTrackForResponse(model, sourceKey, animationId, track)
	local profile = resolveAnimationProfile(sourceKey, animationId, true)
	if not profile or not profile.Enabled or PendingResponseTracks[track] then
		return
	end

	if not isModelWithinDistance(model, ResponseDistance) then
		return
	end

	if track.TimePosition > profile.WaitBeforeResponse + 0.15 then
		return
	end

	PendingResponseTracks[track] = {
		Model = model,
		SourceKey = sourceKey,
		AnimationId = animationId,
	}
end

function hasEnabledAnimationProfiles()
	for _, sourceProfiles in AnimationProfiles do
		for _, profile in sourceProfiles do
			if profile.Enabled then return true end
		end
	end
	return false
end

function getResponsePingSeconds()
	if not UseReplicatorPing then
		return LocalPlayer:GetNetworkPing()
	end

	local networkStats = Stats:FindFirstChild("Network")
	local serverStats = networkStats and networkStats:FindFirstChild("ServerStatsItem")
	local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")
	if dataPing then
		local success, pingMilliseconds = pcall(dataPing.GetValue, dataPing)
		if success and type(pingMilliseconds) == "number" and pingMilliseconds >= 0 then
			return pingMilliseconds / 1000
		end
	end

	if not ReplicatorPingWarningShown then
		ReplicatorPingWarningShown = true
		warn("Auto Response: Replicator Data Ping is unavailable; falling back to GetNetworkPing()")
	end
	return LocalPlayer:GetNetworkPing()
end

function updatePendingResponses()
	local ping = getResponsePingSeconds()
	for track, pending in PendingResponseTracks do
		local profile = resolveAnimationProfile(pending.SourceKey, pending.AnimationId, true)
		local model = pending.Model
		local humanoid = model and model:FindFirstChildOfClass("Humanoid")

		if not profile or not profile.Enabled or not model or not model:IsDescendantOf(Workspace)
			or (humanoid and humanoid.Health <= 0) or not track.IsPlaying
			or not isModelWithinDistance(model, ResponseDistance) then
			PendingResponseTracks[track] = nil
		else
			local speed = math.abs(tonumber(track.Speed) or 1)
			local threshold = math.max(0, profile.WaitBeforeResponse - ping * PingMultiplier * speed)
			local currentTime = track.TimePosition

			if currentTime > profile.WaitBeforeResponse + 0.15 then
				PendingResponseTracks[track] = nil
			elseif currentTime >= threshold and performConfiguredResponse(profile.ResponseAction, profile.BlockHoldTime) then
				PendingResponseTracks[track] = nil
			end
		end
	end
end

function refreshResponseHeartbeat()
	local enabled = hasEnabledAnimationProfiles()
	if enabled and not ResponseHeartbeatConnection then
		ResponseHeartbeatConnection = RunService.Heartbeat:Connect(updatePendingResponses)
	elseif not enabled and ResponseHeartbeatConnection then
		ResponseHeartbeatConnection:Disconnect()
		ResponseHeartbeatConnection = nil
		table.clear(PendingResponseTracks)
		releaseActiveResponse()
	end
end

function disconnectAnimationObserver()
	for _, connection in AnimationObserverConnections do
		connection:Disconnect()
	end
	table.clear(AnimationObserverConnections)
	table.clear(BoundAnimationModels)
	table.clear(BoundAnimators)
	AnimationObserverActive = false
end

function handleObservedTrack(model, animator, track)
	if not track or not track.Animation then
		return
	end

	local profile
	local sourceKey = getAnimationSourceKey(model)
	local animationId = normalizeAnimationId(track.Animation.AnimationId)

	if AnalysisEnabled and isModelWithinDistance(model, CaptureRadius) then
		profile, sourceKey, animationId = registerObservedAnimation(model, animator, track)
	end

	if animationId then
		profile = profile or resolveAnimationProfile(sourceKey, animationId, true)
		if profile and profile.Enabled then
			cacheSourcePreviewTemplate(model, sourceKey)
			if model ~= LocalPlayer.Character then
				queueTrackForResponse(model, sourceKey, animationId, track)
			end
		end
	end
end

function bindAnimationModel(model)
	if BoundAnimationModels[model] or not model:IsA("Model") then
		return
	end
	BoundAnimationModels[model] = true

	local function bindAnimator(animator)
		if not animator:IsA("Animator") or BoundAnimators[animator] then
			return
		end
		BoundAnimators[animator] = true
		table.insert(AnimationObserverConnections, animator.AnimationPlayed:Connect(function(track)
			handleObservedTrack(model, animator, track)
		end))

		for _, track in animator:GetPlayingAnimationTracks() do
			handleObservedTrack(model, animator, track)
		end
	end

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("Animator") then
			bindAnimator(descendant)
		end
	end

	table.insert(AnimationObserverConnections, model.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Animator") then
			bindAnimator(descendant)
		end
	end))
end

function refreshAnimationObserver()
	local shouldRun = AnalysisEnabled or hasEnabledAnimationProfiles()
	if shouldRun and not AnimationObserverActive then
		AnimationObserverActive = true

		local function bindLivingContainer(living)
			for _, model in living:GetChildren() do
				bindAnimationModel(model)
			end
			table.insert(AnimationObserverConnections, living.ChildAdded:Connect(bindAnimationModel))
		end

		local living = Workspace:FindFirstChild("Living")
		if living then
			bindLivingContainer(living)
		end
		table.insert(AnimationObserverConnections, Workspace.ChildAdded:Connect(function(child)
			if child.Name == "Living" then
				bindLivingContainer(child)
			end
		end))

		local function bindPlayer(player)
			if player.Character then
				bindAnimationModel(player.Character)
			end
			table.insert(AnimationObserverConnections, player.CharacterAdded:Connect(bindAnimationModel))
		end

		for _, player in Players:GetPlayers() do
			bindPlayer(player)
		end
		table.insert(AnimationObserverConnections, Players.PlayerAdded:Connect(bindPlayer))
	elseif not shouldRun and AnimationObserverActive then
		disconnectAnimationObserver()
	end

	refreshResponseHeartbeat()
end

local function ChangeWalkSpeedLoop()

	if IsWalkspeedAlreadyBeingUsed then return end

	task.spawn(function()

		local humanoid = getHumanoid()

		while library.Flags["flag_WalkSpeed"] do
			task.wait()
			if humanoid then
				humanoid.WalkSpeed = DesiredWalkSpeed
			else
				humanoid = getHumanoid()
			end
		end

	end)
end

local function getWalkSpeedPressedKey()
	local key = library.Flags["flag_WalkSpeedPressedKey"]
	if typeof(key) == "EnumItem" then
		return key
	end

	if type(key) == "string" then
		local keyName = key:match("Enum%.KeyCode%.(.+)") or key
		local success, enumKey = pcall(function()
			return Enum.KeyCode[keyName]
		end)
		return success and enumKey or nil
	end

	return nil
end

local function setWalkSpeedToggle(value)
	if WalkSpeedToggle then
		WalkSpeedToggle:Set(value == true)
	else
		library.Flags["flag_WalkSpeed"] = value == true
		if value then
			ChangeWalkSpeedLoop()
		end
	end
end

local function setWalkSpeedPressedKeyHeld(value)
	if WalkSpeedPressedKeyHeld == (value == true) then
		return
	end

	WalkSpeedPressedKeyHeld = value == true
	setWalkSpeedToggle(WalkSpeedPressedKeyHeld)
end

local function getESPText(character)
	local text = {}
	local targetPlayer = Players:GetPlayerFromCharacter(character)

	if ESPState.ShowNames then
		table.insert(text, targetPlayer and targetPlayer.Name or character.Name)
	end

	if ESPState.ShowDistance then
		local localCharacter = LocalPlayer.Character
		local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
		local targetRoot = character:FindFirstChild("HumanoidRootPart")

		if localRoot and targetRoot then
			local distance = (localRoot.Position - targetRoot.Position).Magnitude
			table.insert(text, tostring(math.floor(distance + 0.5)) .. " studs")
		end
	end

	return table.concat(text, "\n")
end

local function updateESPBillboard(character)
	local billboard = character:FindFirstChild("ESPBillboard")
	if not billboard then
		return
	end

	if not billboard.Adornee then
		billboard.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
	end

	local textLabel = billboard:FindFirstChild("ESPText")
	if not textLabel then
		return
	end

	local text = getESPText(character)
	billboard.Enabled = text ~= ""
	textLabel.Text = text
end

local function updateAllESPBillboards()
	for _, player in Players:GetPlayers() do
		if player ~= LocalPlayer and player.Character then
			updateESPBillboard(player.Character)
		end
	end
end

local function addESP(character)
	if Players:GetPlayerFromCharacter(character) == LocalPlayer or character.Name == LocalPlayer.Name then
		return
	end

	if not character:FindFirstChild("ESPHighlight") then
		local highlight = Instance.new("Highlight", character)
		highlight.Name = "ESPHighlight"
		highlight.FillColor = Color3.fromRGB(0,0,0)
	end

	if not character:FindFirstChild("ESPBillboard") then
		local adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESPBillboard"
		billboard.Adornee = adornee
		billboard.AlwaysOnTop = true
		billboard.Size = UDim2.fromOffset(160, 42)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.Parent = character

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "ESPText"
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Font = Enum.Font.Code
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextStrokeTransparency = 0
		textLabel.TextScaled = true
		textLabel.Parent = billboard
	end

	updateESPBillboard(character)
	print(character, "ESP - true")
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

	playerAddedConnection = Players.PlayerAdded:Connect(function(player)
        newPlayer(player)
    end)

	if ESPState.UpdateConnection then
		ESPState.UpdateConnection:Disconnect()
	end

	ESPState.UpdateConnection = RunService.RenderStepped:Connect(updateAllESPBillboards)
end

local function disableESP()
	for _, v in pairs(Players:GetPlayers()) do
		if v.Character then
			local esp = v.Character:FindFirstChild("ESPHighlight")
			if esp then esp:Destroy() end

			local billboard = v.Character:FindFirstChild("ESPBillboard")
			if billboard then billboard:Destroy() end
		end
	end

	if playerAddedConnection then
		playerAddedConnection:Disconnect()
		playerAddedConnection = nil
	end

	for _, connection in pairs(characterConnections) do
		connection:Disconnect()
	end

	characterConnections = {}

	if ESPState.UpdateConnection then
		ESPState.UpdateConnection:Disconnect()
		ESPState.UpdateConnection = nil
	end
end

local function AutoRainbow()
	if AutoRainbowState.Task then
		return
	end

	AutoRainbowState.Task = task.spawn(function()
		while library.Flags["flag_AutoRainbow"] do
			local character = LocalPlayer.Character
			if character then
				local color = Color3.fromHSV((os.clock() * 0.35) % 1, 1, 1)
				for _, descendant in ipairs(character:GetDescendants()) do
					if descendant:IsA("BasePart") then
						descendant.Color = color
					end
				end
			end

			task.wait(0.08)
		end

		AutoRainbowState.Task = nil
	end)
end

local function DisableAutoRainbow()
	if AutoRainbowState.Task then
		task.cancel(AutoRainbowState.Task)
		AutoRainbowState.Task = nil
	end
end

local function getOrCreateAutoRainbowHighlight()
	local character = LocalPlayer.Character
	if not character then
		return nil
	end

	local highlight = character:FindFirstChild("AutoRainbowHighlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "AutoRainbowHighlight"
		highlight.FillTransparency = 0.35
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = character
	end

	return highlight
end

local function setAutoRainbowHighlightPreset(preset)
	AutoRainbowHighlightState.Preset = table.find(AutoRainbowHighlightPresets, preset) and preset or "Slow Rainbow"
	if AutoRainbowHighlightState.Tween then
		AutoRainbowHighlightState.Tween:Cancel()
		AutoRainbowHighlightState.Tween = nil
	end
end

local function tweenAutoRainbowHighlight(highlight, fillColor, outlineColor, duration)
	local tween = TweenService:Create(
		highlight,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			FillColor = fillColor,
			OutlineColor = outlineColor,
		}
	)
	AutoRainbowHighlightState.Tween = tween
	tween:Play()
	tween.Completed:Wait()
end

local function StartAutoRainbowHighlight()
	if AutoRainbowHighlightState.Task then
		return
	end

	AutoRainbowHighlightState.Task = task.spawn(function()
		while library.Flags["flag_AutoRainbowHighlight"] do
			local highlight = getOrCreateAutoRainbowHighlight()
			if highlight then
				AutoRainbowHighlightState.Highlight = highlight
				local preset = AutoRainbowHighlightState.Preset
				if preset == "CamokeyRed" then
					tweenAutoRainbowHighlight(
						highlight,
						Color3.fromRGB(18, 58, 34),
						Color3.fromRGB(85, 8, 14),
						0.35
					)
					task.wait(0.15)
				elseif preset == "U...good?" then
					highlight.FillColor = Color3.fromHSV((os.clock() * 12) % 1, 1, 1)
					highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
					task.wait(0.025)
				else
					local color = Color3.fromHSV((os.clock() * 0.22) % 1, 1, 1)
					tweenAutoRainbowHighlight(highlight, color, color, 0.45)
				end
			else
				task.wait(0.25)
			end
		end

		AutoRainbowHighlightState.Task = nil
		AutoRainbowHighlightState.Tween = nil
	end)
end

local function DisableAutoRainbowHighlight()
	if AutoRainbowHighlightState.Tween then
		AutoRainbowHighlightState.Tween:Cancel()
		AutoRainbowHighlightState.Tween = nil
	end

	if AutoRainbowHighlightState.Task then
		task.cancel(AutoRainbowHighlightState.Task)
		AutoRainbowHighlightState.Task = nil
	end

	local character = LocalPlayer.Character
	local highlight = character and character:FindFirstChild("AutoRainbowHighlight")
	if highlight then
		highlight:Destroy()
	end
	AutoRainbowHighlightState.Highlight = nil
end

local function killnpc(NPC, timeout, customOffset, flyBeforeKill)
	if PriorityState.Name == "AutoEatHollowParts" then
		return false
	end

    local char = GetCharacter()
    if not char or char.Parent == nil then return end

    if not NPC then
        return
    end

    if not NPC:FindFirstChild("HumanoidRootPart") then
        return
    end

	local function getNpcKillCFrame()
		local npcHRP = NPC and NPC:FindFirstChild("HumanoidRootPart")
		if not npcHRP then
			return nil
		end

		local hollowType = NPC:GetAttribute("HollowType")
		local offset = getEffectiveKillOffset(customOffset or NpcKillOffsets[hollowType] or DefaultNpcKillOffset)
		return npcHRP.CFrame * CFrame.new(offset.X, offset.Y, offset.Z)
	end

	if flyBeforeKill then
		local targetCFrame = getNpcKillCFrame()
		if not targetCFrame or not flyTo(targetCFrame, 150) then
			return false
		end
		char = GetCharacter()
		if not char or char.Parent == nil then
			return false
		end
	end

    IsKilling = true

    local function SetPlayerPos()
        if not char or char.Parent == nil then return end
        if IsKilling then
            if NPC then
                if NPC:FindFirstChild("HumanoidRootPart") then
                    local pos = getNpcKillCFrame()
                    if pos then
                        --local velocity = npcHRP.AssemblyLinearVelocity
                        --local ping = LocalPlayer:GetNetworkPing()

                        --local predictedPos = pos + ((velocity * (ping * math.random(1,3))) / math.random(1,2))

                        --local predictedCFrame = CFrame.lookAt(
                        --    predictedPos,
                        --    predictedPos + npcHRP.CFrame.LookVector
                        --)

                        --char:PivotTo(predictedCFrame)
						char:FindFirstChild("HumanoidRootPart").CFrame = pos
                    end
                else
                    IsKilling = false
                end
            else
                IsKilling = false
            end
        end
    end

    local function BlockBreaker() -- Auto break NPC block
        if not char or char.Parent == nil then return end

        if IsKilling then
            if not NPC or NPC.Parent == nil then
                return
            end

			local Event = ReplicatedStorage.Requests.Combat
			local EventNetwork = ReplicatedStorage.SharedModules.Dependencies.PacketNetworking.PacketNetworking_Remote

			if not GetCharacter().Status:FindFirstChild("WeaponEquipped") then
				Event:FireServer("ToggleWeapon")
				task.wait(1)
			end

            local randomNumber = math.random(1, 3)

            if NPC:FindFirstChild("Status") then
				if NPC.Status:FindFirstChild("Blocking") then

					Event:FireServer("Feint")

					if randomNumber == 1 then
						Event:FireServer("HeavyAttack", true)
					elseif randomNumber == 2 then
						EventNetwork:FireServer(
							NetworkManager:FireServer("LightAttack", true, true) -- running attack
						)
					end
				elseif NPC.Humanoid.Health <= 1 then
					task.wait(1)
					if NPC then
						if randomNumber == 1 then
							NetworkManager:FireServer("LightAttack", true, false) -- default M1 attack
						elseif randomNumber == 2 or randomNumber == 3 then
     						NetworkManager:FireServer("LightAttack", true, false) -- default M1 attack
						end
					end
					task.wait()
				elseif NPC.Humanoid.Health >= 1 then
					if randomNumber == 1 then
						EventNetwork:FireServer(
							NetworkManager:FireServer("LightAttack", true, false) -- default M1 attack
						)
					elseif randomNumber == 2 or randomNumber == 3 then
						EventNetwork:FireServer(
							NetworkManager:FireServer("LightAttack", true, false) -- default M1 attack
						)
					end
					task.wait()
				end
			end
        end
    end

    
    local TaskWait = task.delay(timeout or 80, function() -- if NPC is not killed in 80 secs, return function
        IsKilling = false
        print("KillNPC timeout returned")
        return
    end)

    local BlockBreakerTask = task.defer(function() -- use BlockBreaker in its own task, because otherwise it will lag very bad
        while IsKilling do
            task.wait()
            BlockBreaker()
        end
    end)

    while IsKilling do
        task.wait()
        char = GetCharacter()
        if not char or char.Parent == nil then print("No character in loop 'BeingTargeted'"); IsKilling = false; return end

        if NPC then
            if NPC:FindFirstChild("HumanoidRootPart") then
                task.spawn(SetPlayerPos)
            else
                task.cancel(TaskWait)
                task.cancel(BlockBreakerTask)
                IsKilling = false
                print("No HumanoidRootPart in ", NPC)
                return
            end
        else
            print("No NPC in ", NPC)
            task.cancel(TaskWait)
            task.cancel(BlockBreakerTask)
            IsKilling = false
            return
        end
    end

    print("KillNPC returned")
    task.cancel(TaskWait)
    task.cancel(BlockBreakerTask)
    return true
end

local function getDeathScreenOptions()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	local mainUI = playerGui and playerGui:FindFirstChild("MainUI")
	local hudContainer = mainUI and mainUI:FindFirstChild("HUDContainer")
	local deathScreen = hudContainer and hudContainer:FindFirstChild("DeathScreen")

	return deathScreen and deathScreen:FindFirstChild("Options")
end

local function normalizeOptionText(text)
	return string.lower((text or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function getOptionText(option)
	local texts = {}

	if option:IsA("TextLabel") or option:IsA("TextButton") then
		table.insert(texts, option.Text)
	end

	for _, descendant in option:GetDescendants() do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			table.insert(texts, descendant.Text)
		end
	end

	return normalizeOptionText(table.concat(texts, " "))
end

local function findDeathScreenButtonByText(targetText)
	local options = getDeathScreenOptions()
	if not options then
		return nil
	end

	local normalizedTarget = normalizeOptionText(targetText)

	for _, option in options:GetChildren() do
		if option:IsA("GuiObject") then
			local optionText = getOptionText(option)
			local button = option:FindFirstChildWhichIsA("GuiButton", true)

			if optionText == normalizedTarget then
				return button
			end
		end
	end

	return nil
end

local function clickGuiButton(button)
	if not button then
		warn("clickGuiButton: button is nil")
		return false
	end

	if firesignal then
		local fired = false

		betterPcall(function()
			firesignal(button.MouseButton1Click)
			fired = true
		end)

		if fired then
			return true
		end

		betterPcall(function()
			firesignal(button.Activated)
			fired = true
		end)

		if fired then
			return true
		end
	end

	local center = button.AbsolutePosition + (button.AbsoluteSize / 2)
	VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
	print("Pressing clickGuiButton")
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)

	return true
end

local function clickRespawnButton()
	local startedAt = os.clock()

	while AutoRespawnState.Enabled and os.clock() - startedAt < 20 do
		local respawnButton = findDeathScreenButtonByText("Respawn")

		if respawnButton then
			return clickGuiButton(respawnButton)
		end

		task.wait(0.25)
	end

	warn("AutoRespawn: Respawn button was not found")
	return false
end

local function AutoRespawn()
	if AutoRespawnState.DiedConnection then
		AutoRespawnState.DiedConnection:Disconnect()
		AutoRespawnState.DiedConnection = nil
	end

	if AutoRespawnState.CharacterAddedConnection then
		AutoRespawnState.CharacterAddedConnection:Disconnect()
		AutoRespawnState.CharacterAddedConnection = nil
	end

	if AutoRespawnState.CharacterRemovingConnection then
		AutoRespawnState.CharacterRemovingConnection:Disconnect()
		AutoRespawnState.CharacterRemovingConnection = nil
	end

	if AutoRespawnState.CharacterAncestryConnection then
		AutoRespawnState.CharacterAncestryConnection:Disconnect()
		AutoRespawnState.CharacterAncestryConnection = nil
	end

	if AutoRespawnState.Task then
		task.cancel(AutoRespawnState.Task)
		AutoRespawnState.Task = nil
	end

	local function queueRespawn()
		if AutoRespawnState.Task then
			task.cancel(AutoRespawnState.Task)
		end

		AutoRespawnState.Task = task.spawn(function()
			task.wait(7)

			if AutoRespawnState.Enabled then
				clickRespawnButton()
			end

			AutoRespawnState.Task = nil
		end)
	end

	local function bindCharacter(character)
		if AutoRespawnState.DiedConnection then
			AutoRespawnState.DiedConnection:Disconnect()
			AutoRespawnState.DiedConnection = nil
		end

		if AutoRespawnState.CharacterAncestryConnection then
			AutoRespawnState.CharacterAncestryConnection:Disconnect()
			AutoRespawnState.CharacterAncestryConnection = nil
		end

		if not character or character.Parent == nil then
			queueRespawn()
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
		if not humanoid then
			return
		end

		AutoRespawnState.DiedConnection = humanoid.Died:Connect(queueRespawn)
		AutoRespawnState.CharacterAncestryConnection = character.AncestryChanged:Connect(function(_, parent)
			if parent == nil then
				queueRespawn()
			end
		end)

		if humanoid.Health <= 0 or not LocalPlayer.Character or LocalPlayer.Character.Parent == nil then
			queueRespawn()
		end
	end

	AutoRespawnState.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(bindCharacter)
	AutoRespawnState.CharacterRemovingConnection = LocalPlayer.CharacterRemoving:Connect(queueRespawn)

	if LocalPlayer.Character then
		bindCharacter(LocalPlayer.Character)
	end

	if getDeathScreenOptions() then
		queueRespawn()
	end
end

local function DisableAutoRespawn()
	AutoRespawnState.Enabled = false

	if AutoRespawnState.DiedConnection then
		AutoRespawnState.DiedConnection:Disconnect()
		AutoRespawnState.DiedConnection = nil
	end

	if AutoRespawnState.CharacterAddedConnection then
		AutoRespawnState.CharacterAddedConnection:Disconnect()
		AutoRespawnState.CharacterAddedConnection = nil
	end

	if AutoRespawnState.CharacterRemovingConnection then
		AutoRespawnState.CharacterRemovingConnection:Disconnect()
		AutoRespawnState.CharacterRemovingConnection = nil
	end

	if AutoRespawnState.CharacterAncestryConnection then
		AutoRespawnState.CharacterAncestryConnection:Disconnect()
		AutoRespawnState.CharacterAncestryConnection = nil
	end

	if AutoRespawnState.Task then
		task.cancel(AutoRespawnState.Task)
		AutoRespawnState.Task = nil
	end
end


-- Auto Farms, Difficult Logic and etc functions
local function AutoKillNpc(whoToKill)
	local killList = whoToKill or nil -- table
	while library.Flags["flag_AutoFarmLevel"] do
		local living = Workspace:FindFirstChild("Living") or Workspace:WaitForChild("Living", 5)
		if not living then
			task.wait(1)
			continue
		end

		for i,v in living:GetChildren() do
			if library.Flags["flag_AutoFarmLevel"] then
				if isLivingNpcModel(v) then
					local npcType = getLivingNpcType(v)
					registerDiscoveredNpcType(npcType)

					if killList == nil then
						print("Starting flying to ", i, v)

						if v:WaitForChild("HumanoidRootPart",5) then
							flyTo(v:WaitForChild("HumanoidRootPart",5).CFrame, 150)
						end

						if library.Flags["flag_AutoFarmLevel"] then
							print("Starting killing: ", i, v)
							killnpc(v, nil, NpcKillOffsets[npcType] or DefaultNpcKillOffset)
						end
					else
						if npcType and killList[npcType] then
							print("Starting flying to ", i, v)

							if v:WaitForChild("HumanoidRootPart",5) then
								flyTo(v:WaitForChild("HumanoidRootPart",5).CFrame, 150)
							end

							if library.Flags["flag_AutoFarmLevel"] then
								print("Starting killing: ", i, v)
								killnpc(v, nil, NpcKillOffsets[npcType] or DefaultNpcKillOffset)
							end
						end
					end
				end
			else
				return
			end
		end
		task.wait()
	end
end

local function AutoKillBoss(whoToKill)
	local killList = whoToKill or nil

	while library.Flags["flag_AutoKillBoss"] do
		local living = Workspace:FindFirstChild("Living") or Workspace:WaitForChild("Living", 5)
		local foundBoss = false

		if living then
			for i, boss in living:GetChildren() do
				if not library.Flags["flag_AutoKillBoss"] then
					return
				end

				local isBoss = isLivingBossModel(boss)
				local bossName = isBoss and getLivingBossName(boss) or nil
				if bossName then
					registerDiscoveredBossName(bossName)
				end
				local isSelected = bossName and BossNameSet[bossName] and (killList == nil or killList[bossName])

				if isBoss and isSelected then
					local humanoid = boss:FindFirstChildOfClass("Humanoid")
					local root = boss:FindFirstChild("HumanoidRootPart") or boss:WaitForChild("HumanoidRootPart", 5)

					if humanoid and humanoid.Health > 0 and root then
						foundBoss = true
						print("Starting flying to boss ", i, boss)
						flyTo(root.CFrame, 150)

						if library.Flags["flag_AutoKillBoss"] and boss.Parent then
							print("Starting killing boss: ", i, boss)
							killnpc(boss, nil, BossKillOffsets[bossName] or DefaultBossKillOffset)
						end
					end
				end
			end
		end

		if not foundBoss then
			task.wait(1)
		else
			task.wait()
		end
	end
end

function setAutoQuestStatus(status)
	AutoQuestState.Status = tostring(status or "Idle")
	if AutoQuestState.UI and AutoQuestState.UI.Status then
		AutoQuestState.UI.Status.Text = "Status: " .. AutoQuestState.Status
	end
end

function clickGuiObject(guiObject)
	if not guiObject or not guiObject:IsA("GuiObject") then
		return false
	end

	local center = guiObject.AbsolutePosition + (guiObject.AbsoluteSize / 2)
	VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
	return true
end

function findLiveQuestGiver(profile)
	if type(profile) ~= "table" then
		return nil
	end

	local folder = Workspace:FindFirstChild("DialogueInteractables")
	if not folder then
		return nil
	end

	for _, model in folder:GetChildren() do
		if model:IsA("Model") then
			local dialogueTag = normalizeDynamicListName(model:GetAttribute("DialogueTag"))
			local questId = normalizeDynamicListName(model:GetAttribute("QuestId"))
			local modelName = normalizeDynamicListName(model.Name)

			if (profile.DialogueTag and dialogueTag == profile.DialogueTag)
				or (profile.QuestId and questId == profile.QuestId)
				or (profile.ModelName and modelName == profile.ModelName)
			then
				return model
			end
		end
	end

	return nil
end

function triggerQuestPrompt(model)
	local prompt = findQuestPrompt(model)
	if not prompt then
		return false
	end

	local function waitForDialogueOpened(timeout)
		local startedAt = os.clock()
		while os.clock() - startedAt < (timeout or 1.25) do
			local dialogue = getDialogueFrame()
			if dialogue and dialogue.Visible then
				return true
			end
			task.wait(0.05)
		end
		return false
	end

	local dialogue = getDialogueFrame()
	if dialogue and dialogue.Visible then
		return true
	end

	if prompt.Parent and prompt.Parent:IsA("BasePart") then
		local promptPart = prompt.Parent
		flyTo(promptPart.CFrame, 150)
		task.wait(0.2)
	end

	local keyCode = prompt.KeyboardKeyCode
	if typeof(keyCode) ~= "EnumItem" or keyCode.EnumType ~= Enum.KeyCode then
		keyCode = Enum.KeyCode.E
	end

	for _ = 1, 4 do
		if not prompt.Parent or prompt.Enabled == false then
			task.wait(0.2)
			continue
		end

		if type(fireproximityprompt) == "function" then
			pcall(fireproximityprompt, prompt)
			if waitForDialogueOpened(0.75) then
				return true
			end
		end

		pcall(function()
			prompt:InputHoldBegin()
			task.wait(math.max(prompt.HoldDuration, 0.1))
			prompt:InputHoldEnd()
		end)
		if waitForDialogueOpened(0.75) then
			return true
		end

		VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
		task.wait(math.max(prompt.HoldDuration, 0.15))
		VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
		if waitForDialogueOpened(0.75) then
			return true
		end

		task.wait(0.25)
	end

	warn("AutoQuest: failed to open dialogue with quest giver")
	return false
end

function getDialogueFrame()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	local mainUI = playerGui and playerGui:FindFirstChild("MainUI")
	local hud = mainUI and mainUI:FindFirstChild("HUDContainer")
	return hud and hud:FindFirstChild("Dialogue")
end

function readDialogueSpeakerName()
	local dialogue = getDialogueFrame()
	if not dialogue or not dialogue.Visible then
		return nil
	end

	local nameTitle = dialogue:FindFirstChild("NameTitle")
	if not nameTitle then
		return nil
	end

	local label = nameTitle:FindFirstChild("Label", true) or nameTitle:FindFirstChild("Title", true)
	if label and (label:IsA("TextLabel") or label:IsA("TextButton")) then
		return normalizeDynamicListName(label.Text)
	end

	for _, descendant in nameTitle:GetDescendants() do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			local text = normalizeDynamicListName(descendant.Text)
			if text then
				return text
			end
		end
	end

	return nil
end

function readDialogueTextSnapshot()
	local dialogue = getDialogueFrame()
	if not dialogue or not dialogue.Visible then
		return nil
	end

	local texts = {}
	for _, descendant in dialogue:GetDescendants() do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			local text = normalizeDynamicListName(stripQuestRichText(descendant.Text))
			if text and text ~= "" then
				local lower = string.lower(text)
				if lower ~= "view" and lower ~= "track" then
					table.insert(texts, text)
				end
			end
		end
	end

	return #texts > 0 and table.concat(texts, " | ") or nil
end

function readDialogueOptions()
	local dialogue = getDialogueFrame()
	if not dialogue or not dialogue.Visible then
		return {}
	end

	local options = {}
	local seen = {}
	local function addOption(text, path)
		text = normalizeDynamicListName(stripQuestRichText(text))
		if not text or text == "" or seen[text] then
			return
		end

		seen[text] = true
		table.insert(options, {
			Text = text,
			Normalized = normalizeOptionText(text),
			Path = normalizeDynamicListName(path),
			CapturedAt = os.time(),
		})
	end

	local optionFrame = dialogue:FindFirstChild("OptionFrame")
	if optionFrame then
		for _, option in optionFrame:GetChildren() do
			if option:IsA("GuiObject") then
				addOption(getOptionText(option), option:GetFullName())
			end
		end
	end

	for _, descendant in dialogue:GetDescendants() do
		if descendant:IsA("GuiButton") then
			addOption(getOptionText(descendant.Parent or descendant), descendant:GetFullName())
		end
	end

	return options
end

function captureDialogueSpeakerForQuestProfile(profile)
	if type(profile) ~= "table" then
		return false
	end

	local changed = false
	local speakerName = readDialogueSpeakerName()
	if speakerName and profile.SpeakerName ~= speakerName then
		profile.SpeakerName = speakerName
		changed = true
	end

	local options = readDialogueOptions()
	if #options > 0 then
		profile.DialogueOptions = type(profile.DialogueOptions) == "table" and profile.DialogueOptions or {}
		local seenOptions = {}
		for _, option in ipairs(profile.DialogueOptions) do
			if type(option) == "table" and option.Text then
				seenOptions[option.Text] = true
			end
		end
		for _, option in ipairs(options) do
			if option.Text and not seenOptions[option.Text] then
				table.insert(profile.DialogueOptions, option)
				seenOptions[option.Text] = true
				changed = true
			end
		end
	end

	local snapshotText = readDialogueTextSnapshot()
	if snapshotText then
		profile.DialogueSnapshots = type(profile.DialogueSnapshots) == "table" and profile.DialogueSnapshots or {}
		local snapshot = {
			SpeakerName = speakerName,
			Text = snapshotText,
			CapturedAt = os.time(),
		}
		local alreadySeen = false
		for _, existing in ipairs(profile.DialogueSnapshots) do
			if type(existing) == "table" and existing.Text == snapshotText then
				alreadySeen = true
				break
			end
		end
		if not alreadySeen then
			table.insert(profile.DialogueSnapshots, snapshot)
			changed = true
		end
	end

	if changed then
		scheduleQuestProfilesSave()
		refreshAutoQuestMenuLists()
	end
	return changed
end

function findDialogueOptionButton()
	local dialogue = getDialogueFrame()
	if not dialogue or not dialogue.Visible then
		return nil
	end

	local fallback
	for _, descendant in dialogue:GetDescendants() do
		if descendant:IsA("GuiButton") then
			local optionText = getOptionText(descendant.Parent or descendant)
			local normalized = normalizeOptionText(optionText)
			if normalized ~= "" and not normalized:find("leave") and not normalized:find("goodbye") and not normalized:find("bye") then
				if normalized:find("accept")
					or normalized:find("quest")
					or normalized:find("help")
					or normalized:find("sure")
					or normalized:find("yes")
					or normalized:find("ok")
					or normalized:find("okay")
					or normalized:find("continue")
				then
					return descendant
				end

				fallback = fallback or descendant
			end
		end
	end

	return fallback
end

function clickDialogueContinue()
	local dialogue = getDialogueFrame()
	if not dialogue or not dialogue.Visible then
		return false
	end

	local optionButton = findDialogueOptionButton()
	if optionButton then
		return clickGuiButton(optionButton)
	end

	local backing = dialogue:FindFirstChild("Backing") or dialogue:FindFirstChildWhichIsA("GuiObject", true)
	if backing then
		return clickGuiObject(backing)
	end

	return false
end

function LeaveFromDialogue()
	local dialogue = getDialogueFrame()
	if not dialogue or not dialogue.Visible then
		return false
	end

	local function waitForDialogueClosed(timeout)
		local startedAt = os.clock()
		while os.clock() - startedAt < (timeout or 1.25) do
			local currentDialogue = getDialogueFrame()
			if not currentDialogue or not currentDialogue.Visible then
				return true
			end
			task.wait(0.05)
		end
		return false
	end

	local function tryClickLeaveOption()
		local function isLeaveText(text)
			local normalized = normalizeOptionText(text)
			return normalized:find("leave", 1, true)
				or normalized:find("goodbye", 1, true)
				or normalized:find("bye", 1, true)
		end

		local currentDialogue = getDialogueFrame()
		local optionFrame = currentDialogue and currentDialogue:FindFirstChild("OptionFrame")
		if optionFrame then
			for _, option in optionFrame:GetChildren() do
				if option:IsA("GuiObject") then
					local label = option:FindFirstChild("Label")
					local labelText = label and (label:IsA("TextLabel") or label:IsA("TextButton")) and label.Text or nil
					if isLeaveText(labelText or getOptionText(option)) then
						local button = option:FindFirstChild("Button") or option:FindFirstChildWhichIsA("GuiButton", true)
						if button and button:IsA("GuiButton") and clickGuiButton(button) and waitForDialogueClosed(1.25) then
							return true
						end
						if clickGuiObject(option) and waitForDialogueClosed(1.25) then
							return true
						end
					end
				end
			end
		end

		if currentDialogue then
			for _, descendant in currentDialogue:GetDescendants() do
				if descendant:IsA("GuiButton") then
					local optionText = getOptionText(descendant.Parent or descendant)
					if isLeaveText(optionText) then
						if clickGuiButton(descendant) and waitForDialogueClosed(1.25) then
							return true
						end
					end
				end
			end
		end

		return false
	end

	local startedAt = os.clock()
	while os.clock() - startedAt < 4 do
		if tryClickLeaveOption() then
			return true
		end

		dialogue = getDialogueFrame()
		if not dialogue or not dialogue.Visible then
			return true
		end

		local backing = dialogue:FindFirstChild("Backing")
		if backing and backing:IsA("GuiObject") then
			clickGuiObject(backing)
		end

		task.wait(0.2)
	end

	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
	task.wait(0.05)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
	if waitForDialogueClosed(0.75) then
		return true
	end

	warn("AutoQuest: Leave dialogue option was not found")
	return false
end

function setQuestAcceptCooldown(profileKey, seconds, reason)
	if not profileKey then
		return
	end

	AutoQuestState.AcceptCooldowns[profileKey] = os.clock() + (tonumber(seconds) or 30)
	local profile = AutoQuestState.Profiles[profileKey]
	if profile then
		profile.LastAcceptFailureReason = normalizeDynamicListName(reason)
	end
end

function isQuestAcceptOnCooldown(profileKey)
	local untilTime = profileKey and AutoQuestState.AcceptCooldowns[profileKey]
	if not untilTime then
		return false
	end

	if os.clock() >= untilTime then
		AutoQuestState.AcceptCooldowns[profileKey] = nil
		return false
	end

	return true
end

function getAutoQuestTrackerCooldownKey(tracker)
	if type(tracker) ~= "table" then
		return nil
	end

	local questId = normalizeQuestId(tracker.RawId or tracker.Id)
	if questId then
		return tostring(questId)
	end

	local name = normalizeDynamicListName(tracker.Name)
	local objective = normalizeDynamicListName(tracker.Objective)
	if name or objective then
		return tostring(name or "?") .. "|" .. tostring(objective or "?")
	end

	return nil
end

function setQuestReturnCooldown(tracker, seconds, reason)
	local key = getAutoQuestTrackerCooldownKey(tracker)
	if not key then
		return
	end

	AutoQuestState.ReturnCooldowns[key] = {
		Until = os.clock() + (tonumber(seconds) or 45),
		Reason = normalizeDynamicListName(reason),
	}
end

function isQuestReturnOnCooldown(tracker)
	local key = getAutoQuestTrackerCooldownKey(tracker)
	local cooldown = key and AutoQuestState.ReturnCooldowns[key]
	if type(cooldown) ~= "table" then
		return false
	end

	if os.clock() >= (tonumber(cooldown.Until) or 0) then
		AutoQuestState.ReturnCooldowns[key] = nil
		return false
	end

	return true, cooldown.Reason
end

function acceptQuestFromProfileKey(profileKey)
	if isQuestAcceptOnCooldown(profileKey) then
		setAutoQuestStatus("Quest accept is cooling down")
		return false
	end

	local profile = AutoQuestState.Profiles[profileKey]
	if not profile then
		setAutoQuestStatus("Quest profile not found")
		return false
	end

	local model = findLiveQuestGiver(profile)
	if not model then
		setAutoQuestStatus("Quest giver is not spawned")
		return false
	end

	local cframe = getQuestModelCFrame(model)
	if cframe then
		setAutoQuestStatus("MovingToQuestGiver")
		if not flyTo(cframe, 150) then
			setAutoQuestStatus("Failed to reach quest giver")
			return false
		end
	end

	local before = readQuestTracker() or {}
	setAutoQuestStatus("AcceptingDialogue")
	triggerQuestPrompt(model)

	local startedAt = os.clock()
	local dialogueStartedAt
	while os.clock() - startedAt < 25 do
		local current = readQuestTracker()
		if current and (current.Name ~= before.Name or current.Objective ~= before.Objective) then
			AutoQuestState.LastAcceptedQuestKey = profileKey
			profile.LastQuestName = current.Name
			profile.LastObjective = current.Objective
			local resolved = resolveQuestObjective(current)
			if resolved then
				profile.TargetType = resolved.TargetType
				profile.ResolvedRule = getQuestResolvedLabel(resolved)
				profile.ResolvedRuleSource = resolved.RuleSource
			end
			scheduleQuestProfilesSave()
			setAutoQuestStatus("Quest accepted")
			refreshAutoQuestMenuLists()
			return true
		end

		local dialogue = getDialogueFrame()
		if dialogue and dialogue.Visible then
			dialogueStartedAt = dialogueStartedAt or os.clock()
			if os.clock() - dialogueStartedAt > 5 then
				LeaveFromDialogue()
				setAutoQuestStatus("Accept dialogue timed out")
				setQuestAcceptCooldown(profileKey, 30, "Accept dialogue timed out")
				return false
			end

			captureDialogueSpeakerForQuestProfile(profile)
			clickDialogueContinue()
		else
			dialogueStartedAt = nil
		end

		task.wait(0.35)
	end

	LeaveFromDialogue()
	setAutoQuestStatus("Accept timed out")
	setQuestAcceptCooldown(profileKey, 30, "Accept timed out or quest locked")
	return false
end

function getNearestAvailableQuestProfile()
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local bestKey, bestDistance

	for _, key in ipairs(AutoQuestState.ProfileOrder) do
		local profile = AutoQuestState.Profiles[key]
		if profile and profile.QuestAvailable == true and not isQuestAcceptOnCooldown(key) then
			local position = questTableToVector3(profile.LastPosition)
			local distance = root and position and (root.Position - position).Magnitude or 0
			if distance <= AutoQuestState.Settings.AcceptRadius and (not bestDistance or distance < bestDistance) then
				bestKey = key
				bestDistance = distance
			end
		end
	end

	return bestKey
end

function modelMatchesQuestTarget(model, resolved)
	if not resolved or not isLivingNpcModel(model) then
		return false
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local npcRoot = model:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not npcRoot then
		return false
	end

	if resolved.Type == "KillSpecific" then
		return getLivingNpcType(model) == resolved.TargetType
	end

	if resolved.Type == "KillCategory" and resolved.Category == "AnyHollow" then
		return getLivingHollowType(model) ~= nil
	end

	return false
end

function findQuestTarget(resolved)
	local living = Workspace:FindFirstChild("Living")
	if not living then
		return nil
	end

	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local bestNpc, bestDistance

	for _, model in living:GetChildren() do
		if modelMatchesQuestTarget(model, resolved) then
			local npcRoot = model:FindFirstChild("HumanoidRootPart")
			local distance = root and npcRoot and (root.Position - npcRoot.Position).Magnitude or 0
			if not bestDistance or distance < bestDistance then
				bestNpc = model
				bestDistance = distance
			end
		end
	end

	return bestNpc
end

function getQuestResolvedLabel(resolved)
	if not resolved then
		return "Unknown"
	end

	if resolved.Type == "KillSpecific" then
		return "KillSpecific " .. tostring(resolved.TargetType or "?")
	end

	if resolved.Type == "KillCategory" then
		return "KillCategory " .. tostring(resolved.Category or "?")
	end

	if resolved.Type == "Return" then
		return "Return " .. tostring(resolved.TargetText or "?")
	end

	if resolved.Type == "SwitchQuest" then
		return "SwitchQuest"
	end

	return tostring(resolved.Type or "Unknown")
end

function isAutoQuestCompletableResolved(resolved)
	return resolved
		and (resolved.Type == "KillSpecific" or resolved.Type == "KillCategory" or resolved.Type == "Return")
end

function isAutoQuestSwitchBlacklisted(quest)
	if not quest then
		return true
	end

	local fields = {
		quest.Name,
		quest.Objective,
		quest.Id,
		quest.RawId,
	}

	for _, field in ipairs(fields) do
		local normalizedField = normalizeQuestText(field)
		if normalizedField ~= "" then
			for blockedName, blocked in AutoQuestState.SwitchQuestBlacklist do
				if blocked == true and normalizedField == normalizeQuestText(blockedName) then
					return true
				end
			end
		end
	end

	return false
end

function switchToOwnedAutoQuest(quest)
	if not quest then
		return false
	end

	setAutoQuestStatus("Switching quest: " .. tostring(quest.Name))
	local targetQuestId = normalizeQuestId(quest.RawId or quest.Id)
	if not targetQuestId then
		warn("AutoQuest: cannot switch quest without quest id: " .. tostring(quest.Name))
		setAutoQuestStatus("Failed to switch quest")
		return false
	end

	local success, result = pcall(function()
		AutoQuestState.UpdateMainQuestRemote:FireServer(targetQuestId)
	end)

	if not success then
		warn("AutoQuest: failed to switch quest: " .. tostring(result))
		setAutoQuestStatus("Failed to switch quest")
		return false
	end

	local switched = false
	local startedAt = os.clock()
	while os.clock() - startedAt < 2 do
		local characterData = getAutoQuestCharacterData()
		local currentQuestId = normalizeQuestId(characterData and characterData.CurrentQuestID)
		if tostring(currentQuestId) == tostring(targetQuestId) then
			switched = true
			break
		end
		task.wait(0.15)
	end

	refreshAutoQuestMenuLists()
	if not switched then
		warn("AutoQuest: UpdateMainQuest fired, but CurrentQuestID did not become " .. tostring(targetQuestId))
		setAutoQuestStatus("Failed to switch quest")
		return false
	end

	setAutoQuestStatus("Switched quest: " .. tostring(quest.Name))
	return true
end

function switchToBestOwnedAutoQuest(currentTracker)
	local currentName = currentTracker and currentTracker.Name
	local ownedQuests = readOwnedAutoQuests()
	local preferredCandidates = {}
	local fallbackCandidates = {}

	for _, quest in ipairs(ownedQuests) do
		if not quest.IsCurrent
			and not quest.IsComplete
			and quest.Name ~= currentName
			and not isAutoQuestSwitchBlacklisted(quest)
		then
			if isAutoQuestCompletableResolved(quest.Resolved) then
				table.insert(preferredCandidates, quest)
			elseif quest.Resolved and quest.Resolved.Type ~= "SwitchQuest" then
				table.insert(fallbackCandidates, quest)
			end
		end
	end

	local candidates = #preferredCandidates > 0 and preferredCandidates or fallbackCandidates
	if #candidates > 0 then
		local selected = candidates[math.random(1, #candidates)]
		return switchToOwnedAutoQuest(selected)
	end

	setAutoQuestStatus("No switchable owned quest")
	return false
end

function questProfileTextMatchesTarget(profile, targetText)
	local target = string.lower(tostring(targetText or ""))
	if target == "" or not profile then
		return false
	end

	local fields = {
		profile.SpeakerName,
		profile.DisplayName,
		profile.ModelName,
		profile.DialogueTag,
		profile.QuestId,
		profile.LastQuestName,
	}

	for _, value in fields do
		local text = string.lower(tostring(value or ""))
		if text ~= "" and (text == target or text:find(target, 1, true) or target:find(text, 1, true)) then
			return true
		end
	end

	return false
end

function findQuestProfileKeyForReturnTarget(tracker, targetText)
	local key = AutoQuestState.LastAcceptedQuestKey
	if key and AutoQuestState.Profiles[key] then
		return key
	end

	if tracker then
		for profileKey, profile in AutoQuestState.Profiles do
			if profile.LastQuestName == tracker.Name then
				return profileKey
			end
		end

		for profileKey, profile in AutoQuestState.Profiles do
			if profile.LastObjective == tracker.Objective then
				return profileKey
			end
		end
	end

	if targetText then
		for profileKey, profile in AutoQuestState.Profiles do
			if questProfileTextMatchesTarget(profile, targetText) then
				return profileKey
			end
		end
	end

	return nil
end

function discoverQuestGiverBySpeakerName(targetText)
	local target = string.lower(tostring(targetText or ""))
	if target == "" then
		return nil
	end

	scanDialogueInteractablesForQuests(true)

	for _, key in ipairs(AutoQuestState.ProfileOrder) do
		local profile = AutoQuestState.Profiles[key]
		if profile and questProfileTextMatchesTarget(profile, targetText) then
			return key
		end
	end

	for _, key in ipairs(AutoQuestState.ProfileOrder) do
		local profile = AutoQuestState.Profiles[key]
		if profile and normalizeDynamicListName(profile.SpeakerName) then
			continue
		end

		local model = profile and findLiveQuestGiver(profile)
		if model then
			local cframe = getQuestModelCFrame(model)
			if cframe then
				setAutoQuestStatus("Looking for quest giver: " .. tostring(targetText))
				if not flyTo(cframe, 150) then
					continue
				end
			end

			triggerQuestPrompt(model)
			local startedAt = os.clock()
			while os.clock() - startedAt < 3 do
				local speakerName = readDialogueSpeakerName()
				if speakerName then
					captureDialogueSpeakerForQuestProfile(profile)
					LeaveFromDialogue()
					if string.lower(speakerName) == target then
						return key
					end
					break
				end
				task.wait(0.15)
			end
		end

		task.wait(0.1)
	end

	return nil
end

function getQuestObjectiveMarkerPositions(tracker)
	local positions = {}
	local questInfo = tracker and tracker.QuestInfo
	local objectives = questInfo and questInfo.Objectives
	if type(objectives) ~= "table" then
		return positions
	end

	local objectiveIndexes = {}
	if tracker.ObjectiveIndex then
		table.insert(objectiveIndexes, tracker.ObjectiveIndex)
	end
	for index, objective in ipairs(objectives) do
		if objective.Type == "ReturnTo" then
			table.insert(objectiveIndexes, index)
		end
	end

	local seenIndexes = {}
	for _, objectiveIndex in ipairs(objectiveIndexes) do
		if not seenIndexes[objectiveIndex] then
			seenIndexes[objectiveIndex] = true
			local objective = objectives[objectiveIndex]
			local markers = objective and objective.Markers
			if type(markers) == "table" then
				for _, marker in markers do
					if type(marker.GetPosition) == "function" then
						local ok, markerPosition = pcall(marker.GetPosition)
						if ok then
							if typeof(markerPosition) == "Vector3" then
								table.insert(positions, markerPosition)
							elseif typeof(markerPosition) == "CFrame" then
								table.insert(positions, markerPosition.Position)
							end
						end
					end
				end
			end
		end
	end

	return positions
end

function findNearestQuestGiverNearPosition(position, maxDistance)
	if typeof(position) ~= "Vector3" then
		return nil
	end

	local folder = Workspace:FindFirstChild("DialogueInteractables")
	if not folder then
		return nil
	end

	local bestModel, bestInfo, bestDistance
	for _, model in folder:GetChildren() do
		local info = getQuestGiverInfo(model)
		if info then
			local root = getQuestModelRoot(model)
			local distance = root and (root.Position - position).Magnitude or math.huge
			if distance <= (maxDistance or 120) and (not bestDistance or distance < bestDistance) then
				bestModel = model
				bestInfo = info
				bestDistance = distance
			end
		end
	end

	return bestModel, bestInfo, bestDistance
end

function captureQuestGiverFromQuestMarker(tracker, targetText)
	local markerPositions = getQuestObjectiveMarkerPositions(tracker)
	if #markerPositions == 0 then
		return nil
	end

	for _, markerPosition in ipairs(markerPositions) do
		setAutoQuestStatus("Moving to quest marker: " .. tostring(targetText or tracker.Name or "quest giver"))
		if not flyTo(CFrame.new(markerPosition), 150) then
			continue
		end

		task.wait(0.25)
		scanDialogueInteractablesForQuests(true)
		local model, info, distance = findNearestQuestGiverNearPosition(markerPosition, 160)
		if model and info then
			setAutoQuestStatus("Capturing quest giver near marker")
			mergeQuestProfile(info.Key, info, false)
			local profile = AutoQuestState.Profiles[info.Key]
			if profile then
				profile.LastQuestName = tracker and tracker.Name or profile.LastQuestName
				profile.LastObjective = tracker and tracker.Objective or profile.LastObjective
			end

			triggerQuestPrompt(model)
			local startedAt = os.clock()
			while os.clock() - startedAt < 5 do
				local dialogue = getDialogueFrame()
				if dialogue and dialogue.Visible then
					captureDialogueSpeakerForQuestProfile(profile)
					LeaveFromDialogue()
					break
				end
				task.wait(0.15)
			end

			if profile then
				profile.MarkerCaptureTarget = normalizeDynamicListName(targetText)
				profile.MarkerCaptureDistance = math.floor((distance or 0) + 0.5)
				scheduleQuestProfilesSave()
				refreshAutoQuestMenuLists()
			end
			return info.Key
		end
	end

	return nil
end

function returnToQuestGiverIfKnown(tracker, targetText)
	local key = findQuestProfileKeyForReturnTarget(tracker, targetText)
	if not key and targetText then
		key = discoverQuestGiverBySpeakerName(targetText)
	end
	if not key then
		key = captureQuestGiverFromQuestMarker(tracker, targetText)
	end

	if not key then
		if targetText then
			setAutoQuestStatus("Needs quest giver capture: " .. tostring(targetText))
		else
			setAutoQuestStatus("Needs quest giver capture")
		end
		return false
	end

	local profile = AutoQuestState.Profiles[key]
	local model = findLiveQuestGiver(profile)
	if not model then
		setAutoQuestStatus("Quest giver is not spawned")
		return false
	end

	local cframe = getQuestModelCFrame(model)
	if cframe then
		setAutoQuestStatus("ReturningToQuestGiver")
		if not flyTo(cframe, 150) then
			return false
		end
	end

	triggerQuestPrompt(model)
	local startedAt = os.clock()
	local dialogueStartedAt
	local originalName = tracker and tracker.Name
	local originalObjective = tracker and tracker.Objective
	while os.clock() - startedAt < 18 do
		local current = readQuestTracker()
		if not current or current.Name ~= originalName or current.Objective ~= originalObjective then
			setAutoQuestStatus("Completed")
			return true
		end

		local dialogue = getDialogueFrame()
		if dialogue and dialogue.Visible then
			dialogueStartedAt = dialogueStartedAt or os.clock()
			if os.clock() - dialogueStartedAt > 5 then
				LeaveFromDialogue()
				setQuestReturnCooldown(tracker, 45, "Dialogue timed out")
				setAutoQuestStatus("Dialogue timed out")
				return false
			end

			captureDialogueSpeakerForQuestProfile(profile)
			clickDialogueContinue()
		else
			dialogueStartedAt = nil
		end
		task.wait(0.35)
	end

	LeaveFromDialogue()
	setQuestReturnCooldown(tracker, 45, "Return timed out")
	return false
end

function completeCurrentQuest()
	if library.Flags["flag_AutoFarmLevel"] == true or library.Flags["flag_AutoKillBoss"] == true then
		setAutoQuestStatus("Auto Kill is busy")
		return false
	end

	local tracker = readQuestTracker()
	if not tracker then
		setAutoQuestStatus("No active quest")
		return false
	end

	local resolved = resolveQuestObjective(tracker)
	if not resolved then
		warn("AutoQuest: objective not recognized. Quest=" .. tostring(tracker.Name) .. " Objective=" .. tostring(tracker.Objective))
		setAutoQuestStatus("Objective not recognized: " .. tostring(tracker.Objective))
		return false
	end

	if resolved.Type == "Return" then
		local onCooldown, reason = isQuestReturnOnCooldown(tracker)
		if onCooldown then
			setAutoQuestStatus("Skipping return quest: " .. tostring(reason or "cooldown"))
			return switchToBestOwnedAutoQuest(tracker)
		end

		local returned = returnToQuestGiverIfKnown(tracker, resolved.TargetText)
		if not returned and isQuestReturnOnCooldown(tracker) then
			return switchToBestOwnedAutoQuest(tracker)
		end
		return returned
	end

	if resolved.Type == "SwitchQuest" then
		return switchToBestOwnedAutoQuest(tracker)
	end

	if resolved.Type ~= "KillSpecific" and resolved.Type ~= "KillCategory" then
		warn("AutoQuest: unsupported objective type. Quest=" .. tostring(tracker.Name) .. " Objective=" .. tostring(tracker.Objective) .. " Type=" .. tostring(resolved.Type))
		setAutoQuestStatus("Objective not recognized: " .. tostring(tracker.Objective))
		return false
	end

	setAutoQuestStatus("Resolved: " .. getQuestResolvedLabel(resolved) .. " (" .. tostring(resolved.RuleSource or "unknown") .. ")")
	while AutoQuestState.Settings.AutoComplete do
		tracker = readQuestTracker()
		if not tracker then
			setAutoQuestStatus("Completed")
			return true
		end

		if tracker.IsComplete then
			local onCooldown, reason = isQuestReturnOnCooldown(tracker)
			if onCooldown then
				setAutoQuestStatus("Skipping completed quest return: " .. tostring(reason or "cooldown"))
				return switchToBestOwnedAutoQuest(tracker)
			end

			local returned = returnToQuestGiverIfKnown(tracker)
			if not returned and isQuestReturnOnCooldown(tracker) then
				return switchToBestOwnedAutoQuest(tracker)
			end
			return returned
		end

		local currentResolved = resolveQuestObjective(tracker)
		if not currentResolved then
			warn("AutoQuest: objective not recognized. Quest=" .. tostring(tracker.Name) .. " Objective=" .. tostring(tracker.Objective))
			setAutoQuestStatus("Objective not recognized: " .. tostring(tracker.Objective))
			return false
		end

		if currentResolved.Type == "Return" then
			local onCooldown, reason = isQuestReturnOnCooldown(tracker)
			if onCooldown then
				setAutoQuestStatus("Skipping return quest: " .. tostring(reason or "cooldown"))
				return switchToBestOwnedAutoQuest(tracker)
			end

			local returned = returnToQuestGiverIfKnown(tracker, currentResolved.TargetText)
			if not returned and isQuestReturnOnCooldown(tracker) then
				return switchToBestOwnedAutoQuest(tracker)
			end
			return returned
		end

		if currentResolved.Type == "SwitchQuest" then
			return switchToBestOwnedAutoQuest(tracker)
		end

		if currentResolved.Type ~= "KillSpecific" and currentResolved.Type ~= "KillCategory" then
			warn("AutoQuest: unsupported objective type. Quest=" .. tostring(tracker.Name) .. " Objective=" .. tostring(tracker.Objective) .. " Type=" .. tostring(currentResolved.Type))
			setAutoQuestStatus("Objective not recognized: " .. tostring(tracker.Objective))
			return false
		end

		if currentResolved.Type ~= resolved.Type
			or currentResolved.TargetType ~= resolved.TargetType
			or currentResolved.Category ~= resolved.Category
		then
			resolved = currentResolved
			setAutoQuestStatus("Resolved: " .. getQuestResolvedLabel(resolved) .. " (" .. tostring(resolved.RuleSource or "unknown") .. ")")
		end

		local npc = findQuestTarget(resolved)
		if not npc then
			setAutoQuestStatus("Waiting for " .. getQuestResolvedLabel(resolved))
			task.wait(1)
			continue
		end

		local npcType = getLivingHollowType(npc) or getLivingNpcType(npc) or resolved.TargetType
		local npcOffset = NpcKillOffsets[npcType] or NpcKillOffsets[resolved.TargetType] or DefaultNpcKillOffset
		setAutoQuestStatus("Target: " .. tostring(npcType) .. " | " .. getQuestResolvedLabel(resolved))
		killnpc(npc, 80, npcOffset, true)
		task.wait(0.5)
	end

	setAutoQuestStatus("Idle")
	return true
end

function runAutoQuestExecutor()
	if AutoQuestState.Busy then
		return
	end

	AutoQuestState.Busy = true
	AutoQuestState.ExecutorTask = task.spawn(function()
		while AutoQuestState.Settings.AutoAccept or AutoQuestState.Settings.AutoComplete do
			scanDialogueInteractablesForQuests()

			local tracker = readQuestTracker()
			if tracker then
				if AutoQuestState.Settings.AutoComplete then
					completeCurrentQuest()
				else
					setAutoQuestStatus("Quest active")
				end
			elseif AutoQuestState.Settings.AutoAccept then
				local questKey = AutoQuestState.SelectedQuestKey
				local selected = questKey and AutoQuestState.Profiles[questKey]
				if not selected or selected.QuestAvailable ~= true or isQuestAcceptOnCooldown(questKey) then
					questKey = getNearestAvailableQuestProfile()
				end

				if questKey then
					acceptQuestFromProfileKey(questKey)
				else
					setAutoQuestStatus("No available quests")
					task.wait(1)
				end
			else
				setAutoQuestStatus("Idle")
				task.wait(1)
			end

			task.wait(0.5)
		end

		AutoQuestState.Busy = false
		AutoQuestState.ExecutorTask = nil
		setAutoQuestStatus("Idle")
	end)
end

function setAutoEatHollowPartsEnabled(enabled)
	if PriorityState.AutoEatTask then
		task.cancel(PriorityState.AutoEatTask)
		PriorityState.AutoEatTask = nil
	end

	if not enabled then
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.T, false, game)
		return
	end

	PriorityState.AutoEatTask = task.spawn(function()
		while library.Flags["flag_AutoEatHollowParts"] do
			local remains = getNearestHollowRemains(30)
			if remains then
				eatHollowRemains(remains)
			end
			task.wait(0.2)
		end

		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.T, false, game)
		PriorityState.AutoEatTask = nil
	end)
end

function serverHopHttpGet(url)
	local requestFunction = (type(syn) == "table" and syn.request)
		or (type(http) == "table" and http.request)
		or http_request
		or request

	if type(requestFunction) == "function" then
		local success, response = pcall(requestFunction, {
			Url = url,
			Method = "GET",
		})
		if success and type(response) == "table" and type(response.Body) == "string" then
			return response.Body
		end
	end

	local success, body = pcall(function()
		return game:HttpGet(url)
	end)
	if success and type(body) == "string" then
		return body
	end

	success, body = pcall(function()
		return game:HttpGetAsync(url, true)
	end)
	if success and type(body) == "string" then
		return body
	end

	return nil
end

function fetchPublicServers(placeId, maxPages)
	local servers = {}
	local cursor = nil
	local pageCount = 0
	placeId = tonumber(placeId) or game.PlaceId

	repeat
		pageCount += 1
		local url = "https://games.roblox.com/v1/games/"
			.. tostring(placeId)
			.. "/servers/Public?sortOrder=Asc&limit=100"
		if cursor then
			url ..= "&cursor=" .. HttpService:UrlEncode(cursor)
		end

		local body = serverHopHttpGet(url)
		if not body then
			warn("Server hop: failed to read Roblox server list")
			break
		end

		local decodeSuccess, decoded = pcall(HttpService.JSONDecode, HttpService, body)
		if not decodeSuccess or type(decoded) ~= "table" then
			warn("Server hop: failed to decode Roblox server list")
			break
		end

		if type(decoded.data) == "table" then
			for _, server in ipairs(decoded.data) do
				if type(server) == "table"
					and type(server.id) == "string"
					and server.id ~= game.JobId
					and (tonumber(server.playing) or math.huge) < (tonumber(server.maxPlayers) or 0)
				then
					server.placeId = placeId
					server.source = "RobloxPublicServers"
					table.insert(servers, server)
				end
			end
		end

		cursor = decoded.nextPageCursor
	until not cursor or pageCount >= (tonumber(maxPages) or 10)

	return servers
end

function getDefaultGameServerPlaceId()
	return 14218523102
end

function getMenuServerListFrame()
	local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
	local menu = playerGui and playerGui:FindFirstChild("Menu")
	local windows = menu and menu:FindFirstChild("Windows")
	local serverList = windows and windows:FindFirstChild("ServerList")
	local scrollingFrame = serverList and serverList:FindFirstChild("ScrollingFrame")
	return scrollingFrame and scrollingFrame:FindFirstChild("Frame") or nil
end

function getMenuServerListWindow()
	local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
	local menu = playerGui and playerGui:FindFirstChild("Menu")
	local windows = menu and menu:FindFirstChild("Windows")
	return windows and windows:FindFirstChild("ServerList") or nil
end

function refreshMenuServerRows(timeout)
	local serverList = getMenuServerListWindow()
	if not serverList then
		return parseMenuServerRows()
	end

	local refreshButton = serverList:FindFirstChild("BottomButtons")
		and serverList.BottomButtons:FindFirstChild("Refresh")
	if refreshButton and refreshButton:IsA("GuiButton") then
		if type(firesignal) == "function" then
			pcall(firesignal, refreshButton.MouseButton1Click)
			pcall(firesignal, refreshButton.Activated)
		else
			pcall(clickGuiButton, refreshButton)
		end
	end

	local startedAt = os.clock()
	while os.clock() - startedAt < (tonumber(timeout) or 8) do
		local rows = parseMenuServerRows()
		if #rows > 0 then
			return rows
		end
		task.wait(0.25)
	end

	return parseMenuServerRows()
end

function getMenuServerPlaceIdFromButton(button)
	if not button or type(getconnections) ~= "function" or type(getupvalues) ~= "function" then
		return nil
	end

	local success, connections = pcall(getconnections, button.MouseButton1Click)
	if not success or type(connections) ~= "table" then
		return nil
	end

	for _, connection in ipairs(connections) do
		local callback = connection and connection.Function
		if typeof(callback) == "function" then
			local upvalueSuccess, upvalues = pcall(getupvalues, callback)
			if upvalueSuccess and type(upvalues) == "table" then
				for _, upvalue in ipairs(upvalues) do
					if type(upvalue) == "table" and tonumber(upvalue.PlaceId) then
						return tonumber(upvalue.PlaceId)
					end
				end
			end
		end
	end

	return nil
end

function parseMenuServerRows()
	local frame = getMenuServerListFrame()
	local servers = {}
	if not frame then
		return servers
	end

	for _, entry in ipairs(frame:GetChildren()) do
		if entry:IsA("Frame") and entry.Name ~= "Template" then
			local container = entry:FindFirstChild("Container")
			local button = entry:FindFirstChild("Button")
			local playerCountText = container and container:FindFirstChild("PlayerCount")
			local locationText = container and container:FindFirstChild("ServerLocation")
			local uptimeText = container and container:FindFirstChild("ServerUptime")
			local missionText = container and container:FindFirstChild("MissionName")
			local indicator = container and container:FindFirstChild("ServerIndicator")
			local indicatorText = indicator and indicator:FindFirstChildWhichIsA("TextLabel", true)
			local players = tonumber(tostring(playerCountText and playerCountText.Text or ""):match("(%d+)%s+players?"))
			if type(entry.Name) == "string" and entry.Name ~= "" and players then
				table.insert(servers, {
					id = entry.Name,
					playing = players,
					location = normalizeDynamicListName(locationText and locationText.Text),
					uptime = normalizeDynamicListName(uptimeText and uptimeText.Text),
					serverName = normalizeDynamicListName(missionText and missionText.Text),
					difficulty = normalizeDynamicListName(indicatorText and indicatorText.Text),
					placeId = getMenuServerPlaceIdFromButton(button),
					source = "MenuServerList",
				})
			end
		end
	end

	return servers
end

function getPingByServerId(placeId)
	local pingByServerId = {}
	for _, server in ipairs(fetchPublicServers(placeId, 10)) do
		local ping = tonumber(server.ping or server.Ping)
		if type(server.id) == "string" and ping then
			pingByServerId[server.id] = ping
		end
	end
	return pingByServerId
end

function teleportToServerInstance(server, reason)
	if type(server) ~= "table" or type(server.id) ~= "string" then
		warn("Server hop: server was not found")
		return false
	end

	local player = game:GetService("Players").LocalPlayer
	warn(string.format(
		"Server hop: teleporting to %s | players %s/%s | ping %s",
		tostring(reason or server.id),
		tostring(server.playing or "?"),
		tostring(server.maxPlayers or "?"),
		tostring(server.ping or server.Ping or "?")
	))

	if server.source == "MenuServerList" then
		local teleportRemote = ReplicatedStorage:FindFirstChild("Requests")
			and ReplicatedStorage.Requests:FindFirstChild("TeleportToServer")
		if teleportRemote and teleportRemote:IsA("RemoteFunction") then
			local success, err = pcall(function()
				return teleportRemote:InvokeServer(server.id)
			end)
			if success then
				return true
			end
			warn("Server hop: game TeleportToServer failed, falling back to TeleportService: " .. tostring(err))
		end
	end

	local placeId = tonumber(server.placeId or server.PlaceId) or game.PlaceId
	local success, err = pcall(function()
		TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
	end)
	if not success then
		warn("Server hop: teleport failed: " .. tostring(err))
		return false
	end

	return true
end

function joinLowestPlayerServer()
	local hotReload = type(getgenv) == "function" and getgenv().VVUltimatum or _G.VVUltimatum
	if hotReload and hotReload.ServerHop and type(hotReload.ServerHop.JoinLowestPlayer) == "function" then
		return hotReload.ServerHop.JoinLowestPlayer()
	end

	local servers = parseMenuServerRows()
	if #servers == 0 then
		servers = refreshMenuServerRows(8)
	end
	if #servers == 0 then
		servers = fetchPublicServers(getDefaultGameServerPlaceId(), 10)
	end
	local bestServer
	for _, server in ipairs(servers) do
		if not bestServer
			or (tonumber(server.playing) or math.huge) < (tonumber(bestServer.playing) or math.huge)
		then
			bestServer = server
		end
	end

	return teleportToServerInstance(bestServer, "lowest player server")
end

function joinLowestPingServer()
	local hotReload = type(getgenv) == "function" and getgenv().VVUltimatum or _G.VVUltimatum
	if hotReload and hotReload.ServerHop and type(hotReload.ServerHop.JoinLowestPing) == "function" then
		return hotReload.ServerHop.JoinLowestPing()
	end

	local servers = parseMenuServerRows()
	if #servers == 0 then
		servers = refreshMenuServerRows(8)
	end
	if #servers > 0 then
		local placeId
		for _, server in ipairs(servers) do
			placeId = placeId or tonumber(server.placeId)
		end

		placeId = placeId or getDefaultGameServerPlaceId()
		if placeId then
			local pingByServerId = getPingByServerId(placeId)
			for _, server in ipairs(servers) do
				server.ping = pingByServerId[server.id]
			end
		end
	else
		servers = fetchPublicServers(getDefaultGameServerPlaceId(), 10)
	end

	local bestServer
	local sawPing = false
	for _, server in ipairs(servers) do
		local ping = tonumber(server.ping or server.Ping)
		if ping then
			sawPing = true
			if not bestServer or ping < (tonumber(bestServer.ping or bestServer.Ping) or math.huge) then
				bestServer = server
			end
		end
	end

	if not bestServer then
		warn("Server hop: server list did not include ping; joining lowest player server from current list instead")
		for _, server in ipairs(servers) do
			if not bestServer
				or (tonumber(server.playing) or math.huge) < (tonumber(bestServer.playing) or math.huge)
			then
				bestServer = server
			end
		end
	end

	if not bestServer then
		warn("Server hop: no playable servers were found")
		return false
	end

	if not sawPing then
		warn("Server hop: ping data was unavailable")
	end

	return teleportToServerInstance(bestServer, "lowest ping server")
end

function stopVisualizerPlayback()
	VisualizerPreviewGeneration += 1
	if VisualizerUpdateConnection then
		VisualizerUpdateConnection:Disconnect()
		VisualizerUpdateConnection = nil
	end

	for _, track in VisualizerTracks do
		track:Stop(0)
		track:Destroy()
	end
	table.clear(VisualizerTracks)

	for _, rigData in VisualizerRigs do
		if rigData.Model then
			rigData.Model:Destroy()
		end
	end
	table.clear(VisualizerRigs)
	table.clear(VisualizerKeyframes)
	if VisualizerKeyframeSequence then
		VisualizerKeyframeSequence:Destroy()
		VisualizerKeyframeSequence = nil
	end
end

function setAnimationAnalysisEnabled(enabled, refreshControls)
	AnalysisEnabled = enabled == true
	if refreshControls ~= false then
		updateVisualizerAnalysisControls()
	end
	refreshAnimationObserver()
end

function closeAnimationVisualizer()
	stopVisualizerAutoUseTimeLoop()
	stopVisualizerPlayback()
	setAnimationAnalysisEnabled(false, false)
	VVAnimationAnalysisPulseId = (VVAnimationAnalysisPulseId or 0) + 1
	if VVPepsiTooltipFrame then VVPepsiTooltipFrame.Visible = false end
	VVPepsiTooltipTarget = nil
	for _, connection in VisualizerListConnections do
		connection:Disconnect()
	end
	table.clear(VisualizerListConnections)
	for _, connection in VisualizerConnections do
		connection:Disconnect()
	end
	table.clear(VisualizerConnections)
	if VisualizerGui then
		VisualizerGui:Destroy()
		VisualizerGui = nil
	end
	AnimationVisualizerHotReload.State.VisualizerGui = nil
	AnimationVisualizerHotReload.State.Open = false
	table.clear(VisualizerUI)
end

function getOrCreateAnimator(container)
	local animator = container:FindFirstChildWhichIsA("Animator", true)
	if animator then
		return animator
	end

	local humanoid = container:FindFirstChildOfClass("Humanoid")
	local controller = container:FindFirstChildOfClass("AnimationController")
	if not humanoid and not controller then
		controller = Instance.new("AnimationController")
		controller.Parent = container
	end

	animator = Instance.new("Animator")
	animator.Parent = humanoid or controller
	return animator
end

function prepareVisualizerModel(model, name)
	model.Name = name
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.Massless = true
			descendant.Anchored = false
		end
	end

	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	if root then
		root.Anchored = true
		model.PrimaryPart = root
	end
	return model
end

function createHumanoidPreviewRig(rigType, name)
	local success, rig = pcall(function()
		return Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), rigType)
	end)
	if not success or not rig then
		return nil
	end
	return prepareVisualizerModel(rig, name)
end

function loadTrackOnVisualizerRig(rigName, rigData, animationId, animatorPath)
	local animator
	if animatorPath and animatorPath ~= "" then
		local resolved = resolveRelativeInstancePath(rigData.Model, animatorPath)
		animator = resolved and resolved:IsA("Animator") and resolved or nil
	end
	animator = animator or getOrCreateAnimator(rigData.Model)

	for _, existingTrack in animator:GetPlayingAnimationTracks() do
		existingTrack:Stop(0)
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. animationId
	local success, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	animation:Destroy()

	if not success or not track then
		rigData.Error = tostring(track)
		return
	end

	track.Looped = true
	track:Play(0, 1, 1)
	VisualizerTracks[rigName] = track
end

function getVisibleVisualizerRigs()
	local visible = {}
	for name, rigData in VisualizerRigs do
		if VisualizerMode == "All" or VisualizerMode == name then
			table.insert(visible, rigData)
		end
	end
	return visible
end

function layoutVisualizerRigs(world, camera)
	local visible = getVisibleVisualizerRigs()
	if #visible == 0 then
		VisualizerMode = "All"
		visible = getVisibleVisualizerRigs()
	end

	for _, rigData in VisualizerRigs do
		rigData.Model.Parent = nil
	end

	local spacing = 5
	for index, rigData in ipairs(visible) do
		rigData.Model.Parent = world
		local x = (index - (#visible + 1) / 2) * spacing
		rigData.Model:PivotTo(CFrame.new(x, 0, 0) * CFrame.Angles(0, math.pi, 0))
	end

	local minPosition = Vector3.new(math.huge, math.huge, math.huge)
	local maxPosition = Vector3.new(-math.huge, -math.huge, -math.huge)
	for _, rigData in visible do
		local boxCFrame, boxSize = rigData.Model:GetBoundingBox()
		local half = boxSize / 2
		minPosition = Vector3.new(
			math.min(minPosition.X, boxCFrame.Position.X - half.X),
			math.min(minPosition.Y, boxCFrame.Position.Y - half.Y),
			math.min(minPosition.Z, boxCFrame.Position.Z - half.Z)
		)
		maxPosition = Vector3.new(
			math.max(maxPosition.X, boxCFrame.Position.X + half.X),
			math.max(maxPosition.Y, boxCFrame.Position.Y + half.Y),
			math.max(maxPosition.Z, boxCFrame.Position.Z + half.Z)
		)
	end

	if #visible > 0 then
		local center = (minPosition + maxPosition) / 2
		local size = maxPosition - minPosition
		local distance = math.max(size.X, size.Y, size.Z, 4) * 1.8
		camera.CFrame = CFrame.lookAt(center + Vector3.new(0, size.Y * 0.08, distance), center)
	end
end

function getMainVisualizerTrack()
	return VisualizerTracks.Source or VisualizerTracks.R15 or VisualizerTracks.R6
end

function setVisualizerTime(timePosition)
	for _, track in VisualizerTracks do
		if track.Length > 0 then
			track.TimePosition = math.clamp(timePosition, 0, track.Length)
		end
	end
end

function setVisualizerPaused(paused)
	VisualizerPaused = paused == true
	for _, track in VisualizerTracks do
		track:AdjustSpeed(VisualizerPaused and 0 or 1)
	end
	if VisualizerUI.PlayButton then
		VisualizerUI.PlayButton.Text = VisualizerPaused and "Play" or "Pause"
	end
end

function getAnimationVisualizerHotReload()
	return VVExecutionGuard.VVUltimatum and VVExecutionGuard.VVUltimatum.AnimationVisualizer
end

function useCurrentVisualizerTimeAsResponseTime()
	local hotReload = getAnimationVisualizerHotReload()
	if hotReload and type(hotReload.UseCurrentTimeAsResponseTime) == "function" then
		return hotReload.UseCurrentTimeAsResponseTime()
	end

	local track = getMainVisualizerTrack()
	local profile = SelectedAnimationSourceKey and SelectedAnimationId
		and getAnimationProfile(SelectedAnimationSourceKey, SelectedAnimationId, false)
	if not track or not profile then
		return false
	end

	local normalize = hotReload and hotReload.NormalizeResponseTime
	local responseTime = type(normalize) == "function"
		and normalize(track.TimePosition)
		or math.clamp(math.floor(track.TimePosition * 1000 + 0.5) / 1000, 0, 10)
	if not responseTime then
		return false
	end

	profile.WaitBeforeResponse = responseTime
	profile.Enabled = true
	syncAnimationIdResponseSettings(SelectedAnimationId, profile)
	if VisualizerUI.ProfileEnabled then
		local previousLoadingState = IsLoadingAnimationProfile
		IsLoadingAnimationProfile = true
		VisualizerUI.ProfileEnabled:Set(true, false)
		IsLoadingAnimationProfile = previousLoadingState
	end
	if VisualizerUI.ProfileWait then
		local previousLoadingState = IsLoadingAnimationProfile
		IsLoadingAnimationProfile = true
		VisualizerUI.ProfileWait:Set(string.format("%.3f", responseTime), false)
		IsLoadingAnimationProfile = previousLoadingState
	end
	scheduleAnimationProfilesSave()
	return true
end

function stopVisualizerAutoUseTimeLoop()
end

function startVisualizerAutoUseTimeLoop()
	return false
end

AnimationVisualizerHotReload.State.GetMainTrack = getMainVisualizerTrack
AnimationVisualizerHotReload.State.GetSelectedProfile = function()
	return SelectedAnimationSourceKey and SelectedAnimationId
		and getAnimationProfile(SelectedAnimationSourceKey, SelectedAnimationId, false)
		or nil
end
AnimationVisualizerHotReload.State.SetProfileWaitText = function(responseTime)
	if not VisualizerUI.ProfileWait then
		return
	end

	local previousLoadingState = IsLoadingAnimationProfile
	IsLoadingAnimationProfile = true
	VisualizerUI.ProfileWait:Set(string.format("%.3f", responseTime), false)
	IsLoadingAnimationProfile = previousLoadingState
end
AnimationVisualizerHotReload.State.SetProfileEnabled = function(enabled)
	if not VisualizerUI.ProfileEnabled then
		return
	end

	local previousLoadingState = IsLoadingAnimationProfile
	IsLoadingAnimationProfile = true
	VisualizerUI.ProfileEnabled:Set(enabled == true, false)
	IsLoadingAnimationProfile = previousLoadingState
end
AnimationVisualizerHotReload.State.ScheduleSave = scheduleAnimationProfilesSave
AnimationVisualizerHotReload.State.SyncResponseSettings = function(profile)
	syncAnimationIdResponseSettings(SelectedAnimationId, profile)
end

function countKeyframePoses(instance)
	local count = 0
	for _, child in instance:GetChildren() do
		if child:IsA("Pose") then
			count += 1 + countKeyframePoses(child)
		end
	end
	return count
end

function getNearestVisualizerKeyframe(timePosition)
	local nearest
	local nearestDistance = math.huge
	for _, keyframe in VisualizerKeyframes do
		local distance = math.abs(keyframe.Time - timePosition)
		if distance < nearestDistance then
			nearest = keyframe
			nearestDistance = distance
		end
	end
	return nearest, nearestDistance
end

local SelectedLeafThemeIndex = math.random(1, 2)

local CustomMenuThemePresets = {
	[1] = {
		Window = Color3.fromRGB(18, 15, 15),
		Title = Color3.fromRGB(30, 17, 18),
		Panel = Color3.fromRGB(25, 21, 21),
		PanelAlt = Color3.fromRGB(31, 25, 25),
		PanelDeep = Color3.fromRGB(15, 13, 13),
		Header = Color3.fromRGB(40, 21, 22),
		Field = Color3.fromRGB(36, 30, 30),
		FieldBorder = Color3.fromRGB(36, 30, 30),
		Button = Color3.fromRGB(45, 23, 24),
		ButtonHover = Color3.fromRGB(55, 28, 29),
		ButtonSelected = Color3.fromRGB(68, 34, 35),
		ButtonSelectedHover = Color3.fromRGB(78, 39, 40),
		Text = Color3.fromRGB(224, 218, 216),
		TextSoft = Color3.fromRGB(194, 185, 183),
		TextMuted = Color3.fromRGB(137, 126, 125),
		Accent = Color3.fromRGB(85, 40, 41),
		AccentBright = Color3.fromRGB(111, 52, 53),
		Track = Color3.fromRGB(44, 36, 36),
		Good = Color3.fromRGB(91, 141, 93),
		GoodRow = Color3.fromRGB(38, 48, 39),
		GoodRowSelected = Color3.fromRGB(47, 61, 48),
		Bad = Color3.fromRGB(147, 63, 60),
		BadRow = Color3.fromRGB(49, 26, 27),
		BadRowSelected = Color3.fromRGB(63, 32, 33),
		Profile = Color3.fromRGB(32, 25, 25),
		ProfileMatch = Color3.fromRGB(37, 29, 29),
		Resize = Color3.fromRGB(61, 33, 34),
		ViewportAmbient = Color3.fromRGB(57, 48, 48),
	},
	[2] = {
		Window = Color3.fromRGB(23, 30, 24),
		Title = Color3.fromRGB(31, 43, 33),
		Panel = Color3.fromRGB(29, 37, 31),
		PanelAlt = Color3.fromRGB(34, 43, 35),
		PanelDeep = Color3.fromRGB(21, 27, 22),
		Header = Color3.fromRGB(40, 52, 41),
		Field = Color3.fromRGB(39, 49, 40),
		FieldBorder = Color3.fromRGB(39, 49, 40),
		Button = Color3.fromRGB(45, 59, 45),
		ButtonHover = Color3.fromRGB(52, 68, 52),
		ButtonSelected = Color3.fromRGB(63, 83, 62),
		ButtonSelectedHover = Color3.fromRGB(70, 91, 68),
		Text = Color3.fromRGB(219, 226, 218),
		TextSoft = Color3.fromRGB(195, 205, 194),
		TextMuted = Color3.fromRGB(136, 149, 135),
		Accent = Color3.fromRGB(84, 112, 80),
		AccentBright = Color3.fromRGB(98, 128, 92),
		Track = Color3.fromRGB(48, 58, 48),
		Good = Color3.fromRGB(105, 166, 102),
		GoodRow = Color3.fromRGB(40, 62, 40),
		GoodRowSelected = Color3.fromRGB(51, 78, 50),
		Bad = Color3.fromRGB(174, 87, 80),
		BadRow = Color3.fromRGB(58, 42, 41),
		BadRowSelected = Color3.fromRGB(73, 50, 48),
		Profile = Color3.fromRGB(35, 45, 36),
		ProfileMatch = Color3.fromRGB(39, 50, 40),
		Resize = Color3.fromRGB(62, 80, 60),
		ViewportAmbient = Color3.fromRGB(74, 86, 72),
	},
}

local VisualizerTheme = CustomMenuThemePresets[SelectedLeafThemeIndex]

function connectVisualizer(signal, callback, list)
	local connection = signal:Connect(callback)
	table.insert(list or VisualizerConnections, connection)
	return connection
end

function createVisualizerButton(parent, textValue)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.BackgroundColor3 = VisualizerTheme.Button
	button.BorderColor3 = VisualizerTheme.FieldBorder
	button.Font = Enum.Font.Code
	button.Text = textValue
	button.TextColor3 = VisualizerTheme.Text
	button.TextSize = 14
	button.Parent = parent
	connectVisualizer(button.MouseEnter, function()
		local statusColor = button:GetAttribute("StatusColor")
		button.BackgroundColor3 = statusColor
			and statusColor:Lerp(Color3.new(1, 1, 1), 0.15)
			or (button:GetAttribute("Selected") and VisualizerTheme.ButtonSelectedHover or VisualizerTheme.ButtonHover)
	end)
	connectVisualizer(button.MouseLeave, function()
		local statusColor = button:GetAttribute("StatusColor")
		button.BackgroundColor3 = statusColor
			or (button:GetAttribute("Selected") and VisualizerTheme.ButtonSelected or VisualizerTheme.Button)
	end)
	return button
end

function createVisualizerToggle(parent, labelText, initialValue, callback)
	local row = Instance.new("TextButton")
	row.AutoButtonColor = false
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, -8, 0, 30)
	row.Text = ""
	row.Parent = parent

	local box = Instance.new("Frame")
	box.Position = UDim2.fromOffset(2, 7)
	box.Size = UDim2.fromOffset(16, 16)
	box.BorderColor3 = VisualizerTheme.FieldBorder
	box.Parent = row
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(26, 0)
	label.Size = UDim2.new(1, -28, 1, 0)
	label.Font = Enum.Font.Code
	label.Text = labelText
	label.TextColor3 = VisualizerTheme.Text
	label.TextSize = 13
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local control = {Value = initialValue == true, Instance = row}
	function control:Set(value, fireCallback)
		self.Value = value == true
		box.BackgroundColor3 = self.Value and VisualizerTheme.AccentBright or VisualizerTheme.Field
		if fireCallback and callback then callback(self.Value) end
	end
	function control:Get() return self.Value end
	control:Set(control.Value, false)
	connectVisualizer(row.MouseButton1Click, function()
		control:Set(not control.Value, true)
	end)
	return control
end

function createVisualizerTextbox(parent, labelText, initialValue, callback)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, -8, 0, 48)
	row.Parent = parent
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 19)
	label.Font = Enum.Font.Code
	label.Text = labelText
	label.TextColor3 = VisualizerTheme.TextSoft
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row
	local box = Instance.new("TextBox")
	box.Position = UDim2.fromOffset(0, 21)
	box.Size = UDim2.new(1, 0, 0, 25)
	box.BackgroundColor3 = VisualizerTheme.Field
	box.BorderColor3 = VisualizerTheme.FieldBorder
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.Code
	box.Text = tostring(initialValue or "")
	box.TextColor3 = VisualizerTheme.Text
	box.TextSize = 13
	box.Parent = row
	local control = {Instance = box}
	function control:Set(value, fireCallback)
		box.Text = tostring(value or "")
		if fireCallback and callback then callback(box.Text) end
	end
	function control:Get() return box.Text end
	connectVisualizer(box.FocusLost, function(enterPressed)
		if callback then callback(box.Text, enterPressed) end
	end)
	return control
end

function createVisualizerSlider(parent, labelText, minimum, maximum, initialValue, decimals, formatValue, callback)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, -8, 0, 54)
	row.Parent = parent
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0.64, 0, 0, 20)
	label.Font = Enum.Font.Code
	label.Text = labelText
	label.TextColor3 = VisualizerTheme.TextSoft
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row
	local valueBox = Instance.new("TextBox")
	valueBox.AnchorPoint = Vector2.new(1, 0)
	valueBox.Position = UDim2.fromScale(1, 0)
	valueBox.Size = UDim2.new(0.34, 0, 0, 20)
	valueBox.BackgroundColor3 = VisualizerTheme.Field
	valueBox.BorderColor3 = VisualizerTheme.FieldBorder
	valueBox.ClearTextOnFocus = false
	valueBox.Font = Enum.Font.Code
	valueBox.TextColor3 = VisualizerTheme.Text
	valueBox.TextSize = 12
	valueBox.Parent = row
	local bar = Instance.new("TextButton")
	bar.Position = UDim2.fromOffset(0, 30)
	bar.Size = UDim2.new(1, 0, 0, 12)
	bar.BackgroundColor3 = VisualizerTheme.Track
	bar.BorderSizePixel = 0
	bar.Text = ""
	bar.Parent = row
	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = VisualizerTheme.AccentBright
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(0, 1)
	fill.Parent = bar

	local control = {Value = initialValue, Dragging = false, Instance = row}
	local scale = 10 ^ (decimals or 0)
	function control:Set(value, fireCallback)
		value = math.clamp(tonumber(value) or minimum, minimum, maximum)
		value = math.floor(value * scale + 0.5) / scale
		self.Value = value
		fill.Size = UDim2.fromScale((value - minimum) / (maximum - minimum), 1)
		valueBox.Text = formatValue and formatValue(value) or tostring(value)
		if fireCallback and callback then callback(value) end
	end
	function control:Get() return self.Value end
	local function setFromMouse()
		local alpha = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		control:Set(minimum + (maximum - minimum) * alpha, true)
	end
	connectVisualizer(bar.MouseButton1Down, function()
		control.Dragging = true
		setFromMouse()
	end)
	connectVisualizer(UserInputService.InputChanged, function(input)
		if control.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then setFromMouse() end
	end)
	connectVisualizer(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then control.Dragging = false end
	end)
	connectVisualizer(valueBox.Focused, function()
		valueBox.Text = tostring(control.Value)
		valueBox.CursorPosition = #valueBox.Text + 1
	end)
	connectVisualizer(valueBox.FocusLost, function()
		control:Set(tonumber(valueBox.Text) or control.Value, true)
	end)
	control:Set(initialValue, false)
	return control
end

function createVisualizerDropdown(parent, labelText, options, initialValue, callback)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.ClipsDescendants = true
	row.Size = UDim2.new(1, -8, 0, 48)
	row.Parent = parent
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 19)
	label.Font = Enum.Font.Code
	label.Text = labelText
	label.TextColor3 = VisualizerTheme.TextSoft
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row
	local button = createVisualizerButton(row, tostring(initialValue))
	button.Position = UDim2.fromOffset(0, 21)
	button.Size = UDim2.new(1, 0, 0, 25)
	local holder = Instance.new("Frame")
	holder.BackgroundColor3 = VisualizerTheme.PanelAlt
	holder.BorderColor3 = VisualizerTheme.FieldBorder
	holder.Position = UDim2.fromOffset(0, 48)
	holder.Size = UDim2.new(1, 0, 0, #options * 25)
	holder.Visible = false
	holder.Parent = row
	local list = Instance.new("UIListLayout")
	list.Parent = holder
	local control = {Value = initialValue, Open = false}
	function control:Set(value, fireCallback)
		if not table.find(options, value) then value = options[1] end
		self.Value = value
		button.Text = tostring(value)
		if fireCallback and callback then callback(value) end
	end
	function control:Get() return self.Value end
	function control:SetOpen(open)
		self.Open = open == true
		holder.Visible = self.Open
		row.Size = UDim2.new(1, -8, 0, self.Open and (50 + #options * 25) or 48)
	end
	connectVisualizer(button.MouseButton1Click, function() control:SetOpen(not control.Open) end)
	for _, option in options do
		local optionButton = createVisualizerButton(holder, option)
		optionButton.Size = UDim2.new(1, 0, 0, 25)
		connectVisualizer(optionButton.MouseButton1Click, function()
			control:Set(option, true)
			control:SetOpen(false)
		end)
	end
	return control
end

function updateVisualizerAnalysisControls()
	VVAnimationAnalysisPulseId = (VVAnimationAnalysisPulseId or 0) + 1
	local pulseId = VVAnimationAnalysisPulseId
	local button = VisualizerUI.AnalysisButton
	if button then
		button.Text = AnalysisEnabled and "Stop Animation Analysis" or "Start Animation Analysis"
		if AnalysisEnabled then
			local enabledColor = VisualizerTheme.Good
			button:SetAttribute("StatusColor", enabledColor)
			button.BackgroundColor3 = enabledColor
			button.TextColor3 = VisualizerTheme.Text
		else
			task.spawn(function()
				local showWhite = true
				while VisualizerGui and button.Parent and not AnalysisEnabled and VVAnimationAnalysisPulseId == pulseId do
					local color = showWhite and Color3.fromRGB(226, 226, 210) or VisualizerTheme.Bad
					button:SetAttribute("StatusColor", color)
					button.BackgroundColor3 = color
					button.TextColor3 = showWhite and Color3.fromRGB(24, 30, 22) or VisualizerTheme.Text
					showWhite = not showWhite
					task.wait(0.2)
				end
			end)
		end
	end
	if VisualizerUI.AnalysisStatus then
		VisualizerUI.AnalysisStatus.Text = AnalysisEnabled and "Capturing nearby NPC animations" or "Analysis stopped"
	end
end

function refreshVisualizerAnimationList()
	local holder = VisualizerUI.AnimationList
	if not holder then return end
	for _, connection in VisualizerListConnections do connection:Disconnect() end
	table.clear(VisualizerListConnections)
	for _, child in holder:GetChildren() do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end

	local search = string.lower(VisualizerSearchText or "")
	local layoutOrder = 0
	local animationGroups = {}
	local manualItems = {}
	local regularGroups = {}
	local regularCount = 0
	local hollowGroups = {}
	local hollowCount = 0
	local otherGroups = {}
	local otherCount = 0

	local function makeHeader(expandKey, textValue, indent, count)
		if VisualizerExpandedSources[expandKey] == nil then VisualizerExpandedSources[expandKey] = true end
		local header = Instance.new("TextButton")
		layoutOrder += 1
		header.LayoutOrder = layoutOrder
		header.AutoButtonColor = false
		header.BackgroundColor3 = VisualizerTheme.Header
		header.BorderSizePixel = 0
		header.Size = UDim2.new(1, -6, 0, 26)
		header.Font = Enum.Font.Code
		header.Text = string.rep("  ", indent) .. (VisualizerExpandedSources[expandKey] and "[-] " or "[+] ") .. textValue .. " (" .. count .. ")"
		header.TextColor3 = VisualizerTheme.Text
		header.TextSize = 13
		header.TextXAlignment = Enum.TextXAlignment.Left
		header.Parent = holder
		connectVisualizer(header.MouseButton1Click, function()
			VisualizerExpandedSources[expandKey] = not VisualizerExpandedSources[expandKey]
			refreshVisualizerAnimationList()
		end, VisualizerListConnections)
		return header
	end

	local function makeAnimationRow(item, indent)
		local selected = SelectedAnimationId == item.Id
			and (SelectedAnimationSourceKey == item.SourceKey or (item.SourceSet and item.SourceSet[SelectedAnimationSourceKey]))
		local effectiveProfile = resolveAnimationProfile(item.SourceKey, item.Id, true)
		local configuredColor = VisualizerTheme.GoodRow
		local missingColor = VisualizerTheme.BadRow
		local selectedConfiguredColor = VisualizerTheme.GoodRowSelected
		local selectedMissingColor = VisualizerTheme.BadRowSelected
		local row = Instance.new("TextButton")
		layoutOrder += 1
		row.LayoutOrder = layoutOrder
		row.AutoButtonColor = false
		row.BackgroundColor3 = effectiveProfile
			and (selected and selectedConfiguredColor or configuredColor)
			or (selected and selectedMissingColor or missingColor)
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, -6, 0, 32)
		row.Font = Enum.Font.Code
		row.Text = string.rep("  ", indent) .. item.Text
		row.TextColor3 = VisualizerTheme.TextSoft
		row.TextSize = 12
		row.TextTruncate = Enum.TextTruncate.AtEnd
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Parent = holder
		connectVisualizer(row.MouseButton1Click, function()
			loadVisualizerSelection(item.SourceKey, item.Id)
		end, VisualizerListConnections)
	end

	for sourceKey, sourceProfiles in AnimationProfiles do
		for animationId, profile in sourceProfiles do
			local group = animationGroups[animationId]
			if not group then
				group = {
					Id = animationId,
					Sources = {},
					SourceSet = {},
				}
				animationGroups[animationId] = group
			end
			if not group.SourceSet[sourceKey] then
				group.SourceSet[sourceKey] = true
				table.insert(group.Sources, {
					SourceKey = sourceKey,
					Profile = profile,
					Name = formatAnimationSourceName(sourceKey),
				})
			end
		end
	end

	local function addRegularItem(item)
		local parts = splitAnimationSourceKey(item.SourceKey)
		local weaponType = parts[2] or "Legacy"
		local weaponName = parts[3]
		local group = regularGroups[weaponType]
		if not group then
			group = {Count = 0, Shared = {}, Weapons = {}}
			regularGroups[weaponType] = group
		end

		group.Count += 1
		regularCount += 1
		if weaponName then
			local weaponGroup = group.Weapons[weaponName]
			if not weaponGroup then
				weaponGroup = {Count = 0, Items = {}}
				group.Weapons[weaponName] = weaponGroup
			end
			weaponGroup.Count += 1
			table.insert(weaponGroup.Items, item)
		else
			table.insert(group.Shared, item)
		end
	end

	local function addSourceGroupItem(groups, sourceName, item)
		local group = groups[sourceName]
		if not group then
			group = {Count = 0, Items = {}}
			groups[sourceName] = group
		end

		group.Count += 1
		table.insert(group.Items, item)
	end

	local function addCategorizedItem(item)
		if item.SourceKey == "Manual" then
			table.insert(manualItems, item)
			return
		end

		if isRegularPlayerSourceKey(item.SourceKey) then
			addRegularItem(item)
			return
		end

		if string.find(string.lower(tostring(item.SourceKey or "")), "hollow", 1, true) then
			hollowCount += 1
			addSourceGroupItem(hollowGroups, formatAnimationSourceName(item.SourceKey), item)
			return
		end

		otherCount += 1
		addSourceGroupItem(otherGroups, formatAnimationSourceName(item.SourceKey), item)
	end

	for _, group in animationGroups do
		table.sort(group.Sources, function(a, b) return a.Name < b.Name end)
		local bestSource, bestScore = nil, -1
		for _, sourceData in group.Sources do
			local score = 0
			if SelectedAnimationId == group.Id and SelectedAnimationSourceKey == sourceData.SourceKey then score += 16 end
			if sourceData.Profile.Enabled == true then score += 8 end
			if isAnimationResponseConfigured(sourceData.Profile) then score += 4 end
			if SourcePreviewTemplates[sourceData.SourceKey] then score += 2 end
			if sourceData.SourceKey == "Manual" then score += 1 end
			if not bestSource or score > bestScore or (score == bestScore and sourceData.Name < bestSource.Name) then
				bestSource, bestScore = sourceData, score
			end
		end

		if bestSource then
			local sourceNames = {}
			for _, sourceData in group.Sources do
				table.insert(sourceNames, sourceData.Name)
			end

			local sourceSummary = sourceNames[1] or "Unknown"
			if #sourceNames > 1 then
				sourceSummary = sourceSummary .. " +" .. tostring(#sourceNames - 1) .. " sources"
			end

			local priority = bestSource.Profile.Priority or "Unknown"
			local textValue = string.format("%s | %s | %s", group.Id, priority, sourceSummary)
			local searchText = string.lower(textValue .. " | " .. table.concat(sourceNames, " | "))
			if search == "" or string.find(searchText, search, 1, true) then
				addCategorizedItem({
					Id = group.Id,
					Priority = priority,
					SourceKey = bestSource.SourceKey,
					SourceSet = group.SourceSet,
					Text = textValue,
					SearchText = searchText,
				})
			end
		end
	end

	local function sortItems(items)
		table.sort(items, function(a, b) return a.SearchText < b.SearchText end)
	end

	sortItems(manualItems)
	if #manualItems > 0 then
		makeHeader("AnimationIdList:Manual", "Manual", 0, #manualItems)
		if VisualizerExpandedSources["AnimationIdList:Manual"] then
			for _, item in manualItems do
				makeAnimationRow(item, 1)
			end
		end
	end

	if regularCount > 0 then
		makeHeader("RegularPlayer", "RegularPlayer", 0, regularCount)
		if VisualizerExpandedSources.RegularPlayer then
			local weaponTypes = {}
			for weaponType in regularGroups do table.insert(weaponTypes, weaponType) end
			table.sort(weaponTypes)
			for _, weaponType in weaponTypes do
				local group = regularGroups[weaponType]
				local weaponExpandKey = "RegularPlayer:" .. weaponType
				makeHeader(weaponExpandKey, weaponType, 1, group.Count)
				if VisualizerExpandedSources[weaponExpandKey] then
					sortItems(group.Shared)
					for _, item in group.Shared do
						makeAnimationRow(item, 2)
					end

					local weaponNames = {}
					for weaponName in group.Weapons do table.insert(weaponNames, weaponName) end
					table.sort(weaponNames)
					for _, weaponName in weaponNames do
						local weaponGroup = group.Weapons[weaponName]
						local exactExpandKey = weaponExpandKey .. ":" .. weaponName
						makeHeader(exactExpandKey, weaponName, 2, weaponGroup.Count)
						if VisualizerExpandedSources[exactExpandKey] then
							sortItems(weaponGroup.Items)
							for _, item in weaponGroup.Items do
								makeAnimationRow(item, 3)
							end
						end
					end
				end
			end
		end
	end

	if hollowCount > 0 then
		makeHeader("AnimationIdList:Hollows", "Hollows", 0, hollowCount)
		if VisualizerExpandedSources["AnimationIdList:Hollows"] then
			local sourceNames = {}
			for sourceName in hollowGroups do table.insert(sourceNames, sourceName) end
			table.sort(sourceNames)
			for _, sourceName in sourceNames do
				local group = hollowGroups[sourceName]
				local expandKey = "AnimationIdList:Hollows:" .. sourceName
				makeHeader(expandKey, sourceName, 1, group.Count)
				if VisualizerExpandedSources[expandKey] then
					sortItems(group.Items)
					for _, item in group.Items do
						makeAnimationRow(item, 2)
					end
				end
			end
		end
	end

	if otherCount > 0 then
		makeHeader("AnimationIdList:Other", "Other", 0, otherCount)
		if VisualizerExpandedSources["AnimationIdList:Other"] then
			local sourceNames = {}
			for sourceName in otherGroups do table.insert(sourceNames, sourceName) end
			table.sort(sourceNames)
			for _, sourceName in sourceNames do
				local group = otherGroups[sourceName]
				local expandKey = "AnimationIdList:Other:" .. sourceName
				makeHeader(expandKey, sourceName, 1, group.Count)
				if VisualizerExpandedSources[expandKey] then
					sortItems(group.Items)
					for _, item in group.Items do
						makeAnimationRow(item, 2)
					end
				end
			end
		end
	end
	task.defer(function()
		if holder and holder.Parent then
			local layout = holder:FindFirstChildOfClass("UIListLayout")
			holder.CanvasSize = UDim2.fromOffset(0, layout and layout.AbsoluteContentSize.Y + 6 or 0)
		end
	end)
end

function syncVisualizerProfileControls()
	local profile = SelectedAnimationSourceKey and SelectedAnimationId
		and getAnimationProfile(SelectedAnimationSourceKey, SelectedAnimationId, false)
	local effectiveProfile, effectiveSourceKey, effectiveLevel = nil, nil, nil
	if SelectedAnimationSourceKey and SelectedAnimationId then
		effectiveProfile, effectiveSourceKey, effectiveLevel = resolveAnimationProfile(SelectedAnimationSourceKey, SelectedAnimationId, true)
	end
	if VisualizerUI.SelectedProfile then
		VisualizerUI.SelectedProfile.Text = profile
			and string.format("%s\n%s | %s", formatAnimationSourceName(SelectedAnimationSourceKey), SelectedAnimationId, profile.Priority or "Unknown")
			or "No animation selected"
	end
	if VisualizerUI.ProfileMatch then
		VisualizerUI.ProfileMatch.Text = effectiveProfile
			and string.format("Effective: %s\n%s", effectiveLevel or "Exact", formatAnimationSourceName(effectiveSourceKey))
			or "Effective: none\nThis animation is not configured yet"
		VisualizerUI.ProfileMatch.TextColor3 = effectiveProfile and Color3.fromRGB(161, 219, 165) or Color3.fromRGB(224, 141, 124)
	end
	if VisualizerUI.SaveSharedButton then
		local sharedKey = SelectedAnimationSourceKey and getSharedAnimationSourceKey(SelectedAnimationSourceKey)
		VisualizerUI.SaveSharedButton.Visible = sharedKey ~= nil and sharedKey ~= SelectedAnimationSourceKey
	end
	if VisualizerUI.ForgetButton then
		VisualizerUI.ForgetButton.Visible = profile ~= nil
	end
	if not profile then
		IsLoadingAnimationProfile = true
		if VisualizerUI.ProfileEnabled then VisualizerUI.ProfileEnabled:Set(false, false) end
		if VisualizerUI.ProfileWait then VisualizerUI.ProfileWait:Set("0.000", false) end
		if VisualizerUI.ProfileAction then VisualizerUI.ProfileAction:Set("Block / Parry", false) end
		if VisualizerUI.ResponseHold then VisualizerUI.ResponseHold:Set(ResponseHoldTime * 1000, false) end
		IsLoadingAnimationProfile = false
		return
	end
	IsLoadingAnimationProfile = true
	VisualizerUI.ProfileEnabled:Set(profile.Enabled, false)
	VisualizerUI.ProfileWait:Set(string.format("%.3f", profile.WaitBeforeResponse), false)
	local actionNames = {
		["Press F"] = "Counter",
		["Press Right Mouse Click"] = "Block / Parry",
		["Press Q (Dash)"] = "Dash",
	}
	VisualizerUI.ProfileAction:Set(actionNames[profile.ResponseAction] or "Block / Parry", false)
	if VisualizerUI.ResponseHold then
		VisualizerUI.ResponseHold:Set((tonumber(profile.BlockHoldTime) or ResponseHoldTime) * 1000, false)
	end
	IsLoadingAnimationProfile = false
end

function setVisualizerMode(mode)
	if mode == "Source" and not VisualizerRigs.Source then return end
	VisualizerMode = mode
	for name, button in VisualizerUI.ModeButtons or {} do
		button:SetAttribute("Selected", name == mode)
		button.BackgroundColor3 = name == mode and VisualizerTheme.ButtonSelected or VisualizerTheme.Button
	end
	if VisualizerUI.World and VisualizerUI.Camera then
		layoutVisualizerRigs(VisualizerUI.World, VisualizerUI.Camera)
	end
end

function showVisualizerEmptyState(message)
	stopVisualizerPlayback()
	if VisualizerUI.EmptyLabel then
		VisualizerUI.EmptyLabel.Text = message or "Select or import an animation"
		VisualizerUI.EmptyLabel.Visible = true
	end
	if VisualizerUI.Info then VisualizerUI.Info.Text = "No animation selected" end
	if VisualizerUI.Title then VisualizerUI.Title.Text = "Animation Visualizer" end
	syncVisualizerProfileControls()
end

function loadVisualizerSelection(sourceKey, animationId)
	animationId = normalizeAnimationId(animationId)
	local profile = animationId and getAnimationProfile(sourceKey or "Manual", animationId, false)
	if not profile or not VisualizerGui then return false end

	stopVisualizerPlayback()
	local generation = VisualizerPreviewGeneration
	SelectedAnimationSourceKey = sourceKey or "Manual"
	SelectedAnimationId = animationId
	VisualizerMode = SourcePreviewTemplates[SelectedAnimationSourceKey] and "Source" or "All"
	if VisualizerUI.Title then VisualizerUI.Title.Text = formatAnimationSourceName(SelectedAnimationSourceKey) .. " | " .. animationId end
	setVisualizerPaused(false)

	if VisualizerUI.World then VisualizerUI.World:Destroy() end
	if VisualizerUI.Camera then VisualizerUI.Camera:Destroy() end
	local world = Instance.new("WorldModel")
	world.Parent = VisualizerUI.Viewport
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.Parent = VisualizerUI.Viewport
	VisualizerUI.Viewport.CurrentCamera = camera
	VisualizerUI.World, VisualizerUI.Camera = world, camera

	local sourceTemplate = SourcePreviewTemplates[SelectedAnimationSourceKey]
	if sourceTemplate then
		local sourceModel = prepareVisualizerModel(sourceTemplate:Clone(), "Source")
		VisualizerRigs.Source = {Model = sourceModel}
		loadTrackOnVisualizerRig("Source", VisualizerRigs.Source, animationId, profile.AnimatorPath)
	end
	if VisualizerUI.EmptyLabel then
		VisualizerUI.EmptyLabel.Text = sourceTemplate
			and ""
			or "<i>no source model available, use Animation Analysis and check your Radius Distance to capture NPC models.</i>"
		VisualizerUI.EmptyLabel.Visible = not sourceTemplate
	end
	local r15 = createHumanoidPreviewRig(Enum.HumanoidRigType.R15, "R15")
	if r15 then
		VisualizerRigs.R15 = {Model = r15}
		loadTrackOnVisualizerRig("R15", VisualizerRigs.R15, animationId)
	end
	local r6 = createHumanoidPreviewRig(Enum.HumanoidRigType.R6, "R6")
	if r6 then
		VisualizerRigs.R6 = {Model = r6}
		loadTrackOnVisualizerRig("R6", VisualizerRigs.R6, animationId)
	end
	setVisualizerMode(VisualizerMode)
	syncVisualizerProfileControls()
	refreshVisualizerAnimationList()
	scheduleAnimationProfilesSave()

	task.spawn(function()
		local success, sequence = pcall(function()
			return KeyframeSequenceProvider:GetKeyframeSequenceAsync("rbxassetid://" .. animationId)
		end)
		if success and sequence and VisualizerGui and generation == VisualizerPreviewGeneration then
			VisualizerKeyframeSequence = sequence
			VisualizerKeyframes = sequence:GetKeyframes()
			table.sort(VisualizerKeyframes, function(a, b) return a.Time < b.Time end)
		elseif success and sequence then
			sequence:Destroy()
		end
	end)

	VisualizerUpdateConnection = RunService.RenderStepped:Connect(function()
		if generation ~= VisualizerPreviewGeneration then return end
		local track = getMainVisualizerTrack()
		if not track then
			VisualizerUI.Info.Text = "Animation could not be loaded on available preview rigs."
			return
		end
		local nearest, distance = getNearestVisualizerKeyframe(track.TimePosition)
		local keyframeText = nearest and string.format("%s @ %.3fs | delta %.3fs | %d poses", nearest.Name, nearest.Time, distance, countKeyframePoses(nearest)) or "No keyframe data"
		local sourceStatus = VisualizerRigs.Source and "source ready" or "source unavailable; using humanoid fallback"
		VisualizerUI.Info.Text = string.format("%.3f / %.3f | speed %.2f | weight %.2f | %s\n%s | %s",
			track.TimePosition, track.Length, track.Speed, track.WeightCurrent, tostring(track.Priority), sourceStatus, keyframeText)
		if track.Length > 0 then
			VisualizerUI.TimelineFill.Size = UDim2.fromScale(math.clamp(track.TimePosition / track.Length, 0, 1), 1)
		end
	end)
	return true
end

function layoutVisualizerWorkspace()
	local panel = VisualizerUI.Panel
	if not panel then return end
	local size = panel.AbsoluteSize
	local contentHeight = size.Y - 44
	local gap = 8
	local leftWidth = math.clamp(size.X * 0.29, 220, 338)
	local rightWidth = math.clamp(size.X * 0.25, 220, 280)
	local centerWidth = size.X - leftWidth - rightWidth - gap * 4
	VisualizerUI.Left.Position = UDim2.fromOffset(gap, 36)
	VisualizerUI.Left.Size = UDim2.fromOffset(leftWidth, contentHeight)
	VisualizerUI.Center.Position = UDim2.fromOffset(leftWidth + gap * 2, 36)
	VisualizerUI.Center.Size = UDim2.fromOffset(centerWidth, contentHeight)
	VisualizerUI.Right.Position = UDim2.fromOffset(leftWidth + centerWidth + gap * 3, 36)
	VisualizerUI.Right.Size = UDim2.fromOffset(rightWidth, contentHeight)
	VisualizerUI.AnimationList.Position = UDim2.fromOffset(6, 198)
	VisualizerUI.AnimationList.Size = UDim2.new(1, -12, 1, -204)
	local viewportHeight = math.max(200, contentHeight - 186)
	VisualizerUI.Viewport.Position = UDim2.fromOffset(6, 38)
	VisualizerUI.Viewport.Size = UDim2.new(1, -12, 0, viewportHeight)
	VisualizerUI.Timeline.Position = UDim2.fromOffset(6, viewportHeight + 46)
	VisualizerUI.Timeline.Size = UDim2.new(1, -12, 0, 14)
	VisualizerUI.PlayButton.Position = UDim2.fromOffset(6, viewportHeight + 68)
	VisualizerUI.CopyButton.Position = UDim2.fromOffset(102, viewportHeight + 68)
	VisualizerUI.SeekBox.Position = UDim2.fromOffset(6, viewportHeight + 100)
	VisualizerUI.SeekButton.Position = UDim2.fromOffset(100, viewportHeight + 100)
	VisualizerUI.Info.Position = UDim2.fromOffset(6, viewportHeight + 134)
	VisualizerUI.Info.Size = UDim2.new(1, -12, 0, 42)
end

function openAnimationVisualizer(sourceKey, animationId)
	if VisualizerGui then
		if sourceKey and animationId then loadVisualizerSelection(sourceKey, animationId) end
		return true
	end
	setAnimationAnalysisEnabled(true, false)

	local gui = Instance.new("ScreenGui")
	gui.Name = "VVAnimationVisualizer"
	gui.DisplayOrder = 30
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = library.gui_parent or LocalPlayer:WaitForChild("PlayerGui")
	VisualizerGui = gui
	AnimationVisualizerHotReload.State.VisualizerGui = gui
	AnimationVisualizerHotReload.State.Open = true
	local viewportSize = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local width, height = math.min(1180, viewportSize.X - 24), math.min(720, viewportSize.Y - 24)
	width = math.max(math.min(720, viewportSize.X - 8), width)
	height = math.max(math.min(520, viewportSize.Y - 8), height)

	local panel = Instance.new("Frame")
	panel.Active = true
	panel.Position = UDim2.fromOffset(math.max(8, (viewportSize.X - width) / 2), math.max(8, (viewportSize.Y - height) / 2))
	panel.Size = UDim2.fromOffset(width, height)
	panel.BackgroundColor3 = VisualizerTheme.Window
	panel.BorderColor3 = VisualizerTheme.FieldBorder
	panel.Parent = gui
	VisualizerUI.Panel = panel

	local titleBar = Instance.new("Frame")
	titleBar.Active = true
	titleBar.Size = UDim2.new(1, 0, 0, 34)
	titleBar.BackgroundColor3 = VisualizerTheme.Title
	titleBar.BorderSizePixel = 0
	titleBar.Parent = panel
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(10, 0)
	title.Size = UDim2.new(1, -52, 1, 0)
	title.Font = Enum.Font.Code
	title.Text = "Animation Visualizer"
	title.TextColor3 = VisualizerTheme.Text
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar
	VisualizerUI.Title = title
	local closeButton = createVisualizerButton(titleBar, "X")
	closeButton.Position = UDim2.new(1, -36, 0, 4)
	closeButton.Size = UDim2.fromOffset(30, 26)
	connectVisualizer(closeButton.MouseButton1Click, closeAnimationVisualizer)

	for _, name in {"Left", "Center", "Right"} do
		local frame = Instance.new(name == "Right" and "ScrollingFrame" or "Frame")
		frame.Name = name
		frame.BackgroundColor3 = VisualizerTheme.Panel
		frame.BorderColor3 = VisualizerTheme.FieldBorder
		if frame:IsA("ScrollingFrame") then
			frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			frame.CanvasSize = UDim2.new()
			frame.ScrollBarThickness = 5
		end
		frame.Parent = panel
		VisualizerUI[name] = frame
	end

	local left = VisualizerUI.Left
	local analysisButton = createVisualizerButton(left, "Start Animation Analysis")
	analysisButton.Position = UDim2.fromOffset(6, 6)
	analysisButton.Size = UDim2.new(1, -12, 0, 28)
	VisualizerUI.AnalysisButton = analysisButton
	connectVisualizer(analysisButton.MouseButton1Click, function()
		setAnimationAnalysisEnabled(not AnalysisEnabled)
	end)
	attachPepsiTooltip(
		analysisButton,
		"Watches nearby NPCs and bosses and saves every animation they play to the list below Turn it on, walk up to your target, and let them show you their moves"
	)
	local status = Instance.new("TextLabel")
	status.BackgroundTransparency = 1
	status.Position = UDim2.fromOffset(6, 36)
	status.Size = UDim2.new(1, -12, 0, 20)
	status.Font = Enum.Font.Code
	status.TextColor3 = VisualizerTheme.TextMuted
	status.TextSize = 12
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Parent = left
	VisualizerUI.AnalysisStatus = status
	local captureHolder = Instance.new("Frame")
	captureHolder.BackgroundTransparency = 1
	captureHolder.Position = UDim2.fromOffset(6, 58)
	captureHolder.Size = UDim2.new(1, -12, 0, 54)
	captureHolder.Parent = left
	VisualizerUI.CaptureRadius = createVisualizerSlider(captureHolder, "Capture Radius", 10, 300, CaptureRadius, 0, function(v) return tostring(v) .. " studs" end, function(value)
		CaptureRadius = value
		scheduleAnimationProfilesSave()
	end)
	VisualizerUI.CaptureRadius.Instance = captureHolder

	local searchBox = Instance.new("TextBox")
	searchBox.Position = UDim2.fromOffset(6, 118)
	searchBox.Size = UDim2.new(1, -12, 0, 28)
	searchBox.BackgroundColor3 = VisualizerTheme.Field
	searchBox.BorderColor3 = VisualizerTheme.FieldBorder
	searchBox.ClearTextOnFocus = false
	searchBox.Font = Enum.Font.Code
	searchBox.PlaceholderText = "Search source, ID or priority"
	searchBox.Text = VisualizerSearchText
	searchBox.TextColor3 = VisualizerTheme.Text
	searchBox.TextSize = 12
	searchBox.Parent = left
	connectVisualizer(searchBox:GetPropertyChangedSignal("Text"), function()
		VisualizerSearchText = searchBox.Text
		refreshVisualizerAnimationList()
	end)
	local manualBox = Instance.new("TextBox")
	manualBox.Position = UDim2.fromOffset(6, 154)
	manualBox.Size = UDim2.new(1, -76, 0, 28)
	manualBox.BackgroundColor3 = VisualizerTheme.Field
	manualBox.BorderColor3 = VisualizerTheme.FieldBorder
	manualBox.ClearTextOnFocus = false
	manualBox.Font = Enum.Font.Code
	manualBox.PlaceholderText = "AnimationID"
	manualBox.Text = ""
	manualBox.TextColor3 = VisualizerTheme.Text
	manualBox.TextSize = 12
	manualBox.Parent = left
	local addButton = createVisualizerButton(left, "Add")
	addButton.Position = UDim2.new(1, -64, 0, 154)
	addButton.Size = UDim2.fromOffset(58, 28)
	connectVisualizer(addButton.MouseButton1Click, function()
		local id = normalizeAnimationId(manualBox.Text)
		if not id then
			warn("Animation visualizer: invalid AnimationID")
			return
		end
		local profile = getAnimationProfile("Manual", id, true)
		local sharedProfile = findAnimationProfileById(id, false, nil, profile)
		if sharedProfile and isAnimationResponseConfigured(sharedProfile) then
			copyAnimationResponseSettings(sharedProfile, profile)
		end
		rebuildAnimationEntryList()
		scheduleAnimationProfilesSave()
		manualBox.Text = ""
		loadVisualizerSelection("Manual", id)
	end)
	local animationList = Instance.new("ScrollingFrame")
	animationList.BackgroundColor3 = VisualizerTheme.PanelDeep
	animationList.BorderColor3 = VisualizerTheme.FieldBorder
	animationList.CanvasSize = UDim2.new()
	animationList.ScrollBarThickness = 5
	animationList.Parent = left
	local animationLayout = Instance.new("UIListLayout")
	animationLayout.Padding = UDim.new(0, 2)
	animationLayout.SortOrder = Enum.SortOrder.LayoutOrder
	animationLayout.Parent = animationList
	VisualizerUI.AnimationList = animationList

	local center = VisualizerUI.Center
	VisualizerUI.ModeButtons = {}
	for index, mode in ipairs({"Source", "R15", "R6", "All"}) do
		local button = createVisualizerButton(center, mode)
		button.Position = UDim2.fromOffset(6 + (index - 1) * 76, 6)
		button.Size = UDim2.fromOffset(70, 26)
		VisualizerUI.ModeButtons[mode] = button
		connectVisualizer(button.MouseButton1Click, function() setVisualizerMode(mode) end)
	end
	local viewport = Instance.new("ViewportFrame")
	viewport.BackgroundColor3 = VisualizerTheme.PanelDeep
	viewport.BorderColor3 = VisualizerTheme.FieldBorder
	viewport.Ambient = VisualizerTheme.ViewportAmbient
	viewport.LightColor = Color3.fromRGB(232, 232, 210)
	viewport.LightDirection = Vector3.new(-1, -1, -1)
	viewport.Parent = center
	VisualizerUI.Viewport = viewport
	local emptyLabel = Instance.new("TextLabel")
	emptyLabel.BackgroundTransparency = 1
	emptyLabel.Size = UDim2.fromScale(1, 1)
	emptyLabel.Font = Enum.Font.Code
	emptyLabel.Text = "Select or import an animation"
	emptyLabel.TextColor3 = VisualizerTheme.TextMuted
	emptyLabel.TextSize = 15
	emptyLabel.RichText = true
	emptyLabel.TextWrapped = true
	emptyLabel.ZIndex = 3
	emptyLabel.Parent = viewport
	VisualizerUI.EmptyLabel = emptyLabel
	local timeline = Instance.new("TextButton")
	timeline.BackgroundColor3 = VisualizerTheme.Track
	timeline.BorderSizePixel = 0
	timeline.Text = ""
	timeline.Parent = center
	local timelineFill = Instance.new("Frame")
	timelineFill.BackgroundColor3 = VisualizerTheme.AccentBright
	timelineFill.BorderSizePixel = 0
	timelineFill.Size = UDim2.fromScale(0, 1)
	timelineFill.Parent = timeline
	VisualizerUI.Timeline, VisualizerUI.TimelineFill = timeline, timelineFill
	connectVisualizer(timeline.MouseButton1Down, function()
		local track = getMainVisualizerTrack()
		if track and track.Length > 0 then
			local alpha = math.clamp((UserInputService:GetMouseLocation().X - timeline.AbsolutePosition.X) / timeline.AbsoluteSize.X, 0, 1)
			setVisualizerPaused(true)
			setVisualizerTime(track.Length * alpha)
		end
	end)
	local playButton = createVisualizerButton(center, "Pause")
	playButton.Size = UDim2.fromOffset(88, 28)
	VisualizerUI.PlayButton = playButton
	connectVisualizer(playButton.MouseButton1Click, function()
		setVisualizerPaused(not VisualizerPaused)
	end)
	local seekBox = Instance.new("TextBox")
	seekBox.Size = UDim2.fromOffset(86, 28)
	seekBox.BackgroundColor3 = VisualizerTheme.Field
	seekBox.BorderColor3 = VisualizerTheme.FieldBorder
	seekBox.ClearTextOnFocus = false
	seekBox.Font = Enum.Font.Code
	seekBox.PlaceholderText = "Seconds"
	seekBox.Text = ""
	seekBox.TextColor3 = VisualizerTheme.Text
	seekBox.TextSize = 12
	seekBox.Parent = center
	VisualizerUI.SeekBox = seekBox
	local seekButton = createVisualizerButton(center, "Seek")
	seekButton.Size = UDim2.fromOffset(62, 28)
	VisualizerUI.SeekButton = seekButton
	connectVisualizer(seekButton.MouseButton1Click, function()
		local value = tonumber(seekBox.Text)
		if value then setVisualizerTime(value) end
	end)
	local seekTooltip = "Jump to an exact second in the animation Super useful when you already know roughly where the hit/parry moment should be"
	attachPepsiTooltip(seekBox, seekTooltip)
	attachPepsiTooltip(seekButton, seekTooltip)
	local copyButton = createVisualizerButton(center, "Use Time")
	copyButton.Size = UDim2.fromOffset(112, 28)
	VisualizerUI.CopyButton = copyButton
	connectVisualizer(copyButton.MouseButton1Click, function()
		if not useCurrentVisualizerTimeAsResponseTime() then
			warn("Animation visualizer: select an animation before using current time")
		end
	end)
	attachPepsiTooltip(
		copyButton,
		"Sets Wait Before Response to the current animation time"
	)
	local info = Instance.new("TextLabel")
	info.BackgroundTransparency = 1
	info.Font = Enum.Font.Code
	info.Text = "No animation selected"
	info.TextColor3 = VisualizerTheme.TextSoft
	info.TextSize = 12
	info.TextWrapped = true
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextYAlignment = Enum.TextYAlignment.Top
	info.Parent = center
	VisualizerUI.Info = info

	local right = VisualizerUI.Right
	local rightPadding = Instance.new("UIPadding")
	rightPadding.PaddingLeft = UDim.new(0, 8)
	rightPadding.PaddingRight = UDim.new(0, 4)
	rightPadding.PaddingTop = UDim.new(0, 8)
	rightPadding.Parent = right
	local rightLayout = Instance.new("UIListLayout")
	rightLayout.Padding = UDim.new(0, 4)
	rightLayout.Parent = right
	local selectedProfile = Instance.new("TextLabel")
	selectedProfile.BackgroundColor3 = VisualizerTheme.Profile
	selectedProfile.BorderSizePixel = 0
	selectedProfile.Size = UDim2.new(1, -8, 0, 52)
	selectedProfile.Font = Enum.Font.Code
	selectedProfile.Text = "No animation selected"
	selectedProfile.TextColor3 = VisualizerTheme.Text
	selectedProfile.TextSize = 13
	selectedProfile.TextWrapped = true
	selectedProfile.Parent = right
	VisualizerUI.SelectedProfile = selectedProfile
	local profileMatch = Instance.new("TextLabel")
	profileMatch.BackgroundColor3 = VisualizerTheme.ProfileMatch
	profileMatch.BorderSizePixel = 0
	profileMatch.Size = UDim2.new(1, -8, 0, 42)
	profileMatch.Font = Enum.Font.Code
	profileMatch.Text = "Effective: none"
	profileMatch.TextColor3 = Color3.fromRGB(224, 141, 124)
	profileMatch.TextSize = 12
	profileMatch.TextWrapped = true
	profileMatch.TextXAlignment = Enum.TextXAlignment.Left
	profileMatch.Parent = right
	VisualizerUI.ProfileMatch = profileMatch
	VisualizerUI.ProfileEnabled = createVisualizerToggle(right, "Use for Auto Response", false, function(value)
		if IsLoadingAnimationProfile then return end
		local profile = SelectedAnimationSourceKey and SelectedAnimationId and getAnimationProfile(SelectedAnimationSourceKey, SelectedAnimationId, false)
		if profile then
			profile.Enabled = value
			syncAnimationIdResponseSettings(SelectedAnimationId, profile)
			refreshVisualizerAnimationList()
			refreshAnimationObserver()
			scheduleAnimationProfilesSave()
		end
	end)
	attachPepsiTooltip(
		VisualizerUI.ProfileEnabled,
		"Enables automatic responses for this animation When this attack plays nearby, the configured counter, block, or dash will trigger for you"
	)
	VisualizerUI.ProfileWait = createVisualizerTextbox(right, "Wait Before Response (seconds)", "0.000", function(value)
		if IsLoadingAnimationProfile then return end
		local profile = SelectedAnimationSourceKey and SelectedAnimationId and getAnimationProfile(SelectedAnimationSourceKey, SelectedAnimationId, false)
		if profile then
			profile.WaitBeforeResponse = math.clamp(tonumber(value) or profile.WaitBeforeResponse, 0, 10)
			syncAnimationIdResponseSettings(SelectedAnimationId, profile)
			VisualizerUI.ProfileWait:Set(string.format("%.3f", profile.WaitBeforeResponse), false)
			scheduleAnimationProfilesSave()
		end
	end)
	VisualizerUI.ProfileAction = createVisualizerDropdown(right, "Response Action", {"Counter", "Block / Parry", "Dash"}, "Block / Parry", function(value)
		if IsLoadingAnimationProfile then return end
		local profile = SelectedAnimationSourceKey and SelectedAnimationId and getAnimationProfile(SelectedAnimationSourceKey, SelectedAnimationId, false)
		local actions = {Counter = "Press F", ["Block / Parry"] = "Press Right Mouse Click", Dash = "Press Q (Dash)"}
		if profile then
			profile.ResponseAction = actions[value]
			syncAnimationIdResponseSettings(SelectedAnimationId, profile)
			refreshVisualizerAnimationList()
			scheduleAnimationProfilesSave()
		end
	end)
	local forgetButton = createVisualizerButton(right, "Forget Animation")
	forgetButton.Size = UDim2.new(1, -8, 0, 28)
	forgetButton.Visible = false
	VisualizerUI.ForgetButton = forgetButton
	connectVisualizer(forgetButton.MouseButton1Click, function()
		local animationId = SelectedAnimationId
		if not animationId then
			return
		end

		if not forgetAnimationProfileById(animationId) then
			warn("Animation visualizer: selected animation was not found in config")
		end
	end)
	attachPepsiTooltip(
		forgetButton,
		"Removes this animation from saved profiles so Animation Analysis can capture it again"
	)
	local saveSharedButton = createVisualizerButton(right, "Save as Shared Weapon Profile")
	saveSharedButton.Size = UDim2.new(1, -8, 0, 28)
	VisualizerUI.SaveSharedButton = saveSharedButton
	connectVisualizer(saveSharedButton.MouseButton1Click, function()
		local sourceKey, animationId = SelectedAnimationSourceKey, SelectedAnimationId
		local sharedKey = sourceKey and getSharedAnimationSourceKey(sourceKey)
		local sourceProfile = sourceKey and animationId and getAnimationProfile(sourceKey, animationId, false)
		if not sharedKey or sharedKey == sourceKey or not sourceProfile then
			return
		end

		local sharedProfile = getAnimationProfile(sharedKey, animationId, true)
		copyAnimationProfileValues(sourceProfile, sharedProfile)
		syncAnimationIdResponseSettings(animationId, sharedProfile)
		rebuildAnimationEntryList()
		syncVisualizerProfileControls()
		refreshAnimationObserver()
		scheduleAnimationProfilesSave()
	end)
	attachPepsiTooltip(
		saveSharedButton,
		"Copies this response to the shared weapon profile Nice for M1 animations that are the same across Katana variants, while crits can stay exact"
	)
	local separator = Instance.new("TextLabel")
	separator.BackgroundTransparency = 1
	separator.Size = UDim2.new(1, -8, 0, 24)
	separator.Font = Enum.Font.Code
	separator.Text = "AUTO RESPONSE"
	separator.TextColor3 = VisualizerTheme.AccentBright
	separator.TextSize = 13
	separator.TextXAlignment = Enum.TextXAlignment.Left
	separator.Parent = right
	VisualizerUI.ResponseDistance = createVisualizerSlider(right, "Response Distance", 5, 150, ResponseDistance, 0, function(v) return tostring(v) .. " studs" end, function(value)
		ResponseDistance = value
		scheduleAnimationProfilesSave()
	end)
	attachPepsiTooltip(
		VisualizerUI.ResponseDistance,
		"How close the attacker needs to be before Auto Response reacts Keep it around your usual fight range - bigger isn't always better"
	)
	VisualizerUI.ResponseHold = createVisualizerSlider(right, "Block Hold Time", 20, 300, ResponseHoldTime * 1000, 0, function(v) return tostring(v) .. " ms" end, function(value)
		if IsLoadingAnimationProfile then return end
		local profile = SelectedAnimationSourceKey and SelectedAnimationId and getAnimationProfile(SelectedAnimationSourceKey, SelectedAnimationId, false)
		if profile then
			profile.BlockHoldTime = value / 1000
			syncAnimationIdResponseSettings(SelectedAnimationId, profile)
		else
			ResponseHoldTime = value / 1000
		end
		scheduleAnimationProfilesSave()
	end)
	attachPepsiTooltip(
		VisualizerUI.ResponseHold,
		"How long Block / Parry stays held for this animation"
	)
	VisualizerUI.OtherPing = createVisualizerToggle(right, "Use Other Ping Method", UseReplicatorPing, function(value)
		UseReplicatorPing = value
		scheduleAnimationProfilesSave()
	end)
	attachPepsiTooltip(
		VisualizerUI.OtherPing,
		"If you have problems with auto parrying/dashing/countering, try using this feature It uses different method to check players ping"
	)
	VisualizerUI.PingMultiplier = createVisualizerSlider(right, "Ping Multiplier", 0, 1, PingMultiplier, 2, function(v) return string.format("%.2f", v) end, function(value)
		PingMultiplier = value
		scheduleAnimationProfilesSave()
	end)
	attachPepsiTooltip(
		VisualizerUI.PingMultiplier,
		"Controls how much of your ping is compensated Raise it if responses feel late; lower it if they happen a little too early"
	)

	local resize = Instance.new("TextButton")
	resize.AnchorPoint = Vector2.new(1, 1)
	resize.Position = UDim2.fromScale(1, 1)
	resize.Size = UDim2.fromOffset(18, 18)
	resize.BackgroundColor3 = VisualizerTheme.Resize
	resize.BorderSizePixel = 0
	resize.Text = ""
	resize.Parent = panel
	local dragging, resizing, dragStart, startPosition, startSize
	connectVisualizer(titleBar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging, dragStart, startPosition = true, input.Position, panel.Position
		end
	end)
	connectVisualizer(resize.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing, dragStart, startSize = true, input.Position, panel.AbsoluteSize
		end
	end)
	connectVisualizer(UserInputService.InputChanged, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local camera = Workspace.CurrentCamera
		local vp = camera and camera.ViewportSize or viewportSize
		if dragging then
			local delta = input.Position - dragStart
			local x = startPosition.X.Offset + delta.X
			local y = startPosition.Y.Offset + delta.Y
			panel.Position = UDim2.fromOffset(x, y)
		elseif resizing then
			local delta = input.Position - dragStart
			local minWidth, minHeight = math.min(720, vp.X - 8), math.min(520, vp.Y - 8)
			local newWidth = math.max(minWidth, startSize.X + delta.X)
			local newHeight = math.max(minHeight, startSize.Y + delta.Y)
			panel.Size = UDim2.fromOffset(newWidth, newHeight)
			layoutVisualizerWorkspace()
			if VisualizerUI.World and VisualizerUI.Camera then layoutVisualizerRigs(VisualizerUI.World, VisualizerUI.Camera) end
		end
	end)
	connectVisualizer(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging, resizing = false, false end
	end)

	updateVisualizerAnalysisControls()
	layoutVisualizerWorkspace()
	refreshVisualizerAnimationList()
	local requestedId = normalizeAnimationId(animationId)
	if requestedId and getAnimationProfile(sourceKey or "Manual", requestedId, false) then
		loadVisualizerSelection(sourceKey or "Manual", requestedId)
	elseif SelectedAnimationSourceKey and SelectedAnimationId and getAnimationProfile(SelectedAnimationSourceKey, SelectedAnimationId, false) then
		loadVisualizerSelection(SelectedAnimationSourceKey, SelectedAnimationId)
	else
		showVisualizerEmptyState()
	end
	return true
end

function unloadAnimationSystem()
	closeAnimationVisualizer()
	AnalysisEnabled = false
	disconnectAnimationObserver()
	if ResponseHeartbeatConnection then
		ResponseHeartbeatConnection:Disconnect()
		ResponseHeartbeatConnection = nil
	end
	table.clear(PendingResponseTracks)
	releaseActiveResponse()
	for sourceKey, template in SourcePreviewTemplates do
		if template then template:Destroy() end
		SourcePreviewTemplates[sourceKey] = nil
	end
end

VVPreviousUnloadCallback = library.UnloadCallback
library.UnloadCallback = function()
	unloadAnimationSystem()
	VVExecutionGuard.__VVUltimatumExecuted = false
	if type(VVPreviousUnloadCallback) == "function" then VVPreviousUnloadCallback() end
end


-------- SETTINGS AND CONFIG
local LeafUiThemes = {
    '{"__Designer.Colors.topGradient":"D5D5D5","__Designer.Settings.ShowHideKey":"Enum.KeyCode.RightShift","__Designer.Colors.section":"000000","__Designer.Colors.hoveredOptionBottom":"FFFFFF","__Designer.Background.ImageAssetID":"rbxassetid://73587552329979","__Designer.Colors.selectedOption":"BAA0A0","__Designer.Colors.unselectedOption":"282828","__Designer.Files.WorkspaceFile":"Pepsis World","__Designer.Colors.unhoveredOptionTop":"323232","__Designer.Colors.outerBorder":"D5D5D5","__Designer.Background.ImageColor":"E0E0E0","__Designer.Colors.tabText":"BAA0A0","__Designer.Colors.elementBorder":"D4D4D4","__Designer.Colors.sectionBackground":"E4E4E4","__Designer.Colors.innerBorder":"D5D5D5","__Designer.Colors.background":"D5D5D5","__Designer.Colors.bottomGradient":"D5D5D5","__Designer.Background.ImageTransparency":15,"__Designer.Colors.main":"6E2E2E","__Designer.Colors.elementText":"532B2B","__Designer.Colors.hoveredOptionTop":"414141","__Designer.Colors.otherElementText":"A695A1","__Designer.Colors.unhoveredOptionBottom":"232323","__Designer.Background.UseBackgroundImage":true}', -- Gaara Theme (dark red)
    '{"__Designer.Colors.topGradient":"D0D0D0","__Designer.Settings.ShowHideKey":"Enum.KeyCode.RightShift","__Designer.Colors.section":"000000","__Designer.Colors.hoveredOptionBottom":"FFFFFF","__Designer.Background.ImageAssetID":"rbxassetid://118747125406885","__Designer.Colors.innerBorder":"D0D0D0","__Designer.Colors.unselectedOption":"282828","__Designer.Files.WorkspaceFile":"Pepsis World","__Designer.Colors.unhoveredOptionTop":"323232","__Designer.Colors.outerBorder":"D0D0D0","__Designer.Background.ImageColor":"E0E0E0","__Designer.Colors.tabText":"BAA0A0","__Designer.Colors.elementBorder":"D4D4D4","__Designer.Colors.selectedOption":"BAA0A0","__Designer.Colors.background":"D0D0D0","__Designer.Colors.bottomGradient":"D5D5D5","__Designer.Background.ImageTransparency":15,"__Designer.Colors.otherElementText":"A695A1","__Designer.Colors.main":"517340","__Designer.Colors.elementText":"373734","__Designer.Colors.hoveredOptionTop":"414141","__Designer.Colors.sectionBackground":"E4E4E4","__Designer.Colors.unhoveredOptionBottom":"232323","__Designer.Background.UseBackgroundImage":true}', -- Ulquiorra Theme (green)
}
LeafUiThemes.BackgroundImages = {
	{
		"rbxassetid://73587552329979", -- GaaraRight
		"rbxassetid://83069921308354", -- GaaraLeft
		"rbxassetid://125942528963898", -- GaaraRightAlt
		"rbxassetid://131354141032603", -- GaaraClean
		"rbxassetid://102686280421729", -- GaaraBottom
	},
	{
		"rbxassetid://118747125406885", -- UlqRight
		"rbxassetid://122518947182948", -- UlqLeft
		"rbxassetid://89163792232928", -- UlqRightAlt
		"rbxassetid://100822294242137", -- UlqMiddle
		"rbxassetid://86179379369011", -- UlqClean
	},
}

do
	local backgroundImages = LeafUiThemes.BackgroundImages[SelectedLeafThemeIndex]
	if type(backgroundImages) == "table" and #backgroundImages > 0 then
		local decodeSuccess, themeConfig = pcall(HttpService.JSONDecode, HttpService, LeafUiThemes[SelectedLeafThemeIndex])
		if decodeSuccess and type(themeConfig) == "table" then
			themeConfig["__Designer.Background.ImageAssetID"] = backgroundImages[math.random(1, #backgroundImages)]
			LeafUiThemes[SelectedLeafThemeIndex] = HttpService:JSONEncode(themeConfig)
		else
			warn("LeafUiThemes: failed to randomize background image for selected theme")
		end
	end
end
local HubName = {"Hidden Leaf Hub", "Hub Hidden In The Leaf", "The Leaf", "Leaf Hub",}
local HubSpace = {" ~ ", " | ", " / ", " \ ", " : ", " <> ", "://", ", "}
local HubQuote = {"One and Only", "Utterly Gutsy Ninja", "Dattebayo!"}
local LeafHub = library:CreateWindow({
	Name = HubName[math.random(1,4)] .. HubSpace[math.random(1,8)] .. HubQuote[math.random(1,3)],
	DefaultTheme = LeafUiThemes[SelectedLeafThemeIndex],
	Themeable = {
		Credit = false
	},
})

function toggleLeafHubVisibility()
	if type(safeSetPepsiTooltipVisible) == "function" then
		safeSetPepsiTooltipVisible(false)
	elseif VVPepsiTooltipFrame then
		VVPepsiTooltipFrame.Visible = false
	end

	if LeafHub and type(LeafHub.CloseDropdown) == "function" then
		pcall(LeafHub.CloseDropdown)
	end

	if not LeafHub or type(LeafHub.Visibility) ~= "function" then
		warn("Pepsi UI: window visibility API is unavailable")
		return false
	end

	local success, visible = pcall(LeafHub.Visibility, LeafHub)
	if not success then
		warn("Pepsi UI: failed to toggle visibility: " .. tostring(visible))
		return false
	end

	return visible
end

LeafUiThemes.BackgroundAnimator = {
	Enabled = false,
	LastImage = nil,
	Task = nil,
	TransparencyEnabled = false,
	TransparencyTask = nil,
	Delay = 0.1,
	MinTransparency = 45,
	MaxTransparency = 80,
}

function setLeafThemeBackgroundImage(assetId)
	if type(assetId) ~= "string" then
		return false
	end

	library.Flags["__Designer.Background.UseBackgroundImage"] = true
	library.Flags["__Designer.Background.ImageAssetID"] = assetId

	if library.Backdrop then
		library.Backdrop.Visible = true
		library.Backdrop.Image = assetId
	end

	return true
end

function setLeafThemeBackgroundTransparency(transparency)
	transparency = tonumber(transparency)
	if not transparency then
		return false
	end

	transparency = math.max(0, math.min(100, transparency))
	library.Flags["__Designer.Background.ImageTransparency"] = transparency

	if library.Backdrop then
		library.Backdrop.ImageTransparency = transparency / 100
	end

	return true
end

function getRandomLeafThemeBackgroundImage()
	local backgroundImages = LeafUiThemes.BackgroundImages[SelectedLeafThemeIndex]
	if type(backgroundImages) ~= "table" or #backgroundImages == 0 then
		return nil
	end

	if #backgroundImages == 1 then
		return backgroundImages[1]
	end

	local nextImage
	for _ = 1, 5 do
		nextImage = backgroundImages[math.random(1, #backgroundImages)]
		if nextImage ~= LeafUiThemes.BackgroundAnimator.LastImage then
			break
		end
	end

	return nextImage
end

function stopLeafThemeBackgroundVideo()
	LeafUiThemes.BackgroundAnimator.Enabled = false

	if LeafUiThemes.BackgroundAnimator.Task then
		task.cancel(LeafUiThemes.BackgroundAnimator.Task)
		LeafUiThemes.BackgroundAnimator.Task = nil
	end
end

function stopLeafThemeBackgroundTransparency()
	LeafUiThemes.BackgroundAnimator.TransparencyEnabled = false

	if LeafUiThemes.BackgroundAnimator.TransparencyTask then
		task.cancel(LeafUiThemes.BackgroundAnimator.TransparencyTask)
		LeafUiThemes.BackgroundAnimator.TransparencyTask = nil
	end
end

function startLeafThemeBackgroundVideo()
	stopLeafThemeBackgroundVideo()
	LeafUiThemes.BackgroundAnimator.Enabled = true
	LeafUiThemes.BackgroundAnimator.Task = task.spawn(function()
		while LeafUiThemes.BackgroundAnimator.Enabled and library.Flags["flag_LeafThemeBackgroundVideo"] do
			local nextImage = getRandomLeafThemeBackgroundImage()
			if nextImage then
				LeafUiThemes.BackgroundAnimator.LastImage = nextImage
				setLeafThemeBackgroundImage(nextImage)
			end
			task.wait(LeafUiThemes.BackgroundAnimator.Delay)
		end

		LeafUiThemes.BackgroundAnimator.Enabled = false
		LeafUiThemes.BackgroundAnimator.Task = nil
	end)
end

function startLeafThemeBackgroundTransparency()
	stopLeafThemeBackgroundTransparency()
	LeafUiThemes.BackgroundAnimator.TransparencyEnabled = true
	LeafUiThemes.BackgroundAnimator.TransparencyTask = task.spawn(function()
		while LeafUiThemes.BackgroundAnimator.TransparencyEnabled and library.Flags["flag_LeafThemeBackgroundTransparency"] do
			setLeafThemeBackgroundTransparency(math.random(
				LeafUiThemes.BackgroundAnimator.MinTransparency,
				LeafUiThemes.BackgroundAnimator.MaxTransparency
			))
			task.wait(LeafUiThemes.BackgroundAnimator.Delay)
		end

		LeafUiThemes.BackgroundAnimator.TransparencyEnabled = false
		LeafUiThemes.BackgroundAnimator.TransparencyTask = nil
	end)
end

local VVPepsiTooltipRenderConnection
local VVPepsiTooltipCapabilityWarningShown = false

function safeSetPepsiTooltipVisible(visible, text, target)
	local success, err = pcall(function()
		if text ~= nil and VVPepsiTooltipText then
			VVPepsiTooltipText.Text = tostring(text)
		end

		if VVPepsiTooltipFrame then
			VVPepsiTooltipFrame.Visible = visible == true
		end

		VVPepsiTooltipTarget = visible and target or nil
	end)

	if not success then
		VVPepsiTooltipTarget = nil
		if not VVPepsiTooltipCapabilityWarningShown then
			VVPepsiTooltipCapabilityWarningShown = true
			warn("Tooltip: Roblox blocked access to tooltip UI from this thread; tooltip was skipped: " .. tostring(err))
		end
	end
end

function createPepsiTooltip()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local tooltipParent = library.gui_parent or playerGui
	if typeof(VVPepsiTooltipRenderConnection) == "RBXScriptConnection" then
		VVPepsiTooltipRenderConnection:Disconnect()
		VVPepsiTooltipRenderConnection = nil
	end
	local oldPlayerGuiTooltip = playerGui:FindFirstChild("VVPepsiTooltip")
	if oldPlayerGuiTooltip then
		oldPlayerGuiTooltip:Destroy()
	end
	if tooltipParent ~= playerGui then
		local oldParentTooltip = tooltipParent:FindFirstChild("VVPepsiTooltip")
		if oldParentTooltip then
			oldParentTooltip:Destroy()
		end
	end

	VVPepsiTooltipGui = Instance.new("ScreenGui")
	VVPepsiTooltipGui.Name = "VVPepsiTooltip"
	VVPepsiTooltipGui.DisplayOrder = 10000
	VVPepsiTooltipGui.IgnoreGuiInset = true
	VVPepsiTooltipGui.ResetOnSpawn = false
	VVPepsiTooltipGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	VVPepsiTooltipGui.Parent = tooltipParent
	table.insert(library.signals, VVPepsiTooltipGui)

	VVPepsiTooltipFrame = Instance.new("Frame")
	VVPepsiTooltipFrame.Name = "Tooltip"
	VVPepsiTooltipFrame.AutomaticSize = Enum.AutomaticSize.Y
	VVPepsiTooltipFrame.BackgroundColor3 = Color3.fromRGB(250, 251, 248)
	VVPepsiTooltipFrame.BorderSizePixel = 0
	VVPepsiTooltipFrame.Size = UDim2.fromOffset(330, 0)
	VVPepsiTooltipFrame.Visible = false
	VVPepsiTooltipFrame.ZIndex = 100
	VVPepsiTooltipFrame.Parent = VVPepsiTooltipGui

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(184, 194, 180)
	stroke.Thickness = 1
	stroke.Parent = VVPepsiTooltipFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 9)
	padding.PaddingBottom = UDim.new(0, 9)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = VVPepsiTooltipFrame

	VVPepsiTooltipText = Instance.new("TextLabel")
	VVPepsiTooltipText.Name = "Text"
	VVPepsiTooltipText.AutomaticSize = Enum.AutomaticSize.Y
	VVPepsiTooltipText.BackgroundTransparency = 1
	VVPepsiTooltipText.Font = Enum.Font.Code
	VVPepsiTooltipText.Size = UDim2.new(1, 0, 0, 0)
	VVPepsiTooltipText.TextColor3 = Color3.fromRGB(34, 42, 34)
	VVPepsiTooltipText.TextSize = 14
	VVPepsiTooltipText.TextWrapped = true
	VVPepsiTooltipText.TextXAlignment = Enum.TextXAlignment.Left
	VVPepsiTooltipText.TextYAlignment = Enum.TextYAlignment.Top
	VVPepsiTooltipText.ZIndex = 101
	VVPepsiTooltipText.Parent = VVPepsiTooltipFrame

	VVPepsiTooltipRenderConnection = RunService.RenderStepped:Connect(function()
		local ok, err = pcall(function()
			if not VVPepsiTooltipFrame or not VVPepsiTooltipFrame.Visible then
				return
			end

			local camera = Workspace.CurrentCamera
			if not camera then
				return
			end

			local viewportSize = camera.ViewportSize
			local tooltipWidth = math.max(180, math.min(330, viewportSize.X - 24))
			VVPepsiTooltipFrame.Size = UDim2.fromOffset(tooltipWidth, 0)

			local mousePosition = UserInputService:GetMouseLocation()
			local tooltipSize = VVPepsiTooltipFrame.AbsoluteSize
			local x = math.clamp(mousePosition.X + 16, 8, math.max(8, viewportSize.X - tooltipSize.X - 8))
			local y = math.clamp(mousePosition.Y + 18, 8, math.max(8, viewportSize.Y - tooltipSize.Y - 8))
			VVPepsiTooltipFrame.Position = UDim2.fromOffset(x, y)
		end)

		if not ok and not VVPepsiTooltipCapabilityWarningShown then
			VVPepsiTooltipCapabilityWarningShown = true
			warn("Tooltip: Roblox blocked tooltip position update: " .. tostring(err))
		end
	end)
	table.insert(library.signals, VVPepsiTooltipRenderConnection)
end

function attachPepsiTooltip(element, text, hoverTarget)
	if not VVPepsiTooltipGui then
		createPepsiTooltip()
	end

	local target = hoverTarget or (type(element) == "table" and element.Instance) or element
	if typeof(target) ~= "Instance" or not target:IsA("GuiObject") then
		warn("Tooltip: the supplied PepsiUI element has no GuiObject target")
		return false
	end

	table.insert(library.signals, target.MouseEnter:Connect(function()
		safeSetPepsiTooltipVisible(true, text, target)
	end))
	table.insert(library.signals, target.MouseLeave:Connect(function()
		if VVPepsiTooltipTarget == target then
			safeSetPepsiTooltipVisible(false)
		end
	end))

	return true
end

function addPepsiSpacer(section, height, flag)
	local spacer = section:AddLabel({
		Text = "",
		Flag = flag or ("flag_PepsiSpacer_" .. tostring(math.random(100000, 999999))),
	})
	if spacer and spacer.Instance then
		spacer.Instance.TextTransparency = 1
		local frame = spacer.Instance.Parent
		if frame then
			frame.Size = UDim2.new(1, 0, 0, tonumber(height) or 8)
		end
		if spacer.Parent and type(spacer.Parent.Update) == "function" then
			spacer.Parent:Update()
		end
	end
	return spacer
end

createPepsiTooltip()







-------- FRONT END, UI LIB
-- General Tab (ESP, Auto Aim, NoClip, etc.)
GeneralTab = LeafHub:CreateTab({
	Name = "General"
})
GeneralSections = {}
GeneralSections.Movement = GeneralTab:CreateSection({
	Name = "Movement"
})
GeneralSections.Teleports = GeneralTab:CreateSection({
	Name = "Teleports"
})
GeneralSections.ESP = GeneralTab:CreateSection({
	Name = "ESP"
})
GeneralSections.Utility = GeneralTab:CreateSection({
	Name = "Utility",
	Side = "right"
})

-- Special Tab (Auto Farms, Difficult Logic, etc)
SpecialTab = LeafHub:CreateTab({
	Name = "Special"
})
SpecialSections = {}
SpecialSections.AutoFarms = SpecialTab:CreateSection({
	Name = "Auto Farms"
})
SpecialSections.Servers = SpecialTab:CreateSection({
	Name = "Servers"
})
SpecialSections.Visualizer = SpecialTab:CreateSection({
	Name = "Visualizer",
	Side = "right"
})
SpecialSections.Fun = SpecialTab:CreateSection({
	Name = "Fun!",
	Side = "right"
})
SpecialSections.Debug = SpecialTab:CreateSection({
	Name = "Debug",
	Side = "right"
})
SpecialSection = SpecialSections.AutoFarms




GeneralSections.ESP:AddToggle({
	Name = "ESP",
	Flag = "flag_ESP",
	Keybind = {
		Flag = "flag_ESPKeybind",
		Mode = "Toggle"
	},
	Callback = function(Value)
		if Value then
			enableESP()
		else
			disableESP()
		end
	end
})
GeneralSections.ESP:AddToggle({
	Name = "Names",
	Flag = "flag_ESPNames",
	Value = true,
	Callback = function(Value)
		ESPState.ShowNames = Value
		updateAllESPBillboards()
	end
})
GeneralSections.ESP:AddToggle({
	Name = "Distance",
	Flag = "flag_ESPDistance",
	Value = true,
	Callback = function(Value)
		ESPState.ShowDistance = Value
		updateAllESPBillboards()
	end
})




WalkSpeedToggle = GeneralSections.Movement:AddToggle({
	Name = "Walkspeed",
	Flag = "flag_WalkSpeed",
	Keybind = {
		Flag = "flag_WalkSpeedKeybind",
		Mode = "Toggle"
	},
	Callback = function(Value)
		ChangeWalkSpeedLoop()
	end
})
attachPepsiTooltip(WalkSpeedToggle, "Changes walkspeed, duh! If don't want toggle, you can use WalkHold to Hold/Release Walkspeed")
WalkSpeedPressedKeybind = GeneralSections.Movement:AddKeybind({
	Name = "WalkHold",
	Flag = "flag_WalkSpeedPressedKey",
	Pressed = function()
		setWalkSpeedPressedKeyHeld(true)
	end
})
GeneralSections.Movement:AddSlider({
	Name = "Walkspeed",
	Flag = "flag_WalkSpeedValue",
	Value = 16,
	Min = 5,
	Max = 150,
	Decimals = 0,
	Format = "%s studs/s",
	Callback = function(Value)
		DesiredWalkSpeed = Value
	end
})
table.insert(library.signals, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local pressedKey = getWalkSpeedPressedKey()
	if pressedKey and input.KeyCode == pressedKey then
		setWalkSpeedPressedKeyHeld(true)
	end
end))
table.insert(library.signals, UserInputService.InputEnded:Connect(function(input)
	local pressedKey = getWalkSpeedPressedKey()
	if pressedKey and input.KeyCode == pressedKey then
		setWalkSpeedPressedKeyHeld(false)
	end
end))

addPepsiSpacer(GeneralSections.Movement, 8, "flag_PepsiSpacer_Movement_WalkspeedToFly")

GeneralSections.Movement:AddToggle({
	Name = "Fly",
	Flag = "flag_Fly",
	Keybind = {
		Flag = "flag_FlyKeybind",
		Mode = "Toggle"
	},
	Callback = function(Value)
		if Value then
			fly()
		else
			stopFly()
		end
	end
})
GeneralSections.Movement:AddSlider({
	Name = "Fly Speed",
	Flag = "flag_FlySpeed",
	Value = 60,
	Min = 10,
	Max = 200,
	Decimals = 0,
	Format = "%s studs/s",
	Callback = function(Value)
		FlyState.Speed = Value
	end
})

VVInstaBlitzTeleportKeybind = GeneralSections.Teleports:AddKeybind({
	Name = "Insta Blitz",
	Flag = "flag_InstaBlitzTeleportKeybind",
	Pressed = function()
		VelocityTeleport(TeleportState.InstaBlitzDistance)
	end
})
attachPepsiTooltip(
	VVInstaBlitzTeleportKeybind,
	"Dashes you forward",
	VVInstaBlitzTeleportKeybind.Instance.Parent.Parent
)
GeneralSections.Teleports:AddSlider({
	Name = "Insta Blitz Distance",
	Flag = "flag_InstaBlitzDistance",
	Value = TeleportState.InstaBlitzDistance,
	Min = 1,
	Max = 300,
	Decimals = 0,
	Format = "%s studs tp distance",
	Callback = function(Value)
		TeleportState.InstaBlitzDistance = Value
	end
})

addPepsiSpacer(GeneralSections.Teleports, 8, "flag_PepsiSpacer_Teleports_InstaToEnemy")

VVBlitzTeleportToEnemyKeybind = GeneralSections.Teleports:AddKeybind({
	Name = "Enemy Blitz",
	Flag = "flag_BlitzTeleportToEnemyKeybind",
	Pressed = function()
		BlitzTeleportToNearestEnemy()
	end
})
attachPepsiTooltip(
	VVBlitzTeleportToEnemyKeybind,
	"Teleports behind a nearby enemy",
	VVBlitzTeleportToEnemyKeybind.Instance.Parent.Parent
)
GeneralSections.Teleports:AddSlider({
	Name = "Blitz Enemy Radius",
	Flag = "flag_BlitzTeleportEnemyRadius",
	Value = TeleportState.BlitzEnemyRadius,
	Min = 5,
	Max = 100,
	Decimals = 0,
	Format = "%s studs radius",
	Callback = function(Value)
		TeleportState.BlitzEnemyRadius = Value
	end
})

addPepsiSpacer(GeneralSections.Teleports, 8, "flag_PepsiSpacer_Teleports_EnemyToSoru")

VVSoruTeleportKeybind = GeneralSections.Teleports:AddKeybind({
	Name = "Soru",
	Flag = "flag_SoruTeleportKeybind",
	Pressed = function()
		SoruTeleportToMouse()
	end
})
attachPepsiTooltip(
	VVSoruTeleportKeybind,
	"Teleports where your mouse points, THE ONE PIECE IS REAL!!!",
	VVSoruTeleportKeybind.Instance.Parent.Parent
)
GeneralSections.Teleports:AddSlider({
	Name = "Soru Radius",
	Flag = "flag_SoruTeleportRadius",
	Value = TeleportState.SoruRadius,
	Min = 10,
	Max = 300,
	Decimals = 0,
	Format = "%s studs radius",
	Callback = function(Value)
		TeleportState.SoruRadius = Value
	end
})

GeneralSections.Utility:AddToggle({
	Name = "No Fall Damage",
	Flag = "flag_FallDamage",
})

GeneralSections.Utility:AddToggle({
	Name = "Auto Respawn",
	Flag = "flag_AutoRespawn",
	Callback = function(Value)
		if Value then
			AutoRespawnState.Enabled = true
			AutoRespawn()
		else
			DisableAutoRespawn()
		end
	end
})

GeneralSections.Utility:AddToggle({
	Name = "NoClip",
	Flag = "flag_NoClip",
	Keybind = {
		Flag = "flag_NoClipKeybind",
		Mode = "Toggle"
	},
	Callback = function(Value)
		if Value then
			StartNoClipFunc()
		else
			NoClipDisableFunc()
		end
	end
})

attachPepsiTooltip(GeneralSections.Utility:AddKeybind({
	Name = "Close/Open UI",
	Flag = "flag_CloseOpenUIKeybind",
	Value = Enum.KeyCode.RightShift,
	Pressed = function()
		toggleLeafHubVisibility()
	end
}), "Hides or shows the main Pepsi UI without unloading it")

InvisibilityToggle = GeneralSections.Utility:AddToggle({
	Name = "Desync",
	Flag = "flag_Invisibility",
	Keybind = {
		Flag = "flag_InvisibilityKeybind",
		Mode = "Toggle"
	},
	UnloadValue = false,
	UnloadFunc = function()
		setInvisibilityEnabled(false)
	end,
	Callback = function(Value)
		if not setInvisibilityEnabled(Value) and Value and InvisibilityToggle then
			InvisibilityToggle:RawSet(false)
		end
	end
})
attachPepsiTooltip(InvisibilityToggle, "Toggles desync invisibility")

attachPepsiTooltip(GeneralSections.Utility:AddToggle({
	Name = "Eat Hollow Parts",
	Flag = "flag_AutoEatHollowParts",
	Callback = function(Value)
		setAutoEatHollowPartsEnabled(Value)
	end
}), "Eats nearby hollow parts")

attachPepsiTooltip(SpecialSections.Fun:AddToggle({
	Name = "Rainbow",
	Flag = "flag_AutoRainbow",
	Callback = function(Value)
		if Value then
			AutoRainbow()
		else
			DisableAutoRainbow()
		end
	end
}), "Makes your character rainbow")

addPepsiSpacer(SpecialSections.Fun, 8, "flag_PepsiSpacer_Fun_RainbowToHighlight")

attachPepsiTooltip(SpecialSections.Fun:AddToggle({
	Name = "Highlight",
	Flag = "flag_AutoRainbowHighlight",
	Callback = function(Value)
		if Value then
			StartAutoRainbowHighlight()
		else
			DisableAutoRainbowHighlight()
		end
	end
}), "Adds a rainbow highlight")

attachPepsiTooltip(SpecialSections.Fun:AddDropdown({
	Name = "Preset",
	Flag = "flag_AutoRainbowHighlightPreset",
	List = AutoRainbowHighlightPresets,
	Value = "Slow Rainbow",
	Callback = function(Value)
		setAutoRainbowHighlightPreset(Value)
	end
}), "Choose the highlight style")

addPepsiSpacer(SpecialSections.Fun, 8, "flag_PepsiSpacer_Fun_HighlightToPreset")

attachPepsiTooltip(SpecialSections.Fun:AddToggle({
	Name = "Video",
	Flag = "flag_LeafThemeBackgroundVideo",
	UnloadValue = false,
	UnloadFunc = stopLeafThemeBackgroundVideo,
	Callback = function(Value)
		if Value then
			startLeafThemeBackgroundVideo()
		else
			stopLeafThemeBackgroundVideo()
		end
	end
}), "Cycles theme backgrounds")

attachPepsiTooltip(SpecialSections.Fun:AddToggle({
	Name = "Transparency",
	Flag = "flag_LeafThemeBackgroundTransparency",
	UnloadValue = false,
	UnloadFunc = stopLeafThemeBackgroundTransparency,
	Callback = function(Value)
		if Value then
			startLeafThemeBackgroundTransparency()
		else
			stopLeafThemeBackgroundTransparency()
		end
	end
}), "Randomly changes background fade")

SpecialSections.Fun:AddSlider({
	Name = "Theme Background Delay",
	Flag = "flag_LeafThemeBackgroundDelay",
	Value = LeafUiThemes.BackgroundAnimator.Delay,
	Min = 0.1,
	Max = 1,
	Decimals = 1,
	Format = "%ss",
	Callback = function(Value)
		LeafUiThemes.BackgroundAnimator.Delay = math.max(0.1, math.min(1, tonumber(Value) or 0.1))
	end
})

local function updateAutoKillNpcTypes(Value)
	local selectedTypes = {}

	for _, npcType in Value do
		if npcType == "All" then
			whoToKillTable = nil
			return
		end

		selectedTypes[npcType] = true
	end

	if next(selectedTypes) == nil then
		whoToKillTable = nil
	else
		whoToKillTable = selectedTypes
	end
end

VVAutoKillNpcToggle = SpecialSection:AddToggle({
	Name = "Auto Kill Npc",
	Flag = "flag_AutoFarmLevel",
	Callback = function(Value)
		if AutoConfigState.Loading then
			return
		end

		if Value then
			AutoKillNpc(whoToKillTable)
		else
			if FlyState.Tween then
				FlyState.Tween:Cancel()
				FlyState.Tween:Destroy()
				FlyState.Tween = nil
			end

			IsKilling = false
		end
	end
})
VVNpcTypesDropdown = SpecialSection:AddDropdown({
	Name = "NPC Types",
	Flag = "flag_AutoFarmNpcTypes",
	List = AutoFarmNpcTypes,
	MultiSelect = "Selected NPC Types",
	Callback = function(Value)
		updateAutoKillNpcTypes(Value)
	end
})
attachPepsiTooltip(
	VVNpcTypesDropdown,
	"Which NPC's would you like to farm?",
	VVNpcTypesDropdown.Instance.Parent.Parent
)

local AutoKillNpcDistanceXSlider
local AutoKillNpcDistanceYSlider
local AutoKillNpcDistanceZSlider

local function displayNpcOffsetProfile(npcType)
	local offset = NpcKillOffsets[npcType]
	if not offset then
		registerDiscoveredNpcType(npcType, true)
		offset = NpcKillOffsets[npcType]
		if not offset then
			return
		end
	end

	SelectedNpcOffsetType = npcType

	if not AutoKillNpcDistanceXSlider or not AutoKillNpcDistanceYSlider or not AutoKillNpcDistanceZSlider then
		return
	end

	IsLoadingNpcOffsetProfile = true
	AutoKillNpcDistanceXSlider:RawSet(offset.X)
	AutoKillNpcDistanceYSlider:RawSet(offset.Y)
	AutoKillNpcDistanceZSlider:RawSet(offset.Z)
	IsLoadingNpcOffsetProfile = false
end

VVNpcOffsetProfileDropdown = SpecialSection:AddDropdown({
	Name = "NPC Offset Profile",
	Flag = "flag_NpcOffsetProfile",
	List = NpcTypes,
	Value = SelectedNpcOffsetType,
	Callback = function(Value)
		displayNpcOffsetProfile(Value)
	end
})
attachPepsiTooltip(
	VVNpcOffsetProfileDropdown,
	"Pick NPC/boss you'd like to configure and setup custom XYZ coordinates for that specific NPC/boss You can have multiple custom NPC coordinates for each NPC accordingly, and it automatically saves to you config so you can share it with your friends ;)",
	VVNpcOffsetProfileDropdown.Instance.Parent.Parent
)

AutoKillNpcDistanceXSlider = SpecialSection:AddSlider({
	Name = "Kill Offset X",
	Flag = "flag_KillOffsetX",
	Value = NpcKillOffsets[SelectedNpcOffsetType].X,
	Min = -50,
	Max = 50,
	Decimals = 1,
	Format = "X: %s studs",
	Callback = function(Value)
		if IsLoadingNpcOffsetProfile or AutoConfigState.Loading then
			return
		end

		NpcKillOffsets[SelectedNpcOffsetType].X = sanitizeNpcOffsetCoordinate(Value, DefaultNpcKillOffset.X)
		scheduleNpcKillOffsetsSave()
	end
})
AutoKillNpcDistanceYSlider = SpecialSection:AddSlider({
	Name = "Kill Offset Y",
	Flag = "flag_KillOffsetY",
	Value = NpcKillOffsets[SelectedNpcOffsetType].Y,
	Min = -50,
	Max = 50,
	Decimals = 1,
	Format = "Y: %s studs",
	Callback = function(Value)
		if IsLoadingNpcOffsetProfile or AutoConfigState.Loading then
			return
		end

		NpcKillOffsets[SelectedNpcOffsetType].Y = sanitizeNpcOffsetCoordinate(Value, DefaultNpcKillOffset.Y)
		scheduleNpcKillOffsetsSave()
	end
})
AutoKillNpcDistanceZSlider = SpecialSection:AddSlider({
	Name = "Kill Offset Z",
	Flag = "flag_KillOffsetZ",
	Value = NpcKillOffsets[SelectedNpcOffsetType].Z,
	Min = -50,
	Max = 50,
	Decimals = 1,
	Format = "Z: %s studs",
	Callback = function(Value)
		if IsLoadingNpcOffsetProfile or AutoConfigState.Loading then
			return
		end

		NpcKillOffsets[SelectedNpcOffsetType].Z = sanitizeNpcOffsetCoordinate(Value, DefaultNpcKillOffset.Z)
		scheduleNpcKillOffsetsSave()
	end
})

displayNpcOffsetProfile(SelectedNpcOffsetType)

local function updateAutoKillBossTypes(Value)
	local selectedBosses = {}

	for _, bossName in Value do
		if bossName == "All" then
			whoToKillBossTable = nil
			return
		end

		selectedBosses[bossName] = true
	end

	if next(selectedBosses) == nil then
		whoToKillBossTable = nil
	else
		whoToKillBossTable = selectedBosses
	end
end

VVAutoKillBossToggle = SpecialSection:AddToggle({
	Name = "AutoKillBoss",
	Flag = "flag_AutoKillBoss",
	Callback = function(Value)
		if AutoConfigState.Loading then
			return
		end

		if Value then
			AutoKillBoss(whoToKillBossTable)
		else
			if FlyState.Tween then
				FlyState.Tween:Cancel()
				FlyState.Tween:Destroy()
				FlyState.Tween = nil
			end

			IsKilling = false
		end
	end
})

VVBossesDropdown = SpecialSection:AddDropdown({
	Name = "Bosses",
	Flag = "flag_AutoFarmBossTypes",
	List = AutoFarmBossNames,
	MultiSelect = "Selected Bosses",
	Callback = function(Value)
		updateAutoKillBossTypes(Value)
	end
})
attachPepsiTooltip(
	VVBossesDropdown,
	"Same as Auto Kill Npc, but for bosses",
	VVBossesDropdown.Instance.Parent.Parent
)

local AutoKillBossDistanceXSlider
local AutoKillBossDistanceYSlider
local AutoKillBossDistanceZSlider

local function displayBossOffsetProfile(bossName)
	local offset = BossKillOffsets[bossName]
	if not offset then
		registerDiscoveredBossName(bossName, true)
		offset = BossKillOffsets[bossName]
		if not offset then
			return
		end
	end

	SelectedBossOffsetName = bossName

	if not AutoKillBossDistanceXSlider or not AutoKillBossDistanceYSlider or not AutoKillBossDistanceZSlider then
		return
	end

	IsLoadingBossOffsetProfile = true
	AutoKillBossDistanceXSlider:RawSet(offset.X)
	AutoKillBossDistanceYSlider:RawSet(offset.Y)
	AutoKillBossDistanceZSlider:RawSet(offset.Z)
	IsLoadingBossOffsetProfile = false
end

VVBossOffsetProfileDropdown = SpecialSection:AddDropdown({
	Name = "Boss Offset Profile",
	Flag = "flag_BossOffsetProfile",
	List = BossNames,
	Value = SelectedBossOffsetName,
	Callback = function(Value)
		displayBossOffsetProfile(Value)
	end
})
attachPepsiTooltip(
	VVBossOffsetProfileDropdown,
	"Pick NPC/boss you'd like to configure and setup custom XYZ coordinates for that specific NPC/boss You can have multiple custom NPC coordinates for each NPC accordingly, and it automatically saves to you config so you can share it with your friends ;)",
	VVBossOffsetProfileDropdown.Instance.Parent.Parent
)

AutoKillBossDistanceXSlider = SpecialSection:AddSlider({
	Name = "Boss Offset X",
	Flag = "flag_BossKillOffsetX",
	Value = BossKillOffsets[SelectedBossOffsetName].X,
	Min = -50,
	Max = 50,
	Decimals = 1,
	Format = "X: %s studs",
	Callback = function(Value)
		if IsLoadingBossOffsetProfile or AutoConfigState.Loading then
			return
		end

		BossKillOffsets[SelectedBossOffsetName].X = sanitizeBossOffsetCoordinate(Value, DefaultBossKillOffset.X)
		scheduleBossKillOffsetsSave()
	end
})

AutoKillBossDistanceYSlider = SpecialSection:AddSlider({
	Name = "Boss Offset Y",
	Flag = "flag_BossKillOffsetY",
	Value = BossKillOffsets[SelectedBossOffsetName].Y,
	Min = -50,
	Max = 50,
	Decimals = 1,
	Format = "Y: %s studs",
	Callback = function(Value)
		if IsLoadingBossOffsetProfile or AutoConfigState.Loading then
			return
		end

		BossKillOffsets[SelectedBossOffsetName].Y = sanitizeBossOffsetCoordinate(Value, DefaultBossKillOffset.Y)
		scheduleBossKillOffsetsSave()
	end
})

AutoKillBossDistanceZSlider = SpecialSection:AddSlider({
	Name = "Boss Offset Z",
	Flag = "flag_BossKillOffsetZ",
	Value = BossKillOffsets[SelectedBossOffsetName].Z,
	Min = -50,
	Max = 50,
	Decimals = 1,
	Format = "Z: %s studs",
	Callback = function(Value)
		if IsLoadingBossOffsetProfile or AutoConfigState.Loading then
			return
		end

		BossKillOffsets[SelectedBossOffsetName].Z = sanitizeBossOffsetCoordinate(Value, DefaultBossKillOffset.Z)
		scheduleBossKillOffsetsSave()
	end
})

function connectAutoKillMenu(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(AutoKillDynamicState.Connections, connection)
	return connection
end

local AutoKillTheme = CustomMenuThemePresets[SelectedLeafThemeIndex]

function createAutoKillButton(parent, textValue)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.BackgroundColor3 = AutoKillTheme.Button
	button.BorderColor3 = AutoKillTheme.FieldBorder
	button.Font = Enum.Font.Code
	button.Text = textValue
	button.TextColor3 = AutoKillTheme.Text
	button.TextSize = 14
	button.Parent = parent
	connectAutoKillMenu(button.MouseEnter, function()
		button.BackgroundColor3 = button:GetAttribute("Selected") and AutoKillTheme.ButtonSelectedHover or AutoKillTheme.ButtonHover
	end)
	connectAutoKillMenu(button.MouseLeave, function()
		button.BackgroundColor3 = button:GetAttribute("Selected") and AutoKillTheme.ButtonSelected or AutoKillTheme.Button
	end)
	return button
end

function createAutoKillToggle(parent, labelText, initialValue, callback)
	local row = Instance.new("TextButton")
	row.AutoButtonColor = false
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, -8, 0, 30)
	row.Text = ""
	row.Parent = parent

	local box = Instance.new("Frame")
	box.Position = UDim2.fromOffset(2, 7)
	box.Size = UDim2.fromOffset(16, 16)
	box.BorderColor3 = AutoKillTheme.FieldBorder
	box.Parent = row

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(26, 0)
	label.Size = UDim2.new(1, -28, 1, 0)
	label.Font = Enum.Font.Code
	label.Text = labelText
	label.TextColor3 = AutoKillTheme.Text
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local control = {Value = initialValue == true, Instance = row}
	function control:Set(value, fireCallback)
		self.Value = value == true
		box.BackgroundColor3 = self.Value and AutoKillTheme.AccentBright or AutoKillTheme.Field
		if fireCallback and callback then callback(self.Value) end
	end
	function control:RawSet(value)
		return self:Set(value, false)
	end
	function control:Get()
		return self.Value
	end
	control:Set(control.Value, false)
	connectAutoKillMenu(row.MouseButton1Click, function()
		control:Set(not control.Value, true)
	end)
	return control
end

function createAutoKillSlider(parent, labelText, minimum, maximum, initialValue, decimals, formatValue, callback)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, -8, 0, 54)
	row.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0.58, 0, 0, 20)
	label.Font = Enum.Font.Code
	label.Text = labelText
	label.TextColor3 = AutoKillTheme.TextSoft
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local valueBox = Instance.new("TextBox")
	valueBox.AnchorPoint = Vector2.new(1, 0)
	valueBox.Position = UDim2.fromScale(1, 0)
	valueBox.Size = UDim2.new(0.4, 0, 0, 20)
	valueBox.BackgroundColor3 = AutoKillTheme.Field
	valueBox.BorderColor3 = AutoKillTheme.FieldBorder
	valueBox.ClearTextOnFocus = false
	valueBox.Font = Enum.Font.Code
	valueBox.TextColor3 = AutoKillTheme.Text
	valueBox.TextSize = 12
	valueBox.Parent = row

	local bar = Instance.new("TextButton")
	bar.Position = UDim2.fromOffset(0, 30)
	bar.Size = UDim2.new(1, 0, 0, 12)
	bar.BackgroundColor3 = AutoKillTheme.Track
	bar.BorderSizePixel = 0
	bar.Text = ""
	bar.Parent = row

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = AutoKillTheme.AccentBright
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(0, 1)
	fill.Parent = bar

	local control = {Value = initialValue, Dragging = false, Instance = row}
	local scale = 10 ^ (decimals or 0)
	function control:Set(value, fireCallback)
		value = math.clamp(tonumber(value) or minimum, minimum, maximum)
		value = math.floor(value * scale + 0.5) / scale
		self.Value = value
		fill.Size = UDim2.fromScale((value - minimum) / (maximum - minimum), 1)
		valueBox.Text = formatValue and formatValue(value) or tostring(value)
		if fireCallback and callback then callback(value) end
	end
	function control:RawSet(value)
		return self:Set(value, false)
	end
	function control:Get()
		return self.Value
	end

	local function setFromMouse()
		local alpha = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		control:Set(minimum + (maximum - minimum) * alpha, true)
	end

	connectAutoKillMenu(bar.MouseButton1Down, function()
		control.Dragging = true
		setFromMouse()
	end)
	connectAutoKillMenu(UserInputService.InputChanged, function(input)
		if control.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromMouse()
		end
	end)
	connectAutoKillMenu(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			control.Dragging = false
		end
	end)
	connectAutoKillMenu(valueBox.Focused, function()
		valueBox.Text = tostring(control.Value)
		valueBox.CursorPosition = #valueBox.Text + 1
	end)
	connectAutoKillMenu(valueBox.FocusLost, function()
		control:Set(tonumber(valueBox.Text) or control.Value, true)
	end)
	control:Set(initialValue, false)
	return control
end

function createAutoKillDropdown(parent, labelText, options, initialValue, callback)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.ClipsDescendants = false
	row.Size = UDim2.new(1, -8, 0, 48)
	row.ZIndex = 40
	row.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 19)
	label.Font = Enum.Font.Code
	label.Text = labelText
	label.TextColor3 = AutoKillTheme.TextSoft
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 41
	label.Parent = row

	local button = createAutoKillButton(row, tostring(initialValue or ""))
	button.Position = UDim2.fromOffset(0, 21)
	button.Size = UDim2.new(1, 0, 0, 25)
	button.ZIndex = 41

	local holder = Instance.new("Frame")
	holder.BackgroundColor3 = AutoKillTheme.PanelAlt
	holder.BorderColor3 = AutoKillTheme.FieldBorder
	holder.Position = UDim2.fromOffset(0, 48)
	holder.Visible = false
	holder.ClipsDescendants = true
	holder.ZIndex = 80
	holder.Parent = row

	local scroller = Instance.new("ScrollingFrame")
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.Size = UDim2.fromScale(1, 1)
	scroller.CanvasSize = UDim2.new()
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller.ScrollBarThickness = 5
	scroller.ScrollBarImageColor3 = AutoKillTheme.AccentBright
	scroller.ZIndex = 81
	scroller.Parent = holder

	local list = Instance.new("UIListLayout")
	list.Parent = scroller

	local control = {
		Value = initialValue,
		Options = table.clone(options or {}),
		Open = false,
		Instance = row,
		Holder = holder,
		Scroller = scroller,
	}

	function control:RebuildOptions()
		for _, child in scroller:GetChildren() do
			if not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end

		holder.Size = UDim2.new(1, 0, 0, math.min(#self.Options * 25, self.MaxListHeight or 150))
		for _, option in ipairs(self.Options) do
			local optionButton = createAutoKillButton(scroller, tostring(option))
			optionButton.Size = UDim2.new(1, 0, 0, 25)
			optionButton.ZIndex = 82
			connectAutoKillMenu(optionButton.MouseButton1Click, function()
				control:Set(option, true)
				control:SetOpen(false)
			end)
		end
	end

	function control:SetOpen(open)
		self.Open = open == true
		holder.Visible = self.Open
		row.Size = UDim2.new(1, -8, 0, 48)
		if AutoKillDynamicState.Layout then
			AutoKillDynamicState.Layout()
		end
	end

	function control:SetOptions(newOptions)
		self.Options = table.clone(newOptions or {})
		if #self.Options > 0 and not table.find(self.Options, self.Value) then
			self.Value = self.Options[1]
			button.Text = tostring(self.Value)
		end
		self:RebuildOptions()
		self:SetOpen(false)
	end

	function control:Set(value, fireCallback)
		if #self.Options > 0 and not table.find(self.Options, value) then
			value = self.Options[1]
		end
		self.Value = value
		button.Text = tostring(value or "")
		if fireCallback and callback then callback(value) end
	end
	function control:RawSet(value)
		return self:Set(value, false)
	end
	function control:Get()
		return self.Value
	end

	connectAutoKillMenu(button.MouseButton1Click, function()
		control:SetOpen(not control.Open)
	end)
	control:RebuildOptions()
	control:Set(initialValue or options[1], false)
	return control
end

function getAutoKillSelectedList(flagName)
	local current = library.Flags[flagName]
	if type(current) == "table" and #current > 0 then
		return table.clone(current)
	end
	return {"All"}
end

function getAutoKillSelectionText(flagName)
	local selected = getAutoKillSelectedList(flagName)
	if table.find(selected, "All") then
		return "All"
	end

	if #selected == 0 then
		return "All"
	end

	if #selected == 1 then
		return tostring(selected[1])
	end

	return tostring(#selected) .. " selected"
end

function setAutoKillNpcEnabled(value)
	if VVAutoKillNpcToggle then
		VVAutoKillNpcToggle:Set(value == true)
	else
		library.Flags["flag_AutoFarmLevel"] = value == true
		if value then
			task.spawn(AutoKillNpc, whoToKillTable)
		else
			if FlyState.Tween then
				FlyState.Tween:Cancel()
				FlyState.Tween:Destroy()
				FlyState.Tween = nil
			end
			IsKilling = false
		end
	end
	syncAutoKillMenuControls()
end

function setAutoKillBossEnabled(value)
	if VVAutoKillBossToggle then
		VVAutoKillBossToggle:Set(value == true)
	else
		library.Flags["flag_AutoKillBoss"] = value == true
		if value then
			task.spawn(AutoKillBoss, whoToKillBossTable)
		else
			if FlyState.Tween then
				FlyState.Tween:Cancel()
				FlyState.Tween:Destroy()
				FlyState.Tween = nil
			end
			IsKilling = false
		end
	end
	syncAutoKillMenuControls()
end

function setAutoKillNpcSelection(selected)
	if VVNpcTypesDropdown then
		VVNpcTypesDropdown:Set(selected)
	else
		library.Flags["flag_AutoFarmNpcTypes"] = selected
	end
	updateAutoKillNpcTypes(selected)
	refreshAutoKillMenuLists()
end

function setAutoKillBossSelection(selected)
	if VVBossesDropdown then
		VVBossesDropdown:Set(selected)
	else
		library.Flags["flag_AutoFarmBossTypes"] = selected
	end
	updateAutoKillBossTypes(selected)
	refreshAutoKillMenuLists()
end

function setAutoKillNpcProfile(npcType)
	if VVNpcOffsetProfileDropdown then
		VVNpcOffsetProfileDropdown:Set(npcType)
	else
		library.Flags["flag_NpcOffsetProfile"] = npcType
	end
	displayNpcOffsetProfile(npcType)
	syncAutoKillMenuControls()
end

function setAutoKillBossProfile(bossName)
	if VVBossOffsetProfileDropdown then
		VVBossOffsetProfileDropdown:Set(bossName)
	else
		library.Flags["flag_BossOffsetProfile"] = bossName
	end
	displayBossOffsetProfile(bossName)
	syncAutoKillMenuControls()
end

function setAutoKillNpcOffset(axis, value)
	if AutoKillDynamicState.LoadingControls then return end
	if axis == "X" and AutoKillNpcDistanceXSlider then
		AutoKillNpcDistanceXSlider:Set(value)
	elseif axis == "Y" and AutoKillNpcDistanceYSlider then
		AutoKillNpcDistanceYSlider:Set(value)
	elseif axis == "Z" and AutoKillNpcDistanceZSlider then
		AutoKillNpcDistanceZSlider:Set(value)
	else
		NpcKillOffsets[SelectedNpcOffsetType][axis] = sanitizeNpcOffsetCoordinate(value, DefaultNpcKillOffset[axis])
		scheduleNpcKillOffsetsSave()
	end
end

function setAutoKillBossOffset(axis, value)
	if AutoKillDynamicState.LoadingControls then return end
	if axis == "X" and AutoKillBossDistanceXSlider then
		AutoKillBossDistanceXSlider:Set(value)
	elseif axis == "Y" and AutoKillBossDistanceYSlider then
		AutoKillBossDistanceYSlider:Set(value)
	elseif axis == "Z" and AutoKillBossDistanceZSlider then
		AutoKillBossDistanceZSlider:Set(value)
	else
		BossKillOffsets[SelectedBossOffsetName][axis] = sanitizeBossOffsetCoordinate(value, DefaultBossKillOffset[axis])
		scheduleBossKillOffsetsSave()
	end
end

function clearAutoKillRows(rows)
	for _, row in rows do
		row:Destroy()
	end
	table.clear(rows)
end

function renderAutoKillTargetList(holder, rows, options, flagName, setSelectionCallback)
	if not holder then return end
	clearAutoKillRows(rows)

	local selected = getAutoKillSelectedList(flagName)
	local selectedSet = {}
	for _, value in ipairs(selected) do
		selectedSet[value] = true
	end

	for _, option in ipairs(options) do
		local row = Instance.new("TextButton")
		row.AutoButtonColor = false
		row.BackgroundColor3 = selectedSet[option] and AutoKillTheme.GoodRowSelected or AutoKillTheme.Field
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, -4, 0, 25)
		row.Font = Enum.Font.Code
		row.Text = (selectedSet[option] and "[x] " or "[ ] ") .. tostring(option)
		row.TextColor3 = AutoKillTheme.TextSoft
		row.TextSize = 12
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.TextTruncate = Enum.TextTruncate.AtEnd
		row.ZIndex = holder.ZIndex + 1
		row.Parent = holder
		table.insert(rows, row)

		connectAutoKillMenu(row.MouseButton1Click, function()
			local newSelection = {}

			if option == "All" then
				newSelection = {"All"}
			else
				for _, selectedValue in ipairs(getAutoKillSelectedList(flagName)) do
					if selectedValue ~= "All" and selectedValue ~= option then
						table.insert(newSelection, selectedValue)
					end
				end

				if not selectedSet[option] then
					table.insert(newSelection, option)
				end

				if #newSelection == 0 then
					newSelection = {"All"}
				end
			end

			setSelectionCallback(newSelection)
		end)
	end
end

function createAutoKillTargetDropdown(parent, labelText, options, flagName, setSelectionCallback, rows)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.ClipsDescendants = false
	row.Size = UDim2.new(1, -8, 0, 32)
	row.ZIndex = 55
	row.Parent = parent

	local button = createAutoKillButton(row, labelText .. ": " .. getAutoKillSelectionText(flagName))
	button.Size = UDim2.new(1, 0, 0, 30)
	button.ZIndex = 56

	local holder = Instance.new("Frame")
	holder.BackgroundColor3 = AutoKillTheme.PanelAlt
	holder.BorderColor3 = AutoKillTheme.FieldBorder
	holder.Position = UDim2.fromOffset(0, 34)
	holder.Visible = false
	holder.ClipsDescendants = true
	holder.ZIndex = 90
	holder.Parent = row

	local scroller = Instance.new("ScrollingFrame")
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.Size = UDim2.fromScale(1, 1)
	scroller.CanvasSize = UDim2.new()
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller.ScrollBarThickness = 5
	scroller.ScrollBarImageColor3 = AutoKillTheme.AccentBright
	scroller.ZIndex = 91
	scroller.Parent = holder

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 2)
	layout.Parent = scroller

	local control = {
		Options = table.clone(options or {}),
		Open = false,
		Instance = row,
		Holder = holder,
		Scroller = scroller,
		Button = button,
		Rows = rows,
		FlagName = flagName,
		SetSelectionCallback = setSelectionCallback,
	}

	function control:SetOpen(open)
		self.Open = open == true
		holder.Visible = self.Open
		if AutoKillDynamicState.Layout then
			AutoKillDynamicState.Layout()
		end
	end

	function control:SetOptions(newOptions)
		self.Options = table.clone(newOptions or {})
		self:Refresh()
	end

	function control:Refresh()
		button.Text = labelText .. ": " .. getAutoKillSelectionText(flagName)
		renderAutoKillTargetList(scroller, rows, self.Options, flagName, function(selected)
			setSelectionCallback(selected)
			button.Text = labelText .. ": " .. getAutoKillSelectionText(flagName)
		end)
	end

	connectAutoKillMenu(button.MouseButton1Click, function()
		control:SetOpen(not control.Open)
	end)

	control:Refresh()
	return control
end

function connectAutoQuestMenu(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(AutoQuestState.Connections, connection)
	return connection
end

function trySetGuiProperty(instance, propertyName, value, warningContext)
	local success, err = pcall(function()
		instance[propertyName] = value
	end)

	if not success then
		warn(tostring(warningContext or "GUI") .. ": failed to set " .. tostring(propertyName) .. ": " .. tostring(err))
	end

	return success
end

function createAutoQuestButton(parent, textValue)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.BackgroundColor3 = AutoKillTheme.Button
	button.BorderColor3 = AutoKillTheme.FieldBorder
	button.Font = Enum.Font.Code
	button.Text = textValue
	button.TextColor3 = AutoKillTheme.Text
	button.TextSize = 13
	button.TextTruncate = Enum.TextTruncate.AtEnd
	button.Parent = parent
	connectAutoQuestMenu(button.MouseEnter, function()
		local selected = false
		pcall(function()
			selected = button:GetAttribute("Selected") == true
		end)
		trySetGuiProperty(button, "BackgroundColor3", selected and AutoKillTheme.ButtonSelectedHover or AutoKillTheme.ButtonHover, "AutoQuest button hover")
	end)
	connectAutoQuestMenu(button.MouseLeave, function()
		local selected = false
		pcall(function()
			selected = button:GetAttribute("Selected") == true
		end)
		trySetGuiProperty(button, "BackgroundColor3", selected and AutoKillTheme.ButtonSelected or AutoKillTheme.Button, "AutoQuest button hover")
	end)
	return button
end

function createAutoQuestToggle(parent, labelText, initialValue, callback)
	local row = Instance.new("TextButton")
	row.AutoButtonColor = false
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, -8, 0, 28)
	row.Text = ""
	row.Parent = parent

	local box = Instance.new("Frame")
	box.Position = UDim2.fromOffset(2, 6)
	box.Size = UDim2.fromOffset(16, 16)
	box.BorderColor3 = AutoKillTheme.FieldBorder
	box.Parent = row

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(26, 0)
	label.Size = UDim2.new(1, -28, 1, 0)
	label.Font = Enum.Font.Code
	label.Text = labelText
	label.TextColor3 = AutoKillTheme.Text
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local control = {Value = initialValue == true, Instance = row}
	function control:Set(value, fireCallback)
		self.Value = value == true
		box.BackgroundColor3 = self.Value and AutoKillTheme.AccentBright or AutoKillTheme.Field
		if fireCallback and callback then callback(self.Value) end
	end
	function control:RawSet(value)
		return self:Set(value, false)
	end
	control:Set(control.Value, false)
	connectAutoQuestMenu(row.MouseButton1Click, function()
		control:Set(not control.Value, true)
	end)
	return control
end

function createAutoQuestSlider(parent, labelText, minimum, maximum, initialValue, decimals, callback)
	local previousConnectionCount = #AutoKillDynamicState.Connections
	local control = createAutoKillSlider(parent, labelText, minimum, maximum, initialValue, decimals, function(value)
		return tostring(value)
	end, callback)

	for index = #AutoKillDynamicState.Connections, previousConnectionCount + 1, -1 do
		local connection = AutoKillDynamicState.Connections[index]
		if connection then
			table.remove(AutoKillDynamicState.Connections, index)
			table.insert(AutoQuestState.Connections, connection)
		end
	end

	return control
end

function getQuestProfileDisplayText(profile, key)
	if not profile then
		return tostring(key or "Unknown")
	end

	local title = profile.SpeakerName or profile.QuestTitle or profile.LastQuestName or profile.DisplayName or profile.ModelName or profile.DialogueTag or key
	local suffix = profile.DialogueTag or profile.QuestId or profile.ModelName or key
	local state = profile.QuestAvailable and "available" or "seen"
	local levelText = profile.LevelRequirement and ("LVL " .. tostring(profile.LevelRequirement)) or "LVL ?"
	local distanceText = profile.NearestMarkerDistanceStuds and (tostring(profile.NearestMarkerDistanceStuds) .. " studs") or "? studs"
	return tostring(title) .. " | " .. tostring(suffix) .. " | " .. levelText .. " | " .. distanceText .. " | " .. state
end

function questProfileMatchesFilters(profile, key)
	if not profile then
		return false
	end

	if AutoQuestState.Settings.AvailableOnly and profile.QuestAvailable ~= true then
		return false
	end

	local search = string.lower(AutoQuestState.SearchText or "")
	if search ~= "" then
		local haystack = string.lower(table.concat({
			tostring(key or ""),
			tostring(profile.DisplayName or ""),
			tostring(profile.ModelName or ""),
			tostring(profile.DialogueTag or ""),
			tostring(profile.QuestId or ""),
			tostring(profile.SpeakerName or ""),
			tostring(profile.QuestTitle or ""),
			tostring(profile.QuestDescription or ""),
			tostring(profile.QuestStartArea or ""),
			tostring(profile.LevelRequirement or ""),
			tostring(profile.NearestMarkerDistanceStuds or ""),
			tostring(profile.LastQuestName or ""),
			tostring(profile.LastObjective or ""),
			tostring(profile.TargetType or ""),
			tostring(profile.ResolvedRule or ""),
			tostring(profile.ResolvedRuleSource or ""),
		}, " "))
		if not haystack:find(search, 1, true) then
			return false
		end
	end

	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local position = questTableToVector3(profile.LastPosition)
	if root and position and (root.Position - position).Magnitude > AutoQuestState.Settings.AcceptRadius then
		return false
	end

	return true
end

function clearAutoQuestRows()
	for _, row in AutoQuestState.Rows do
		pcall(function()
			row:Destroy()
		end)
	end
	table.clear(AutoQuestState.Rows)
end

function refreshAutoQuestTrackerLabels()
	if not AutoQuestState.UI or not AutoQuestState.UI.QuestName then
		return
	end

	local tracker = readQuestTracker()
	if tracker then
		AutoQuestState.UI.QuestName.Text = "Quest: " .. tostring(tracker.Name or "Unknown")
		AutoQuestState.UI.Objective.Text = "Objective: " .. tostring(tracker.Objective or "Unknown")
	else
		AutoQuestState.UI.QuestName.Text = "Quest: none"
		AutoQuestState.UI.Objective.Text = "Objective: none"
	end

	if AutoQuestState.UI.Status then
		AutoQuestState.UI.Status.Text = "Status: " .. tostring(AutoQuestState.Status)
	end
end

function refreshAutoQuestMenuLists()
	if not AutoQuestState.UI or not AutoQuestState.UI.List then
		return
	end

	clearAutoQuestRows()
	refreshAutoQuestTrackerLabels()

	for _, key in ipairs(AutoQuestState.ProfileOrder) do
		local profile = AutoQuestState.Profiles[key]
		if questProfileMatchesFilters(profile, key) then
			local row = Instance.new("TextLabel")
			row.BackgroundColor3 = profile.QuestAvailable and AutoKillTheme.GoodRowSelected or AutoKillTheme.Field
			row.BorderColor3 = AutoKillTheme.FieldBorder
			row.Font = Enum.Font.Code
			row.Text = getQuestProfileDisplayText(profile, key)
			row.TextColor3 = AutoKillTheme.Text
			row.TextSize = 12
			row.TextTruncate = Enum.TextTruncate.AtEnd
			row.Size = UDim2.new(1, -4, 0, 28)
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.Parent = AutoQuestState.UI.List
			table.insert(AutoQuestState.Rows, row)
			attachPepsiTooltip(row, "Read-only quest giver info The scanner updates this list automatically every 5 seconds")
		end
	end
end

function syncAutoQuestControls()
	if not AutoQuestState.UI then
		return
	end

	if AutoQuestState.UI.AutoAccept then AutoQuestState.UI.AutoAccept:RawSet(AutoQuestState.Settings.AutoAccept) end
	if AutoQuestState.UI.AutoComplete then AutoQuestState.UI.AutoComplete:RawSet(AutoQuestState.Settings.AutoComplete) end
	if AutoQuestState.UI.AvailableOnly then AutoQuestState.UI.AvailableOnly:RawSet(AutoQuestState.Settings.AvailableOnly) end
	refreshAutoQuestMenuLists()
end

function closeAutoQuestMenu()
	for _, connection in AutoQuestState.Connections do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(AutoQuestState.Connections)
	clearAutoQuestRows()
	if AutoQuestState.Gui then
		pcall(function()
			AutoQuestState.Gui:Destroy()
		end)
		AutoQuestState.Gui = nil
	end
	table.clear(AutoQuestState.UI)
end

function openAutoQuestMenu()
	if AutoQuestState.Gui then
		scanDialogueInteractablesForQuests(true)
		refreshAutoQuestMenuLists()
		return true
	end

	scanDialogueInteractablesForQuests(true)

	local gui = Instance.new("ScreenGui")
	gui.Name = "VVAutoQuestMenu"
	gui.DisplayOrder = 9000
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	AutoQuestState.Gui = gui

	local viewportSize = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local width = math.min(470, viewportSize.X - 24)
	local height = math.min(520, viewportSize.Y - 24)

	local panel = Instance.new("Frame")
	panel.Active = true
	panel.Position = UDim2.fromOffset(math.max(8, (viewportSize.X - width) / 2 + 40), math.max(8, (viewportSize.Y - height) / 2 + 30))
	panel.Size = UDim2.fromOffset(width, height)
	panel.BackgroundColor3 = AutoKillTheme.Window
	panel.BorderSizePixel = 0
	panel.Parent = gui
	AutoQuestState.UI.Panel = panel

	local titleBar = Instance.new("Frame")
	titleBar.Active = true
	titleBar.Size = UDim2.new(1, 0, 0, 34)
	titleBar.BackgroundColor3 = AutoKillTheme.Title
	titleBar.BorderSizePixel = 0
	titleBar.Parent = panel

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(10, 0)
	title.Size = UDim2.new(1, -52, 1, 0)
	title.Font = Enum.Font.Code
	title.Text = "Auto Quests"
	title.TextColor3 = AutoKillTheme.Text
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar

	local closeButton = createAutoQuestButton(titleBar, "X")
	closeButton.Position = UDim2.new(1, -36, 0, 4)
	closeButton.Size = UDim2.fromOffset(30, 26)
	attachPepsiTooltip(closeButton, "Close this menu Enabled Auto Quest toggles keep running in the background")
	connectAutoQuestMenu(closeButton.MouseButton1Click, function()
		task.defer(closeAutoQuestMenu)
	end)
	connectAutoQuestMenu(closeButton.Activated, function()
		task.defer(closeAutoQuestMenu)
	end)

	local dragging, dragStart, startPosition
	connectAutoQuestMenu(titleBar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPosition = panel.Position
		end
	end)
	connectAutoQuestMenu(UserInputService.InputChanged, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		if not dragging or not dragStart or not startPosition then
			return
		end

		local delta = input.Position - dragStart
		local nextPosition = UDim2.fromOffset(startPosition.X.Offset + delta.X, startPosition.Y.Offset + delta.Y)
		if not trySetGuiProperty(panel, "Position", nextPosition, "AutoQuestMenu drag") then
			dragging = false
		end
	end)
	connectAutoQuestMenu(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	local body = Instance.new("Frame")
	body.BackgroundColor3 = AutoKillTheme.Panel
	body.BorderColor3 = AutoKillTheme.FieldBorder
	body.Position = UDim2.fromOffset(8, 42)
	body.Size = UDim2.new(1, -16, 1, -50)
	body.Parent = panel

	local y = 8
	AutoQuestState.UI.AutoAccept = createAutoQuestToggle(body, "Auto Accept Available Quests", AutoQuestState.Settings.AutoAccept, function(value)
		AutoQuestState.Settings.AutoAccept = value
		scheduleQuestProfilesSave()
		if value then runAutoQuestExecutor() end
	end)
	AutoQuestState.UI.AutoAccept.Instance.Position = UDim2.fromOffset(8, y)
	attachPepsiTooltip(AutoQuestState.UI.AutoAccept, "Automatically flies to an available quest giver and tries to accept a quest through normal dialogue")
	y += 30

	AutoQuestState.UI.AutoComplete = createAutoQuestToggle(body, "Auto Complete Current Quest", AutoQuestState.Settings.AutoComplete, function(value)
		AutoQuestState.Settings.AutoComplete = value
		scheduleQuestProfilesSave()
		if value then runAutoQuestExecutor() end
	end)
	AutoQuestState.UI.AutoComplete.Instance.Position = UDim2.fromOffset(8, y)
	attachPepsiTooltip(AutoQuestState.UI.AutoComplete, "Reads QuestTracker, resolves the objective, farms the target, and returns to the quest giver when needed")
	y += 34

	local questName = Instance.new("TextLabel")
	questName.BackgroundColor3 = AutoKillTheme.Profile
	questName.BorderColor3 = AutoKillTheme.FieldBorder
	questName.Position = UDim2.fromOffset(8, y)
	questName.Size = UDim2.new(1, -16, 0, 28)
	questName.Font = Enum.Font.Code
	questName.TextColor3 = AutoKillTheme.Text
	questName.TextSize = 12
	questName.TextXAlignment = Enum.TextXAlignment.Left
	questName.TextTruncate = Enum.TextTruncate.AtEnd
	questName.Parent = body
	AutoQuestState.UI.QuestName = questName
	y += 30

	local objective = questName:Clone()
	objective.Position = UDim2.fromOffset(8, y)
	objective.Parent = body
	AutoQuestState.UI.Objective = objective
	y += 30

	local status = questName:Clone()
	status.Position = UDim2.fromOffset(8, y)
	status.Parent = body
	AutoQuestState.UI.Status = status
	y += 34

	local searchBox = Instance.new("TextBox")
	searchBox.BackgroundColor3 = AutoKillTheme.Field
	searchBox.BorderColor3 = AutoKillTheme.FieldBorder
	searchBox.Position = UDim2.fromOffset(8, y)
	searchBox.Size = UDim2.new(1, -16, 0, 28)
	searchBox.ClearTextOnFocus = false
	searchBox.Font = Enum.Font.Code
	searchBox.PlaceholderText = "Search name / DialogueTag / QuestId"
	searchBox.Text = AutoQuestState.SearchText
	searchBox.TextColor3 = AutoKillTheme.Text
	searchBox.TextSize = 12
	searchBox.Parent = body
	AutoQuestState.UI.Search = searchBox
	attachPepsiTooltip(searchBox, "Filter saved quest givers by name, speaker, model, QuestId, objective, or resolved rule")
	connectAutoQuestMenu(searchBox:GetPropertyChangedSignal("Text"), function()
		AutoQuestState.SearchText = searchBox.Text
		refreshAutoQuestMenuLists()
	end)
	y += 34

	AutoQuestState.UI.AvailableOnly = createAutoQuestToggle(body, "Show QuestAvailable only", AutoQuestState.Settings.AvailableOnly, function(value)
		AutoQuestState.Settings.AvailableOnly = value
		scheduleQuestProfilesSave()
		refreshAutoQuestMenuLists()
	end)
	AutoQuestState.UI.AvailableOnly.Instance.Position = UDim2.fromOffset(8, y)
	attachPepsiTooltip(AutoQuestState.UI.AvailableOnly, "Only show quest givers marked QuestAvailable by the game Nice when the list gets huge")
	y += 32

	local giverHeader = Instance.new("TextLabel")
	giverHeader.BackgroundTransparency = 1
	giverHeader.Position = UDim2.fromOffset(8, y)
	giverHeader.Size = UDim2.new(1, -16, 0, 20)
	giverHeader.Font = Enum.Font.Code
	giverHeader.Text = "Quest Givers"
	giverHeader.TextColor3 = AutoKillTheme.TextSoft
	giverHeader.TextSize = 12
	giverHeader.TextXAlignment = Enum.TextXAlignment.Left
	giverHeader.Parent = body
	y += 22

	local list = Instance.new("ScrollingFrame")
	list.BackgroundColor3 = AutoKillTheme.PanelDeep
	list.BorderColor3 = AutoKillTheme.FieldBorder
	list.Position = UDim2.fromOffset(8, y)
	list.Size = UDim2.new(1, -16, 1, -(y + 8))
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.ScrollBarThickness = 5
	list.ScrollBarImageColor3 = AutoKillTheme.AccentBright
	list.Parent = body
	AutoQuestState.UI.List = list

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = list

	task.spawn(function()
		while AutoQuestState.Gui == gui do
			refreshAutoQuestTrackerLabels()
			task.wait(0.5)
		end
	end)

	syncAutoQuestControls()
	return true
end

function refreshAutoKillMenuLists()
	if not AutoKillDynamicState.UI or not AutoKillDynamicState.UI.Panel then
		return
	end

	if AutoKillDynamicState.UI.NpcProfileDropdown then
		AutoKillDynamicState.UI.NpcProfileDropdown:SetOptions(NpcTypes)
	end
	if AutoKillDynamicState.UI.BossProfileDropdown then
		AutoKillDynamicState.UI.BossProfileDropdown:SetOptions(BossNames)
	end

	if AutoKillDynamicState.UI.NpcTargetsDropdown then
		AutoKillDynamicState.UI.NpcTargetsDropdown:SetOptions(AutoFarmNpcTypes)
	end
	if AutoKillDynamicState.UI.BossTargetsDropdown then
		AutoKillDynamicState.UI.BossTargetsDropdown:SetOptions(AutoFarmBossNames)
	end

	syncAutoKillMenuControls()
end

function syncAutoKillMenuControls()
	local ui = AutoKillDynamicState.UI
	if not ui or not ui.Panel then
		return
	end

	AutoKillDynamicState.LoadingControls = true
	if ui.NpcToggle then ui.NpcToggle:RawSet(library.Flags["flag_AutoFarmLevel"] == true) end
	if ui.BossToggle then ui.BossToggle:RawSet(library.Flags["flag_AutoKillBoss"] == true) end

	local npcOffset = NpcKillOffsets[SelectedNpcOffsetType] or DefaultNpcKillOffset
	if ui.NpcProfileDropdown then ui.NpcProfileDropdown:RawSet(SelectedNpcOffsetType) end
	if ui.NpcX then ui.NpcX:RawSet(npcOffset.X) end
	if ui.NpcY then ui.NpcY:RawSet(npcOffset.Y) end
	if ui.NpcZ then ui.NpcZ:RawSet(npcOffset.Z) end

	local bossOffset = BossKillOffsets[SelectedBossOffsetName] or DefaultBossKillOffset
	if ui.BossProfileDropdown then ui.BossProfileDropdown:RawSet(SelectedBossOffsetName) end
	if ui.BossX then ui.BossX:RawSet(bossOffset.X) end
	if ui.BossY then ui.BossY:RawSet(bossOffset.Y) end
	if ui.BossZ then ui.BossZ:RawSet(bossOffset.Z) end

	AutoKillDynamicState.LoadingControls = false
end

function setAutoKillMenuMode(mode)
	if mode ~= "NPC" and mode ~= "Bosses" then
		return
	end

	AutoKillDynamicState.Mode = mode
	local ui = AutoKillDynamicState.UI
	if not ui or not ui.Panel then
		return
	end

	if ui.NpcPanel then ui.NpcPanel.Visible = mode == "NPC" end
	if ui.BossPanel then ui.BossPanel.Visible = mode == "Bosses" end
	if ui.NpcModeButton then
		ui.NpcModeButton:SetAttribute("Selected", mode == "NPC")
		ui.NpcModeButton.BackgroundColor3 = mode == "NPC" and AutoKillTheme.ButtonSelected or AutoKillTheme.Button
	end
	if ui.BossModeButton then
		ui.BossModeButton:SetAttribute("Selected", mode == "Bosses")
		ui.BossModeButton.BackgroundColor3 = mode == "Bosses" and AutoKillTheme.ButtonSelected or AutoKillTheme.Button
	end
	if AutoKillDynamicState.Layout then
		AutoKillDynamicState.Layout()
	end
end

function closeAutoKillMenu()
	if VVPepsiTooltipFrame then VVPepsiTooltipFrame.Visible = false end
	VVPepsiTooltipTarget = nil
	for _, connection in AutoKillDynamicState.Connections do
		connection:Disconnect()
	end
	table.clear(AutoKillDynamicState.Connections)
	clearAutoKillRows(AutoKillDynamicState.NpcRows)
	clearAutoKillRows(AutoKillDynamicState.BossRows)
	if AutoKillDynamicState.Gui then
		AutoKillDynamicState.Gui:Destroy()
		AutoKillDynamicState.Gui = nil
	end
	table.clear(AutoKillDynamicState.UI)
end

function createAutoKillPanel(parent, titleText)
	local panel = Instance.new("Frame")
	panel.BackgroundColor3 = AutoKillTheme.Panel
	panel.BorderSizePixel = 0
	panel.Parent = parent

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(10, 8)
	title.Size = UDim2.new(1, -20, 0, 26)
	title.Font = Enum.Font.Code
	title.Text = titleText
	title.TextColor3 = AutoKillTheme.AccentBright
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel
	AutoKillDynamicState.UI[titleText == "NPC" and "NpcTitle" or "BossTitle"] = title

	return panel
end

function openAutoKillMenu()
	if AutoKillDynamicState.Gui then
		scanLivingForAutoKillTargets()
		refreshAutoKillMenuLists()
		return true
	end

	scanLivingForAutoKillTargets()

	local gui = Instance.new("ScreenGui")
	gui.Name = "VVAutoKillMenu"
	gui.DisplayOrder = 31
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = library.gui_parent or LocalPlayer:WaitForChild("PlayerGui")
	AutoKillDynamicState.Gui = gui

	local viewportSize = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local width = math.min(392, viewportSize.X - 24)
	local height = math.min(450, viewportSize.Y - 24)
	width = math.max(math.min(322, viewportSize.X - 8), width)
	height = math.max(math.min(450, viewportSize.Y - 8), height)

	local panel = Instance.new("Frame")
	panel.Active = true
	panel.Position = UDim2.fromOffset(math.max(8, (viewportSize.X - width) / 2), math.max(8, (viewportSize.Y - height) / 2))
	panel.Size = UDim2.fromOffset(width, height)
	panel.BackgroundColor3 = AutoKillTheme.Window
	panel.BorderSizePixel = 0
	panel.Parent = gui
	AutoKillDynamicState.UI.Panel = panel

	local titleBar = Instance.new("Frame")
	titleBar.Active = true
	titleBar.Size = UDim2.new(1, 0, 0, 34)
	titleBar.BackgroundColor3 = AutoKillTheme.Title
	titleBar.BorderSizePixel = 0
	titleBar.Parent = panel

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(10, 0)
	title.Size = UDim2.new(1, -52, 1, 0)
	title.Font = Enum.Font.Code
	title.Text = "Auto Kill NPC / Bosses"
	title.TextColor3 = AutoKillTheme.Text
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar

	local closeButton = createAutoKillButton(titleBar, "X")
	closeButton.Position = UDim2.new(1, -36, 0, 4)
	closeButton.Size = UDim2.fromOffset(30, 26)
	connectAutoKillMenu(closeButton.MouseButton1Click, closeAutoKillMenu)

	local npcModeButton = createAutoKillButton(panel, "NPC")
	npcModeButton.Position = UDim2.fromOffset(8, 42)
	npcModeButton.Size = UDim2.fromOffset(110, 28)
	AutoKillDynamicState.UI.NpcModeButton = npcModeButton
	connectAutoKillMenu(npcModeButton.MouseButton1Click, function()
		setAutoKillMenuMode("NPC")
	end)

	local bossModeButton = createAutoKillButton(panel, "Bosses")
	bossModeButton.Position = UDim2.fromOffset(124, 42)
	bossModeButton.Size = UDim2.fromOffset(110, 28)
	AutoKillDynamicState.UI.BossModeButton = bossModeButton
	connectAutoKillMenu(bossModeButton.MouseButton1Click, function()
		setAutoKillMenuMode("Bosses")
	end)

	local npcPanel = createAutoKillPanel(panel, "NPC")
	local bossPanel = createAutoKillPanel(panel, "Bosses")
	AutoKillDynamicState.UI.NpcPanel = npcPanel
	AutoKillDynamicState.UI.BossPanel = bossPanel

	AutoKillDynamicState.UI.NpcToggle = createAutoKillToggle(npcPanel, "Auto Kill NPC", library.Flags["flag_AutoFarmLevel"] == true, setAutoKillNpcEnabled)
	AutoKillDynamicState.UI.NpcTargetsDropdown = createAutoKillTargetDropdown(
		npcPanel,
		"Who to kill",
		AutoFarmNpcTypes,
		"flag_AutoFarmNpcTypes",
		setAutoKillNpcSelection,
		AutoKillDynamicState.NpcRows
	)

	AutoKillDynamicState.UI.NpcProfileDropdown = createAutoKillDropdown(npcPanel, "NPC Offset Profile", NpcTypes, SelectedNpcOffsetType, setAutoKillNpcProfile)
	AutoKillDynamicState.UI.NpcX = createAutoKillSlider(npcPanel, "Kill Offset X", -50, 50, (NpcKillOffsets[SelectedNpcOffsetType] or DefaultNpcKillOffset).X, 1, function(v) return "X: " .. tostring(v) end, function(value) setAutoKillNpcOffset("X", value) end)
	AutoKillDynamicState.UI.NpcY = createAutoKillSlider(npcPanel, "Kill Offset Y", -50, 50, (NpcKillOffsets[SelectedNpcOffsetType] or DefaultNpcKillOffset).Y, 1, function(v) return "Y: " .. tostring(v) end, function(value) setAutoKillNpcOffset("Y", value) end)
	AutoKillDynamicState.UI.NpcZ = createAutoKillSlider(npcPanel, "Kill Offset Z", -50, 50, (NpcKillOffsets[SelectedNpcOffsetType] or DefaultNpcKillOffset).Z, 1, function(v) return "Z: " .. tostring(v) end, function(value) setAutoKillNpcOffset("Z", value) end)
	local offsetTooltip = "Pick NPC/boss you'd like to configure and setup custom XYZ coordinates for that specific NPC/boss You can have multiple custom NPC coordinates for each NPC accordingly, and it automatically saves to you config so you can share it with your friends ;)"
	attachPepsiTooltip(AutoKillDynamicState.UI.NpcProfileDropdown, offsetTooltip)
	attachPepsiTooltip(AutoKillDynamicState.UI.NpcX, offsetTooltip)
	attachPepsiTooltip(AutoKillDynamicState.UI.NpcY, offsetTooltip)
	attachPepsiTooltip(AutoKillDynamicState.UI.NpcZ, offsetTooltip)

	AutoKillDynamicState.UI.BossToggle = createAutoKillToggle(bossPanel, "Auto Kill Boss", library.Flags["flag_AutoKillBoss"] == true, setAutoKillBossEnabled)
	AutoKillDynamicState.UI.BossTargetsDropdown = createAutoKillTargetDropdown(
		bossPanel,
		"Who to kill",
		AutoFarmBossNames,
		"flag_AutoFarmBossTypes",
		setAutoKillBossSelection,
		AutoKillDynamicState.BossRows
	)

	AutoKillDynamicState.UI.BossProfileDropdown = createAutoKillDropdown(bossPanel, "Boss Offset Profile", BossNames, SelectedBossOffsetName, setAutoKillBossProfile)
	AutoKillDynamicState.UI.BossX = createAutoKillSlider(bossPanel, "Boss Offset X", -50, 50, (BossKillOffsets[SelectedBossOffsetName] or DefaultBossKillOffset).X, 1, function(v) return "X: " .. tostring(v) end, function(value) setAutoKillBossOffset("X", value) end)
	AutoKillDynamicState.UI.BossY = createAutoKillSlider(bossPanel, "Boss Offset Y", -50, 50, (BossKillOffsets[SelectedBossOffsetName] or DefaultBossKillOffset).Y, 1, function(v) return "Y: " .. tostring(v) end, function(value) setAutoKillBossOffset("Y", value) end)
	AutoKillDynamicState.UI.BossZ = createAutoKillSlider(bossPanel, "Boss Offset Z", -50, 50, (BossKillOffsets[SelectedBossOffsetName] or DefaultBossKillOffset).Z, 1, function(v) return "Z: " .. tostring(v) end, function(value) setAutoKillBossOffset("Z", value) end)
	attachPepsiTooltip(AutoKillDynamicState.UI.BossProfileDropdown, offsetTooltip)
	attachPepsiTooltip(AutoKillDynamicState.UI.BossX, offsetTooltip)
	attachPepsiTooltip(AutoKillDynamicState.UI.BossY, offsetTooltip)
	attachPepsiTooltip(AutoKillDynamicState.UI.BossZ, offsetTooltip)

	local resize = Instance.new("TextButton")
	resize.AnchorPoint = Vector2.new(1, 1)
	resize.Position = UDim2.fromScale(1, 1)
	resize.Size = UDim2.fromOffset(18, 18)
	resize.BackgroundColor3 = AutoKillTheme.Resize
	resize.BorderSizePixel = 0
	resize.Text = ""
	resize.Parent = panel

	function AutoKillDynamicState.Layout()
		local panelSize = panel.AbsoluteSize
		local contentTop = 78
		local gap = 8
		local contentWidth = panelSize.X - gap * 2
		local contentHeight = panelSize.Y - contentTop - gap
		local targetDropdownY = 76
		local compactOffsetY = targetDropdownY + 38
		local offsetBlockY = compactOffsetY
		local targetListHeight = math.min(160, math.max(80, contentHeight - targetDropdownY - 56))

		for _, targetPanel in {npcPanel, bossPanel} do
			targetPanel.Position = UDim2.fromOffset(gap, contentTop)
			targetPanel.Size = UDim2.fromOffset(contentWidth, contentHeight)
		end

		AutoKillDynamicState.UI.NpcToggle.Instance.Position = UDim2.fromOffset(10, 36)
		AutoKillDynamicState.UI.NpcToggle.Instance.Size = UDim2.new(1, -20, 0, 30)
		AutoKillDynamicState.UI.NpcTargetsDropdown.Instance.Position = UDim2.fromOffset(10, targetDropdownY)
		AutoKillDynamicState.UI.NpcTargetsDropdown.Instance.Size = UDim2.new(1, -20, 0, 32)
		AutoKillDynamicState.UI.NpcTargetsDropdown.Holder.Position = UDim2.fromOffset(0, 34)
		AutoKillDynamicState.UI.NpcTargetsDropdown.Holder.Size = UDim2.new(1, 0, 0, math.min(targetListHeight, #AutoKillDynamicState.UI.NpcTargetsDropdown.Options * 25))
		local npcDropdownY = offsetBlockY
		local npcListHeight = math.min(160, math.max(80, contentHeight - npcDropdownY - 56), #AutoKillDynamicState.UI.NpcProfileDropdown.Options * 25)
		AutoKillDynamicState.UI.NpcProfileDropdown.MaxListHeight = npcListHeight
		AutoKillDynamicState.UI.NpcProfileDropdown.Instance.Position = UDim2.fromOffset(10, npcDropdownY)
		AutoKillDynamicState.UI.NpcProfileDropdown.Instance.Size = UDim2.new(1, -20, 0, 48)
		AutoKillDynamicState.UI.NpcProfileDropdown.Holder.Position = UDim2.fromOffset(0, 48)
		AutoKillDynamicState.UI.NpcProfileDropdown.Holder.Size = UDim2.new(1, 0, 0, npcListHeight)
		AutoKillDynamicState.UI.NpcX.Instance.Position = UDim2.fromOffset(10, offsetBlockY + 88)
		AutoKillDynamicState.UI.NpcX.Instance.Size = UDim2.new(1, -20, 0, 54)
		AutoKillDynamicState.UI.NpcY.Instance.Position = UDim2.fromOffset(10, offsetBlockY + 142)
		AutoKillDynamicState.UI.NpcY.Instance.Size = UDim2.new(1, -20, 0, 54)
		AutoKillDynamicState.UI.NpcZ.Instance.Position = UDim2.fromOffset(10, offsetBlockY + 196)
		AutoKillDynamicState.UI.NpcZ.Instance.Size = UDim2.new(1, -20, 0, 54)

		AutoKillDynamicState.UI.BossToggle.Instance.Position = UDim2.fromOffset(10, 36)
		AutoKillDynamicState.UI.BossToggle.Instance.Size = UDim2.new(1, -20, 0, 30)
		AutoKillDynamicState.UI.BossTargetsDropdown.Instance.Position = UDim2.fromOffset(10, targetDropdownY)
		AutoKillDynamicState.UI.BossTargetsDropdown.Instance.Size = UDim2.new(1, -20, 0, 32)
		AutoKillDynamicState.UI.BossTargetsDropdown.Holder.Position = UDim2.fromOffset(0, 34)
		AutoKillDynamicState.UI.BossTargetsDropdown.Holder.Size = UDim2.new(1, 0, 0, math.min(targetListHeight, #AutoKillDynamicState.UI.BossTargetsDropdown.Options * 25))
		local bossDropdownY = offsetBlockY
		local bossListHeight = math.min(160, math.max(80, contentHeight - bossDropdownY - 56), #AutoKillDynamicState.UI.BossProfileDropdown.Options * 25)
		AutoKillDynamicState.UI.BossProfileDropdown.MaxListHeight = bossListHeight
		AutoKillDynamicState.UI.BossProfileDropdown.Instance.Position = UDim2.fromOffset(10, bossDropdownY)
		AutoKillDynamicState.UI.BossProfileDropdown.Instance.Size = UDim2.new(1, -20, 0, 48)
		AutoKillDynamicState.UI.BossProfileDropdown.Holder.Position = UDim2.fromOffset(0, 48)
		AutoKillDynamicState.UI.BossProfileDropdown.Holder.Size = UDim2.new(1, 0, 0, bossListHeight)
		AutoKillDynamicState.UI.BossX.Instance.Position = UDim2.fromOffset(10, offsetBlockY + 88)
		AutoKillDynamicState.UI.BossX.Instance.Size = UDim2.new(1, -20, 0, 54)
		AutoKillDynamicState.UI.BossY.Instance.Position = UDim2.fromOffset(10, offsetBlockY + 142)
		AutoKillDynamicState.UI.BossY.Instance.Size = UDim2.new(1, -20, 0, 54)
		AutoKillDynamicState.UI.BossZ.Instance.Position = UDim2.fromOffset(10, offsetBlockY + 196)
		AutoKillDynamicState.UI.BossZ.Instance.Size = UDim2.new(1, -20, 0, 54)
	end

	local dragging, resizing, dragStart, startPosition, startSize
	connectAutoKillMenu(titleBar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging, dragStart, startPosition = true, input.Position, panel.Position
		end
	end)
	connectAutoKillMenu(resize.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing, dragStart, startSize = true, input.Position, panel.AbsoluteSize
		end
	end)
	connectAutoKillMenu(UserInputService.InputChanged, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		if dragging and dragStart and startPosition then
			local delta = input.Position - dragStart
			if not trySetGuiProperty(panel, "Position", UDim2.fromOffset(startPosition.X.Offset + delta.X, startPosition.Y.Offset + delta.Y), "AutoKillMenu drag") then
				dragging = false
			end
		elseif resizing and dragStart and startSize then
			local delta = input.Position - dragStart
			if trySetGuiProperty(panel, "Size", UDim2.fromOffset(math.max(322, startSize.X + delta.X), math.max(450, startSize.Y + delta.Y)), "AutoKillMenu resize") then
				AutoKillDynamicState.Layout()
			else
				resizing = false
			end
		end
	end)
	connectAutoKillMenu(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging, resizing = false, false
		end
	end)

	AutoKillDynamicState.Layout()
	setAutoKillMenuMode(AutoKillDynamicState.Mode)
	refreshAutoKillMenuLists()
	return true
end

function removeAutoKillBackingControls()
	for _, control in {
		VVAutoKillNpcToggle,
		VVNpcTypesDropdown,
		VVNpcOffsetProfileDropdown,
		AutoKillNpcDistanceXSlider,
		AutoKillNpcDistanceYSlider,
		AutoKillNpcDistanceZSlider,
		VVAutoKillBossToggle,
		VVBossesDropdown,
		VVBossOffsetProfileDropdown,
		AutoKillBossDistanceXSlider,
		AutoKillBossDistanceYSlider,
		AutoKillBossDistanceZSlider,
	} do
		if control and type(control.Remove) == "function" then
			control:Remove()
		end
	end
end

displayBossOffsetProfile(SelectedBossOffsetName)
removeAutoKillBackingControls()
scanLivingForAutoKillTargets()
startDynamicLivingListScan()
loadQuestProfiles()
scanDialogueInteractablesForQuests(true)
startQuestScanner()
if AutoQuestState.Settings.AutoAccept or AutoQuestState.Settings.AutoComplete then
	runAutoQuestExecutor()
end

function setLeafDebugEnabled(value)
	local hotReload = type(getgenv) == "function" and getgenv().VVUltimatum or _G.VVUltimatum
	if hotReload and hotReload.Debug then
		hotReload.Debug.Enabled = value == true
		if hotReload.Debug.Enabled then
			print("LEAF_DEBUG:", "Core", "DebugEnabled")
		end
	end
end

function setLeafUltraDebugEnabled(value)
	local hotReload = type(getgenv) == "function" and getgenv().VVUltimatum or _G.VVUltimatum
	if hotReload and hotReload.UltraDebug then
		hotReload.UltraDebug.Enabled = value == true
		if hotReload.UltraDebug.Enabled then
			warn("LEAF_ULTRA_WARN:", "Core", "UltraDebugEnabled", "This can spam output hard. Use scopes wisely, bruh")
		end
	end
end

function setLeafDebugScope(scope, value)
	local hotReload = type(getgenv) == "function" and getgenv().VVUltimatum or _G.VVUltimatum
	if hotReload and hotReload.Debug and hotReload.Debug.Scope then
		hotReload.Debug.Scope[scope] = value == true
		leafDebugStep("Core", "DebugScopeChanged", {Scope = scope, Enabled = value == true})
	end
end

function setLeafUltraDebugScope(scope, value)
	local hotReload = type(getgenv) == "function" and getgenv().VVUltimatum or _G.VVUltimatum
	if hotReload and hotReload.UltraDebug and hotReload.UltraDebug.Scope then
		hotReload.UltraDebug.Scope[scope] = value == true
		leafUltraWarn("Core", "UltraDebugScopeChanged", "Scope changed", {Scope = scope, Enabled = value == true})
	end
end

function applyLoadedLeafDebugScope(scope)
	local flagValue = library.Flags["flag_DebugScope_" .. scope]
	if type(flagValue) == "boolean" then
		setLeafDebugScope(scope, flagValue)
	end
end

function applyLoadedLeafUltraDebugScope(scope)
	local flagValue = library.Flags["flag_UltraDebugScope_" .. scope]
	if type(flagValue) == "boolean" then
		setLeafUltraDebugScope(scope, flagValue)
	end
end

SpecialSections.AutoFarms:AddButton({
	Name = "Auto Kill Menu",
	Callback = function()
		openAutoKillMenu()
	end
})

SpecialSections.AutoFarms:AddButton({
	Name = "Auto Quest Menu",
	Callback = function()
		openAutoQuestMenu()
	end
})

SpecialSections.Visualizer:AddButton({
	Name = "Open Visualizer",
	Callback = function()
		openAnimationVisualizer()
	end
})

attachPepsiTooltip(SpecialSections.Servers:AddButton({
	Name = "Lowest Player Server",
	Callback = function()
		task.spawn(joinLowestPlayerServer)
	end
}), "Joins a server with fewer players")

SpecialSections.Servers:AddKeybind({
	Name = "Lowest Player Keybind",
	Flag = "flag_JoinLowestPlayerServerKeybind",
	Pressed = function()
		task.spawn(joinLowestPlayerServer)
	end
})

addPepsiSpacer(SpecialSections.Servers, 8, "flag_PepsiSpacer_Servers_PlayerToPing")

attachPepsiTooltip(SpecialSections.Servers:AddButton({
	Name = "Lowest Ping Server",
	Callback = function()
		task.spawn(joinLowestPingServer)
	end
}), "Joins a server with lower ping")

SpecialSections.Servers:AddKeybind({
	Name = "Lowest Ping Keybind",
	Flag = "flag_JoinLowestPingServerKeybind",
	Pressed = function()
		task.spawn(joinLowestPingServer)
	end
})

SpecialSections.Debug:AddToggle({
	Name = "Debug Mode",
	Flag = "flag_DebugMode",
	Callback = function(Value)
		setLeafDebugEnabled(Value)
	end
})

SpecialSections.Debug:AddToggle({
	Name = "Ultra Debug Mode",
	Flag = "flag_UltraDebugMode",
	Callback = function(Value)
		setLeafUltraDebugEnabled(Value)
	end
})

function addLeafDebugScopeToggle(scope)
	SpecialSections.Debug:AddToggle({
		Name = "Debug Scope: " .. scope,
		Flag = "flag_DebugScope_" .. scope,
		Default = scope == "ServerHop" or scope == "AutoQuest",
		Callback = function(Value)
			setLeafDebugScope(scope, Value)
		end
	})
end

function addLeafUltraDebugScopeToggle(scope)
	SpecialSections.Debug:AddToggle({
		Name = "Ultra Scope: " .. scope,
		Flag = "flag_UltraDebugScope_" .. scope,
		Default = scope == "ServerHop" or scope == "AutoQuest",
		Callback = function(Value)
			setLeafUltraDebugScope(scope, Value)
		end
	})
end

addLeafDebugScopeToggle("ServerHop")
addLeafDebugScopeToggle("AutoQuest")
addLeafDebugScopeToggle("AutoKill")
addLeafDebugScopeToggle("Animation")

addLeafUltraDebugScopeToggle("ServerHop")
addLeafUltraDebugScopeToggle("AutoQuest")
addLeafUltraDebugScopeToggle("AutoKill")
addLeafUltraDebugScopeToggle("Animation")

function hasAutoConfigFileFunctions()
	local available = type(isfile) == "function"
		and type(readfile) == "function"
		and type(writefile) == "function"

	if not available and not AutoConfigState.FileWarningShown then
		AutoConfigState.FileWarningShown = true
		warn("Auto config: isfile/readfile/writefile are unavailable; UI settings will not persist between sessions")
	end

	return available
end

function getAutoConfigJson()
	if not AutoConfigState.Persistence then
		return nil
	end

	local success, json = pcall(function()
		return AutoConfigState.Persistence:GetJSON(false)
	end)

	if not success then
		warn("Auto config: failed to serialize UI settings: " .. tostring(json))
		return nil
	end

	return json
end

function saveAutoConfigJson(json)
	if not hasAutoConfigFileFunctions() or type(json) ~= "string" then
		return false
	end

	local success, writeError = pcall(writefile, AutoConfigState.File, json)
	if not success then
		warn("Auto config: failed to save UI settings: " .. tostring(writeError))
		return false
	end

	return true
end

function scheduleAutoConfigSave(json)
	if AutoConfigState.SaveTask then
		task.cancel(AutoConfigState.SaveTask)
	end

	AutoConfigState.SaveTask = task.delay(0.35, function()
		AutoConfigState.SaveTask = nil
		saveAutoConfigJson(json)
	end)
end

function migrateLegacyAnimationSettings()
	if AnimationSettingsLoadedFromFile or not hasAutoConfigFileFunctions() then return false end
	local existsSuccess, exists = pcall(isfile, AutoConfigState.File)
	if not existsSuccess or not exists then
		AnimationSettingsLoadedFromFile = true
		scheduleAnimationProfilesSave()
		return false
	end
	local readSuccess, content = pcall(readfile, AutoConfigState.File)
	if not readSuccess then return false end
	local decodeSuccess, decoded = pcall(HttpService.JSONDecode, HttpService, content)
	if not decodeSuccess or type(decoded) ~= "table" then return false end
	CaptureRadius = math.clamp(tonumber(decoded.flag_AnimationCaptureRadius) or CaptureRadius, 10, 300)
	ResponseDistance = math.clamp(tonumber(decoded.flag_ResponseDistance) or ResponseDistance, 5, 150)
	ResponseHoldTime = math.clamp((tonumber(decoded.flag_ResponseHoldTime) or (ResponseHoldTime * 1000)) / 1000, 0.02, 0.3)
	PingMultiplier = math.clamp(tonumber(decoded.flag_ResponsePingMultiplier) or PingMultiplier, 0, 1)
	UseReplicatorPing = decoded.flag_UseReplicatorPing == true
	if type(decoded.flag_SelectedAnimationEntry) == "string" then
		local sourceKey, animationId = string.match(decoded.flag_SelectedAnimationEntry, "^(.-) | (%d+)")
		if sourceKey and animationId and getAnimationProfile(sourceKey, animationId, false) then
			SelectedAnimationSourceKey, SelectedAnimationId = sourceKey, animationId
		end
	end
	AnimationSettingsLoadedFromFile = true
	scheduleAnimationProfilesSave()
	return true
end

function synchronizeLoadedAutoConfig()
	migrateLegacyAnimationSettings()

	local selectedNpcTypes = library.Flags["flag_AutoFarmNpcTypes"]
	if type(selectedNpcTypes) == "table" then
		updateAutoKillNpcTypes(selectedNpcTypes)
	else
		whoToKillTable = nil
	end

	local selectedBossTypes = library.Flags["flag_AutoFarmBossTypes"]
	if type(selectedBossTypes) == "table" then
		updateAutoKillBossTypes(selectedBossTypes)
	else
		whoToKillBossTable = nil
	end

	local selectedOffsetProfile = library.Flags["flag_NpcOffsetProfile"]
	if NpcKillOffsets[selectedOffsetProfile] then
		displayNpcOffsetProfile(selectedOffsetProfile)
	else
		displayNpcOffsetProfile(SelectedNpcOffsetType)
	end

	local selectedBossOffsetProfile = library.Flags["flag_BossOffsetProfile"]
	if BossKillOffsets[selectedBossOffsetProfile] then
		displayBossOffsetProfile(selectedBossOffsetProfile)
	else
		displayBossOffsetProfile(SelectedBossOffsetName)
	end

	setLeafDebugEnabled(library.Flags["flag_DebugMode"] == true)
	setLeafUltraDebugEnabled(library.Flags["flag_UltraDebugMode"] == true)
	applyLoadedLeafDebugScope("ServerHop")
	applyLoadedLeafDebugScope("AutoQuest")
	applyLoadedLeafDebugScope("AutoKill")
	applyLoadedLeafDebugScope("Animation")
	applyLoadedLeafUltraDebugScope("ServerHop")
	applyLoadedLeafUltraDebugScope("AutoQuest")
	applyLoadedLeafUltraDebugScope("AutoKill")
	applyLoadedLeafUltraDebugScope("Animation")

	TeleportState.InstaBlitzDistance = math.clamp(tonumber(library.Flags["flag_InstaBlitzDistance"]) or TeleportState.InstaBlitzDistance, 1, 300)
	TeleportState.BlitzEnemyRadius = math.clamp(tonumber(library.Flags["flag_BlitzTeleportEnemyRadius"]) or TeleportState.BlitzEnemyRadius, 5, 100)
	TeleportState.SoruRadius = math.clamp(tonumber(library.Flags["flag_SoruTeleportRadius"]) or TeleportState.SoruRadius, 10, 300)

	AnalysisEnabled = false

	AutoConfigState.Loading = false
	AutoConfigState.LastJson = getAutoConfigJson()

	if library.Flags["flag_AutoFarmLevel"] then
		task.spawn(AutoKillNpc, whoToKillTable)
	end

	if library.Flags["flag_AutoKillBoss"] then
		task.spawn(AutoKillBoss, whoToKillBossTable)
	end

	refreshAnimationObserver()
end

function loadAutoConfig()
	if not AutoConfigState.Persistence or not hasAutoConfigFileFunctions() then
		return false
	end

	local isFileSuccess, configExists = pcall(isfile, AutoConfigState.File)
	if not isFileSuccess then
		warn("Auto config: failed to check config file: " .. tostring(configExists))
		return false
	end

	if not configExists then
		return true
	end

	local readSuccess, content = pcall(readfile, AutoConfigState.File)
	if not readSuccess then
		warn("Auto config: failed to read UI settings: " .. tostring(content))
		return false
	end

	local decodeSuccess, decoded = pcall(function()
		return HttpService:JSONDecode(content)
	end)
	if not decodeSuccess or type(decoded) ~= "table" then
		warn("Auto config: config is damaged; default UI settings will be used")
		return false
	end

	local loadSuccess, loadError = pcall(function()
		AutoConfigState.Persistence:LoadJSON(content)
	end)
	if not loadSuccess then
		warn("Auto config: failed to apply UI settings: " .. tostring(loadError))
		return false
	end

	return true
end

AutoConfigState.Persistence = SpecialSection:AddPersistence({
	Name = "Auto Config",
	Flag = "flag_AutoConfigPersistence",
	Value = "AutoConfig",
	Workspace = "VV Ultimatum",
	Persistive = "all",
})

if AutoConfigState.Persistence then
	AutoConfigState.Persistence:Remove()
	AutoConfigState.Loading = true
	loadAutoConfig()

	task.spawn(function()
		RunService.Heartbeat:Wait()
		RunService.Heartbeat:Wait()
		synchronizeLoadedAutoConfig()
	end)

	task.spawn(function()
		while Wait() do
			task.wait(0.25)

			if not AutoConfigState.Loading then
				local currentJson = getAutoConfigJson()
				if currentJson and currentJson ~= AutoConfigState.LastJson then
					AutoConfigState.LastJson = currentJson
					scheduleAutoConfigSave(currentJson)
				end
			end
		end
	end)
else
	warn("Auto config: PepsiUILib persistence is unavailable")
	migrateLegacyAnimationSettings()
	AutoConfigState.Loading = false
	refreshAnimationObserver()
end






-------- HookMetamethod, hookfunction and etc hook-like functions
EventTakeDamage = ReplicatedStorage.Requests.TakeDamage
mtHook = hookmetamethod(game, "__namecall", function(...)
	local self = ...

	if (library.Flags["flag_FallDamage"] or TakeFallDamageHookEnabled or library.Flags["flag_Fly"]) and rawequal(self, EventTakeDamage) and getnamecallmethod() == "FireServer" then
		return true
	end

	return mtHook(...)
end)

OldFireServer = hookfunction(EventTakeDamage.FireServer, function(...)
	local self = ...

	if (library.Flags["flag_FallDamage"] or TakeFallDamageHookEnabled or library.Flags["flag_Fly"]) and rawequal(self, EventTakeDamage) then
		return true
	end

	return OldFireServer(self, ...)
end)







-------- CharacterAdded connection, instead of making 10 connections, put all functions here (like setWalkSpeed, NoClip, esp, and any other function that requires constant existance of player's character)
LocalPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid and library.Flags["flag_WalkSpeed"]  then
		ChangeWalkSpeedLoop()
	end

	if humanoid and library.Flags["flag_Fly"] then
		stopFly()
		fly()
	end
end)
