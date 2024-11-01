
local function on_player_selected_area(event)
  if event.item ~= "power-grid-comb" then return end
  local distances = {}
  local create = {}
  for k, entity in pairs(event.entities) do
    if entity.name == "ret-pole-wire" then goto continue end
    local info = {
      surface = entity.surface,
      name = entity.name,
      unit_number = entity.unit_number,
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
        target_unit_number = connection.target_entity.unit_number,
        target_entity = connection.target_entity,
      }
    end
    local max_wire_distance = entity.prototype.max_wire_distance
    if create[max_wire_distance] == nil then
      create[max_wire_distance] = {}
      table.insert(distances, max_wire_distance)
    end
    table.insert(create[max_wire_distance], info)
    entity.destroy()
    ::continue::
  end
  table.sort(distances)
  local old_new_map = {}
  for _, distance in ipairs(distances) do
    for k, newinfo in pairs(create[distance]) do
      local newpole = newinfo.surface.create_entity({
        name = newinfo.name,
        position = newinfo.position,
        force = newinfo.force,
      })
      newpole.health = newinfo.health
      create[distance][k].newpole = newpole
      old_new_map[newinfo.unit_number] = newpole
    end
  end
  for _, distance in ipairs(distances) do
    for _, newinfo in pairs(create[distance]) do
      for k, connection in pairs(newinfo.connections) do
        local target
        if connection.target_entity.valid then
          target = connection.target_entity
        else
          target = old_new_map[connection.target_unit_number]
        end
        if target then
          newinfo.newpole.connect_neighbour({
            wire = connection.wire,
            target_entity = target,
            source_circuit_id = connection.source_circuit_id,
            target_circuit_id = connection.target_circuit_id,
          })
        end
      end
    end
  end
end
script.on_event(defines.events.on_player_selected_area, on_player_selected_area)

local function on_player_alt_selected_area(event)
  if event.item ~= "power-grid-comb" then return end
  local unit_numbers = {}
  local x_axis = {}
  local y_axis = {}
  for _, entity in pairs(event.entities) do
    if entity.name == "ret-pole-wire" then goto continue end

    unit_numbers[entity.unit_number] = true
    local to_reconnect = {}
    local len = 0
    for _, connection in pairs(entity.neighbours.copper) do
      if not unit_numbers[connection.unit_number] then
        len = len + 1
        to_reconnect[len] = connection
      end
    end
    entity.disconnect_neighbour()
    for _, connection in pairs(to_reconnect) do
      entity.connect_neighbour(connection)
    end

    local position = entity.position
    local x, y = position.x, position.y

    local x_entities = x_axis[x] or {}
    x_axis[x] = x_entities
    x_entities[#x_entities+1] = entity

    local y_entities = y_axis[y] or {}
    y_axis[y] = y_entities
    y_entities[#y_entities+1] = entity

    ::continue::
  end

  for _, entities in pairs(x_axis) do
    table.sort(entities, function(a, b)
      return a.position.y < b.position.y
    end)
    for i = 2, #entities do
      entities[i].connect_neighbour(entities[i-1])
    end
  end

  for _, entities in pairs(y_axis) do
    table.sort(entities, function(a, b)
      return a.position.x < b.position.x
    end)
    for i = 2, #entities do
      entities[i].connect_neighbour(entities[i-1])
    end
  end
end
script.on_event(defines.events.on_player_alt_selected_area, on_player_alt_selected_area)
