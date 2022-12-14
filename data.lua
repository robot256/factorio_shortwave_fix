local cc = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
local dc = table.deepcopy(data.raw["decider-combinator"]["decider-combinator"])

for _, point in ipairs(cc.circuit_wire_connection_points) do
	point.shadow = point.wire
end

local nosprites = {
	north = {
		filename = "__shortwave_fix__/nothing.png",
		width = 32,
		height = 32,
		priority = "low",
	},
	south = {
		filename = "__shortwave_fix__/nothing.png",
		width = 32,
		height = 32,
		priority = "low",
	},
	east = {
		filename = "__shortwave_fix__/nothing.png",
		width = 32,
		height = 32,
		priority = "low",
	},
	west = {
		filename = "__shortwave_fix__/nothing.png",
		width = 32,
		height = 32,
		priority = "low",
	},
}

data:extend({
	{
		type = "constant-combinator",
		name = "shortwave-link",
		flags = {
			"player-creation",
			"not-flammable",
			"not-blueprintable",
			"not-rotatable",
			"not-deconstructable",
		},
		selectable_in_game = false,
		collision_mask = {},
		collision_box = nil, --{{-0.25,-0.25},{0.25,0.25}},
		selection_box = nil, --{{-0.5,-0.5},{0.5,0.5}},
		icon = "__shortwave_fix__/nothing.png",
		icon_size = 32,
		tile_width = 1,
		tile_height = 1,
		item_slot_count = 1,
		sprites = nosprites,
		activity_led_sprites = cc.activity_led_sprites,
		activity_led_light = { intensity = 0, size = 0 },
		activity_led_light_offsets = cc.activity_led_light_offsets,
		circuit_wire_connection_points = cc.circuit_wire_connection_points,
		circuit_wire_max_distance = 1000000,
		draw_circuit_wires = false,
		corpse = "small-remnants",
	},
--	{
--		type = "constant-combinator",
--		name = "shortwave-port",
--		flags = {
--			"player-creation",
--			"not-flammable",
--			"not-rotatable",
--			"not-deconstructable",
--		},
--		selectable_in_game = true,
--		collision_mask = { "layer-15" },
--		collision_box = {{-0.25,-0.25},{0.25,0.25}},
--		selection_box = {{-0.5,-0.5},{0,0}},
--		icon = "__shortwave_fix__/radio-icon.png",
--		icon_size = 32,
--		tile_width = 1,
--		tile_height = 1,
--		item_slot_count = 1,
--		sprites = {
--			north = {
--				filename = "__shortwave_fix__/nothing.png",
--				width = 32,
--				height = 32,
--				priority = "high",
--			},
--			south = {
--				filename = "__shortwave_fix__/nothing.png",
--				width = 32,
--				height = 32,
--				priority = "high",
--			},
--			east = {
--				filename = "__shortwave_fix__/nothing.png",
--				width = 32,
--				height = 32,
--				priority = "high",
--			},
--			west = {
--				filename = "__shortwave_fix__/nothing.png",
--				width = 32,
--				height = 32,
--				priority = "high",
--			},
--		},
--		activity_led_sprites = cc.activity_led_sprites,
--		activity_led_light = { intensity = 0, size = 0 },
--		activity_led_light_offsets = cc.activity_led_light_offsets,
--		circuit_wire_connection_points = cc.circuit_wire_connection_points,
--		circuit_wire_max_distance = 9,
--		corpse = "small-remnants",
--	},
	{
		type = "decider-combinator",
		name = "shortwave-port",
		flags = {
			"player-creation",
			"not-flammable",
			"not-rotatable",
			"not-deconstructable",
			"hide-alt-info",
		},
		selectable_in_game = true,
		collision_mask = { "rail-layer" },
		collision_box = {{-0.25,-0.25},{0.25,0.25}},
		selection_box = {{-0.5,-0.5},{0,0}},
		icon = "__shortwave_fix__/radio-icon.png",
		icon_size = 32,
		tile_width = 1,
		tile_height = 1,
		energy_source = dc.energy_source,
		active_energy_usage = dc.active_energy_usage,
		input_connection_bounding_box = {{-0.5,-0.5},{0,0}},
		output_connection_bounding_box = {{-1000000,-1000000},{-1000000,-1000000}},
		screen_light = {
      color = {
        b = 1,
        g = 1,
        r = 1
      },
      intensity = 0,
      size = 0,
    },
    screen_light_offsets = dc.screen_light_offsets,
		sprites = nosprites,
		equal_symbol_sprites = nosprites,
		not_equal_symbol_sprites = nosprites,
		greater_or_equal_symbol_sprites = nosprites,
		greater_symbol_sprites = nosprites,
		less_symbol_sprites = nosprites,
		less_or_equal_symbol_sprites = nosprites,
		activity_led_sprites = cc.activity_led_sprites,
		activity_led_light = { intensity = 0, size = 0 },
		activity_led_light_offsets = cc.activity_led_light_offsets,
		input_connection_points = cc.circuit_wire_connection_points,
		output_connection_points = cc.circuit_wire_connection_points,
		circuit_wire_max_distance = 9,
		corpse = "small-remnants",
	},
	{
		type = "item",
		name = "shortwave-radio",
		stack_size = 50,
		icon = "__shortwave_fix__/radio-icon.png",
		icon_size = 32,
		subgroup = "circuit-network",
		order = "z",
		place_result = "shortwave-radio",
	},
	{
		type = "item",
		name = "shortwave-port",
		stack_size = 50,
		icon = "__shortwave_fix__/radio-icon.png",
		icon_size = 32,
		subgroup = "circuit-network",
		order = "z",
		place_result = "shortwave-port",
		flags = {"hidden","only-in-cursor"},
	},
	{
		type = "recipe",
		name = "shortwave-radio",
		category = "crafting",
		subgroup = "circuit-network",
		enabled = false,
		icon = "__shortwave_fix__/radio-icon.png",
		icon_size = 32,
		ingredients = {
			{ type = "item", name = "iron-stick", amount = 1 },
			{ type = "item", name = "copper-cable", amount = 2 },
			{ type = "item", name = "constant-combinator", amount = 1 },
		},
		results = {
			{ type = "item", name = "shortwave-radio", amount = 1 },
		},
		hidden = false,
		energy_required = 1.0,
		order = "z",
	},
	{
		type = "technology",
		name = "shortwave",
		icon = "__shortwave_fix__/tech.png",
		icon_size = 128,
		effects = {
			{ type = "unlock-recipe", recipe = "shortwave-radio" },
		},
		prerequisites = {
			"circuit-network",
		},
		unit = {
			count = 100,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
			},
			time = 15
		},
		order = "a",
	},
	{
		type = "constant-combinator",
		name = "shortwave-radio",
		flags = {
			"player-creation",
			"not-flammable",
			"not-rotatable",
		},
		selectable_in_game = true,
		minable = {
			result = "shortwave-radio",
			mining_time = cc.minable.mining_time,
		},
		collision_mask = { "item-layer", "object-layer", "player-layer", "water-tile" },
		collision_box = {{-0.25,-0.25},{0.25,0.25}},
		selection_box = {{0,0},{0.5,0.5}},
		icon = "__shortwave_fix__/radio-icon.png",
		icon_size = 32,
		tile_width = 1,
		tile_height = 1,
		item_slot_count = 1,
		sprites = {
			north = {
				filename = "__shortwave_fix__/radio-lr.png",
				width = 48,
				height = 48,
				priority = "high",
				shift = { 0, 0.05 },
				hr_version = {
					filename = "__shortwave_fix__/radio-hr.png",
					width = 96,
					height = 96,
					priority = "high",
					shift = { 0, 0.05 },
					scale = 0.5,
				}
			},
			south = {
				filename = "__shortwave_fix__/radio-lr.png",
				width = 48,
				height = 48,
				priority = "high",
				shift = { 0, 0.05 },
				hr_version = {
					filename = "__shortwave_fix__/radio-hr.png",
					width = 96,
					height = 96,
					priority = "high",
					shift = { 0, 0.05 },
					scale = 0.5,
				}
			},
			east = {
				filename = "__shortwave_fix__/radio-lr.png",
				width = 48,
				height = 48,
				priority = "high",
				shift = { 0, 0.05 },
				hr_version = {
					filename = "__shortwave_fix__/radio-hr.png",
					width = 96,
					height = 96,
					priority = "high",
					shift = { 0, 0.05 },
					scale = 0.5,
				}
			},
			west = {
				filename = "__shortwave_fix__/radio-lr.png",
				width = 48,
				height = 48,
				priority = "high",
				shift = { 0, 0.05 },
				hr_version = {
					filename = "__shortwave_fix__/radio-hr.png",
					width = 96,
					height = 96,
					priority = "high",
					shift = { 0, 0.05 },
					scale = 0.5,
				}
			},
		},
		activity_led_sprites = cc.activity_led_sprites,
		activity_led_light = { intensity = 0, size = 0 },
		activity_led_light_offsets = cc.activity_led_light_offsets,
		circuit_wire_connection_points = cc.circuit_wire_connection_points,
		corpse = "small-remnants",
	},
})
