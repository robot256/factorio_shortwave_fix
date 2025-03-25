local cc = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
local dc = data.raw["decider-combinator"]["decider-combinator"]

for _, point in pairs(cc.circuit_wire_connection_points) do
  point.shadow = point.wire
end

local shortwave_sprite = {
  filename = "__shortwave_fix__/graphics/radio-hr.png",
  width = 96,
  height = 96,
  priority = "high",
  shift = { 0, 0.05 },
  scale = 0.5,
}

data:extend{
  {
    type = "constant-combinator",
    name = "shortwave-link",
    flags = {
      "player-creation",
      "not-flammable",
      "not-blueprintable",
      "not-rotatable",
      "not-deconstructable",
      "placeable-off-grid"
    },
    max_health = 1000000,
    selectable_in_game = false,
    collision_mask = {layers={}},
    icon = "__shortwave_fix__/graphics/radio-icon.png",
    icon_size = 32,
    activity_led_light_offsets = cc.activity_led_light_offsets,
    circuit_wire_connection_points = cc.circuit_wire_connection_points,
    circuit_wire_max_distance = 2000000,
    draw_circuit_wires = false,
  },
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
    max_health = 1000000,
    selectable_in_game = true,
    collision_mask = { layers={} },
    collision_box = {{-0.25,-0.25},{0.25,0.25}},
    selection_box = {{-0.5,-0.5},{0,0}},
    icon = "__shortwave_fix__/graphics/radio-icon.png",
    icon_size = 32,
    tile_width = 1,
    tile_height = 1,
    energy_source = {type="void"},
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
    activity_led_light_offsets = cc.activity_led_light_offsets,
    input_connection_points = cc.circuit_wire_connection_points,
    output_connection_points = cc.circuit_wire_connection_points,
    circuit_wire_max_distance = 9,
  },
  {
    type = "constant-combinator",
    name = "shortwave-radio",
    flags = {
      "player-creation",
      "not-flammable",
      "not-rotatable",
    },
    max_health = cc.max_health,
    selectable_in_game = true,
    minable = {
      result = "shortwave-radio",
      mining_time = 1,
    },
    collision_mask = { layers={object=true, item=true, player=true, water_tile=true} },
    collision_box = {{-0.25,-0.25},{0.25,0.25}},
    selection_box = {{0,0},{0.5,0.5}},
    icon = "__shortwave_fix__/graphics/radio-icon.png",
    icon_size = 32,
    tile_width = 1,
    tile_height = 1,
    sprites = {
      north = shortwave_sprite,
      south = shortwave_sprite,
      east = shortwave_sprite,
      west = shortwave_sprite,
    },
    activity_led_sprites = cc.activity_led_sprites,
    activity_led_light = { intensity = 0, size = 0 },
    activity_led_light_offsets = cc.activity_led_light_offsets,
    circuit_wire_connection_points = cc.circuit_wire_connection_points,
    corpse = "small-remnants",
  },
  
  {
    type = "item",
    name = "shortwave-radio",
    stack_size = 50,
    icon = "__shortwave_fix__/graphics/radio-icon.png",
    icon_size = 32,
    subgroup = "circuit-network",
    order = "z",
    place_result = "shortwave-radio",
  },
  {
    type = "item",
    name = "shortwave-port",
    stack_size = 50,
    icon = "__shortwave_fix__/graphics/radio-icon.png",
    icon_size = 32,
    subgroup = "circuit-network",
    order = "z",
    place_result = "shortwave-port",
    hidden = true,
    flags = {"only-in-cursor"},
  },
  
  {
    type = "recipe",
    name = "shortwave-radio",
    category = "crafting",
    subgroup = "circuit-network",
    enabled = false,
    icon = "__shortwave_fix__/graphics/radio-icon.png",
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
    icon = "__shortwave_fix__/graphics/tech.png",
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
    type = "custom-input",
    name = "shortwave-toggle",
    key_sequence = "CTRL + R",
    linked_game_control = "toggle-entity",
  }
}
