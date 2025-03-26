
if not storage.teams then
  local teams = {}
  for force_index,channels in pairs(storage) do
    if game.forces[force_index] and game.forces[force_index].valid then
      teams[force_index] = channels
    end
  end
  local objects = storage.objects or {}
  storage = {objects=objects, teams=teams}
end

-- Register all existing links for on_object_destroyed
for team,channels in pairs(storage.teams) do
  for channel,link in pairs(channels) do
    if link.valid then
      storage.objects[script.register_on_object_destroyed(link)] = true
    end
  end
end

log("Migrated Shortwave storage table format.")
