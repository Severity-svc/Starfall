local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = {}

local Collection = {
	Env = {
		IsInStudio = game:GetService("RunService"):IsStudio(),
		IsInStarfall = nil,
	},

	Services = {
		TweenService = game:GetService("TweenService"),
		UserInputService = game:GetService("UserInputService"),
		ReplicatedStorage = game:GetService("ReplicatedStorage"),
		RunService = game:GetService("RunService"),
		HttpService = game:GetService("HttpService"),
		Lighting = game:GetService("Lighting"),
		TextService = game:GetService("TextService"),
		Players = game:GetService("Players"),
		Stats = game:GetService("Stats"),
		Core = nil,
		Analystics = nil,
	},

	LocalPlayer = {
		LocalPlayer = game:GetService("Players").LocalPlayer,
		Username = game:GetService("Players").LocalPlayer.Name,
		Display = game:GetService("Players").LocalPlayer.DisplayName,
		UserId = game:GetService("Players").LocalPlayer.UserId,
		Mouse = game:GetService("Players").LocalPlayer:GetMouse(),
		Camera = game:GetService("Workspace").CurrentCamera,
		Hwid = nil,
		ClientId = nil,
	},

	Functions = {
		["AttachButton"] = function(Parent, Addition, Addition2, ZIndex)
			local AdditionalSize = Addition or 0
			local Addy2 = Addition2 or 0
			local ZINDEX = ZIndex or 1
			local Button = Instance.new("TextButton")

			Button.Parent = Parent
			Button.Text = ""
			Button.AnchorPoint = Vector2.new(0.5, 0.5)
			Button.Position = UDim2.new(0.5, 0, 0.5, 0)
			Button.Size = UDim2.new(1 + AdditionalSize + Addy2, 0, 1 + AdditionalSize, 0)
			Button.Name = "ClickableButton"
			Button.BackgroundTransparency = 1
			Button.ZIndex = ZINDEX

			return Button
		end,

		["Tween"] = function(Instance, Info, Propriety)
			local TweenService = game:GetService("TweenService")
			local Tween = TweenService:Create(Instance, Info, Propriety)
			Tween:Play()

			return Tween
		end,

		["Create Gradient"] = function(Parent)
			local UIGradient = Instance.new("UIGradient")

			UIGradient.Parent = Parent
			UIGradient.Rotation = 90
			UIGradient.Transparency =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.216606) })

			return UIGradient
		end,

		["GetIconFromLucide"] = function(Lucide, Name)
			if Lucide then
				for i, v in pairs(Lucide) do
					if i:find(tostring(Name)) then
						return v
					end
				end
			end

			return nil
		end,
	},

	Shared = {
		VERSION = "1.0.0",
		API = "",
		KEY = "",
		EXECUTOR = nil,
	},

	File = {
		Header = "Starfall",
		Config = "Starfall/Configs",
		Profiles = "Starfall/Profiles",

		Settings = "Starfall/Configs//Settings.lua",
		Profile = "Starfall/Profiles/Profile.json",

		CanSave = true,
		ToLoad = false,
	},

	Gui = {
		MinimizeKeybind = Enum.KeyCode.RightControl,
		IsMinimized = false,

		Fonts = {
			SemiBoldInter = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			BoldInter = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		},
	},
}

--// Faster Names
local Env = Collection.Env
local Services = Collection.Services
local LocalPlayer = Collection.LocalPlayer
local Functions = Collection.Functions
local Shared = Collection.Shared
local File = Collection.File
local Gui = Collection.Gui
local Tab = Gui.TabVariables

local Tween = Functions.Tween

--// Setup
if not Env.IsInStudio then
	Services.Core = game:GetService("CoreGui")
	Services.Analystics = game:GetService("RbxAnalyticsService")

	LocalPlayer.Hwid = getgenv().gethwid() or "CUSTOMHWID_2929sk0is20so02"
	LocalPlayer.ClientId = Services.Analystics:GetClientId() or "CUSTOM_CLIENT_ID_2929sk0is20so02"

	Env.IsInStarfall = true

	File.IsFile = getgenv().isfile
	File.WriteFile = getgenv().writefile
	File.ReadFile = getgenv().readfile
	File.WriteFolder = getgenv().makefolder
	File.IsFolder = getgenv().isfolder
	File.DelFile = getgenv().delfile
	File.DelFolder = getgenv().delfolder
	File.ListFiles = getgenv().listfiles

	Shared.EXECUTOR = getgenv().getexecutorname()
else
	Env.IsInStarfall = false
	Services.Core = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	Services.Analystics = nil

	LocalPlayer.Hwid = "STUDIO_HWID_2929sk0is20so02"
	LocalPlayer.ClientId = "STUDIO_CLIENT_ID_2929sk0is20so02"
end

--// File [Saving]

if Env.IsInStudio then
	File.CanSave = false
else
	if not File.IsFile or not File.WriteFile or not File.ReadFile or not File.WriteFolder or not File.IsFolder then
		File.CanSave = false
	else
		if not File.IsFolder(File.Header) then
			File.WriteFolder(File.Header)
		end

		if not File.IsFolder(File.Config) then
			File.WriteFolder(File.Config)
		end

		if not File.IsFile(File.Settings) then
			File.WriteFile(File.Settings, "")
		end

		if not File.IsFile(File.Profile) then
			File.WriteFile(File.Profile, "")
		end
	end
end

--// Gui
local Starfall = Instance.new("ScreenGui")
Starfall.Name = "Starfall"
Starfall.Parent = Services.Core
Starfall.ResetOnSpawn = false
Starfall.IgnoreGuiInset = false

function Library:CreateConfig(ConfigName)
	if not File.CanSave then
		return
	end

	local Path = File.Config .. "/" .. ConfigName .. ".json"
	local ConfigTable = {}

	for _, v in pairs(Starfall:GetDescendants()) do
		if v:IsA("StringValue") and v.Name == "Flag" and v.Value ~= "nil" then
			local Holder = v.Parent
			local SaveValue = Holder:FindFirstChild("Value")

			if SaveValue and SaveValue:IsA("ValueBase") then
				local Name = v.Value
				local Value = SaveValue.Value
				ConfigTable[Name] = Value
			end
		end
	end

	local Data = Services.HttpService:JSONEncode(ConfigTable)
	File.WriteFile(Path, Data)
end

function Library:LoadConfig(ConfigName)
	if not File.CanSave then
		return
	end

	File.ToLoad = true

	local Path = File.Config .. "/" .. ConfigName .. ".json"

	if not File.IsFile(Path) then
		warn("[Starfall] Config file does not exist: " .. Path)
		File.ToLoad = false
		return
	end

	local Success, Result = pcall(function()
		local Data = File.ReadFile(Path)
		return Services.HttpService:JSONDecode(Data)
	end)

	if not Success then
		warn("[Starfall] Failed to load config: " .. tostring(Result))
		File.ToLoad = false
		return
	end

	local ConfigTable = Result

	for _, v in pairs(Starfall:GetDescendants()) do
		if v:IsA("StringValue") and v.Name == "Flag" and v.Value ~= "nil" then
			local Holder = v.Parent
			local ValueObject = Holder:FindFirstChild("Value")

			if ValueObject and ValueObject:IsA("ValueBase") then
				local FlagName = v.Value

				if ConfigTable[FlagName] ~= nil then
					local NewValue = ConfigTable[FlagName]
					if typeof(NewValue) == typeof(ValueObject.Value) then
						ValueObject.Value = NewValue
					else
						warn("[Starfall] Type mismatch for flag '" .. FlagName .. "'. Skipping.")
					end
				end
			end
		end
	end

	File.ToLoad = false
end

function Library:DeleteConfig(ConfigName)
	local Path = File.Config .. "/" .. ConfigName .. ".json"
	File.DelFile(Path)
end

function Library:AnimateButton(Button, Addition)
	local ButtonState = {}

	local OriginalSize = Button.Size
	local OriginalPosition = Button.Position
	local AdditionSize = Addition or 4

	local HoverSize = UDim2.new(
		OriginalSize.X.Scale,
		OriginalSize.X.Offset + AdditionSize,
		OriginalSize.Y.Scale,
		OriginalSize.Y.Offset + AdditionSize
	)

	ButtonState[Button] = {
		IsAnimating = false,
		IsHovered = false,
	}

	local function GetOffsetDelta(Size1, Size2)
		local Dx = (Size2.X.Offset - Size1.X.Offset) / 2
		local Dy = (Size2.Y.Offset - Size1.Y.Offset) / 2
		return UDim2.new(0, -Dx, 0, -Dy)
	end

	local function TweenTo(Size)
		if ButtonState[Button].IsAnimating then
			return
		end
		ButtonState[Button].IsAnimating = true

		local Delta = GetOffsetDelta(Button.Size, Size)
		local TargetPosition = Button.Position + Delta

		Functions.Tween(Button, TweenInfo.new(0.15), {
			Size = Size,
			Position = TargetPosition,
		})

		task.delay(0.15, function()
			ButtonState[Button].IsAnimating = false

			if ButtonState[Button].IsHovered and Button.Size ~= HoverSize then
				TweenTo(HoverSize)
			elseif not ButtonState[Button].IsHovered and Button.Size ~= OriginalSize then
				TweenTo(OriginalSize)
			end
		end)
	end

	Button.MouseEnter:Connect(function()
		ButtonState[Button].IsHovered = true
		TweenTo(HoverSize)
	end)

	Button.MouseLeave:Connect(function()
		ButtonState[Button].IsHovered = false
		TweenTo(OriginalSize)
	end)
end

--// Notifications
local NotificationDebounce = false
function Library:CreateNotification(Index)
	local Offset2 = 0

	local YOffset = 0.835
	local XOffset = 0.862

	local Notification = Instance.new("Frame")
	local UICorner_1 = Instance.new("UICorner")
	local CloseButton_1 = Instance.new("ImageButton")
	local UICorner_2 = Instance.new("UICorner")
	local Title_1 = Instance.new("TextLabel")
	local Content_1 = Instance.new("TextLabel")
	local UIStroke_5 = Instance.new("UIStroke")

	local function GetOffset()
		for _, v in next, Starfall:GetChildren() do
			if v.Name == "Notification" then
				Offset2 = Offset2 + 0.12
			end
		end

		return Offset2
	end

	Notification.Name = "Notification"
	Notification.Parent = Starfall
	Notification.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
	Notification.BackgroundTransparency = 1
	Notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Notification.BorderSizePixel = 0
	Notification.Position = UDim2.new(XOffset, 0, YOffset - (GetOffset() - 0.045), 0)
	Notification.Size = UDim2.new(0, 271, 0, 91)

	UICorner_1.Parent = Notification
	UICorner_1.CornerRadius = UDim.new(0, 12)

	UIStroke_5.Parent = Notification
	UIStroke_5.Color = Color3.fromRGB(36, 40, 47)
	UIStroke_5.Thickness = 1
	UIStroke_5.Transparency = 1

	CloseButton_1.Name = "CloseButton"
	CloseButton_1.Parent = Notification
	CloseButton_1.Active = true
	CloseButton_1.BackgroundColor3 = Color3.fromRGB(31, 35, 40)
	CloseButton_1.BackgroundTransparency = 1
	CloseButton_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	CloseButton_1.BorderSizePixel = 0
	CloseButton_1.Position = UDim2.new(0.878181458, 1, 0.0643140972, -1)
	CloseButton_1.Size = UDim2.new(0, 25, 0, 25)
	CloseButton_1.Image = "http://www.roblox.com/asset/?id=10002373478"
	CloseButton_1.ImageTransparency = 1
	CloseButton_1.ImageColor3 = Color3.fromRGB(189, 189, 189)

	UICorner_2.Parent = CloseButton_1

	Title_1.Name = "Title"
	Title_1.Parent = Notification
	Title_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title_1.BackgroundTransparency = 1
	Title_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Title_1.BorderSizePixel = 0
	Title_1.Position = UDim2.new(0.0502159446, 0, 0.123093784, 0)
	Title_1.Size = UDim2.new(0, 200, 0, 24)
	Title_1.FontFace = Gui.Fonts.BoldInter
	Title_1.Text = Index.Title or Index.Header or "Starfall"
	Title_1.TextTransparency = 1
	Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title_1.TextSize = 16
	Title_1.TextXAlignment = Enum.TextXAlignment.Left
	Title_1.TextYAlignment = Enum.TextYAlignment.Top

	Content_1.Name = "Content"
	Content_1.Parent = Notification
	Content_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Content_1.BackgroundTransparency = 1
	Content_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Content_1.BorderSizePixel = 0
	Content_1.Position = UDim2.new(0.0502159446, 0, 0.364852071, 2)
	Content_1.Size = UDim2.new(0, 250, 0, 46)
	Content_1.FontFace = Gui.Fonts.SemiBoldInter
	Content_1.Text = Index.Content or ""
	Content_1.TextTransparency = 1
	Content_1.TextColor3 = Color3.fromRGB(232, 232, 232)
	Content_1.TextSize = 14
	Content_1.TextWrapped = true
	Content_1.RichText = true
	Content_1.TextXAlignment = Enum.TextXAlignment.Left
	Content_1.TextYAlignment = Enum.TextYAlignment.Top

	local Duration = Index.Duration or 3.5
	local UseBoldText = Index.UseBoldContent or false

	if UseBoldText then
		Content_1.FontFace = Gui.Fonts.SemiBoldInter
	end

	Starfall.ChildAdded:Connect(function(Instance)
		local Offset = 0
		if Instance.Name == "Notification" then
			for _, v in pairs(Starfall:GetChildren()) do
				if v.Name == "Notification" then
					Tween(v, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(XOffset, 0, YOffset - Offset, 0),
					})

					Offset = Offset + 0.12
				end
			end
		end
	end)

	Starfall.ChildRemoved:Connect(function(Instance)
		local Offset = 0
		if Instance.Name == "Notification" then
			for _, v in pairs(Starfall:GetChildren()) do
				if v.Name == "Notification" then
					Tween(v, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(XOffset, 0, YOffset - Offset, 0),
					})

					Offset = Offset + 0.12
				end
			end
		end
	end)
	CloseButton_1.MouseEnter:Connect(function()
		Tween(CloseButton_1, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ImageColor3 = Color3.fromRGB(231, 231, 231),
		})
	end)

	CloseButton_1.MouseLeave:Connect(function()
		Tween(CloseButton_1, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			ImageColor3 = Color3.fromRGB(189, 189, 189),
		})
	end)

	CloseButton_1.MouseButton1Click:Connect(function()
		Tween(
			Notification,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		)

		Tween(Content_1, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 })

		Tween(Title_1, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 })

		Tween(
			CloseButton_1,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ ImageTransparency = 1 }
		)

		Tween(UIStroke_5, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 })

		task.wait(0.29)
		Notification:Destroy()
	end)

	if Duration then
		coroutine.wrap(function()
			--// Entrance
			Tween(
				Notification,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 0 }
			)

			Tween(UIStroke_5, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0 })

			Tween(
				Content_1,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ TextTransparency = 0 }
			)

			Tween(
				Title_1,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ TextTransparency = 0 }
			)

			Tween(
				CloseButton_1,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ ImageTransparency = 0 }
			)

			task.wait(Duration)

			Tween(
				Notification,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 1 }
			)

			Tween(UIStroke_5, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 })

			Tween(
				Content_1,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ TextTransparency = 1 }
			)

			Tween(
				Title_1,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ TextTransparency = 1 }
			)

			Tween(
				CloseButton_1,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ ImageTransparency = 1 }
			)

			task.wait(0.29)
			Notification:Destroy()
		end)()
	end
end

function Library:CreateResponse(ResponseIndex)
	local ResponseOverlay = Instance.new("Frame")
	local UICorner_1d = Instance.new("UICorner")
	local Holder_1 = Instance.new("Frame")
	local UICorner_2d = Instance.new("UICorner")
	local Question_1 = Instance.new("Frame")
	local UICorner_3d = Instance.new("UICorner")
	local Title_1d = Instance.new("TextLabel")
	local Option_1 = Instance.new("Frame")
	local UICorner_4d = Instance.new("UICorner")
	local Title_2 = Instance.new("TextLabel")
	local Option_2 = Instance.new("Frame")
	local UICorner_5d = Instance.new("UICorner")
	local Title_3 = Instance.new("TextLabel")

	ResponseOverlay.Name = "ResponseOverlay"
	ResponseOverlay.Parent = Starfall:FindFirstChild("Main")
	ResponseOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ResponseOverlay.BackgroundTransparency = 1 --// 0.5
	ResponseOverlay.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ResponseOverlay.BorderSizePixel = 0
	ResponseOverlay.Size = UDim2.new(1, 0, 1, 0)

	UICorner_1d.Parent = ResponseOverlay
	UICorner_1d.CornerRadius = UDim.new(0, 12)

	Holder_1.Name = "Holder"
	Holder_1.Parent = ResponseOverlay
	Holder_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Holder_1.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
	Holder_1.BackgroundTransparency = 1 --// 0.2
	Holder_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Holder_1.BorderSizePixel = 0
	Holder_1.Position = UDim2.new(0.5, 0, 0.5, 0)
	Holder_1.Size = UDim2.new(0, 441, 0, 195)

	UICorner_2d.Parent = Holder_1
	UICorner_2d.CornerRadius = UDim.new(0, 12)

	Question_1.Name = "Question"
	Question_1.Parent = Holder_1
	Question_1.AnchorPoint = Vector2.new(0.5, 0)
	Question_1.BackgroundColor3 = Color3.fromRGB(31, 34, 40)
	Question_1.BackgroundTransparency = 1
	Question_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Question_1.BorderSizePixel = 0
	Question_1.Position = UDim2.new(0.5, 0, 0.0500000194, 0)
	Question_1.Size = UDim2.new(0, 421, 0, 97)

	UICorner_3d.Parent = Question_1
	UICorner_3d.CornerRadius = UDim.new(0, 12)

	Title_1d.Name = "Title"
	Title_1d.Parent = Question_1
	Title_1d.AnchorPoint = Vector2.new(0.5, 0.5)
	Title_1d.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title_1d.BackgroundTransparency = 1
	Title_1d.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Title_1d.BorderSizePixel = 0
	Title_1d.Position = UDim2.new(0.5, 0, 0.5, 0)
	Title_1d.Size = UDim2.new(0, 369, 0, 39)
	Title_1d.FontFace = Gui.Fonts.SemiBoldInter
	Title_1d.Text = ResponseIndex.Question or ""
	Title_1d.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title_1d.TextTransparency = 1
	Title_1d.TextSize = 17

	Option_1.Name = "Option"
	Option_1.Parent = Holder_1
	Option_1.AnchorPoint = Vector2.new(0.5, 0)
	Option_1.BackgroundColor3 = Color3.fromRGB(31, 34, 40)
	Option_1.BackgroundTransparency = 1
	Option_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Option_1.BorderSizePixel = 0
	Option_1.Position = UDim2.new(0.271201909, 0, 0.619834721, 0)
	Option_1.Size = UDim2.new(0, 204, 0, 58)

	UICorner_4d.Parent = Option_1
	UICorner_4d.CornerRadius = UDim.new(0, 12)

	Title_2.Name = "Title"
	Title_2.Parent = Option_1
	Title_2.AnchorPoint = Vector2.new(0.5, 0.5)
	Title_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title_2.BackgroundTransparency = 1
	Title_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Title_2.BorderSizePixel = 0
	Title_2.Position = UDim2.new(0.5, 0, 0.5, 0)
	Title_2.Size = UDim2.new(0, 203, 0, 39)
	Title_2.FontFace = Gui.Fonts.BoldInter
	Title_2.Text = ResponseIndex.Option1 or ""
	Title_2.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title_2.TextSize = 17

	Option_2.Name = "Option"
	Option_2.Parent = Holder_1
	Option_2.AnchorPoint = Vector2.new(0.5, 0)
	Option_2.BackgroundColor3 = Color3.fromRGB(255, 38, 38)
	Option_2.BackgroundTransparency = 1
	Option_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Option_2.BorderSizePixel = 0
	Option_2.Position = UDim2.new(0.744007766, 0, 0.619834721, 0)
	Option_2.Size = UDim2.new(0, 204, 0, 58)

	UICorner_5d.Parent = Option_2
	UICorner_5d.CornerRadius = UDim.new(0, 12)

	Title_3.Name = "Title"
	Title_3.Parent = Option_2
	Title_3.AnchorPoint = Vector2.new(0.5, 0.5)
	Title_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title_3.BackgroundTransparency = 1
	Title_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Title_3.BorderSizePixel = 0
	Title_3.Position = UDim2.new(0.5, 0, 0.5, 0)
	Title_3.Size = UDim2.new(0, 203, 0, 39)
	Title_3.FontFace = Gui.Fonts.BoldInter
	Title_3.Text = ResponseIndex.Option2 or ""
	Title_3.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title_3.TextSize = 17

	--// Entrance
	Tween(
		ResponseOverlay,
		TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.5 }
	)

	Tween(
		Holder_1,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.2 }
	)

	Tween(
		Question_1,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0 }
	)

	Tween(Option_1, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })

	Tween(Option_2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })

	for _, v in pairs(ResponseOverlay:GetDescendants()) do
		if v:IsA("TextLabel") then
			Tween(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
		end
	end

	--// Exit
	local Exit = function()
		Tween(
			ResponseOverlay,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		)

		Tween(
			Holder_1,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		)

		Tween(
			Question_1,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		)

		Tween(
			Option_1,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		)

		Tween(
			Option_2,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		)

		for _, v in pairs(ResponseOverlay:GetDescendants()) do
			if v:IsA("TextLabel") then
				Tween(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 })
			end
		end

		task.wait(0.22)
		ResponseOverlay:Destroy()
	end

	--// Init
	local Response = ResponseIndex.Response or nil
	local ResponseButton1 = Functions.AttachButton(Option_1, 0.2)
	local ResponseButton2 = Functions.AttachButton(Option_2, 0.2)

	Library:AnimateButton(Option_1, -2)
	Library:AnimateButton(Option_2, -2)

	Functions["Create Gradient"](Option_1)
	Functions["Create Gradient"](Option_2)
	Functions["Create Gradient"](Question_1)

	ResponseButton1.MouseButton1Click:Connect(function()
		Response(true)
		Exit()
	end)

	ResponseButton2.MouseButton1Click:Connect(function()
		Response(false)
		Exit()
	end)

	Option_1.MouseEnter:Connect(function()
		Tween(Option_1, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		})
		Tween(Option_1:FindFirstChild("Title"), TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextColor3 = Color3.fromRGB(0, 0, 0),
		})
	end)

	Option_1.MouseLeave:Connect(function()
		Tween(Option_1, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(31, 34, 40),
		})

		Tween(Option_1:FindFirstChild("Title"), TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextColor3 = Color3.fromRGB(255, 255, 255),
		})
	end)

	Option_2.MouseEnter:Connect(function()
		Tween(Option_2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(255, 52, 52),
		})
	end)

	Option_2.MouseLeave:Connect(function()
		Tween(Option_2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(255, 38, 38),
		})
	end)
end

--// Init
function Library:CreateWindow(Index)
	local Setup = {}

	local KeySystem = Index.KeySystem
	local Key = KeySystem.Key or nil
	local KeyApi = Shared.API or nil

	local Main_1 = Instance.new("Frame")
	local Title_1 = Instance.new("TextLabel")
	local ActionBar_1 = Instance.new("Frame")
	local UICorner_1 = Instance.new("UICorner")
	local UIListLayout_1 = Instance.new("UIListLayout")
	local ZCloseButton_1 = Instance.new("ImageButton")
	local UICorner_2 = Instance.new("UICorner")
	local MinimizeButton_1 = Instance.new("ImageButton")
	local UICorner_3 = Instance.new("UICorner")
	local XFullscreen_1 = Instance.new("ImageButton")
	local UICorner_4 = Instance.new("UICorner")
	local Square_1 = Instance.new("Frame")
	local UICorner_5 = Instance.new("UICorner")
	local UIStroke_1 = Instance.new("UIStroke")
	local Container_1 = Instance.new("Frame")
	local SubTitle_1 = Instance.new("TextLabel")
	local UICorner_31 = Instance.new("UICorner")
	local UIStroke_5 = Instance.new("UIStroke")
	local Sidebar_1 = Instance.new("Frame")
	local Overlay = Instance.new("Frame")
	local UICorner_1dd = Instance.new("UICorner")
	local Sidebar_1 = Instance.new("Frame")
	local UIStroke_1dd = Instance.new("UIStroke")
	local UICorner_2dd = Instance.new("UICorner")
	local UIListLayout_1dd = Instance.new("UIListLayout")
	local UIGradient_2 = Instance.new("UIGradient")
	local Profile_1 = Instance.new("Frame")
	local UIStroke_2 = Instance.new("UIStroke")
	local UICorner_5dd = Instance.new("UICorner")
	local ScreenShot_1 = Instance.new("ImageLabel")
	local UICorner_6 = Instance.new("UICorner")
	local UIStroke_3 = Instance.new("UIStroke")
	local Rank_1 = Instance.new("TextLabel")
	local Display_1 = Instance.new("TextLabel")
	local Spline = Instance.new("Frame")
	local UICorner_1a = Instance.new("UICorner")
	local Username_1 = Instance.new("TextLabel")

	Main_1.Name = "Main"
	Main_1.Parent = Starfall
	Main_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Main_1.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
	Main_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Main_1.BorderSizePixel = 0
	Main_1.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main_1.Size = UDim2.new(0, 751, 0, 459)

	Title_1.Name = "Title"
	Title_1.Parent = Main_1
	Title_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title_1.BackgroundTransparency = 1
	Title_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Title_1.BorderSizePixel = 0
	Title_1.Position = UDim2.new(0.0133155789, 0, 0.03050109, 0)
	Title_1.Size = UDim2.new(0, 200, 0, 24)
	Title_1.FontFace = Gui.Fonts.SemiBoldInter
	Title_1.Text = Index.Title or "Starfall"
	Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title_1.TextSize = 17
	Title_1.TextXAlignment = Enum.TextXAlignment.Left
	Title_1.TextYAlignment = Enum.TextYAlignment.Top

	SubTitle_1.Name = "SubTitle"
	SubTitle_1.Parent = Main_1
	SubTitle_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SubTitle_1.BackgroundTransparency = 1
	SubTitle_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	SubTitle_1.BorderSizePixel = 0
	SubTitle_1.Position = UDim2.new(0.0133155789, 0, 0.0653594807, 2)
	SubTitle_1.Size = UDim2.new(0, 129, 0, 14)
	SubTitle_1.FontFace = Gui.Fonts.SemiBoldInter
	SubTitle_1.Text = Index.SubTitle or "version " .. Shared.VERSION
	SubTitle_1.TextColor3 = Color3.fromRGB(135, 150, 177)
	SubTitle_1.TextSize = 13
	SubTitle_1.TextXAlignment = Enum.TextXAlignment.Left
	SubTitle_1.TextYAlignment = Enum.TextYAlignment.Top

	UICorner_31.Parent = Main_1
	UICorner_31.CornerRadius = UDim.new(0, 12)

	UIStroke_5.Parent = Main_1
	UIStroke_5.Color = Color3.fromRGB(36, 40, 47)
	UIStroke_5.Thickness = 1

	ActionBar_1.Name = "ActionBar"
	ActionBar_1.Parent = Main_1
	ActionBar_1.AnchorPoint = Vector2.new(0.5, 0)
	ActionBar_1.BackgroundColor3 = Color3.fromRGB(23, 26, 30)
	ActionBar_1.BackgroundTransparency = 1
	ActionBar_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ActionBar_1.BorderSizePixel = 0
	ActionBar_1.Position = UDim2.new(0.921438098, 0, 0.0154618742, -6)
	ActionBar_1.Size = UDim2.new(0, 98, 0, 37)

	UICorner_1.Parent = ActionBar_1
	UICorner_1.CornerRadius = UDim.new(0, 15)

	UIListLayout_1.Parent = ActionBar_1
	UIListLayout_1.Padding = UDim.new(0, 5)
	UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout_1.SortOrder = Enum.SortOrder.Name
	UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

	ZCloseButton_1.Name = "ZCloseButton"
	ZCloseButton_1.Parent = ActionBar_1
	ZCloseButton_1.Active = true
	ZCloseButton_1.BackgroundColor3 = Color3.fromRGB(31, 35, 40)
	ZCloseButton_1.BackgroundTransparency = 1
	ZCloseButton_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ZCloseButton_1.BorderSizePixel = 0
	ZCloseButton_1.Position = UDim2.new(0.815450668, 0, 0.0180180185, 0)
	ZCloseButton_1.Size = UDim2.new(0, 25, 0, 25)
	ZCloseButton_1.Image = "http://www.roblox.com/asset/?id=10002373478"
	ZCloseButton_1.ImageColor3 = Color3.fromRGB(154, 154, 154)

	UICorner_2.Parent = ZCloseButton_1

	MinimizeButton_1.Name = "MinimizeButton"
	MinimizeButton_1.Parent = ActionBar_1
	MinimizeButton_1.Active = true
	MinimizeButton_1.BackgroundColor3 = Color3.fromRGB(31, 35, 40)
	MinimizeButton_1.BackgroundTransparency = 1
	MinimizeButton_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	MinimizeButton_1.BorderSizePixel = 0
	MinimizeButton_1.Position = UDim2.new(0.815450668, 0, 0.0180180185, 0)
	MinimizeButton_1.Size = UDim2.new(0, 21, 0, 21)
	MinimizeButton_1.Image = "http://www.roblox.com/asset/?id=15396333997"
	MinimizeButton_1.ImageColor3 = Color3.fromRGB(154, 154, 154)

	UICorner_3.Parent = MinimizeButton_1

	XFullscreen_1.Name = "XFullscreen"
	XFullscreen_1.Parent = ActionBar_1
	XFullscreen_1.Active = true
	XFullscreen_1.BackgroundColor3 = Color3.fromRGB(31, 35, 40)
	XFullscreen_1.BackgroundTransparency = 1
	XFullscreen_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	XFullscreen_1.BorderSizePixel = 0
	XFullscreen_1.Position = UDim2.new(0.815450668, 0, 0.0180180185, 0)
	XFullscreen_1.Size = UDim2.new(0, 21, 0, 21)

	UICorner_4.Parent = XFullscreen_1

	Square_1.Name = "Square"
	Square_1.Parent = XFullscreen_1
	Square_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Square_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Square_1.BackgroundTransparency = 1
	Square_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Square_1.BorderSizePixel = 0
	Square_1.Position = UDim2.new(0.5, 0, 0.5, 0)
	Square_1.Size = UDim2.new(0, 15, 0, 15)

	local UICorner_5a = Instance.new("UICorner")
	UICorner_5a.Parent = Square_1
	UICorner_5a.CornerRadius = UDim.new(0, 4)

	UIStroke_1.Parent = Square_1
	UIStroke_1.Color = Color3.fromRGB(122, 122, 122)
	UIStroke_1.Thickness = 1.600000023841858

	Container_1.Name = "Container"
	Container_1.Parent = Main_1
	Container_1.AnchorPoint = Vector2.new(0.5, 0)
	Container_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Container_1.BackgroundTransparency = 1
	Container_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Container_1.BorderSizePixel = 0
	Container_1.Position = UDim2.new(0.5, 0, 0.127254909, 0)
	Container_1.Size = UDim2.new(0, 731, 0, 480)

	ZCloseButton_1.MouseButton1Click:Connect(function()
		Library:CreateResponse({
			Question = "Are you sure you want to close the interface?",
			Option1 = "Close Interface",
			Option2 = "Cancel",
			Response = function(Bool)
				if Bool then
					task.wait(0.2)
					Starfall:Destroy()
				else
					return
				end
			end,
		})
	end)

	Overlay.Name = "Overlay"
	Overlay.Parent = Main_1
	Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Overlay.BackgroundTransparency = 0.5
	Overlay.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Overlay.BorderSizePixel = 0
	Overlay.Size = UDim2.new(1, 0, 1, 0)
	Overlay.Visible = false

	UICorner_1dd.Parent = Overlay
	UICorner_1dd.CornerRadius = UDim.new(0, 12)

	Sidebar_1.Name = "Sidebar"
	Sidebar_1.Parent = Overlay
	Sidebar_1.AnchorPoint = Vector2.new(0, 0.5)
	Sidebar_1.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
	Sidebar_1.BackgroundTransparency = 0.07000000029802322
	Sidebar_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Sidebar_1.BorderSizePixel = 0
	Sidebar_1.Position = UDim2.new(0.0130000003, 0, 0.370462269, 0)
	Sidebar_1.Size = UDim2.new(0, 217, 0, 323)
	Sidebar_1.ZIndex = 1

	UIStroke_1dd.Parent = Sidebar_1
	UIStroke_1dd.Color = Color3.fromRGB(36, 40, 47)
	UIStroke_1dd.Thickness = 1

	UICorner_2dd.Parent = Sidebar_1
	UICorner_2dd.CornerRadius = UDim.new(0, 12)

	UIListLayout_1dd.Parent = Sidebar_1
	UIListLayout_1dd.Padding = UDim.new(0, 4)
	UIListLayout_1dd.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout_1dd.SortOrder = Enum.SortOrder.LayoutOrder

	local NewPad = Instance.new("UIPadding")
	NewPad.Parent = Sidebar_1
	NewPad.PaddingTop = UDim.new(0, 10)

	Profile_1.Name = "Profile"
	Profile_1.Parent = Overlay
	Profile_1.AnchorPoint = Vector2.new(0, 0.5)
	Profile_1.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
	Profile_1.BackgroundTransparency = 0.07000000029802322
	Profile_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Profile_1.BorderSizePixel = 0
	Profile_1.Position = UDim2.new(0.0130000003, 0, 0.865061224, -4)
	Profile_1.Size = UDim2.new(0, 217, 0, 110)
	Profile_1.ZIndex = 1

	UIStroke_2.Parent = Profile_1
	UIStroke_2.Color = Color3.fromRGB(36, 40, 47)
	UIStroke_2.Thickness = 1

	UICorner_5.Parent = Profile_1
	UICorner_5.CornerRadius = UDim.new(0, 12)

	ScreenShot_1.Name = "ScreenShot"
	ScreenShot_1.Parent = Profile_1
	ScreenShot_1.BackgroundColor3 = Color3.fromRGB(196, 216, 255)
	ScreenShot_1.BackgroundTransparency = 0.949999988079071
	ScreenShot_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScreenShot_1.BorderSizePixel = 0
	ScreenShot_1.Position = UDim2.new(0.0530110486, 0, 0.1590271, 0)
	ScreenShot_1.Size = UDim2.new(0, 75, 0, 75)
	ScreenShot_1.Image = "rbxthumb://type=AvatarHeadShot&id=2343555344&w=420&h=420"

	UICorner_6.Parent = ScreenShot_1
	UICorner_6.CornerRadius = UDim.new(1, 0)

	UIStroke_3.Parent = ScreenShot_1
	UIStroke_3.Color = Color3.fromRGB(52, 58, 68)
	UIStroke_3.Thickness = 1

	Rank_1.Name = "Rank"
	Rank_1.Parent = Profile_1
	Rank_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Rank_1.BackgroundTransparency = 1
	Rank_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Rank_1.BorderSizePixel = 0
	Rank_1.Position = UDim2.new(0.404671431, 7, 0.504597068, 6)
	Rank_1.Size = UDim2.new(0, 122, 0, 23)
	Rank_1.FontFace = Gui.Fonts.SemiBoldInter
	Rank_1.Text = "Unranked User"
	Rank_1.TextColor3 = Color3.fromRGB(157, 173, 204)
	Rank_1.TextSize = 13
	Rank_1.TextXAlignment = Enum.TextXAlignment.Left

	Display_1.Name = "Display"
	Display_1.Parent = Profile_1
	Display_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Display_1.BackgroundTransparency = 1
	Display_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Display_1.BorderSizePixel = 0
	Display_1.Position = UDim2.new(0.404671431, 6, 0.153380796, 11)
	Display_1.Size = UDim2.new(0, 122, 0, 23)
	Display_1.FontFace = Gui.Fonts.SemiBoldInter
	Display_1.Text = "Severity_svc20"
	Display_1.TextColor3 = Color3.fromRGB(255, 255, 255)
	Display_1.TextSize = 15
	Display_1.TextWrapped = true
	Display_1.TextXAlignment = Enum.TextXAlignment.Left

	Username_1.Name = "Username"
	Username_1.Parent = Profile_1
	Username_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Username_1.BackgroundTransparency = 1
	Username_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Username_1.BorderSizePixel = 0
	Username_1.Position = UDim2.new(0.404671431, 6, 0.317017168, 10)
	Username_1.Size = UDim2.new(0, 122, 0, 23)
	Username_1.FontFace = Gui.Fonts.SemiBoldInter
	Username_1.Text = "@tsiuuudy"
	Username_1.TextColor3 = Color3.fromRGB(127, 127, 127)
	Username_1.TextSize = 13
	Username_1.TextWrapped = true
	Username_1.TextXAlignment = Enum.TextXAlignment.Left

	Spline.Name = "Spline"
	Spline.Parent = Main_1
	Spline.AnchorPoint = Vector2.new(0, 0.5)
	Spline.BackgroundColor3 = Color3.fromRGB(53, 56, 67)
	Spline.BackgroundTransparency = 0
	Spline.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Spline.BorderSizePixel = 0
	Spline.Position = UDim2.new(0, 0, 0.5, 0)
	Spline.Size = UDim2.new(0, 5, 0, 244)

	UICorner_1a.Parent = Spline
	UICorner_1a.CornerRadius = UDim.new(1, 0)

	local MinimizeKeybind = Index.MinimizeKeybind or Enum.KeyCode.RightControl
	local IsMinimized = Gui.IsMinimized

	local SplineButton = Functions.AttachButton(Spline, 0.9, 0.3)
	local OutsideButton = Functions.AttachButton(Overlay, 1, 0, 0)
	local IsOverlayed = false

	Library:CreateNotification({
		Title = "Starfall",
		Content = "Press " .. string.upper(MinimizeKeybind.Name) .. " to toggle the Interface",
		Duration = 4,
	})

	MinimizeButton_1.MouseButton1Click:Connect(function()
		IsMinimized = not IsMinimized

		if not IsMinimized then
			Library:CreateNotification({
				Title = "Starfall",
				Content = "Press " .. MinimizeKeybind.Name .. " to toggle the Interface",
				Duration = 4,
			})

			Main_1.Visible = IsMinimized
		end
	end)

	Services.UserInputService.InputBegan:Connect(function(Input, GPE)
		if Input.KeyCode == MinimizeKeybind and not GPE then
			IsMinimized = not IsMinimized
			Main_1.Visible = IsMinimized

			Library:CreateNotification({
				Title = "Starfall",
				Content = "Press " .. MinimizeKeybind.Name .. " to toggle the Interface",
				Duration = 4,
			})
		end
	end)

	for _, v in pairs(ActionBar_1:GetChildren()) do
		if v:IsA("ImageButton") then
			v.MouseEnter:Connect(function()
				Tween(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageColor3 = Color3.fromRGB(225, 225, 225),
				})

				if v.Name == "XFullscreen" then
					Tween(
						v:FindFirstChild("Square"):FindFirstChild("UIStroke"),
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Color = Color3.fromRGB(225, 225, 225),
						}
					)
				end
			end)
			v.MouseLeave:Connect(function()
				Tween(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageColor3 = Color3.fromRGB(154, 154, 154),
				})

				if v.Name == "XFullscreen" then
					Tween(
						v:FindFirstChild("Square"):FindFirstChild("UIStroke"),
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Color = Color3.fromRGB(154, 154, 154),
						}
					)
				end
			end)
		end
	end

	SplineButton.MouseButton1Click:Connect(function()
		IsOverlayed = not IsOverlayed

		if IsOverlayed then
			Overlay.Visible = true

			Tween(
				Spline,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = UDim2.new(0, 5, 0, 150), Position = UDim2.new(0.314, 0, 0.5, 0) }
			)

			Tween(
				Overlay,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 0.5 }
			)

			Tween(
				Sidebar_1,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 0.07 }
			)

			Tween(
				Profile_1,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 0.07 }
			)

			Tween(
				ScreenShot_1,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 0.95 }
			)

			for _, v in pairs(Sidebar_1:GetChildren()) do
				if v:IsA("Frame") then
					Tween(
						v,
						TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundTransparency = 0 }
					)
				end
			end

			for _, v in pairs(Overlay:GetDescendants()) do
				if v:IsA("TextLabel") then
					Tween(
						v,
						TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ TextTransparency = 0 }
					)
				elseif v:IsA("ImageLabel") then
					Tween(
						v,
						TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ ImageTransparency = 0 }
					)
				elseif v:IsA("UIStroke") then
					Tween(v, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0 })
				end
			end
		else
			Tween(
				Spline,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = UDim2.new(0, 5, 0, 244), Position = UDim2.new(0, 0, 0.5, 0) }
			)

			Tween(
				Overlay,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 1 }
			)

			Tween(
				Sidebar_1,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 1 }
			)

			Tween(
				Profile_1,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 1 }
			)

			Tween(
				ScreenShot_1,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 1 }
			)

			for _, v in pairs(Sidebar_1:GetChildren()) do
				if v:IsA("Frame") then
					Tween(
						v,
						TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundTransparency = 1 }
					)
				end
			end

			for _, v in pairs(Overlay:GetDescendants()) do
				if v:IsA("TextLabel") then
					Tween(
						v,
						TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ TextTransparency = 1 }
					)
				elseif v:IsA("ImageLabel") then
					Tween(
						v,
						TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ ImageTransparency = 1 }
					)
				elseif v:IsA("UIStroke") then
					Tween(v, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 })
				end
			end

			coroutine.wrap(function()
				task.wait(0.35)
				Overlay.Visible = false
			end)()
		end
	end)

	OutsideButton.MouseButton1Click:Connect(function()
		Tween(
			Spline,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 5, 0, 244), Position = UDim2.new(0, 0, 0.5, 0) }
		)

		Tween(
			Overlay,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		)

		Tween(
			Sidebar_1,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		)

		Tween(
			Profile_1,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		)

		Tween(
			ScreenShot_1,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 1 }
		)

		for _, v in pairs(Sidebar_1:GetChildren()) do
			if v:IsA("Frame") then
				Tween(
					v,
					TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ BackgroundTransparency = 1 }
				)
			end
		end

		for _, v in pairs(Overlay:GetDescendants()) do
			if v:IsA("TextLabel") then
				Tween(v, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 })
			elseif v:IsA("ImageLabel") then
				Tween(
					v,
					TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ImageTransparency = 1 }
				)
			elseif v:IsA("UIStroke") then
				Tween(v, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 })
			end
		end

		coroutine.wrap(function()
			task.wait(0.35)
			Overlay.Visible = false
		end)()
	end)

	--// Init overlay
	Tween(
		Spline,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.new(0, 5, 0, 244), Position = UDim2.new(0, 0, 0.5, 0) }
	)

	Tween(Overlay, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })

	Tween(
		Sidebar_1,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	)

	Tween(
		Profile_1,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	)

	Tween(
		ScreenShot_1,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	)

	for _, v in pairs(Sidebar_1:GetChildren()) do
		if v:IsA("Frame") then
			Tween(
				v,
				TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 1 }
			)
		end
	end

	for _, v in pairs(Overlay:GetDescendants()) do
		if v:IsA("TextLabel") then
			Tween(v, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 })
		elseif v:IsA("ImageLabel") then
			Tween(v, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 1 })
		elseif v:IsA("UIStroke") then
			Tween(v, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 })
		end
	end

	function Setup:CreateTab(TabIndex)
		local ElementSetup = {}

		local Selected = nil

		local ElementContainer_1 = Instance.new("Frame")
		local Tab_2 = Instance.new("Frame")
		local Icon_2 = Instance.new("ImageLabel")
		local Title_2 = Instance.new("TextLabel")
		local ScrollBar_1 = Instance.new("ScrollingFrame")
		local UIListLayout_3 = Instance.new("UIListLayout")
		local Colorpicker_1 = Instance.new("Frame")
		local UICorner_29 = Instance.new("UICorner")
		local UIGradient_7 = Instance.new("UIGradient")
		local ColorpickerTitle_1 = Instance.new("TextLabel")
		local Description_7 = Instance.new("TextLabel")
		local ColorBox_1 = Instance.new("Frame")
		local UICorner_30 = Instance.new("UICorner")
		local Overlay_1 = Instance.new("Frame")
		local UIGradient_8 = Instance.new("UIGradient")
		local UICorner_4d = Instance.new("UICorner")
		local UIGradient_2d = Instance.new("UIGradient")

		ElementContainer_1.Name = TabIndex.Name or TabIndex.Title or "Container"
		ElementContainer_1.Parent = Container_1
		ElementContainer_1.AnchorPoint = Vector2.new(0.5, 0)
		ElementContainer_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ElementContainer_1.BackgroundTransparency = 1
		ElementContainer_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ElementContainer_1.BorderSizePixel = 0
		ElementContainer_1.Position = UDim2.new(0.5, 0, 0, 0)
		ElementContainer_1.Size = UDim2.new(0, 731, 0, 390)
		ElementContainer_1.Visible = false

		Tab_2.Name = "Tab"
		Tab_2.Parent = Sidebar_1
		Tab_2.BackgroundColor3 = Color3.fromRGB(36, 40, 47)
		Tab_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Tab_2.BorderSizePixel = 0
		Tab_2.Position = UDim2.new(-0.169603527, 0, 0, 0)
		Tab_2.Size = UDim2.new(0, 202, 0, 39)

		UICorner_4d.Parent = Tab_2
		UICorner_4d.CornerRadius = UDim.new(0, 12)

		UIGradient_2d.Parent = Tab_2
		UIGradient_2d.Rotation = 90
		UIGradient_2d.Transparency =
			NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.216606) })

		Icon_2.Name = "TabIcon"
		Icon_2.Parent = Tab_2
		Icon_2.AnchorPoint = Vector2.new(0, 0.5)
		Icon_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Icon_2.BackgroundTransparency = 1
		Icon_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Icon_2.BorderSizePixel = 0
		Icon_2.Position = UDim2.new(0.0410000011, 0, 0.5, 0)
		Icon_2.Size = UDim2.new(0, 23, 0, 23)
		Icon_2.Image = TabIndex.Icon or "rbxassetid://10709781824"
		Icon_2.ImageColor3 = Color3.fromRGB(93, 104, 122)

		Title_2.Name = "TabTitle"
		Title_2.Parent = Tab_2
		Title_2.AnchorPoint = Vector2.new(0, 0.5)
		Title_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Title_2.BackgroundTransparency = 1
		Title_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title_2.BorderSizePixel = 0
		Title_2.Position = UDim2.new(0.185382798, 0, 0.5, 0)
		Title_2.Size = UDim2.new(0, 127, 0, 23)
		Title_2.FontFace = Gui.Fonts.SemiBoldInter
		Title_2.Text = TabIndex.Name or TabIndex.Title or "Container"
		Title_2.TextColor3 = Color3.fromRGB(93, 104, 122)
		Title_2.TextSize = 13
		Title_2.TextXAlignment = Enum.TextXAlignment.Left

		ScrollBar_1.Name = "ScrollBar"
		ScrollBar_1.Parent = ElementContainer_1
		ScrollBar_1.Active = true
		ScrollBar_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ScrollBar_1.BackgroundTransparency = 1
		ScrollBar_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ScrollBar_1.BorderSizePixel = 0
		ScrollBar_1.Position = UDim2.new(0, 0, 0, 0)
		ScrollBar_1.Size = UDim2.new(1, 0, 1, 0)
		ScrollBar_1.ClipsDescendants = true
		ScrollBar_1.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ScrollBar_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
		ScrollBar_1.CanvasPosition = Vector2.new(0, 0)
		ScrollBar_1.CanvasSize = UDim2.new(0, 0, 0, 0)
		ScrollBar_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		ScrollBar_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		ScrollBar_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		ScrollBar_1.ScrollBarImageColor3 = Color3.fromRGB(85, 95, 112)
		ScrollBar_1.ScrollBarImageTransparency = 0
		ScrollBar_1.ScrollBarThickness = 0
		ScrollBar_1.ScrollingDirection = Enum.ScrollingDirection.XY
		ScrollBar_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
		ScrollBar_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
		ScrollBar_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

		for _, v in pairs(ScrollBar_1:GetChildren()) do
			if v:IsA("Frame") then
				v.MouseEnter:Connect(function()
					Tween(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundColor3 = Color3.fromRGB(28, 30, 36),
					})
				end)

				v.MouseLeave:Connect(function()
					Tween(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundColor3 = Color3.fromRGB(24, 26, 31),
					})
				end)
			end
		end

		ScrollBar_1.ChildAdded:Connect(function()
			for _, v in pairs(ScrollBar_1:GetChildren()) do
				if v:IsA("Frame") then
					if Env.IsInStarfall then
						if Shared.EXECUTOR ~= nil and not Shared.EXECUTOR:find("Velocity") then
							Library:AnimateButton(v, 1)
						end
					else
						Library:AnimateButton(v, 1)
					end

					v.MouseEnter:Connect(function()
						Tween(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							BackgroundColor3 = Color3.fromRGB(28, 30, 36),
						})
					end)

					v.MouseLeave:Connect(function()
						Tween(v, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							BackgroundColor3 = Color3.fromRGB(24, 26, 31),
						})
					end)
				end
			end
		end)

		UIListLayout_3.Parent = ScrollBar_1
		UIListLayout_3.Padding = UDim.new(0, 3)
		UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center

		local TabButton = Functions.AttachButton(Tab_2, 0.2)
		Library:AnimateButton(Tab_2, 2)

		local Boolean = Instance.new("BoolValue")
		Boolean.Name = "Selected"
		Boolean.Parent = Tab_2
		Boolean.Value = false

		local AssignedContainer = Instance.new("ObjectValue")
		AssignedContainer.Name = "AssignedContainer"
		AssignedContainer.Parent = Tab_2
		AssignedContainer.Value = ElementContainer_1

		local Lucide = nil
		if Env.IsInStudio then
			Lucide = require(Services.ReplicatedStorage:WaitForChild("Api").Lucide)
		else
			Lucide = loadstring(
				game:HttpGet(
					"https://raw.githubusercontent.com/Severity-svc/Ventures/refs/heads/main/Gui/NewGuiLibrary/Lucide%20Icons.lua"
				)
			)()
		end

		if not TabIndex.Icon:find("rbxassetid") and Lucide then
			Icon_2.Image = Functions.GetIconFromLucide(Lucide, TabIndex.Icon)
		end

		local function GetFirstTab()
			for _, v in ipairs(Sidebar_1:GetChildren()) do
				if v:IsA("Frame") then
					return v
				end
			end

			return nil
		end

		if not GetFirstTab() then
			repeat
				task.wait()
			until GetFirstTab()
		end

		if not Selected then
			Selected = GetFirstTab()
			Selected:FindFirstChild("Selected").Value = true
			Selected:FindFirstChild("AssignedContainer").Value.Visible = true

			Tween(Selected, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(53, 60, 70),
			})

			Tween(
				Selected:FindFirstChild("TabTitle"),
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					TextColor3 = Color3.fromRGB(148, 165, 195),
				}
			)

			Tween(
				Selected:FindFirstChild("TabIcon"),
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					ImageColor3 = Color3.fromRGB(148, 165, 195),
				}
			)
		end

		for _, v in ipairs(Sidebar_1:GetChildren()) do
			if v:IsA("Frame") then
				local Button = v:FindFirstChild("ClickableButton")
				local Debounce = false

				if Button then
					Button.MouseButton1Click:Connect(function()
						if Debounce then
							return
						end
						Debounce = true

						if Button.Parent:FindFirstChild("Selected").Value == false then
							Selected:FindFirstChild("Selected").Value = false
							Selected:FindFirstChild("AssignedContainer").Value.Visible = false

							Tween(Selected, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								BackgroundColor3 = Color3.fromRGB(30, 33, 39),
							})

							Tween(
								Selected:FindFirstChild("TabTitle"),
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TextColor3 = Color3.fromRGB(93, 104, 122),
								}
							)

							Tween(
								Selected:FindFirstChild("TabIcon"),
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									ImageColor3 = Color3.fromRGB(93, 104, 122),
								}
							)

							Selected = Button.Parent
							Selected:FindFirstChild("Selected").Value = true
							Selected:FindFirstChild("AssignedContainer").Value.Visible = true

							Tween(Selected, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								BackgroundColor3 = Color3.fromRGB(53, 60, 70),
							})

							Tween(
								Selected:FindFirstChild("TabTitle"),
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TextColor3 = Color3.fromRGB(148, 165, 195),
								}
							)

							Tween(
								Selected:FindFirstChild("TabIcon"),
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									ImageColor3 = Color3.fromRGB(148, 165, 195),
								}
							)
						end
						task.wait(0.2)
						Debounce = false
					end)
				end
			end
		end

		--// Elements

		function ElementSetup:CreateToggle(ToggleIndex)
			local Actions = {}

			local Toggle_1 = Instance.new("Frame")
			local UICorner_13 = Instance.new("UICorner")
			local UIGradient_3 = Instance.new("UIGradient")
			local ToggleTitle_1 = Instance.new("TextLabel")
			local Handler_3 = Instance.new("Frame")
			local Dot_2 = Instance.new("Frame")
			local UICorner_14 = Instance.new("UICorner")
			local UICorner_15 = Instance.new("UICorner")
			local Description_3 = Instance.new("TextLabel")
			local Key = Instance.new("TextLabel")
			local UICorner_1 = Instance.new("UICorner")
			local UIPadding_1 = Instance.new("UIPadding")

			Toggle_1.Name = ToggleIndex.Title or ToggleIndex.Name or "Toggle"
			Toggle_1.Parent = ScrollBar_1
			Toggle_1.BackgroundColor3 = Color3.fromRGB(24, 26, 31)
			Toggle_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Toggle_1.BorderSizePixel = 0
			Toggle_1.Position = UDim2.new(-4.20495887e-08, 0, 0, 0)
			Toggle_1.Size = UDim2.new(0, 725, 0, 69)

			UICorner_13.Parent = Toggle_1
			UICorner_13.CornerRadius = UDim.new(0, 12)

			UIGradient_3.Parent = Toggle_1
			UIGradient_3.Rotation = 90
			UIGradient_3.Transparency =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.216606) })

			ToggleTitle_1.Name = "ToggleTitle"
			ToggleTitle_1.Parent = Toggle_1
			ToggleTitle_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ToggleTitle_1.BackgroundTransparency = 1
			ToggleTitle_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ToggleTitle_1.BorderSizePixel = 0
			ToggleTitle_1.Position = UDim2.new(0.0158620682, 0, 0.0942028984, 0)
			ToggleTitle_1.Size = UDim2.new(0, 240, 0, 23)
			ToggleTitle_1.FontFace = Gui.Fonts.SemiBoldInter
			ToggleTitle_1.Text = ToggleIndex.Title or ToggleIndex.Name or "Toggle"
			ToggleTitle_1.TextColor3 = Color3.fromRGB(254, 254, 254)
			ToggleTitle_1.TextSize = 15
			ToggleTitle_1.TextXAlignment = Enum.TextXAlignment.Left

			Handler_3.Name = "Handler"
			Handler_3.Parent = Toggle_1
			Handler_3.BackgroundColor3 = Color3.fromRGB(34, 37, 44)
			Handler_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Handler_3.BorderSizePixel = 0
			Handler_3.Position = UDim2.new(0.895172417, 0, 0.285880715, 0)
			Handler_3.Size = UDim2.new(0, 58, 0, 28)

			Dot_2.Name = "Dot"
			Dot_2.Parent = Handler_3
			Dot_2.AnchorPoint = Vector2.new(0, 0.5)
			Dot_2.BackgroundColor3 = Color3.fromRGB(59, 65, 77)
			Dot_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Dot_2.BorderSizePixel = 0
			Dot_2.Position = UDim2.new(0.127000004, 0, 0.5, 0)
			Dot_2.Size = UDim2.new(0, 19, 0, 19)

			UICorner_14.Parent = Dot_2
			UICorner_14.CornerRadius = UDim.new(1, 0)

			UICorner_15.Parent = Handler_3
			UICorner_15.CornerRadius = UDim.new(1, 0)

			Description_3.Name = "Description"
			Description_3.Parent = Toggle_1
			Description_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Description_3.BackgroundTransparency = 1
			Description_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Description_3.BorderSizePixel = 0
			Description_3.Position = UDim2.new(0.0186206903, 0, 0.427536219, 0)
			Description_3.Size = UDim2.new(0, 535, 0, 29)
			Description_3.FontFace = Gui.Fonts.SemiBoldInter
			Description_3.Text = ToggleIndex.Description or ""
			Description_3.TextColor3 = Color3.fromRGB(176, 176, 176)
			Description_3.TextSize = 14
			Description_3.TextXAlignment = Enum.TextXAlignment.Left
			Description_3.TextYAlignment = Enum.TextYAlignment.Top

			Key.Name = "Key"
			Key.Parent = Toggle_1
			Key.AnchorPoint = Vector2.new(0.879999995, 0.5)
			Key.BackgroundColor3 = Color3.fromRGB(34, 37, 44)
			Key.BackgroundTransparency = 1
			Key.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Key.BorderSizePixel = 0
			Key.Position = UDim2.new(0.870000005, 0, 0.5, 0)
			Key.Size = UDim2.new(0, 0, 0, 25)
			Key.FontFace = Gui.Fonts.SemiBoldInter
			Key.Text = ". . ."
			Key.TextColor3 = Color3.fromRGB(176, 176, 176)
			Key.TextSize = 13
			Key.TextTransparency = 1
			Key.TextXAlignment = Enum.TextXAlignment.Center
			Key.ZIndex = 2

			UICorner_1.Parent = Key

			local ToggleButton = Functions.AttachButton(Toggle_1, 0.2)
			local KeybindButton = Functions.AttachButton(Key, 0.2, 0, 2)

			local Callback = ToggleIndex.Callback or nil
			local Default = ToggleIndex.Default or false
			local Boolean = Default or false
			local Debounce = false

			local AssignedKeybind = nil
			local IsSelecting = false

			local Flag = Instance.new("StringValue")
			Flag.Name = "Flag"
			Flag.Parent = Toggle_1
			Flag.Value = ToggleIndex.Flag or "nil"

			local SaveValue = Instance.new("BoolValue")
			SaveValue.Parent = Toggle_1
			SaveValue.Value = Boolean

			if type(Callback) ~= "function" then
				warn(
					"[Starfall]: Callback for Toggle is not a function. /n [Toggle]: ",
					ToggleIndex.Name or ToggleIndex.Title
				)
				return
			end

			if Default then
				SaveValue.Value = Boolean
				Callback(Boolean)

				if Default == true then
					Tween(
						Handler_3,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(49, 53, 63) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(89, 98, 116) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Position = UDim2.new(0.57, 0, 0.5, 0) }
					)
				else
					Tween(
						Handler_3,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(34, 37, 44) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(59, 65, 77) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Position = UDim2.new(0.127, 0, 0.5, 0) }
					)
				end
			end

			SaveValue.Changed:Connect(function(Value)
				if not File.ToLoad then
					return
				end

				Boolean = Value

				local Success, Error = pcall(function()
					Callback(Boolean)
				end)

				if not Success then
					error("[Starfall]: Error: " .. Error .. " at Toggle: " .. ToggleIndex.Name or ToggleIndex.Title)
				end

				if Boolean then
					Tween(
						Handler_3,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(49, 53, 63) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(89, 98, 116) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Position = UDim2.new(0.57, 0, 0.5, 0) }
					)
				else
					Tween(
						Handler_3,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(34, 37, 44) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(59, 65, 77) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Position = UDim2.new(0.127, 0, 0.5, 0) }
					)
				end
			end)

			ToggleButton.MouseButton1Click:Connect(function()
				Boolean = not Boolean
				SaveValue.Value = Boolean

				local Success, Error = pcall(function()
					Callback(Boolean)
				end)

				if not Success then
					error("[Starfall]: Error: " .. Error .. "/n at Toggle: " .. ToggleIndex.Name or ToggleIndex.Title)
				end

				if Boolean then
					Tween(
						Handler_3,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(49, 53, 63) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(89, 98, 116) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Position = UDim2.new(0.57, 0, 0.5, 0) }
					)
				else
					Tween(
						Handler_3,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(34, 37, 44) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(59, 65, 77) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Position = UDim2.new(0.127, 0, 0.5, 0) }
					)
				end
			end)

			--// Keybinding
			Key:GetPropertyChangedSignal("Text"):Connect(function()
				local TextSize = Key.TextBounds.X
				Tween(Key, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, TextSize + 16, 0, 25),
				})
			end)

			local TextSize = Key.TextBounds.X
			Tween(Key, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, TextSize + 16, 0, 25),
			})

			Toggle_1.MouseEnter:Connect(function()
				Tween(Key, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0,
					TextTransparency = 0,
				})
			end)

			KeybindButton.MouseButton1Click:Connect(function()
				Key.Text = "Press any key..."
				IsSelecting = true
			end)

			Services.UserInputService.InputBegan:Connect(function(input, procesed)
				if IsSelecting and not procesed then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						AssignedKeybind = input.KeyCode
						Key.Text = string.upper(input.KeyCode.Name)
					elseif
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.MouseButton2
					then
						AssignedKeybind = input.UserInputType
						Key.Text = string.upper(input.UserInputType.Name)
					end
					IsSelecting = false
				elseif input.KeyCode == AssignedKeybind and not IsSelecting then
					local Success, Error = pcall(function()
						Boolean = not Boolean
						SaveValue.Value = Boolean

						Callback(Boolean)

						if Boolean then
							Library:CreateNotification({
								Title = "Starfall | Keybind",
								Content = ToggleTitle_1.Text
									.. ' Has been set to <font color="rgb(60, 243, 54)">True</font>',
								UseBoldContent = true,
								Duration = 3.5,
							})

							Tween(
								Handler_3,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ BackgroundColor3 = Color3.fromRGB(49, 53, 63) }
							)
							Tween(
								Dot_2,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ BackgroundColor3 = Color3.fromRGB(89, 98, 116) }
							)
							Tween(
								Dot_2,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ Position = UDim2.new(0.57, 0, 0.5, 0) }
							)
						else
							Library:CreateNotification({
								Title = "Starfall | Keybind",
								Content = ToggleTitle_1.Text
									.. ' Has been set to <font color="rgb(235, 74, 74)">False</font>',
								UseBoldContent = true,
								Duration = 3.5,
							})

							Tween(
								Handler_3,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ BackgroundColor3 = Color3.fromRGB(34, 37, 44) }
							)
							Tween(
								Dot_2,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ BackgroundColor3 = Color3.fromRGB(59, 65, 77) }
							)
							Tween(
								Dot_2,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ Position = UDim2.new(0.127, 0, 0.5, 0) }
							)
						end
					end)

					if not Success then
						warn("[Starfall]: Toggle Keybind failed: " .. Error)
					end
				elseif input.UserInputType == AssignedKeybind and not IsSelecting then
					local Success, Error = pcall(function()
						Boolean = not Boolean
						SaveValue.Value = Boolean

						Callback(Boolean)

						if Boolean then
							Library:CreateNotification({
								Title = "Starfall | Keybind",
								Content = ToggleTitle_1.Text
									.. ' Has been set to <font color="rgb(60, 243, 54)">True</font>',
								UseBoldContent = true,
								Duration = 3.5,
							})

							Tween(
								Handler_3,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ BackgroundColor3 = Color3.fromRGB(49, 53, 63) }
							)
							Tween(
								Dot_2,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ BackgroundColor3 = Color3.fromRGB(89, 98, 116) }
							)
							Tween(
								Dot_2,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ Position = UDim2.new(0.57, 0, 0.5, 0) }
							)
						else
							Library:CreateNotification({
								Title = "Starfall | Keybind",
								Content = ToggleTitle_1.Text
									.. ' Has been set to <font color="rgb(235, 74, 74)">False</font>',
								UseBoldContent = true,
								Duration = 3.5,
							})
							Tween(
								Handler_3,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ BackgroundColor3 = Color3.fromRGB(34, 37, 44) }
							)
							Tween(
								Dot_2,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ BackgroundColor3 = Color3.fromRGB(59, 65, 77) }
							)
							Tween(
								Dot_2,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ Position = UDim2.new(0.127, 0, 0.5, 0) }
							)
						end
					end)

					if not Success then
						warn("[Starfall]: Toggle Keybind failed:  " .. Error)
					end
				end
			end)

			Toggle_1.MouseLeave:Connect(function()
				Tween(Key, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 1,
					TextTransparency = 1,
				})
			end)

			--// Actions
			function Actions:SetValue(Bool)
				if type(Bool) ~= "boolean" then
					warn(
						"[Starfall]: SetValue failed, Parameter is not a boolean /n Toggle: " .. ToggleIndex.Name
							or ToggleIndex.Title
							or "unamed toggle"
					)
					return
				end

				local Success, Error = pcall(function()
					Callback(Bool)
				end)

				if not Success then
					error("[Starfall]: Error: " .. Error .. "/n at Toggle: " .. ToggleIndex.Name or ToggleIndex.Title)
				end

				Boolean = Bool
				SaveValue.Value = Boolean

				if Bool then
					Tween(
						Handler_3,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(49, 53, 63) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(89, 98, 116) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Position = UDim2.new(0.57, 0, 0.5, 0) }
					)
				else
					Tween(
						Handler_3,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(34, 37, 44) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(59, 65, 77) }
					)
					Tween(
						Dot_2,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Position = UDim2.new(0.127, 0, 0.5, 0) }
					)
				end
			end

			return Actions
		end

		function ElementSetup:CreateSlider(SliderIndex)
			local Actions = {}

			local Slider_1 = Instance.new("Frame")
			local UICorner_16 = Instance.new("UICorner")
			local UIGradient_4 = Instance.new("UIGradient")
			local SliderTitle_1 = Instance.new("TextLabel")
			local Description_4 = Instance.new("TextLabel")
			local Handler_4 = Instance.new("Frame")
			local UICorner_17 = Instance.new("UICorner")
			local Percent_1 = Instance.new("Frame")
			local Frame_1 = Instance.new("Frame")
			local UICorner_18 = Instance.new("UICorner")
			local UICorner_19 = Instance.new("UICorner")
			local Value_1 = Instance.new("TextLabel")

			Slider_1.Name = SliderIndex.Title or SliderIndex.Name or "Slider"
			Slider_1.Parent = ScrollBar_1
			Slider_1.BackgroundColor3 = Color3.fromRGB(24, 26, 31)
			Slider_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Slider_1.BorderSizePixel = 0
			Slider_1.Position = UDim2.new(-4.20495887e-08, 0, 0, 0)
			Slider_1.Size = UDim2.new(0, 725, 0, 69)

			UICorner_16.Parent = Slider_1
			UICorner_16.CornerRadius = UDim.new(0, 12)

			UIGradient_4.Parent = Slider_1
			UIGradient_4.Rotation = 90
			UIGradient_4.Transparency =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.216606) })

			SliderTitle_1.Name = "SliderTitle"
			SliderTitle_1.Parent = Slider_1
			SliderTitle_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SliderTitle_1.BackgroundTransparency = 1
			SliderTitle_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			SliderTitle_1.BorderSizePixel = 0
			SliderTitle_1.Position = UDim2.new(0.0158620682, 0, 0.0942028984, 0)
			SliderTitle_1.Size = UDim2.new(0, 240, 0, 23)
			SliderTitle_1.FontFace = Gui.Fonts.SemiBoldInter
			SliderTitle_1.Text = SliderIndex.Title or SliderIndex.Name or "Slider"
			SliderTitle_1.TextColor3 = Color3.fromRGB(254, 254, 254)
			SliderTitle_1.TextSize = 15
			SliderTitle_1.TextXAlignment = Enum.TextXAlignment.Left

			Description_4.Name = "Description"
			Description_4.Parent = Slider_1
			Description_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Description_4.BackgroundTransparency = 1
			Description_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Description_4.BorderSizePixel = 0
			Description_4.Position = UDim2.new(0.0186206903, 0, 0.427536219, 0)
			Description_4.Size = UDim2.new(0, 535, 0, 29)
			Description_4.FontFace = Gui.Fonts.SemiBoldInter
			Description_4.Text = SliderIndex.Description or ""
			Description_4.TextColor3 = Color3.fromRGB(176, 176, 176)
			Description_4.TextSize = 14
			Description_4.TextXAlignment = Enum.TextXAlignment.Left
			Description_4.TextYAlignment = Enum.TextYAlignment.Top

			Handler_4.Name = "Handler"
			Handler_4.Parent = Slider_1
			Handler_4.AnchorPoint = Vector2.new(0, 0.5)
			Handler_4.BackgroundColor3 = Color3.fromRGB(34, 37, 44)
			Handler_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Handler_4.BorderSizePixel = 0
			Handler_4.Position = UDim2.new(0.721000016, 0, 0.5, 0)
			Handler_4.Size = UDim2.new(0, 165, 0, 3)

			UICorner_17.Parent = Handler_4
			UICorner_17.CornerRadius = UDim.new(1, 0)

			Percent_1.Name = "Percent"
			Percent_1.Parent = Handler_4
			Percent_1.BackgroundColor3 = Color3.fromRGB(56, 61, 72)
			Percent_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Percent_1.BorderSizePixel = 0
			Percent_1.Size = UDim2.new(0.600000024, 0, 1, 0)

			Frame_1.Parent = Percent_1
			Frame_1.AnchorPoint = Vector2.new(0, 0.5)
			Frame_1.BackgroundColor3 = Color3.fromRGB(56, 61, 72)
			Frame_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Frame_1.BorderSizePixel = 0
			Frame_1.Position = UDim2.new(1, 0, 0.5, 0)
			Frame_1.Size = UDim2.new(0, 9, 0, 9)

			UICorner_18.Parent = Frame_1
			UICorner_18.CornerRadius = UDim.new(1, 0)

			UICorner_19.Parent = Percent_1
			UICorner_19.CornerRadius = UDim.new(1, 0)

			Value_1.Name = "Value"
			Value_1.Parent = Slider_1
			Value_1.AnchorPoint = Vector2.new(0, 0.5)
			Value_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Value_1.BackgroundTransparency = 1
			Value_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Value_1.BorderSizePixel = 0
			Value_1.Position = UDim2.new(0.967000008, 0, 0.5, 0)
			Value_1.Size = UDim2.new(0, 19, 0, 23)
			Value_1.FontFace = Gui.Fonts.SemiBoldInter
			Value_1.Text = ""
			Value_1.TextColor3 = Color3.fromRGB(161, 161, 161)
			Value_1.TextSize = 13
			Value_1.TextXAlignment = Enum.TextXAlignment.Left

			local Callback = SliderIndex.Callback or nil
			local Default = SliderIndex.Default or nil
			local Value = Default or nil
			local IsDragging = false

			local MinValue = SliderIndex.MinValue or SliderIndex.MinimumValue or 0
			local MaxValue = SliderIndex.MaxValue or SliderIndex.MaximumValue or 100
			local Increment = SliderIndex.Increment or 1

			local SliderButton = Functions.AttachButton(Handler_4, 0.2)

			local Flag = Instance.new("StringValue")
			Flag.Parent = Slider_1
			Flag.Name = "Flag"
			Flag.Value = SliderIndex.Flag or "nil"

			local SaveValue = Instance.new("NumberValue")
			SaveValue.Parent = Slider_1
			SaveValue.Value = Value

			if Default ~= nil then
				local PercentValue = (Default - MinValue) / (MaxValue - MinValue)
				Percent_1.Size = UDim2.new(PercentValue, 0, 1, 0)
				Frame_1.Position = UDim2.new(1, 0, 0.5, 0)
				Value_1.Text = tostring(Default)

				SaveValue.Value = tonumber(Value_1.Text)

				if type(Callback) == "function" then
					local Success, Error = pcall(function()
						Callback(Default)
					end)
					if not Success then
						error(
							"[Starfall]: Failed to callback at slider: " .. SliderIndex.Title
								or SliderIndex.Name
								or "unammed slider" .. " /n With Error: " .. Error
						)
					end
				elseif MinValue ~= nil then
					Percent_1.Size = UDim2.new(0, 0, 1, 0)
					Frame_1.Position = UDim2.new(1, 0, 0.5, 0)
					Value_1.Text = tostring(MinValue)

					SaveValue.Value = tonumber(Value_1.Text)

					if type(Callback) == "function" then
						local Success, Error = pcall(function()
							Callback(MinValue)
						end)
						if not Success then
							error(
								"[Starfall]: Failed to callback at slider: " .. SliderIndex.Title
									or SliderIndex.Name
									or "unammed slider" .. " /n With Error: " .. Error
							)
						end
					end
				end
			end

			SaveValue.Changed:Connect(function(Value2)
				if not File.ToLoad then
					return
				end
				Value = Value2

				local PercentValue = (Default - MinValue) / (MaxValue - MinValue)
				Percent_1.Size = UDim2.new(PercentValue, 0, 1, 0)
				Frame_1.Position = UDim2.new(1, 0, 0.5, 0)
				Value_1.Text = tostring(Default)

				if type(Callback) == "function" then
					local Success, Error = pcall(function()
						Callback(Default)
					end)
					if not Success then
						error(
							"[Starfall]: Failed to callback at slider: " .. SliderIndex.Title
								or SliderIndex.Name
								or "unammed slider" .. " /n With Error: " .. Error
						)
					end
				end
			end)

			SliderButton.MouseButton1Down:Connect(function()
				IsDragging = true
			end)

			Services.UserInputService.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					IsDragging = false
				end
			end)

			Services.RunService.Heartbeat:Connect(function()
				if IsDragging then
					local Position = Services.UserInputService:GetMouseLocation().X
					local AbsolutePosition = Handler_4.AbsolutePosition.X
					local AbsoluteSize = Handler_4.AbsoluteSize.X
					local PercentValue = math.clamp((Position - AbsolutePosition) / AbsoluteSize, 0, 1)

					Value = math.floor(((MinValue + ((MaxValue - MinValue) * PercentValue)) / Increment) + 0.5)
						* Increment
					Value_1.Text = string.format("%." .. tostring(math.log10(1 / Increment)) .. "f", Value)

					SaveValue.Value = Value

					Tween(
						Frame_1,
						TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ Position = UDim2.new(1, 0, 0.5, 0) }
					)
					Tween(
						Percent_1,
						TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{ Size = UDim2.new(PercentValue, 0, 1, 0) }
					)

					if type(Callback) == "function" then
						local Success, Error = pcall(function()
							Callback(Value)
						end)
						if not Success then
							error(Error)
						end
					end
				end
			end)

			--// TODO: add setvalue for sliders
			return Actions
		end

		function ElementSetup:CreateDropdown(DropdownIndex)
			local Actions = {}

			local Dropdown_1 = Instance.new("Frame")
			local UICorner_22 = Instance.new("UICorner")
			local UIGradient_6 = Instance.new("UIGradient")
			local DropdownTitle_1 = Instance.new("TextLabel")
			local Description_6 = Instance.new("TextLabel")
			local Handler_6 = Instance.new("Frame")
			local UICorner_23 = Instance.new("UICorner")
			local UIStroke_4 = Instance.new("UIStroke")
			local Holder_1 = Instance.new("Frame")
			local Value_2 = Instance.new("TextLabel")
			local UIPadding_3 = Instance.new("UIPadding")
			local Icon_1 = Instance.new("ImageLabel")
			local UIPadding_4 = Instance.new("UIPadding")
			local ValuesHolder_1 = Instance.new("Frame")
			local UICorner_24 = Instance.new("UICorner")
			local UIListLayout_4 = Instance.new("UIListLayout")

			Dropdown_1.Name = "Dropdown"
			Dropdown_1.Parent = ScrollBar_1
			Dropdown_1.BackgroundColor3 = Color3.fromRGB(24, 26, 31)
			Dropdown_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Dropdown_1.BorderSizePixel = 0
			Dropdown_1.Position = UDim2.new(-4.20495887e-08, 0, 0, 0)
			Dropdown_1.Size = UDim2.new(0, 725, 0, 69)
			Dropdown_1.ZIndex = 1

			UICorner_22.Parent = Dropdown_1
			UICorner_22.CornerRadius = UDim.new(0, 12)

			UIGradient_6.Parent = Dropdown_1
			UIGradient_6.Rotation = 90
			UIGradient_6.Transparency =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.216606) })

			DropdownTitle_1.Name = "DropdownTitle"
			DropdownTitle_1.Parent = Dropdown_1
			DropdownTitle_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			DropdownTitle_1.BackgroundTransparency = 1
			DropdownTitle_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			DropdownTitle_1.BorderSizePixel = 0
			DropdownTitle_1.Position = UDim2.new(0.0158620682, 0, 0.0942028984, 0)
			DropdownTitle_1.Size = UDim2.new(0, 240, 0, 23)
			DropdownTitle_1.FontFace = Gui.Fonts.SemiBoldInter
			DropdownTitle_1.Text = DropdownIndex.Title or DropdownIndex.Name or "Dropdown"
			DropdownTitle_1.TextColor3 = Color3.fromRGB(254, 254, 254)
			DropdownTitle_1.TextSize = 15
			DropdownTitle_1.TextXAlignment = Enum.TextXAlignment.Left

			Description_6.Name = "Description"
			Description_6.Parent = Dropdown_1
			Description_6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Description_6.BackgroundTransparency = 1
			Description_6.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Description_6.BorderSizePixel = 0
			Description_6.Position = UDim2.new(0.0186206903, 0, 0.427536219, 0)
			Description_6.Size = UDim2.new(0, 535, 0, 29)
			Description_6.FontFace = Gui.Fonts.SemiBoldInter
			Description_6.Text = DropdownIndex.Description or ""
			Description_6.TextColor3 = Color3.fromRGB(176, 176, 176)
			Description_6.TextSize = 14
			Description_6.TextXAlignment = Enum.TextXAlignment.Left
			Description_6.TextYAlignment = Enum.TextYAlignment.Top

			Handler_6.Name = "Handler"
			Handler_6.Parent = Dropdown_1
			Handler_6.AnchorPoint = Vector2.new(0.970000029, 0.5)
			Handler_6.AutomaticSize = Enum.AutomaticSize.X
			Handler_6.BackgroundColor3 = Color3.fromRGB(34, 37, 44)
			Handler_6.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Handler_6.BorderSizePixel = 0
			Handler_6.Position = UDim2.new(0.970000029, 0, 0.5, 0)
			Handler_6.Size = UDim2.new(0, 0, 0, 30)

			UICorner_23.Parent = Handler_6
			UICorner_23.CornerRadius = UDim.new(0, 10)

			UIStroke_4.Parent = Handler_6
			UIStroke_4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			UIStroke_4.Color = Color3.fromRGB(42, 45, 54)
			UIStroke_4.Thickness = 1.2000000476837158

			Holder_1.Name = "Holder"
			Holder_1.Parent = Handler_6
			Holder_1.AutomaticSize = Enum.AutomaticSize.X
			Holder_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Holder_1.BackgroundTransparency = 1
			Holder_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Holder_1.BorderSizePixel = 0
			Holder_1.Size = UDim2.new(1, 0, 1, 0)

			Value_2.Name = "Value"
			Value_2.Parent = Holder_1
			Value_2.AnchorPoint = Vector2.new(0, 0.5)
			Value_2.AutomaticSize = Enum.AutomaticSize.X
			Value_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Value_2.BackgroundTransparency = 1
			Value_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Value_2.BorderSizePixel = 0
			Value_2.Position = UDim2.new(0.0160030238, 0, 0.5, 0)
			Value_2.Size = UDim2.new(0, 0, 0, 23)
			Value_2.FontFace = Gui.Fonts.SemiBoldInter
			Value_2.Text = "Pro"
			Value_2.TextColor3 = Color3.fromRGB(202, 202, 202)
			Value_2.TextSize = 13

			UIPadding_3.Parent = Value_2
			UIPadding_3.PaddingLeft = UDim.new(0, 4)
			UIPadding_3.PaddingRight = UDim.new(0, 9)

			Icon_1.Name = "Icon"
			Icon_1.Parent = Holder_1
			Icon_1.AnchorPoint = Vector2.new(0, 0.5)
			Icon_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Icon_1.BackgroundTransparency = 1
			Icon_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Icon_1.BorderSizePixel = 0
			Icon_1.Position = UDim2.new(0.855000019, 11, 0.5, 1)
			Icon_1.Size = UDim2.new(0, 20, 0, 20)
			Icon_1.Image = "http://www.roblox.com/asset/?id=11552476728"
			Icon_1.ImageColor3 = Color3.fromRGB(202, 202, 202)

			UIPadding_4.Parent = Holder_1
			UIPadding_4.PaddingRight = UDim.new(0, 20)

			ValuesHolder_1.Name = "ValuesHolder"
			ValuesHolder_1.Parent = Dropdown_1
			ValuesHolder_1.AnchorPoint = Vector2.new(0, 0.5)
			ValuesHolder_1.AutomaticSize = Enum.AutomaticSize.Y
			ValuesHolder_1.BackgroundColor3 = Color3.fromRGB(34, 37, 44)
			ValuesHolder_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ValuesHolder_1.BorderSizePixel = 0
			ValuesHolder_1.Position = UDim2.new(0.734000146, 0, 0.500000119, 0)
			ValuesHolder_1.Size = UDim2.new(0, 187, 0, 96)
			ValuesHolder_1.Visible = false

			UICorner_24.Parent = ValuesHolder_1
			UICorner_24.CornerRadius = UDim.new(0, 10)

			UIListLayout_4.Parent = ValuesHolder_1
			UIListLayout_4.Padding = UDim.new(0, 3)
			UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_4.VerticalAlignment = Enum.VerticalAlignment.Center

			local Values = DropdownIndex.Values or nil
			local Callback = DropdownIndex.Callback or nil
			local Default = DropdownIndex.Default or 1
			local Multi = DropdownIndex.Multi or false

			Actions.Values = Values

			local CurrentValue = nil
			local IsOpened = false

			local DropdownButton = Functions.AttachButton(Handler_6, 0.2)

			local Flag = Instance.new("StringValue")
			Flag.Parent = Dropdown_1
			Flag.Name = "Flag"
			Flag.Value = DropdownIndex.Flag or "nil"

			local SaveValue = Instance.new("StringValue")
			SaveValue.Parent = Dropdown_1
			SaveValue.Value = "nil"

			local function SetBehavior(Value: TextButton, Bool)
				if Bool then
					Tween(
						Value:FindFirstChild("Identifier"),
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundTransparency = 0 }
					)
					Tween(
						Value,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(44, 48, 57) }
					)
				else
					Tween(
						Value:FindFirstChild("Identifier"),
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundTransparency = 1 }
					)
					Tween(
						Value,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ BackgroundColor3 = Color3.fromRGB(38, 41, 49) }
					)
				end
			end

			local function SetupValuesHolder(Bool)
				if Bool then
					for _, v in pairs(Dropdown_1:GetDescendants()) do
						if v:IsA("GuiObject") then
							v.ZIndex = 2
						end
					end

					for _, v in pairs(ValuesHolder_1:GetChildren()) do
						if v:IsA("TextButton") then
							Tween(
								v,
								TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
								{ Size = UDim2.new(1, 0, 0, 45), TextTransparency = 0 }
							)

							ValuesHolder_1.Visible = true
						end
					end
				else
					for _, v in pairs(ValuesHolder_1:GetChildren()) do
						if v:IsA("TextButton") then
							Tween(
								v,
								TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
								{ Size = UDim2.new(1, 0, 0, 0), TextTransparency = 1 }
							)

							coroutine.wrap(function()
								task.wait(0.2)
								ValuesHolder_1.Visible = false
							end)()

							if v ~= CurrentValue then
								Tween(
									v,
									TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{ BackgroundColor3 = Color3.fromRGB(38, 41, 49) }
								)
							end
						end
					end

					for _, v in pairs(Dropdown_1:GetDescendants()) do
						if v:IsA("GuiObject") then
							v.ZIndex = 1
						end
					end
				end
			end

			if not Values then
				warn(
					"[Starfall]: must set a table value at dropdown: " .. DropdownIndex.Title
						or DropdownIndex.Name
						or "Unnamed Dropdown"
				)
			end

			if Multi then
				local Value_3 = Instance.new("TextLabel")
				local UICorner_25 = Instance.new("UICorner")

				Value_3.Name = "Value"
				Value_3.Parent = ValuesHolder_1
				Value_3.Active = true
				Value_3.BackgroundColor3 = Color3.fromRGB(216, 47, 47)
				Value_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Value_3.BorderSizePixel = 0
				Value_3.Size = UDim2.new(1, 0, 0, 35)
				Value_3.FontFace = Gui.Fonts.BoldInter
				Value_3.Text = "Close Dropdown"
				Value_3.TextColor3 = Color3.fromRGB(203, 203, 203)
				Value_3.TextSize = 15

				UICorner_25.Parent = Value_3
				UICorner_25.CornerRadius = UDim.new(0, 10)

				local Button = Functions.AttachButton(Value_3, 0.2)

				Button.MouseButton1Click:Connect(function()
					SetupValuesHolder(false)
				end)
			end

			local SelectedValues = {}

			local function InitDropdown()
				for _, v in pairs(Values) do
					local Value_3 = Instance.new("TextButton")
					local UICorner_25 = Instance.new("UICorner")
					local Identifier_1 = Instance.new("Frame")
					local UICorner_26 = Instance.new("UICorner")

					Value_3.Name = "Value"
					Value_3.Parent = ValuesHolder_1
					Value_3.Active = true
					Value_3.AutoButtonColor = false
					Value_3.BackgroundColor3 = Color3.fromRGB(38, 41, 49)
					Value_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Value_3.BorderSizePixel = 0
					Value_3.Size = UDim2.new(1, 0, 0, 0)
					Value_3.FontFace = Gui.Fonts.SemiBoldInter
					Value_3.Text = tostring(v)
					Value_3.TextColor3 = Color3.fromRGB(203, 203, 203)
					Value_3.TextSize = 14

					UICorner_25.Parent = Value_3
					UICorner_25.CornerRadius = UDim.new(0, 10)

					Identifier_1.Name = "Identifier"
					Identifier_1.Parent = Value_3
					Identifier_1.AnchorPoint = Vector2.new(0, 0.5)
					Identifier_1.BackgroundColor3 = Color3.fromRGB(127, 137, 163)
					Identifier_1.BackgroundTransparency = 1
					Identifier_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Identifier_1.BorderSizePixel = 0
					Identifier_1.Position = UDim2.new(0, 0, 0.5, 0)
					Identifier_1.Size = UDim2.new(0, 6, 0, 24)

					UICorner_26.Parent = Identifier_1
					UICorner_26.CornerRadius = UDim.new(9, 0)

					Value_3.MouseButton1Click:Connect(function()
						if Multi then
							local ValueString = Value_3.Text
							local SelectedAlready = SelectedValues[ValueString]

							if SelectedAlready then
								SetBehavior(Value_3, false)
								SelectedValues[ValueString] = nil
							else
								SetBehavior(Value_3, true)
								SelectedValues[ValueString] = true
							end

							local SelectedKeys = {}
							for v2, _ in pairs(SelectedValues) do
								table.insert(SelectedKeys, v2)
							end
							Value_2.Text = "" .. #SelectedKeys - 1 .. " Selected Value(s)"
							SaveValue.Value = table.concat(SelectedKeys, ",")

							if Callback then
								local Success, Error = pcall(function()
									Callback(SelectedKeys)
								end)

								if not Success then
									warn("[Starfall]: Dropdown callback failed: " .. tostring(Error))
								end
							end
						else
							if CurrentValue and Value_3 ~= CurrentValue then
								SetBehavior(CurrentValue, false)
							end

							CurrentValue = Value_3
							SetBehavior(CurrentValue, true)
							SetupValuesHolder(false)
							Value_2.Text = tostring(Value_3.Text)
							SaveValue.Value = Value_3.Text

							if Callback then
								local Success, Error = pcall(function()
									Callback(Value_3.Text)
								end)

								if not Success then
									warn("[Starfall]: Dropdown callback failed: " .. tostring(Error))
								end
							end
						end
					end)

					Value_3.MouseEnter:Connect(function()
						if Value_3 ~= CurrentValue and not Multi then
							Tween(
								Value_3,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ BackgroundTransparency = 0 }
							)
						end
					end)

					Value_3.MouseLeave:Connect(function()
						if Value_3 ~= CurrentValue and not Multi then
							Tween(
								Value_3,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ BackgroundTransparency = 1 }
							)
						end
					end)
				end

				DropdownButton.MouseButton1Click:Connect(function()
					IsOpened = not IsOpened
					SetupValuesHolder(IsOpened)
				end)

				if Default and Values then
					if Multi then
						for _, v in ipairs(SelectedValues) do
							SelectedValues[v] = true
							for _, v in pairs(ValuesHolder_1:GetChildren()) do
								if v:IsA("TextButton") and v.Text == v then
									SetBehavior(v, true)
								end
							end
						end
						Value_2.Text = table.concat(Default, ", ")
					else
						local DefaultValue = Values[Default]
						Value_2.Text = tostring(DefaultValue)
						SaveValue.Value = tostring(DefaultValue)

						if Callback then
							pcall(function()
								Callback(Value_2.Text)
							end)
						end
						for _, v in pairs(ValuesHolder_1:GetChildren()) do
							if v:IsA("TextButton") and v:FindFirstChild("Identifier") and v.Text == DefaultValue then
								SetBehavior(v, true)
								CurrentValue = v
							end
						end
					end
				end
			end

			InitDropdown()

			SaveValue.Changed:Connect(function(Value)
				if not File.ToLoad then
					return
				end

				if Multi then
					local Items = {}
					for i in string.gmatch(Value, "([^,]+)") do
						i = i:match("^%s*(.-)%s*$")
						Items[i] = true
					end

					for _, v in pairs(ValuesHolder_1:GetChildren()) do
						if v:IsA("TextButton") and Items[v.Text] then
							SetBehavior(v, true)
						end
					end

					Value_2.Text = "" .. #Items .. " Selected Value(s)"
				else
					local Value2 = Values[Value]
					Value_2.Text = tostring(Value2)

					if Callback then
						pcall(function()
							Callback(Value_2.Text)
						end)
					end
					for _, v in pairs(ValuesHolder_1:GetChildren()) do
						if v:IsA("TextButton") and v:FindFirstChild("Identifier") and v.Text == Value2 then
							SetBehavior(v, true)
							CurrentValue = v
						end
					end
				end
			end)

			function Actions:SetValue(Value)
				if table.find(Values, Value) then
					Value_2.Text = tostring(Value)

					local Success, Error = pcall(function()
						Callback(Value)
					end)
					if not Success then
						error(Error) --// lazy to add a notification for this
					end
				end
			end

			function Actions:AddValue(Value)
				if type(Value) == "string" then
					table.insert(Values, Value)
				elseif type(Value) == "table" then
					for _, v in Value do
						table.insert(Values, v)
					end
				end

				InitDropdown()
			end

			return Actions
		end

		function ElementSetup:CreateKeybind(KeybindIndex)
			local Actions = {}

			local Keybind_1 = Instance.new("Frame")
			local UICorner_8 = Instance.new("UICorner")
			local UIGradient_1 = Instance.new("UIGradient")
			local KeybindTitle_1 = Instance.new("TextLabel")
			local Description_1 = Instance.new("TextLabel")
			local Handler_1 = Instance.new("Frame")
			local UICorner_9 = Instance.new("UICorner")
			local Key_1 = Instance.new("TextLabel")
			local UIStroke_2 = Instance.new("UIStroke")

			Keybind_1.Name = "Keybind"
			Keybind_1.Parent = ScrollBar_1
			Keybind_1.BackgroundColor3 = Color3.fromRGB(24, 26, 31)
			Keybind_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Keybind_1.BorderSizePixel = 0
			Keybind_1.Position = UDim2.new(-4.20495887e-08, 0, 0, 0)
			Keybind_1.Size = UDim2.new(0, 725, 0, 69)

			UICorner_8.Parent = Keybind_1
			UICorner_8.CornerRadius = UDim.new(0, 12)

			UIGradient_1.Parent = Keybind_1
			UIGradient_1.Rotation = 90
			UIGradient_1.Transparency =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.216606) })

			KeybindTitle_1.Name = "KeybindTitle"
			KeybindTitle_1.Parent = Keybind_1
			KeybindTitle_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			KeybindTitle_1.BackgroundTransparency = 1
			KeybindTitle_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			KeybindTitle_1.BorderSizePixel = 0
			KeybindTitle_1.Position = UDim2.new(0.0158620682, 0, 0.0942028984, 0)
			KeybindTitle_1.Size = UDim2.new(0, 240, 0, 23)
			KeybindTitle_1.FontFace = Gui.Fonts.SemiBoldInter
			KeybindTitle_1.Text = "Gui Minimize Keybind"
			KeybindTitle_1.TextColor3 = Color3.fromRGB(254, 254, 254)
			KeybindTitle_1.TextSize = 15
			KeybindTitle_1.TextXAlignment = Enum.TextXAlignment.Left

			Description_1.Name = "Description"
			Description_1.Parent = Keybind_1
			Description_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Description_1.BackgroundTransparency = 1
			Description_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Description_1.BorderSizePixel = 0
			Description_1.Position = UDim2.new(0.0186206903, 0, 0.427536219, 0)
			Description_1.Size = UDim2.new(0, 535, 0, 29)
			Description_1.FontFace = Gui.Fonts.SemiBoldInter
			Description_1.Text = "Does something really cool abbdbdbddb"
			Description_1.TextColor3 = Color3.fromRGB(176, 176, 176)
			Description_1.TextSize = 14
			Description_1.TextXAlignment = Enum.TextXAlignment.Left
			Description_1.TextYAlignment = Enum.TextYAlignment.Top

			Handler_1.Name = "Handler"
			Handler_1.Parent = Keybind_1
			Handler_1.BackgroundColor3 = Color3.fromRGB(34, 37, 44)
			Handler_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Handler_1.BorderSizePixel = 0
			Handler_1.Position = UDim2.new(0.894999981, 0, 0.286000013, 0)
			Handler_1.Size = UDim2.new(0, 58, 0, 28)

			UICorner_9.Parent = Handler_1
			UICorner_9.CornerRadius = UDim.new(0, 10)

			Key_1.Name = "Key"
			Key_1.Parent = Handler_1
			Key_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Key_1.BackgroundTransparency = 1
			Key_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Key_1.BorderSizePixel = 0
			Key_1.Size = UDim2.new(1, 0, 1, 0)
			Key_1.FontFace = Gui.Fonts.SemiBoldInter
			Key_1.Text = "INSERT"
			Key_1.TextColor3 = Color3.fromRGB(176, 176, 176)
			Key_1.TextSize = 14

			UIStroke_2.Parent = Handler_1
			UIStroke_2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			UIStroke_2.Color = Color3.fromRGB(52, 56, 67)
			UIStroke_2.Thickness = 1.2000000476837158

			--// Note: this will be done some other time becouse i dont need it right now lellelelellelelelel

			return Actions
		end

		function ElementSetup:CreateButton(ButtonIndex)
			local Actions = {}

			local Button = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local UIGradient_1 = Instance.new("UIGradient")
			local ButtonTitle_1 = Instance.new("TextLabel")
			local ButtonDescription_1 = Instance.new("TextLabel")
			local ButtonBox_1 = Instance.new("Frame")
			local UICorner_2 = Instance.new("UICorner")
			local ClickIcon_1 = Instance.new("ImageLabel")
			local UIGradient_2 = Instance.new("UIGradient")
			local UIStroke_1 = Instance.new("UIStroke")
			local Key = Instance.new("TextLabel")
			local UICorner_1d = Instance.new("UICorner")

			Button.Name = "Button"
			Button.Parent = ScrollBar_1
			Button.BackgroundColor3 = Color3.fromRGB(24, 26, 31)
			Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Button.BorderSizePixel = 0
			Button.Position = UDim2.new(0, 0, 0, 0)
			Button.Size = UDim2.new(0, 725, 0, 69)

			UICorner_1.Parent = Button
			UICorner_1.CornerRadius = UDim.new(0, 12)

			UIGradient_1.Parent = Button
			UIGradient_1.Rotation = 90
			UIGradient_1.Transparency =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.216606) })

			ButtonTitle_1.Name = "ButtonTitle"
			ButtonTitle_1.Parent = Button
			ButtonTitle_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ButtonTitle_1.BackgroundTransparency = 1
			ButtonTitle_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ButtonTitle_1.BorderSizePixel = 0
			ButtonTitle_1.Position = UDim2.new(0.0158620682, 0, 0.0942028984, 0)
			ButtonTitle_1.Size = UDim2.new(0, 240, 0, 23)
			ButtonTitle_1.FontFace = Gui.Fonts.SemiBoldInter
			ButtonTitle_1.Text = ButtonIndex.Title or ButtonIndex.Name or "Button"
			ButtonTitle_1.TextColor3 = Color3.fromRGB(254, 254, 254)
			ButtonTitle_1.TextSize = 15
			ButtonTitle_1.TextXAlignment = Enum.TextXAlignment.Left

			ButtonDescription_1.Name = "ButtonDescription"
			ButtonDescription_1.Parent = Button
			ButtonDescription_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ButtonDescription_1.BackgroundTransparency = 1
			ButtonDescription_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ButtonDescription_1.BorderSizePixel = 0
			ButtonDescription_1.Position = UDim2.new(0.0186206903, 0, 0.427536219, 0)
			ButtonDescription_1.Size = UDim2.new(0, 535, 0, 29)
			ButtonDescription_1.FontFace = Gui.Fonts.SemiBoldInter
			ButtonDescription_1.Text = ButtonIndex.Description or ""
			ButtonDescription_1.TextColor3 = Color3.fromRGB(176, 176, 176)
			ButtonDescription_1.TextSize = 14
			ButtonDescription_1.TextXAlignment = Enum.TextXAlignment.Left
			ButtonDescription_1.TextYAlignment = Enum.TextYAlignment.Top

			ButtonBox_1.Name = "ButtonBox"
			ButtonBox_1.Parent = Button
			ButtonBox_1.AnchorPoint = Vector2.new(0, 0.5)
			ButtonBox_1.BackgroundColor3 = Color3.fromRGB(35, 38, 45)
			ButtonBox_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ButtonBox_1.BorderSizePixel = 0
			ButtonBox_1.Position = UDim2.new(0.90444839, 0, 0.5, 0)
			ButtonBox_1.Size = UDim2.new(0, 50, 0, 50)

			UICorner_2.Parent = ButtonBox_1
			UICorner_2.CornerRadius = UDim.new(0, 12)

			ClickIcon_1.Name = "ClickIcon"
			ClickIcon_1.Parent = ButtonBox_1
			ClickIcon_1.AnchorPoint = Vector2.new(0.5, 0.5)
			ClickIcon_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ClickIcon_1.BackgroundTransparency = 1
			ClickIcon_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ClickIcon_1.BorderSizePixel = 0
			ClickIcon_1.Position = UDim2.new(0.5, 0, 0.5, 0)
			ClickIcon_1.Size = UDim2.new(0.699999988, 0, 0.699999988, 0)
			ClickIcon_1.Image = "rbxassetid://126205341055171"
			ClickIcon_1.ImageColor3 = Color3.fromRGB(200, 200, 200)

			UIGradient_2.Parent = ButtonBox_1
			UIGradient_2.Rotation = 90
			UIGradient_2.Transparency =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.216606) })

			UIStroke_1.Parent = ButtonBox_1
			UIStroke_1.Color = Color3.fromRGB(40, 44, 52)
			UIStroke_1.Thickness = 1

			Key.Name = "Key"
			Key.Parent = Button
			Key.AnchorPoint = Vector2.new(0.879999995, 0.5)
			Key.BackgroundColor3 = Color3.fromRGB(34, 37, 44)
			Key.BackgroundTransparency = 1
			Key.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Key.BorderSizePixel = 0
			Key.Position = UDim2.new(0.870000005, 0, 0.5, 0)
			Key.Size = UDim2.new(0, 0, 0, 25)
			Key.FontFace = Gui.Fonts.SemiBoldInter
			Key.Text = ". . ."
			Key.TextColor3 = Color3.fromRGB(176, 176, 176)
			Key.TextSize = 13
			Key.TextTransparency = 1
			Key.TextXAlignment = Enum.TextXAlignment.Center
			Key.ZIndex = 2

			UICorner_1d.Parent = Key

			local KeybindButton = Functions.AttachButton(Key, 0.2, 0, 2)
			local RealButton = Functions.AttachButton(Button)

			local AssignedKeybind = nil
			local IsSelecting = false

			local Callback = ButtonIndex.Callback or nil

			local function Click()
				Tween(ButtonBox_1, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 45, 0, 45),
				})
				task.wait(0.13)
				Tween(ButtonBox_1, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 50, 0, 50),
				})

				Callback()
			end

			RealButton.MouseButton1Click:Connect(function()
				local Success, Error = pcall(function()
					Click()
				end)

				if not Success then
					warn("[Starfall]: Button Callback failed: " .. Error)
				end
			end)

			--//Keybinding
			Key:GetPropertyChangedSignal("Text"):Connect(function()
				local TextSize = Key.TextBounds.X
				Tween(Key, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, TextSize + 16, 0, 25),
				})
			end)

			local TextSize = Key.TextBounds.X
			Tween(Key, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, TextSize + 16, 0, 25),
			})

			Button.MouseEnter:Connect(function()
				Tween(Key, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0,
					TextTransparency = 0,
				})
			end)

			KeybindButton.MouseButton1Click:Connect(function()
				Key.Text = "Press any key..."
				IsSelecting = true
			end)

			Services.UserInputService.InputBegan:Connect(function(input, procesed)
				if IsSelecting and not procesed then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						AssignedKeybind = input.KeyCode
						Key.Text = string.upper(input.KeyCode.Name)
					elseif
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.MouseButton2
					then
						AssignedKeybind = input.UserInputType
						Key.Text = string.upper(input.UserInputType.Name)
					end
					IsSelecting = false
				elseif input.KeyCode == AssignedKeybind and not IsSelecting then
					local Success, Error = pcall(function()
						Click()
					end)

					if not Success then
						warn("[Starfall]: Button Keybind failed: " .. Error)
					end
				elseif input.UserInputType == AssignedKeybind and not IsSelecting then
					local Success, Error = pcall(function()
						Click()
					end)

					if not Success then
						warn("[Starfall]: Button Keybind failed:  " .. Error)
					end
				end
			end)

			Button.MouseLeave:Connect(function()
				Tween(Key, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 1,
					TextTransparency = 1,
				})
			end)

			return Actions
		end

		function ElementSetup:CreateInput(InputIndex)
			local Actions = {}

			local Input_1 = Instance.new("Frame")
			local UICorner_20 = Instance.new("UICorner")
			local UIGradient_5 = Instance.new("UIGradient")
			local InputTitle_1 = Instance.new("TextLabel")
			local Description_5 = Instance.new("TextLabel")
			local Handler_5 = Instance.new("Frame")
			local UICorner_21 = Instance.new("UICorner")
			local UIStroke_3 = Instance.new("UIStroke")
			local InputBox_1 = Instance.new("TextBox")

			Input_1.Name = "Input"
			Input_1.Parent = ScrollBar_1
			Input_1.BackgroundColor3 = Color3.fromRGB(24, 26, 31)
			Input_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Input_1.BorderSizePixel = 0
			Input_1.Position = UDim2.new(-4.20495887e-08, 0, 0, 0)
			Input_1.Size = UDim2.new(0, 725, 0, 69)

			UICorner_20.Parent = Input_1
			UICorner_20.CornerRadius = UDim.new(0, 12)

			UIGradient_5.Parent = Input_1
			UIGradient_5.Rotation = 90
			UIGradient_5.Transparency =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.216606) })

			InputTitle_1.Name = "InputTitle"
			InputTitle_1.Parent = Input_1
			InputTitle_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			InputTitle_1.BackgroundTransparency = 1
			InputTitle_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			InputTitle_1.BorderSizePixel = 0
			InputTitle_1.Position = UDim2.new(0.0158620682, 0, 0.0942028984, 0)
			InputTitle_1.Size = UDim2.new(0, 240, 0, 23)
			InputTitle_1.FontFace = Gui.Fonts.SemiBoldInter
			InputTitle_1.Text = InputIndex.Title or InputIndex.Name or ""
			InputTitle_1.TextColor3 = Color3.fromRGB(254, 254, 254)
			InputTitle_1.TextSize = 15
			InputTitle_1.TextXAlignment = Enum.TextXAlignment.Left

			Description_5.Name = "Description"
			Description_5.Parent = Input_1
			Description_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Description_5.BackgroundTransparency = 1
			Description_5.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Description_5.BorderSizePixel = 0
			Description_5.Position = UDim2.new(0.0186206903, 0, 0.427536219, 0)
			Description_5.Size = UDim2.new(0, 535, 0, 29)
			Description_5.FontFace = Gui.Fonts.SemiBoldInter
			Description_5.Text = InputIndex.Description or ""
			Description_5.TextColor3 = Color3.fromRGB(176, 176, 176)
			Description_5.TextSize = 14
			Description_5.TextXAlignment = Enum.TextXAlignment.Left
			Description_5.TextYAlignment = Enum.TextYAlignment.Top

			Handler_5.Name = "Handler"
			Handler_5.Parent = Input_1
			Handler_5.AnchorPoint = Vector2.new(0.96, 0.5)
			Handler_5.BackgroundColor3 = Color3.fromRGB(34, 37, 44)
			Handler_5.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Handler_5.BorderSizePixel = 0
			Handler_5.Position = UDim2.new(0.96, 0, 0.5, 0)
			Handler_5.Size = UDim2.new(0, 109, 0, 37)

			UICorner_21.Parent = Handler_5
			UICorner_21.CornerRadius = UDim.new(0, 10)

			UIStroke_3.Parent = Handler_5
			UIStroke_3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			UIStroke_3.Color = Color3.fromRGB(42, 45, 54)
			UIStroke_3.Thickness = 1.2000000476837158

			InputBox_1.Name = "InputBox"
			InputBox_1.Parent = Handler_5
			InputBox_1.Active = true
			InputBox_1.AnchorPoint = Vector2.new(0.5, 0.5)
			InputBox_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			InputBox_1.BackgroundTransparency = 1
			InputBox_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			InputBox_1.BorderSizePixel = 0
			InputBox_1.CursorPosition = -1
			InputBox_1.Position = UDim2.new(0.5, 0, 0.5, 0)
			InputBox_1.Size = UDim2.new(1, 0, 1, 0)
			InputBox_1.FontFace = Gui.Fonts.SemiBoldInter
			InputBox_1.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
			InputBox_1.PlaceholderText = InputIndex.PlaceHolderText or "Input Your Text"
			InputBox_1.Text = InputIndex.PlaceHolderText or ""
			InputBox_1.TextWrapped = false
			InputBox_1.TextColor3 = Color3.fromRGB(241, 241, 241)
			InputBox_1.TextSize = 13

			InputBox_1:GetPropertyChangedSignal("Text"):Connect(function()
				if #InputBox_1.Text >= 50 then
					InputBox_1.TextWrapped = true
					return
				else
					InputBox_1.TextWrapped = false
				end

				local TextSize = InputBox_1.TextBounds.X
				Tween(Handler_5, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, TextSize + 20, 0, 37),
				})
			end)

			local TextSize = InputBox_1.TextBounds.X
			Tween(Handler_5, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, TextSize + 20, 0, 37),
			})

			local Callback = InputIndex.Callback or nil
			local IgnoreBlank = InputIndex.IgnoreBlank
			local Finished = InputIndex.Finished

			local Flag = Instance.new("StringValue")
			Flag.Parent = Input_1
			Flag.Name = "Flag"
			Flag.Value = InputIndex.Flag or "nil"

			local SaveValue = Instance.new("StringValue")
			SaveValue.Parent = Input_1
			SaveValue.Value = "nil"

			InputBox_1:GetPropertyChangedSignal("Text"):Connect(function(Value)
				if Value and type(Value) == "string" then
					SaveValue.Value = Value
				end
			end)

			if Callback and type(Callback) == "function" then
				InputBox_1.FocusLost:Connect(function(Pressed)
					local Text = InputBox_1.Text

					if IgnoreBlank and Text == "" then
						return
					end

					if not Finished or Pressed then
						if InputIndex.Numeric then
							local Number = tonumber(Text)
							if Number then
								local Success, Error = pcall(function()
									Callback(Number)
								end)
								if not Success then
									Library:CreateNotification({
										Title = "Laverity",
										Content = "Input Error: " .. Error,
									})
								end
							else
								Library:CreateNotification({
									Title = "Laverity",
									Content = "Invalid number input for: " .. (InputTitle_1.Text or ""),
								})
							end
						else
							local Success, Error = pcall(function()
								Callback(Text)
							end)
							if not Success then
								Library:CreateNotification({
									Title = "Laverity",
									Content = "Input Error: " .. Error,
								})
							end
						end
					end
				end)
			else
				Library:CreateNotification({
					Content = "Use a function for callback at input: " .. (InputTitle_1.Text or ""),
				})
			end

			function Actions:SetValue(Value)
				InputBox_1.Text = tostring(Value)

				if Callback then
					local Success, Error = pcall(function()
						Callback(Value)
					end)
					if not Success then
						Library:CreateNotification({
							Title = "Laverity",
							Content = "Input Error: " .. Error,
						})
					end
				end
			end

			SaveValue.Changed:Connect(function(Value)
				if not File.ToLoad then
					return
				end

				InputBox_1.Text = tostring(Value)

				if Callback then
					local Success, Error = pcall(function()
						Callback(Value)
					end)
					if not Success then
						Library:CreateNotification({
							Title = "Laverity",
							Content = "Input Error: " .. Error,
						})
					end
				end
			end)

			return Actions
		end

		if nil then
			Colorpicker_1.Name = "Colorpicker"
			Colorpicker_1.Parent = ScrollBar_1
			Colorpicker_1.BackgroundColor3 = Color3.fromRGB(24, 26, 31)
			Colorpicker_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Colorpicker_1.BorderSizePixel = 0
			Colorpicker_1.Position = UDim2.new(-4.20495887e-08, 0, 0, 0)
			Colorpicker_1.Size = UDim2.new(0, 725, 0, 69)

			UICorner_29.Parent = Colorpicker_1
			UICorner_29.CornerRadius = UDim.new(0, 12)

			UIGradient_7.Parent = Colorpicker_1
			UIGradient_7.Rotation = 90
			UIGradient_7.Transparency =
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.216606) })

			ColorpickerTitle_1.Name = "ColorpickerTitle"
			ColorpickerTitle_1.Parent = Colorpicker_1
			ColorpickerTitle_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ColorpickerTitle_1.BackgroundTransparency = 1
			ColorpickerTitle_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ColorpickerTitle_1.BorderSizePixel = 0
			ColorpickerTitle_1.Position = UDim2.new(0.0158620682, 0, 0.0942028984, 0)
			ColorpickerTitle_1.Size = UDim2.new(0, 240, 0, 23)
			ColorpickerTitle_1.FontFace = Gui.Fonts.SemiBoldInter
			ColorpickerTitle_1.Text = "Auto Farm Currency"
			ColorpickerTitle_1.TextColor3 = Color3.fromRGB(254, 254, 254)
			ColorpickerTitle_1.TextSize = 15
			ColorpickerTitle_1.TextXAlignment = Enum.TextXAlignment.Left

			Description_7.Name = "Description"
			Description_7.Parent = Colorpicker_1
			Description_7.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Description_7.BackgroundTransparency = 1
			Description_7.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Description_7.BorderSizePixel = 0
			Description_7.Position = UDim2.new(0.0186206903, 0, 0.427536219, 0)
			Description_7.Size = UDim2.new(0, 535, 0, 29)
			Description_7.FontFace = Gui.Fonts.SemiBoldInter
			Description_7.Text = "Does something really cool abbdbdbddb"
			Description_7.TextColor3 = Color3.fromRGB(176, 176, 176)
			Description_7.TextSize = 14
			Description_7.TextXAlignment = Enum.TextXAlignment.Left
			Description_7.TextYAlignment = Enum.TextYAlignment.Top

			ColorBox_1.Name = "ColorBox"
			ColorBox_1.Parent = Colorpicker_1
			ColorBox_1.AnchorPoint = Vector2.new(0, 0.5)
			ColorBox_1.BackgroundColor3 = Color3.fromRGB(255, 39, 39)
			ColorBox_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ColorBox_1.BorderSizePixel = 0
			ColorBox_1.Position = UDim2.new(0.90444839, 0, 0.5, 0)
			ColorBox_1.Size = UDim2.new(0, 50, 0, 50)

			UICorner_30.Parent = ColorBox_1

			Overlay_1.Name = "Overlay"
			Overlay_1.Parent = ElementContainer_1
			Overlay_1.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
			Overlay_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Overlay_1.BorderSizePixel = 0
			Overlay_1.Position = UDim2.new(0, 0, 0.769999981, 0)
			Overlay_1.Size = UDim2.new(1, 0, 0, 100)

			UIGradient_8.Parent = Overlay_1
			UIGradient_8.Rotation = 90
			UIGradient_8.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.422629, 1),
				NumberSequenceKeypoint.new(1, 0),
			})
		end

		function ElementSetup:CreateSection(SectionsIndex)
			local Section_1 = Instance.new("TextLabel")

			Section_1.Name = "Section"
			Section_1.Parent = ScrollBar_1
			Section_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Section_1.BackgroundTransparency = 1
			Section_1.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Section_1.BorderSizePixel = 0
			Section_1.Position = UDim2.new(0.0158620682, 0, 0.0942028984, 0)
			Section_1.Size = UDim2.new(0, 725, 0, 23)
			Section_1.FontFace = Gui.Fonts.SemiBoldInter
			Section_1.Text = SectionsIndex.Title or SectionsIndex.Name or ""
			Section_1.TextColor3 = Color3.fromRGB(254, 254, 254)
			Section_1.TextSize = 15
			Section_1.TextXAlignment = Enum.TextXAlignment.Left
		end

		return ElementSetup
	end

	--// Saving System

	function Setup:InitSettings()
		local SelectedConfig = nil
		local ConfigName = nil

		local Settings = Setup:CreateTab({
			Title = "Settings",
			Icon = "rbxassetid://10734950309",
		})

		local Section = Settings:CreateSection({ Title = "Load / Delete Configs" })
		local SelectedConfig = nil

		local function GetSavedConfigs()
			local Configs = {}
			if File.CanSave and File.IsFolder and File.IsFile then
				local Success, Files = pcall(function()
					return File.ListFiles(File.Config)
				end)

				if Success then
					for _, v in pairs(Files) do
						if v:sub(-5) == ".json" then
							local name = v:match("([^/\\]+)%.json$")
							if name then
								table.insert(Configs, name)
							end
						end
					end
				end
			end
			return Configs
		end

		local ConfigsDropdown = Settings:CreateDropdown({
			Title = "Saved Configs",
			Description = "Select your saved configs here",
			Values = GetSavedConfigs(),
			Default = 1,
			Callback = function(Value)
				SelectedConfig = Value
			end,
		})

		local RefreshButton = Settings:CreateButton({
			Title = "Refresh Configs",
			Description = "Reloads the list of saved configs",
			Callback = function()
				local Configs = GetSavedConfigs()
				local Existing = {}

				for _, val in ipairs(ConfigsDropdown.Values) do
					Existing[val] = true
				end

				for _, v in ipairs(Configs) do
					if not Existing[v] then
						ConfigsDropdown:AddValue(v)
					end
				end

				if not SelectedConfig and #Configs > 0 then
					ConfigsDropdown:SetValue(Configs[1])
					SelectedConfig = Configs[1]
				end
			end,
		})

		local LoadButton = Settings:CreateButton({
			Title = "Load Config",
			Description = "Load the selected config",
			Callback = function()
				if SelectedConfig then
					Library:CreateResponse({
						Question = "Are you sure you want to load " .. SelectedConfig .. "?",
						Option1 = "Load Config",
						Option2 = "Cancel",
						Response = function(Bool)
							if Bool then
								Library:LoadConfig(SelectedConfig)
							end
						end,
					})
				else
					Library:CreateNotification({
						Title = "Starfall | Config",
						Content = "Please select an existing config to load!",
					})
				end
			end,
		})

		local DeleteButton = Settings:CreateButton({
			Title = "Delete Config",
			Description = "Delete the selected config",
			Callback = function()
				if SelectedConfig then
					Library:CreateResponse({
						Question = "Are you sure you want to delete " .. SelectedConfig .. "?",
						Option1 = "Delete Config",
						Option2 = "Cancel",
						Response = function(Bool)
							if Bool then
								Library:DeleteConfig(SelectedConfig)
							end
						end,
					})
				else
					Library:CreateNotification({
						Title = "Starfall | Config",
						Content = "Please select an existing config to delete!",
					})
				end
			end,
		})

		local Section2 = Settings:CreateSection({ Title = "Save Configs" })

		local ConfigNameInput = Settings:CreateInput({
			Title = "Config Name",
			Description = "Set the name you want ur config to be saved as",
			Finished = true,
			IgnoreBlank = true,
			Numeric = false,
			PlaceHolderText = "Input Name",
			Callback = function(Value)
				ConfigName = Value
				print(ConfigName)
			end,
		})

		local SaveConfig = Settings:CreateButton({
			Title = "Save Config",
			Description = "Save the config with the inputed name",
			Callback = function()
				if ConfigName then
					Library:CreateResponse({
						Question = "Are you sure you want to Save " .. ConfigName .. "?",
						Option1 = "Save Config",
						Option2 = "Cancel",
						Response = function(Bool)
							if Bool then
								Library:CreateConfig(ConfigName)
							end
						end,
					})
				else
					Library:CreateNotification({
						Title = "Starfall | Config",
						Content = "Please input a name to save!",
					})
				end
			end,
		})
	end

	return Setup
end

return Library
