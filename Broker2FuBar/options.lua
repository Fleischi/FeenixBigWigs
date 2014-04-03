local addon = LibStub("AceAddon-3.0"):GetAddon("Broker2FuBar")

addon.objectOptions = {
	enable_ = {
		name = 'Enable',
		desc = 'Only the selected LibDataBroker objects are wrapped into FuBar plugins.',
		type = 'multiselect',
		get = function(info, name)
			return info.handler:IsObjectEnabled(name)
		end,
		set = function(info, name, value)
			info.handler:EnableObject(name, value)
		end,
		values = addon.registry,
		order = 0,
	},
}

addon.options = {
	type = 'group',
	name = addon.name,
	handler = addon,
	args = {
		plugin = {
			name = 'Settings',
			type = 'group',
			args = addon.objectOptions
		}
	},
}

-- What follow is an adaptation from FBP's config table

local SHOW_FUBAR_ICON = "Show FuBar icon"
local SHOW_FUBAR_ICON_DESC = "Show the FuBar plugin's icon on the panel."
local SHOW_FUBAR_TEXT = "Show FuBar text"
local SHOW_FUBAR_TEXT_DESC = "Show the FuBar plugin's text on the panel."
local POSITION_ON_FUBAR = "Position on FuBar"
local POSITION_ON_FUBAR_DESC = "Position the FuBar plugin on the panel."
local POSITION_LEFT = "Left"
local POSITION_RIGHT = "Right"
local POSITION_CENTER = "Center"
local ATTACH_PLUGIN_TO_MINIMAP = "Attach FuBar plugin to minimap"
local ATTACH_PLUGIN_TO_MINIMAP_DESC = "Attach the FuBar plugin to the minimap instead of the panel."

if GetLocale() == "zhCN" then
	SHOW_FUBAR_ICON = "显示FuBar图标"
	SHOW_FUBAR_ICON_DESC = "在面板上显示FuBar插件的图标."
	SHOW_FUBAR_TEXT = "显示FuBar文字"
	SHOW_FUBAR_TEXT_DESC = "在面板上显示Fubar插件文字标题"
	POSITION_ON_FUBAR = "位置"
	POSITION_ON_FUBAR_DESC = "FuBar插件在面板上的位置."
	POSITION_LEFT = "居左"
	POSITION_RIGHT = "居右"
	POSITION_CENTER = "居中"
	ATTACH_PLUGIN_TO_MINIMAP = "依附在小地图"
	ATTACH_PLUGIN_TO_MINIMAP_DESC = "插件图标依附在小地图而不显示在面板上."
elseif GetLocale() == "zhTW" then
	SHOW_FUBAR_ICON = "顯示圖示"
	SHOW_FUBAR_ICON_DESC = "在面板上顯示插件圖示。"
	SHOW_FUBAR_TEXT = "顯示文字"
	SHOW_FUBAR_TEXT_DESC = "在面板上顯示插件文字。"
	POSITION_ON_FUBAR = "位置"
	POSITION_ON_FUBAR_DESC = "插件在面板上的位置。"
	POSITION_LEFT = "靠左"
	POSITION_RIGHT = "靠右"
	POSITION_CENTER = "置中"
	ATTACH_PLUGIN_TO_MINIMAP = "依附在小地圖"
	ATTACH_PLUGIN_TO_MINIMAP_DESC = "插件圖標依附在小地圖而不顯示在面板上。"
elseif GetLocale() == "koKR" then
	SHOW_FUBAR_ICON = "FuBar 아이콘 표시"
	SHOW_FUBAR_ICON_DESC = "FuBar 패널에 플러그인 아이콘을 표시합니다."
	SHOW_FUBAR_TEXT = "FuBar 텍스트 표시"
	SHOW_FUBAR_TEXT_DESC = "FuBar 페널에 플러그인 텍스트를 표시합니다."
	POSITION_ON_FUBAR = "FuBar 위치"
	POSITION_ON_FUBAR_DESC = "패널 위의 FuBar 플러그인의 위치를 설정합니다."
	POSITION_LEFT = "좌측"
	POSITION_RIGHT = "우측"
	POSITION_CENTER = "중앙"
	ATTACH_PLUGIN_TO_MINIMAP = "FuBar 플러그인 미니맵 표시"
	ATTACH_PLUGIN_TO_MINIMAP_DESC = "FuBar 플러그인을 패널 대신 미니맵에 표시합니다."
elseif GetLocale() == "frFR" then
	SHOW_FUBAR_ICON = "Afficher l'icône FuBar"
	SHOW_FUBAR_ICON_DESC = "Affiche l'icône du plugin FuBar sur le panneau."
	SHOW_FUBAR_TEXT = "Afficher le texte FuBar"
	SHOW_FUBAR_TEXT_DESC = "Affiche le texte du plugin FuBar sur le panneau."
	POSITION_ON_FUBAR = "Position sur FuBar"
	POSITION_ON_FUBAR_DESC = "Position du plugin FuBar sur le panneau."
	POSITION_LEFT = "Gauche"
	POSITION_RIGHT = "Droite"
	POSITION_CENTER = "Centre"
	ATTACH_PLUGIN_TO_MINIMAP = "Attacher le plugin FuBar sur la minicarte"
	ATTACH_PLUGIN_TO_MINIMAP_DESC = "Attache le plugin FuBar sur la minicarte au lieu du panneau."
end

addon.objectOptionsMetaTable = { __index = {
	type = 'group',
	hidden = function(info)
		return not info.handler:IsEnabled()
	end,
	args = {
		icon = {
			type = 'toggle',
			name = SHOW_FUBAR_ICON,
			desc = SHOW_FUBAR_ICON_DESC,
			set = "ToggleFuBarIconShown",
			get = "IsFuBarIconShown",
			hidden = function(info)
				return not info.handler.data_object.icon or not info.handler.data_object.text or info.handler:IsDisabled() or info.handler:IsFuBarMinimapAttached()
			end,
			width = 'double',
			order = -13.7,
		},
		text = {
			type = 'toggle',
			name = SHOW_FUBAR_TEXT,
			desc = SHOW_FUBAR_TEXT_DESC,
			set = "ToggleFuBarTextShown",
			get = "IsFuBarTextShown",
			hidden = function(info)
				return not info.handler.data_object.icon or not info.handler.data_object.text or info.handler:IsDisabled() or info.handler:IsFuBarMinimapAttached()
			end,
			width = 'double',
			order = -13.6,
		},
		position = {
			type = 'select',
			name = POSITION_ON_FUBAR,
			desc = POSITION_ON_FUBAR_DESC,
			values = {
				LEFT = POSITION_LEFT,
				CENTER = POSITION_CENTER,
				RIGHT = POSITION_RIGHT
			},
			get = function(info)
				local self = info.handler
				return self:GetPanel() and self:GetPanel():GetPluginSide(self)
			end,
			set = function(info, value)
				local self = info.handler
				if self:GetPanel() then
					self:GetPanel():SetPluginSide(self, value)
				end
			end,
			hidden = function(info)
				return info.handler:IsFuBarMinimapAttached() or info.handler:IsDisabled()
			end,
			order = -13.2,
		},
		minimapAttach = {
			type = 'toggle',
			name = ATTACH_PLUGIN_TO_MINIMAP,
			desc = ATTACH_PLUGIN_TO_MINIMAP_DESC,
			get = "IsFuBarMinimapAttached",
			set = "ToggleFuBarMinimapAttached",
			hidden = function(info)
				return info.handler:IsDisabled()
			end,
			width = 'double',
			order = -13.1,
		},
	}
}}
