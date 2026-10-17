-- Hollow Purple tuning. Lives at ReplicatedStorage.HollowPurple.Config so the
-- server (timing, damage) and every client (visuals) read the same numbers.
return {
	-- Timeline (seconds). Red and blue orbs converge until MergeTime, then the
	-- purple sphere charges until ChargeTime and launches.
	Cooldown = 6,
	MergeTime = 0.9,
	ChargeTime = 2.0,
	ChargeWalkSpeed = 4,

	-- Projectile
	ProjectileSpeed = 150,
	MaxRange = 320,
	SphereOffset = Vector3.new(0, 0.6, -2.6), -- in front of the chest, relative to HumanoidRootPart

	-- Impact. Set Damage and Knockback to 0 for a pure visual showcase.
	ExplosionRadius = 26,
	Damage = 40,
	Knockback = 90,

	-- Camera
	ShakeRadius = 260, -- players further than this from an event feel no shake/flash
	ImpactShake = 1.0,
	LaunchShake = 0.4,

	Colors = {
		Purple = Color3.fromRGB(165, 60, 255),
		Violet = Color3.fromRGB(110, 20, 210),
		Core = Color3.fromRGB(250, 235, 255),
		Red = Color3.fromRGB(255, 40, 60),
		Blue = Color3.fromRGB(50, 130, 255),
		Void = Color3.fromRGB(25, 0, 45),
	},

	-- Built-in Roblox particle textures, so nothing has to be uploaded.
	Textures = {
		Sparkle = "rbxasset://textures/particles/sparkles_main.dds",
		Smoke = "rbxasset://textures/particles/smoke_main.dds",
		Fire = "rbxasset://textures/particles/fire_main.dds",
	},

	-- Optional sound asset ids, e.g. "rbxassetid://123456". Sounds dropped into
	-- ReplicatedStorage.HollowPurple.VFX.Sounds (named Charge/Merge/Launch/Impact)
	-- take priority over these.
	Sounds = {
		Charge = "",
		Merge = "",
		Launch = "",
		Impact = "",
	},

	-- Optional charging animation id. Empty = built-in procedural arm pose.
	AnimationId = "",
}
