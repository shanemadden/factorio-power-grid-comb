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

local function on_player_selected_area(event)
  if event.item ~= "power-grid-comb" then return end
  local unit_numbers = {}
  local x_axis = {}
  local y_axis = {}

  for _, entity in pairs(event.entities) do
    if entity.name == "ret-pole-wire" then goto continue end
    unit_numbers[entity.unit_number] = true
    ::continue::
  end

  for _, entity in pairs(event.entities) do
    if entity.name == "ret-pole-wire" then goto continue end
    local to_reconnect = {}
    local connector = get_copper_wire_connector(entity)
    if connector == nil then goto continue end
    for _, connection in pairs(connector.connections) do
      --  if the connection is not in the selected area, we need to reconnect it
      if not unit_numbers[connection.target.owner.unit_number] then
        to_reconnect[#to_reconnect + 1] = connection.target
      end
    end
    connector.disconnect_all()
    for _, connection in pairs(to_reconnect) do
      connector.connect_to(connection)
    end

    local position = entity.position
    local x, y = position.x, position.y

    local x_entities = x_axis[x] or {}
    x_axis[x] = x_entities
    x_entities[#x_entities + 1] = entity

    local y_entities = y_axis[y] or {}
    y_axis[y] = y_entities
    y_entities[#y_entities + 1] = entity

    ::continue::
  end

  for _, entities in pairs(x_axis) do
    table.sort(entities, function(a, b)
      return a.position.y < b.position.y
    end)
    for i = 2, #entities do
      get_copper_wire_connector(entities[i]).connect_to(get_copper_wire_connector(entities[i - 1]))
    end
  end

  for _, entities in pairs(y_axis) do
    table.sort(entities, function(a, b)
      return a.position.x < b.position.x
    end)
    for i = 2, #entities do
      get_copper_wire_connector(entities[i]).connect_to(get_copper_wire_connector(entities[i - 1]))
    end
  end
end
script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
