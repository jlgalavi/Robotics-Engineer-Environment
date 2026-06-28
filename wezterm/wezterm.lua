local wezterm = require 'wezterm'

local config = wezterm.config_builder()

require('modules.appearance').apply(config)
require('modules.fonts').apply(config)
require('modules.keys').apply(config)
require('modules.ros').apply(config)
require('modules.workspace').apply(config)

config.default_prog = { '/bin/bash' }

return config
