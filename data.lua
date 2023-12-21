local item = {
  type = "selection-tool",
  name = "power-grid-comb",
  subgroup = "tool",
  order = "z[power-grid-comb]",
  show_in_library = true,
  icons = {
    {
      icon = "__power-grid-comb__/graphics/icons/power-grid-comb.png",
      icon_size = 32,
    }
  },
  flags = {"only-in-cursor", "spawnable"},
  stack_size = 1,
  stackable = false,
  selection_color = { r = 0.72, g = 0.45, b = 0.2, a = 1 },
  alt_selection_color = { r = 0.72, g = 0.22, b = 0.1, a = 1 },
  selection_mode = { "buildable-type", "same-force" },
  alt_selection_mode = { "buildable-type", "same-force" },
  selection_cursor_box_type = "entity",
  alt_selection_cursor_box_type = "entity",
  entity_type_filters = {"electric-pole"},
  alt_entity_type_filters = {"electric-pole"},
}

local shortcut = {
  type = "shortcut",
  name = "shortcut-power-grid-comb-item",
  action = "spawn-item",
  item_to_spawn = "power-grid-comb",
  order = "m[power-grid-comb]",
  --style = "yellow",
  icon = {
    filename = "__power-grid-comb__/graphics/icons/power-grid-comb-x32.png",
    flags = {
      "icon"
    },
    priority = "extra-high-no-scale",
    scale = 1,
    size = 32
  },
  small_icon = {
    filename = "__power-grid-comb__/graphics/icons/power-grid-comb-x24.png",
    flags = {
      "icon"
    },
    priority = "extra-high-no-scale",
    scale = 1,
    size = 24
  },
  disabled_small_icon = {
    filename = "__power-grid-comb__/graphics/icons/power-grid-comb-x24-white.png",
    flags = {
      "icon"
    },
    priority = "extra-high-no-scale",
    scale = 1,
    size = 24
  },
}

data:extend{item, shortcut}
