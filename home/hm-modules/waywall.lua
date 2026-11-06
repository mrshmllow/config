local waywall = require("waywall")
local helpers = require("waywall.helpers")

-- values taken from
-- https://github.com/DuncanRuns/Jingle/blob/7c0a4f48177d6dd150928858d664896d60ab7e4c/src/main/resources/defaultscripts/Resizing.lua#L46C86-L46C90

W = 2560
H = 1440

EYE_WIDTH = 384
EYE_HEIGHT = 16384

THIN_W = 350
THIN_H = 1100

WIDE_W = 2560
WIDE_H = 400

local toggle_eye_measure = helpers.toggle_res(EYE_WIDTH, EYE_HEIGHT, 0.18551335583797476)
local toggle_thin_bt = helpers.toggle_res(THIN_W, THIN_H)
local toggle_planar_abuse = helpers.toggle_res(WIDE_W, WIDE_H)

local config = {
	input = {
		layout = "mc",
		sensitivity = 2.7500000123822113,
		confine_pointer = true,
		remaps = {
			["TAB"] = "F3",
			["GRAVE"] = "TAB",
			["mouse5"] = "BACKSPACE",
		},
	},

	theme = {
		ninb_anchor = "right",
		background_png = paths.bg,
	},

	actions = {
		["*-9"] = function()
			waywall.exec(
				paths.java
					.. " -Dswing.defaultlaf=javax.swing.plaf.metal.MetalLookAndFeel -Dawt.useSystemAAFontSettings=on -jar "
					.. paths.ninb
			)
		end,

		["Ctrl-Shift-T"] = function()
			helpers.toggle_floating()
		end,

		["*-6"] = function()
			toggle_planar_abuse()
		end,

		["*-7"] = function()
			toggle_eye_measure()
		end,

		["*-8"] = function()
			toggle_thin_bt()
		end,
	},
}

X_ZOOM_SIZE = 100
Y_ZOOM_SIZE = 200

local eye_w = (W - EYE_WIDTH) / 2
local eye_h = (H * eye_w) / W
local eye_dst = { x = 0, y = (H - eye_h) / 2, w = eye_w, h = eye_h }
local mc_eye_w = 60
local mc_eye_h = 580
local mc_eye_x = (EYE_WIDTH - mc_eye_w) / 2
local mc_eye_y = (EYE_HEIGHT - mc_eye_h) / 2

-- eye:
helpers.res_mirror({
	src = {
		x = mc_eye_x,
		y = mc_eye_y,
		w = mc_eye_w,
		h = mc_eye_h,
	},
	dst = eye_dst,
	depth = 0,
}, EYE_WIDTH, EYE_HEIGHT)
helpers.res_image(paths.overlay, {
	dst = eye_dst,
	depth = 1,
}, EYE_WIDTH, EYE_HEIGHT)
-- waywall.listen("resolution", function()
--      local width, height = waywall.active_res()
--
--      waywall.set_sensitivity((width == EYE_WIDTH and height == EYE_HEIGHT) and 0.1 or 0)
-- end)

local thin_text = nil
waywall.listen("resolution", function()
	local width, height = waywall.active_res()

	if width == THIN_W and height == H then
		thin_text = waywall.text("pure        ~30%\nchest front 50%\nchest back  64%", {
			x = W / 20,
			y = 850,
			size = 4,
			color = "#fc0349",
		})
	else
		if thin_text ~= nil then
			thin_text:close()
			thin_text = nil
		end
	end
end)

helpers.res_mirror({
	src = {
		x = 100,
		y = 300,
		w = 500,
		h = 27,
	},
	dst = {
		x = W / 2 - 500 / 2,
		y = H - (H / 4),
		w = 500 * 2,
		h = 27 * 2,
	},
	color_key = {
		input = "#dddddd",
		output = "#dddddd",
	},
	depth = 1,
}, 0, 0)

return config
