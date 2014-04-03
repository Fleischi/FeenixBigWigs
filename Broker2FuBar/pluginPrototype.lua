local addon = LibStub("AceAddon-3.0"):GetAddon("Broker2FuBar")
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local lfbp = LibStub:GetLibrary("LibFuBarPlugin-Mod-3.0")

addon.pluginPrototype = {}
addon.pluginPrototypeMetatable = { __index = addon.pluginPrototype }

local pluginPrototype = addon.pluginPrototype

function pluginPrototype:Initialize()
	self:SetFuBarOption('tooltipType', self.data_object.tooltip and 'Custom' or 'GameTooltip')
	self:SetFuBarOption('configType', 'AceConfigDialog-3.0')
	self:SetFuBarOption('aceConfig30', addon.name)
	self:SetFuBarOption('iconPath', self.data_object.icon)
	lfbp:OnEmbedInitialize(self)
end

function pluginPrototype:Enable()
	if self.enabled then return end
	self.enabled = true
	ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged_"..self.data_object_name.."_text", "OnUpdateFuBarText")
	ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged_"..self.data_object_name.."_icon", "OnUpdateFuBarIcon")
	ldb.RegisterCallback(self, "LibDataBroker_AttributeChanged_"..self.data_object_name.."_tooltip", "OnUpdateFuBarTooltip")
	self:OnUpdateFuBarText()
	self:OnUpdateFuBarIcon()
	lfbp:OnEmbedEnable(self)
end

function pluginPrototype:Disable()
	if not self.enabled then return end
	self.enabled = false
	ldb.UnregisterAllCallbacks(self)
	lfbp:OnEmbedDisable(self)
end

function pluginPrototype:IsEnabled()
	return self.enabled
end

function pluginPrototype:OnUpdateFuBarText()
	self:SetFuBarText(self.data_object.text)
end

function pluginPrototype:OnUpdateFuBarIcon()
	-- this isn't an official fubar method, note
	self:SetFuBarIcon(self.data_object.icon)
end

function pluginPrototype:OnFuBarClick(button)
	if self.data_object.OnClick then
		self.data_object.OnClick(self:GetFrame(), button)
	end
end

function pluginPrototype:OnFuBarEnter()
	if self.data_object.OnEnter then
		self.data_object.OnEnter(self:GetFrame())
	end
end

function pluginPrototype:OnFuBarLeave(button)
	if self.data_object.OnLeave then
		self.data_object.OnLeave(self:GetFrame())
	end
end

function pluginPrototype:OnUpdateFuBarTooltip()
	if self.data_object.tooltip then
		self.data_object.tooltip:Show()
	elseif self.data_object.OnTooltipShow then
		self.data_object.OnTooltipShow(GameTooltip)
	elseif not self.data_object.OnEnter then
		GameTooltip:AddLine(self.data_object.label or self.data_object_name)
	end
end

