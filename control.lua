local math2d = require("math2d")

local function check_state(force)
  if not storage[force.index] then
    storage[force.index] = {}
  end
end

local function get_channel_string(radio, toggle)
  local cb = radio.get_control_behavior()
  if cb.sections_count == 0 then
    cb.add_section()  -- Make sure there is always one section
  else
    while cb.sections_count > 1 do
      cb.remove_section(2)
    end
  end
  
  -- If "toggle" is true, it means that the toggle-entity keybind is *about to* change the enable state of this combinator.
  -- It doesn't actually happen until after the linked custom input has executed, so we have to assume that it will toggle in the future.
  if (not cb.enabled and not toggle) or (cb.enabled and toggle) then
    return
  end
  
  local section = cb.get_section(1)
  if not section then
    return
  end
  
  local channel_slot = section.get_slot(1)
  if not channel_slot or not channel_slot.value then
    return
  end
  
  local channel_string = channel_slot.value.name..":"..channel_slot.min
  for i=2,section.filters_count do
    channel_slot = section.get_slot(i)
    channel_string = channel_string.."." -- Delimit each slot string with a period
    if channel_slot and channel_slot.value then -- If the slot is non-empty, use its name:value combination
      channel_string = channel_string..channel_slot.value.name..":"..channel_slot.min
    end
  end
  return channel_string
end

local function check_channels()
  for team,channels in pairs(storage) do
    for channel,link in pairs(channels) do
      if not link or not link.valid then
        log("Shortwave origin link became invalid for channel "..tostring(team).."."..channel..", channel removed.")
        channels[channel] = nil
      else
        local link_red = link.get_wire_connector(defines.wire_connector_id.circuit_red)
        local link_green = link.get_wire_connector(defines.wire_connector_id.circuit_green)
        if link_red.connection_count == 0 and link_green.connection_count == 0 then
          link.destroy()
          channels[channel] = nil
        end
      end
    end
  end
end

local function radio_link(radio)
  local links = radio.surface.find_entities_filtered{
    name = "shortwave-link",
    area = math2d.bounding_box.create_from_centre(radio.position, 0.5)
  }

  local link = links and links[1]

  if not link then
    link = radio.surface.create_entity{
      name = "shortwave-link",
      position = radio.position,
      force = radio.force,
    }
  end

  link.operable = false

  return link
end

local function radio_port(radio)
  local ports = radio.surface.find_entities_filtered{
    name = "shortwave-port",
    area = math2d.bounding_box.create_from_centre(radio.position, 0.5)
  }

  local ghosts = radio.surface.find_entities_filtered{
    ghost_name = "shortwave-port",
    area = math2d.bounding_box.create_from_centre(radio.position, 0.5)
  }

  local port = ports and ports[1]

  if not port and ghosts and ghosts[1] then
    local ddd
    ddd, port = ghosts[1].revive()
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
  
  return port
end

local function radio_tune(radio, toggle)
  local team = radio.force.index
  local link = radio_link(radio)
  local port = radio_port(radio)
  local link_red = link.get_wire_connector(defines.wire_connector_id.circuit_red)
  local link_green = link.get_wire_connector(defines.wire_connector_id.circuit_green)

  for _, connection in pairs(link_red.connections) do
    if connection.target.owner.name == "shortwave-link" then
      link_red.disconnect_from(connection.target, defines.wire_origin.script)
    end
  end
  
  for _, connection in pairs(link_green.connections) do
    if connection.target.owner.name == "shortwave-link" then
      link_green.disconnect_from(connection.target, defines.wire_origin.script)
    end
  end

  local channel = get_channel_string(radio, toggle)
  if not channel then
    --game.print("Radio disabled")
    return
  end

  if not storage[team][channel] then
    storage[team][channel] = radio.surface.create_entity{
      name = "shortwave-link",
      position = { 0, 0 },
      force = radio.force,
    }
  end

  local relay = storage[team][channel]
  local relay_red = relay.get_wire_connector(defines.wire_connector_id.circuit_red)
  local relay_green = relay.get_wire_connector(defines.wire_connector_id.circuit_green)

  link_red.connect_to(relay_red, false, defines.wire_origin.script)
  link_green.connect_to(relay_green, false, defines.wire_origin.script)

  local port_red = port.get_wire_connector(defines.wire_connector_id.combinator_input_red)
  local port_green = port.get_wire_connector(defines.wire_connector_id.combinator_input_green)
  
  link_red.connect_to(port_red, false, defines.wire_origin.script)
  link_green.connect_to(port_green, false, defines.wire_origin.script)

  --game.print("Radio tuned")
end

local function OnEntityCreated(event)
  local entity = event.entity or event.destination
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

local function OnEntitySettingChanged(event)
  local entity = event.entity or event.destination
  local toggle = false
  if event.input_name == "shortwave-toggle" then
    entity = event.player_index and game.players[event.player_index].selected
    toggle = true
  end

  if not entity or not entity.valid then
    return
  end

  if entity.name == "shortwave-radio" then
    check_state(entity.force)
    radio_tune(entity, toggle)
    check_channels()
  end
end


remote.add_interface('shortwave', {
    get_channel_merged_signals = function(force, channel)
      local team = force.valid and force.index
      if storage[team] and storage[team][channel] then
        return storage[team][channel].get_signals(defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)
      end
    end,
    get_channel = function(radio)
      if radio.valid and radio.name == 'shortwave-radio' then
        return get_channel_string(radio)
      end
    end,
    get_relay = function(force, channel)
      local team = force.valid and force.index
      return storage[team] and storage[team][channel]
    end,
    get_relays = function()
      return storage
    end,
    get_force_relays = function(force)
      local team = force.valid and force.index
      return storage[team]
    end,
    get_relay_channel = function(relay)
      local team = relay.valid and relay.force.index
      for channel, entity in pairs(storage[team] or {}) do
        if relay == entity then
          return channel
        end
      end
    end,
  }
)

-- When radios are created
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
script.on_event(defines.events.on_space_platform_built_entity, OnEntityCreated, built_filters)

-- When radios are destroyed
local mined_filters = {{filter = "name", name = "shortwave-radio"}}
script.on_event(defines.events.on_player_mined_entity, OnEntityRemoved, mined_filters)
script.on_event(defines.events.on_robot_pre_mined, OnEntityRemoved, mined_filters)
script.on_event(defines.events.on_entity_died, OnEntityRemoved, mined_filters)
script.on_event(defines.events.script_raised_destroy, OnEntityRemoved, mined_filters)
script.on_event(defines.events.on_space_platform_mined_entity, OnEntityRemoved, mined_filters)

-- When player changes settings
script.on_event(defines.events.on_gui_closed, OnEntitySettingChanged)
script.on_event(defines.events.on_entity_settings_pasted, OnEntitySettingChanged)
script.on_event("shortwave-toggle", OnEntitySettingChanged)

-- When player pipettes radio
script.on_event(defines.events.on_player_pipette, function(event)
  local player = game.players[event.player_index]
  if event.item.name ==  "shortwave-port" then
    player.cursor_stack.clear()
    player.pipette_entity({name="shortwave-radio", quality=event.quality})
  end
end)

-- No work on startup
--script.on_init(function()
--end)

--script.on_load(function()
--end)


-- Console commands
commands.add_command("shortwave-dump", "Dump storage to log", function() log(serpent.block(storage)) end)

------------------------------------------------------------------------------------
--                    FIND LOCAL VARIABLES THAT ARE USED GLOBALLY                 --
--                              (Thanks to eradicator!)                           --
------------------------------------------------------------------------------------
setmetatable(_ENV,{
  __newindex=function (self,key,value) --locked_global_write
    error('\n\n[ER Global Lock] Forbidden global *write*:\n'
      .. serpent.line{key=key or '<nil>',value=value or '<nil>'}..'\n')
    end,
  __index   =function (self,key) --locked_global_read
    error('\n\n[ER Global Lock] Forbidden global *read*:\n'
      .. serpent.line{key=key or '<nil>'}..'\n')
    end ,
  })
