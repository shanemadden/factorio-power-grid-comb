local function on_player_selected_area(event)
  if event.item == "power-grid-comb" then
    local create = {}
    for k, entity in pairs(event.entities) do
      if entity.type == "electric-pole" then
        local info = {
          surface = entity.surface,
          name = entity.name,
          position = entity.position,
          health = entity.health,
          force = entity.force,
          connections = {},
        }
        for k, connection in pairs(entity.circuit_connection_definitions) do
          info.connections[k] = {
            wire = connection.wire,
            source_circuit_id = connection.source_circuit_id,
            target_circuit_id = connection.target_circuit_id,
            target_position = connection.target_entity.position,
            target_name = connection.target_entity.name,
          }
        end
        table.insert(create, info)
        entity.destroy()
      end
    end
    for k, newinfo in pairs(create) do
      local newpole = newinfo.surface.create_entity({
        name = newinfo.name,
        position = newinfo.position,
        force = newinfo.force,
      })
      newpole.health = newinfo.health
      create[k].newpole = newpole
    end
    for i, newinfo in pairs(create) do
      for k, connection in pairs(newinfo.connections) do
        local target = newinfo.surface.find_entity(connection.target_name, connection.target_position)
        if target then
          newinfo.newpole.connect_neighbour({
            wire = connection.wire,
            target_entity = newinfo.surface.find_entity(connection.target_name, connection.target_position),
            source_circuit_id = connection.source_circuit_id,
            target_circuit_id = connection.target_circuit_id,
          })
        end
      end
    end
  end
end
script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
