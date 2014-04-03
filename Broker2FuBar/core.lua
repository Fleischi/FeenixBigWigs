local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local lfbp = LibStub:GetLibrary("LibFuBarPlugin-Mod-3.0")

local AceAddon = LibStub("AceAddon-3.0")
local addon = AceAddon:NewAddon("Broker2FuBar", "AceConsole-3.0", "AceHook-3.0")

addon.registry = {}
addon.fubared = {}

function addon:OnInitialize()
	if IsAddOnLoaded('FuBar2Broker') then
		self:Print(self.name..' disabled itself because FuBar2Broker is loaded. Running these two addons at the same time is a very bad idea.')
		self:SetEnabledState(false)
		return
	end

	self.db = LibStub("AceDB-3.0"):New("Broker2FuBarDB", {
		profile = {
			objects = {
				['*'] = true,
			},
		},
	})

	LibStub("AceConfig-3.0"):RegisterOptionsTable(self.name, self.options)
	self:RegisterChatCommand("b2f", "OpenGUI", true)

	for name, data_object in ldb:DataObjectIterator() do
		self:RegisterObject(name, data_object)
	end
	ldb.RegisterCallback(self, "LibDataBroker_DataObjectCreated")
end

function addon:OpenGUI()
	LibStub("AceConfigDialog-3.0"):Open(self.name)
end

function addon:LibDataBroker_DataObjectCreated(event, name, data_object)
	self:RegisterObject(name, data_object)
end

function addon:RegisterObject(name, data_object)
	if data_object.type ~= 'launcher' and data_object.type ~= 'data source' then
		return
	end
	if not self.registry[name] then
		self.registry[name] = data_object.label or name
	end
	if self:IsObjectEnabled(name) then
		self:OnObjectEnable(name, data_object)
	end
end

function addon:IsObjectEnabled(name)
	return self.db.profile.objects[name]
end

function addon:EnableObject(name, value)
	if value and not self.db.profile.objects[name] then
		self.db.profile.objects[name] = true
		self:OnObjectEnable(name)
	elseif not value and self.db.profile.objects[name] then
		self.db.profile.objects[name] = false
		self:OnObjectDisable(name)
	end
end

function addon:OnObjectEnable(name, data_object)
	local fu = self:FuBarize(name, data_object)
	fu:Enable()
end

function addon:OnObjectDisable(name)
	local fu = self.fubared[name]
	if not fu then return end
	fu:Disable()
end

function addon:FuBarize(name, data_object)
	if self.fubared[name] then
		return self.fubared[name]
	end
	data_object = data_object or ldb:GetDataObjectByName(name)

	-- Create the pseudo-addon
	local fu = setmetatable({
		name             = name .. "_B2F",
		data_object_name = name,
		data_object      = data_object,
		db               = self.db:RegisterNamespace(name, {profile={}})
	}, self.pluginPrototypeMetatable)

	-- Embeds FuBarPlugin
	lfbp:Embed(fu)

	-- Initiialize it
	fu:Initialize()

	-- Create the option group
	local optKey = name:gsub('%s', '_')
	self.objectOptions[optKey] = setmetatable({
		name = data_object.label or name,
		handler = fu
	}, self.objectOptionsMetaTable)

	self.fubared[name] = fu
	return fu
end