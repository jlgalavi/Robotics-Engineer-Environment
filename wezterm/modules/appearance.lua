local wezterm = require 'wezterm'
local robotics = require 'themes.robotics'

local M = {}

wezterm.on('format-window-title', function()
  return 'Robotics Engineer Profile'
end)

function M.apply(config)

  -- General appearance settings
  config.font_size = 12.0
  config.enable_tab_bar = true
  config.hide_tab_bar_if_only_one_tab = true
  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = false
  config.show_new_tab_button_in_tab_bar = false
  config.show_tab_index_in_tab_bar = true

  config.colors = config.colors or {}
  config.colors.tab_bar = {
    background = '#11111B',

    active_tab = {
      bg_color = '#313244',
      fg_color = '#CDD6F4',
      intensity = 'Bold',
    },

    inactive_tab = {
      bg_color = '#181825',
      fg_color = '#7F849C',
    },

    inactive_tab_hover = {
      bg_color = '#1E1E2E',
      fg_color = '#CDD6F4',
      italic = false,
    },

    new_tab = {
      bg_color = '#11111B',
      fg_color = '#7F849C',
    },

    new_tab_hover = {
      bg_color = '#1E1E2E',
      fg_color = '#CDD6F4',
    },
  }

  config.window_padding = {
    left = 8,
    right = 8,
    top = 8,
    bottom = 8,
  }

  -- Color scheme
  config.color_schemes = {
    [robotics.name] = robotics.colors,
  }
  config.color_scheme = robotics.name

  config.window_background_image = wezterm.config_dir .. '/backgrounds/neolight_tokyo_night.png'
  config.window_background_image_hsb = {
    brightness = 0.08,
    hue = 1.0,
    saturation = 0.75,
  }
  config.window_background_opacity = 0.94
  
  -- Cursor 
  config.default_cursor_style = 'BlinkingBar'
  config.cursor_blink_rate = 550

  config.colors = config.colors or {}
  config.colors.cursor_bg = '#89B4FA'
  config.colors.cursor_fg = '#11111B'
  config.colors.cursor_border = '#89B4FA'

  -- Pane borders / inactive panes
  config.inactive_pane_hsb = {
    saturation = 0.75,
    brightness = 0.55,
  }

  config.colors = config.colors or {}
  config.colors.split = '#7F849C'
end

return M
