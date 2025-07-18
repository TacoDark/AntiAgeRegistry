-- AntiAgeRegistry - LocalScript (Place in StarterPlayerScripts)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:FindService("TextChatService")

-- Detect chat system
local isLegacyChat = not TextChatService:IsChatServiceRunning()

-- Chat message sender (uses your reference)
function chatMessage(str)
	str = tostring(str)
	if not isLegacyChat then
		TextChatService.TextChannels.RBXGeneral:SendAsync(str)
	else
		ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
	end
end

-- GitHub list URL
local url = "https://raw.githubusercontent.com/TacoDark/AntiAgeRegistry/refs/heads/main/list.txt"

-- Fetch list of usernames from raw GitHub
local function fetchBlacklist()
	local success, result = pcall(function()
		return HttpService:GetAsync(url)
	end)

	if success then
		local lines = {}
		for line in result:gmatch("[^\r\n]+") do
			table.insert(lines, line:lower())
		end
		return lines
	else
		warn("[AntiAgeRegistry] Failed to fetch list:", result)
		return {}
	end
end

-- Main scan logic
local function scanPlayers()
	local startTime = tick()
	local blacklist = fetchBlacklist()
	local detected = {}

	for _, player in ipairs(Players:GetPlayers()) do
		local uname = player.Name:lower()
		for _, bannedName in ipairs(blacklist) do
			if uname == bannedName then
				local msg = "[⚠️] AntiAgeRegistry found a Age Player / Regresser! (" .. player.Name .. ")"
				chatMessage(msg)
				table.insert(detected, player.Name)
				break
			end
		end
	end

	local elapsed = math.floor((tick() - startTime) * 1000)
	print("[AntiAgeRegistry] Scan complete in " .. elapsed .. "ms")

	if #detected > 0 then
		print("[AntiAgeRegistry] Detected players:")
		for _, name in ipairs(detected) do
			print(" - " .. name)
		end
	else
		print("[AntiAgeRegistry] No matches found.")
	end
end

-- Wait for game services to be ready, then scan
task.wait(3)
scanPlayers()
