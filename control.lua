-- Get the copper wire connector from an entity
-- if it exists, return it, otherwise return nil
local function get_copper_wire_connector(entity)
  local connectors = entity.get_wire_connectors(false)
  for _, connector in pairs(connectors) do
    if connector.wire_type == defines.wire_type.copper then
      return connector
    end
  end
  return nil
end


local function find_pole_in_direction(entity, direction, distance)
  local selection_box = entity.prototype.selection_box
  local area
  if direction == defines.direction.north then
    -- top left - top left of current plus distance north
    -- bot right - top right of current
    area = { { entity.position.x + selection_box.left_top.x, entity.position.y + selection_box.left_top.y - distance },
      { entity.position.x + selection_box.right_bottom.x, entity.position.y + selection_box.left_top.y } }
  elseif direction == defines.direction.south then
    -- top left - bot left of current
    -- bot right - bot right of current plus distance south
    area = { { entity.position.x + selection_box.left_top.x, entity.position.y + selection_box.right_bottom.y },
      { entity.position.x + selection_box.right_bottom.x, entity.position.y + selection_box.right_bottom.y + distance } }
  elseif direction == defines.direction.west then
    -- top left - top left of current plus distance west
    -- bot right - bot left of current
    area = { { entity.position.x + selection_box.left_top.x - distance, entity.position.y + selection_box.left_top.y },
      { entity.position.x + selection_box.left_top.x,            entity.position.y + selection_box.right_bottom.y } }
  elseif direction == defines.direction.east then
    -- top left - top right of current
    -- bot right - bot right of current plus distance east
    area = { { entity.position.x + selection_box.right_bottom.x,   entity.position.y + selection_box.left_top.y },
      { entity.position.x + selection_box.right_bottom.x + distance, entity.position.y + selection_box.right_bottom.y } }
  end
  local closest_distance = nil
  local closest = nil
  local entities = entity.surface.find_entities_filtered({
    area = area,
    type = "electric-pole",
    force = entity.force,
  })
  for _, found_entity in pairs(entities) do
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

local function on_player_selected_area(event)
  if event.item == "power-grid-comb" then
    local distances = {}
    local entities = {}
    for _, entity in pairs(event.entities) do
      if entity.type == "electric-pole" then
        local max_wire_distance = entity.prototype.get_max_wire_distance(entity.quality)
        if not entities[max_wire_distance] then
          entities[max_wire_distance] = {}
          table.insert(distances, max_wire_distance)
        end
        table.insert(entities[max_wire_distance], entity)
      end
    end
    table.sort(distances)
    for _, distance in pairs(distances) do
      for _, entity in pairs(entities[distance]) do
        local connector = get_copper_wire_connector(entity)
        if connector ~= nil then
          connector.disconnect_all()
        end
        for _, direction in pairs(scan) do
          local pole = find_pole_in_direction(entity, direction, distance
          )
          if pole ~= nil and connector ~= nil then
            local pole_connector = get_copper_wire_connector(pole)
            if pole_connector ~= nil then
              connector.connect_to(pole_connector)
            end
          end
        end
      end
    end
  end
end
script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
