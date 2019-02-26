local item = {
  type = "selection-tool",
  name = "power-grid-comb",
  subgroup = "tool",
  order = "z[power-grid-comb]",
  icons = {
    {
      icon = "__power-grid-comb__/graphics/icons/power-grid-comb.png",
      icon_size = 32,
    }
  },
  flags = {},
  stack_size = 1,
  stackable = false,
  selection_color = { r = 0.72, g = 0.45, b = 0.2, a = 1 },
  alt_selection_color = { r = 0.72, g = 0.22, b = 0.1, a = 1 },
  selection_mode = { "buildable-type", "same-force" },
  alt_selection_mode = { "buildable-type", "same-force" },
  selection_cursor_box_type = "entity",
  alt_selection_cursor_box_type = "entity",
  --can_be_mod_opened = true,
}

local recipe = {
  type = "recipe",
  name = "power-grid-comb",
  enabled = true,
  ingredients = {
    {'electronic-circuit', 20},
    {'copper-cable', 50},
  },
  result = "power-grid-comb",
}

data:extend{item, recipe}