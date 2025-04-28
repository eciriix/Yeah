return {
	["CHARACTER_SMOOTH_ROTATION"]   = true,                       --// If your character should rotate smoothly or not
	["CHARACTER_ROTATION_SPEED"]    = 4,                          --// How quickly character rotates smoothly
	["OFFSET_TRANSITION_DAMPER"]    = 0.7,                        --// Camera transition spring damper, test it out to see what works for you
	["OFFSET_TRANSITION_IN_SPEED"]  = 6,                         --// How quickly locked camera moves to offset position
	["OFFSET_TRANSITION_OUT_SPEED"] = 10,                         --// How quickly locked camera moves back from offset position
	["LOCKED_CAMERA_OFFSET"]        = Vector3.new(1.75, 0.25, 0), --// Locked camera offset
	["LOCKED_MOUSE_ICON"]           =                             --// Locked mouse icon
		"http://www.roblox.com/asset/?id=17525212639",
	["SHIFT_LOCK_KEYBINDS"]         =                             --// Shift lock keybinds
		{ Enum.KeyCode.LeftAlt}
}
