-- LICENSED UNDER 'ALL RIGHTS RESERVED'
-- DO NOT USE THIS "LIBRARY" ANYWHERE ELSE OTHER THAN THE 'MUTESOUNDFILE' WOW ADDON

local Type, Version = "MuteSoundFileEditBox", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end


local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function Frame_OnShowFocus(frame)
	frame.obj.editbox:SetFocus()
	frame:SetScript("OnShow", nil)
end

local function EditBox_OnEscapePressed(frame)
	AceGUI:ClearFocus()
end

local function EditBox_OnEnterPressed(frame)
	local self = frame.obj
	local value = frame:GetText()
	local cancel = self:Fire("OnEnterPressed", value)
	if not cancel then
		PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
	end
end

local function EditBox_OnTextChanged(frame)
	local self = frame.obj
	local value = frame:GetText()
	if tostring(value) ~= tostring(self.lasttext) then
		self:Fire("OnEnterPressed", value)
		self.lasttext = value
		frame.obj.editbox:SetFocus()
		frame.obj.editbox:SetCursorPosition(100000000)
	end
end

local function EditBox_OnFocusGained(frame)
	AceGUI:SetFocus(frame.obj)
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- height is controlled by SetLabel
		self:SetWidth(200)
		self:SetDisabled(false)
		self:SetLabel()
		self:SetText()
		self:SetMaxLetters(0)
	end,

	["OnRelease"] = function(self)
		self:ClearFocus()
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.editbox:EnableMouse(false)
			self.editbox:ClearFocus()
			self.editbox:SetTextColor(0.5,0.5,0.5)
			self.label:SetTextColor(0.5,0.5,0.5)
		else
			self.editbox:EnableMouse(true)
			self.editbox:SetTextColor(1,1,1)
			self.label:SetTextColor(1,.82,0)
		end
	end,

	["SetText"] = function(self, text)
		self.lasttext = text or ""
		self.editbox:SetText(text or "")
		self.editbox:SetCursorPosition(0)
	end,

	["GetText"] = function(self, text)
		return self.editbox:GetText()
	end,

	["SetLabel"] = function(self, text)
		if text and text ~= "" then
			self.label:SetText(text)
			self.label:Show()
			self.editbox:SetPoint("TOPLEFT",self.frame,"TOPLEFT",7,-18)
			self:SetHeight(44)
			self.alignoffset = 30
		else
			self.label:SetText("")
			self.label:Hide()
			self.editbox:SetPoint("TOPLEFT",self.frame,"TOPLEFT",7,0)
			self:SetHeight(26)
			self.alignoffset = 12
		end
	end,

	["SetMaxLetters"] = function (self, num)
		self.editbox:SetMaxLetters(num or 0)
	end,

	["ClearFocus"] = function(self)
		self.editbox:ClearFocus()
		self.frame:SetScript("OnShow", nil)
	end,

	["SetFocus"] = function(self)
		self.editbox:SetFocus()
		if not self.frame:IsShown() then
			self.frame:SetScript("OnShow", Frame_OnShowFocus)
		end
	end,

	["HighlightText"] = function(self, from, to)
		self.editbox:HighlightText(from, to)
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local num  = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local editbox = CreateFrame("EditBox", "MuteSoundFileEditBox"..num, frame, "InputBoxTemplate")
	editbox:SetAutoFocus(false)
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetScript("OnEnter", Control_OnEnter)
	editbox:SetScript("OnLeave", Control_OnLeave)
	editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	editbox:SetScript("OnTextChanged", EditBox_OnTextChanged)
	editbox:SetScript("OnEditFocusGained", EditBox_OnFocusGained)
	editbox:SetTextInsets(0, 0, 3, 3)
	editbox:SetMaxLetters(256)
	editbox:SetPoint("BOTTOMLEFT", 6, 0)
	editbox:SetPoint("BOTTOMRIGHT")
	editbox:SetHeight(19)

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	label:SetPoint("TOPLEFT", 0, -2)
	label:SetPoint("TOPRIGHT", 0, -2)
	label:SetJustifyH("LEFT")
	label:SetHeight(18)

	local widget = {
		alignoffset = 30,
		editbox     = editbox,
		label       = label,
		frame       = frame,
		type        = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	editbox.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)