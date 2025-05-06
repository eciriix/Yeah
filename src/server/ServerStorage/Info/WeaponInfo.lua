local module = {}

local info = {
	['Blocking'] = {
		ParryFrame = .35;
	},
	
	['MSword'] = {
		Damage = 3;
		HeavyDamage = 5;
		SwingSpeed = 0.75;
		WaitBetweenHits = .15;
		SwordSwingPause = .1;
		HitboxSize = Vector3.new(8,6,6);
		HeavyHitboxSize = Vector3.new(8,6,5);
		HitboxOffset = CFrame.new(0,0,-2.5);
		HeavyHitboxOffset = CFrame.new(0,0,-3.5);
		HeavyForwardTime = .2;
		MaxCombo = 4;
	},
	['HSword'] = {
		Damage = 5;
		HeavyDamage = 7;
		SwingSpeed = 0.65;
		WaitBetweenHits = .15;
		SwordSwingPause = .1;
		HitboxSize = Vector3.new(8,6,7);
		HeavyHitboxSize = Vector3.new(4,6,6);
		HitboxOffset = CFrame.new(0,0,-3);
		HeavyHitboxOffset = CFrame.new(0,0,-3.5);
		HeavyForwardTime = .10;
		MaxCombo = 4;
	},
	['Fists'] = {
		Damage = 3;
		HeavyDamage = 5;
		SwingSpeed = 0.75;
		WaitBetweenHits = .15;
		SwordSwingPause = .1;
		HitboxSize = Vector3.new(8,6,6);
		HeavyHitboxSize = Vector3.new(8,6,5);
		HitboxOffset = CFrame.new(0,0,-2.5);
		HeavyHitboxOffset = CFrame.new(0,0,-3.5);
		HeavyForwardTime = .2;
		MaxCombo = 4;
	},
}

function module:getWeapon(WeaponName :string)
	return info[WeaponName]
end

return module
