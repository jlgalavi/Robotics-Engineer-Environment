local wezterm = require 'wezterm'
local act = wezterm.action

local M = {}

M.families = {
  'JetBrains Mono',
  'DejaVu Sans Mono',
  'Liberation Mono',
  'Noto Sans Mono',
  'Nimbus Mono PS',
}

local function font_stack(family)
  return wezterm.font_with_fallback {
    family,
    'Noto Color Emoji',
    'Symbols Nerd Font Mono',
  }
end

function M.apply(config)
  config.font = font_stack(M.families[1])
end

function M.selector()
  local choices = {}

  for _, family in ipairs(M.families) do
    table.insert(choices, { id = family, label = family })
  end

  return act.InputSelector {
    title = 'Seleccionar fuente',
    fuzzy = true,
    choices = choices,
    action = wezterm.action_callback(function(window, _pane, id, _label)
      if not id then
        return
      end

      local overrides = window:get_config_overrides() or {}
      overrides.font = font_stack(id)
      window:set_config_overrides(overrides)
      window:toast_notification('WezTerm', 'Fuente: ' .. id, nil, 2500)
    end),
  }
end

return M
