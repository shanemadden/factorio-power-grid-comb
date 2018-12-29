
local function on_player_selected_area(event)
  if event.item == "power-grid-comb" then
    local distances = {}
    local create = {}
    for k, entity in pairs(event.entities) do
      if entity.type == "electric-pole" then
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
      end
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
end
script.on_event(defines.events.on_player_selected_area, on_player_selected_area)

local function find_pole_in_direction(entity, direction, distance)
  local selection_box = entity.prototype.selection_box
  local area
  if direction == defines.direction.north then
    -- top left - top left of current plus distance north
    -- bot right - top right of current
    area = {{entity.position.x + selection_box.left_top.x,                entity.position.y + selection_box.left_top.y - distance},
            {entity.position.x + selection_box.right_bottom.x,            entity.position.y + selection_box.left_top.y}}
  elseif direction == defines.direction.south then
    -- top left - bot left of current
    -- bot right - bot right of current plus distance south
    area = {{entity.position.x + selection_box.left_top.x,                entity.position.y + selection_box.right_bottom.y},
            {entity.position.x + selection_box.right_bottom.x,            entity.position.y + selection_box.right_bottom.y + distance}}
  elseif direction == defines.direction.west then
    -- top left - top left of current plus distance west
    -- bot right - bot left of current
    area = {{entity.position.x + selection_box.left_top.x - distance,     entity.position.y + selection_box.left_top.y},
            {entity.position.x + selection_box.left_top.x,                entity.position.y + selection_box.right_bottom.y}}
  elseif direction == defines.direction.east then
    -- top left - top right of current
    -- bot right - bot right of current plus distance east
    area = {{entity.position.x + selection_box.right_bottom.x,            entity.position.y + selection_box.left_top.y},
            {entity.position.x + selection_box.right_bottom.x + distance, entity.position.y + selection_box.right_bottom.y}}
  end
  local closest_distance
  local closest
  local entities = entity.surface.find_entities_filtered({
    area = area,
    type = "electric-pole",
    force = entity.force,
  })
  for _, found_entity in ipairs(entities) do
    local x_dist = math.abs(entity.position.x - found_entity.position.x)
    local y_dist = math.abs(entity.position.y - found_entity.position.y)
    local found_distance = math.sqrt(x_dist * x_dist + y_dist * y_dist)
    if found_distance <= distance and (closest_distance == nil or found_distance < closest_distance) then
      closest = found_entity
      closest_distance = found_distance
    end
  end
  return closest
end

local scan = {
  defines.direction.north,
  defines.direction.south,
  defines.direction.east,
  defines.direction.west,
}

local function on_player_alt_selected_area(event)
  if event.item == "power-grid-comb" then
    local distances = {}
    local entities = {}
    for k, entity in pairs(event.entities) do
      if entity.type == "electric-pole" then
        local max_wire_distance = entity.prototype.max_wire_distance
        if not entities[max_wire_distance] then
          entities[max_wire_distance] = {}
          table.insert(distances, max_wire_distance)
        end
        table.insert(entities[max_wire_distance], entity)
      end
    end
    table.sort(distances)
    for _, distance in ipairs(distances) do
      for k, entity in pairs(entities[distance]) do
        entity.disconnect_neighbour()
        for _, direction in ipairs(scan) do
          local pole = find_pole_in_direction(entity, direction, distance)
          if pole then
            entity.connect_neighbour(pole)
          end
        end
      end
    end
  end
end
script.on_event(defines.events.on_player_alt_selected_area, on_player_alt_selected_area)
