
blueprintLib = require("__Robot256Lib__/script/blueprint_replacement")

local function check_state(force)
  if not global[force.index] then
    global[force.index] = {}
  end
end

local function check_channels()
  for team,channels in pairs(global) do
    for channel,link in pairs(channels) do
      local nodes = link.circuit_connected_entities
      if #nodes.red == 0 and #nodes.green == 0 then
        link.destroy()
        channels[channel] = nil
      end
    end
  end
end

local function radio_link(radio)
  local links = radio.surface.find_entities_filtered({
    name = "shortwave-link",
    area = {
      { x = radio.position.x - 0.25, y = radio.position.y - 0.25, },
      { x = radio.position.x + 0.25, y = radio.position.y + 0.25, },
    },
  })

  local link = links and links[1]

  if not link then
    link = radio.surface.create_entity({
      name = "shortwave-link",
      position = radio.position,
      force = radio.force,
    })
  end

  link.operable = false

  return link
end

local function radio_port(radio)
  local ports = radio.surface.find_entities_filtered({
    name = "shortwave-port",
    area = {
      { x = radio.position.x - 0.25, y = radio.position.y - 0.25, },
      { x = radio.position.x + 0.25, y = radio.position.y + 0.25, },
    },
  })

  local ghosts = radio.surface.find_entities_filtered({
    ghost_name = "shortwave-port",
    area = {
      { x = radio.position.x - 0.25, y = radio.position.y - 0.25, },
      { x = radio.position.x + 0.25, y = radio.position.y + 0.25, },
    },
  })

  local port = ports and ports[1]

  if not port and ghosts and ghosts[1] then
    _, port = ghosts[1].revive()
    table.remove(ghosts, 1)
  end

  if not port then
    port = radio.surface.create_entity({
      name = "shortwave-port",
      position = radio.position,
      force = radio.force,
    })
  end

  for _, ghost in ipairs(ghosts) do
    ghost.destroy()
  end

  port.operable = false
  --port.direction = defines.direction.south

  return port
end

local function radio_tune(radio)
  local team = radio.force.index
  local link = radio_link(radio)
  local port = radio_port(radio)

  for _, l in ipairs(link.circuit_connected_entities.red) do
    if l.name == "shortwave-link" then
      link.disconnect_neighbour({
        wire = defines.wire_type.red,
        target_entity = l,
      })
    end
  end

  for _, l in ipairs(link.circuit_connected_entities.green) do
    if l.name == "shortwave-link" then
      link.disconnect_neighbour({
        wire = defines.wire_type.green,
        target_entity = l,
      })
    end
  end

  local signal = radio.get_control_behavior().get_signal(1)

  if not signal or not signal.signal then
    return
  end

  local channel = signal.signal.name..":"..signal.count

  if not global[team][channel] then
    global[team][channel] = radio.surface.create_entity({
      name = "shortwave-link",
      position = { 0, 0 },
      force = radio.force,
    })
  end

  local relay = global[team][channel]

  link.connect_neighbour({
    wire = defines.wire_type.red,
    target_entity = relay,
  })

  link.connect_neighbour({
    wire = defines.wire_type.green,
    target_entity = relay,
  })

  link.connect_neighbour({
    wire = defines.wire_type.red,
    target_entity = port,
    target_circuit_id = defines.circuit_connector_id.combinator_input,
  })

  link.connect_neighbour({
    wire = defines.wire_type.green,
    target_entity = port,
    target_circuit_id = defines.circuit_connector_id.combinator_input,
  })
end

local function OnEntityCreated(event)
  local entity = event.created_entity or event.entity or event.destination
  -- check for blueprints missing io port or radio body
  if entity.name == "entity-ghost" then
    local r = entity.surface.count_entities_filtered({
      ghost_name = 'shortwave-radio',
      area = {
        left_top = { x = entity.position.x - 0.1, y = entity.position.y - 0.1 },
        right_bottom = { x = entity.position.x + 0.1, y = entity.position.y + 0.1 },
      }
    }) > 0

    local p = entity.surface.count_entities_filtered({
      ghost_name = 'shortwave-port',
      area = {
        left_top = { x = entity.position.x - 0.1, y = entity.position.y - 0.1 },
        right_bottom = { x = entity.position.x + 0.1, y = entity.position.y + 0.1 },
      }
    }) > 0

    if (p and not r) and not event.item then
      game.print("Broken shortwave blueprint! Cannot blueprint I/O port alone.")
      entity.destroy()
      return
    end
  
  -- check for cheat mode pipette of I/O port
  elseif entity.name == "shortwave-port" then
    local stack = event.stack
    -- If the port was *placed* by a valid blueprint, that means it was insta-placed by cheatmode or editor. Don't check for stranded ports.
    --game.print(serpent.line(event))
    --game.print(game.players[event.player_index].cursor_stack.valid_for_read)
    if not (stack and stack.valid_for_read and (stack.name == "blueprint" or event.stack.name == "blueprint-book")) then
      local r = entity.surface.count_entities_filtered({
        name = 'shortwave-radio',
        area = {
          left_top = { x = entity.position.x - 0.1, y = entity.position.y - 0.1 },
          right_bottom = { x = entity.position.x + 0.1, y = entity.position.y + 0.1 },
        }
      })
      if r == 0 then
        game.print("Can't place shortwave I/O port alone.")
        entity.destroy()
        return
      end
    end
  
  elseif entity.name == "shortwave-radio" then
    check_state(entity.force)
    radio_tune(entity)
    check_channels()
  end
end

local function OnEntityRemoved(event)
  local entity = event.entity
  check_state(entity.force)
  radio_link(entity).destroy()
  radio_port(entity).destroy()
  check_channels()
end

local function OnEntitySettingsPasted(event)
  local entity = event.destination

  if not entity or not entity.valid then
    return
  end

  if entity.name == "shortwave-radio" then
    check_state(entity.force)
    radio_tune(entity)
    check_channels()
  end
end


remote.add_interface('shortwave', {
    get_channel_merged_signals = function(force, channel)
      local team = force.index
      if global[team] and global[team][channel] then
        return global[team][channel].get_merged_signals()
      end
      return nil
    end,
    get_channel = function(radio)
      if radio and radio.valid and radio.name == 'shortwave-radio' then
        local signal = radio.get_control_behavior().get_signal(1)
        if signal and signal.signal then
          return signal.signal.name..":"..signal.count
        end
      end
      return nil
    end,
    get_relay = function(force, channel)
      local team = force.index
      return global[team] and global[team][channel]
    end,
  })


local built_filters = {
    {filter = "name", name = "shortwave-radio"},
    {filter = "name", name = "shortwave-port"},
    {filter = "ghost", ghost_name = "shortwave-radio"},
    {filter = "ghost", ghost_name = "shortwave-port"},
  }
script.on_event(defines.events.on_built_entity, OnEntityCreated, built_filters)
script.on_event(defines.events.on_robot_built_entity, OnEntityCreated, built_filters)
script.on_event(defines.events.script_raised_built, OnEntityCreated, built_filters)
script.on_event(defines.events.on_entity_cloned, OnEntityCreated, built_filters)
script.on_event(defines.events.script_raised_revive, OnEntityCreated, built_filters)

    
local mined_filters = {{filter = "name", name = "shortwave-radio"}}
script.on_event(defines.events.on_player_mined_entity, OnEntityRemoved, mined_filters)
script.on_event(defines.events.on_robot_pre_mined, OnEntityRemoved, mined_filters)
script.on_event(defines.events.on_entity_died, OnEntityRemoved, mined_filters)
script.on_event(defines.events.script_raised_destroy, OnEntityRemoved, mined_filters)

script.on_event({defines.events.on_entity_settings_pasted}, OnEntitySettingsPasted)

script.on_event(defines.events.on_player_pipette, function(event)
    blueprintLib.mapPipette(event, {["shortwave-port"]="shortwave-radio"})
  end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.entity and event.entity.name == "shortwave-radio" then
      check_state(event.entity.force)
      radio_tune(event.entity)
      check_channels()
    end
  end)

script.on_init(function()
end)

script.on_load(function()
end)
