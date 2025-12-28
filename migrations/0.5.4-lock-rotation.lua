for _,surface in pairs(game.surfaces) do
  for _,entity in pairs(surface.find_entities_filtered{name="shortwave-radio"}) do
    entity.rotatable = false
  end
  for _,entity in pairs(surface.find_entities_filtered{name="shortwave-port"}) do
    entity.rotatable = false
  end
end


