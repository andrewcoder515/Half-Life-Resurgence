AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2020 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/vj_hlr/opfor/geneworm.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 1200
ENT.SightAngle = 120 -- The sight angle | Example: 180 would make the it see all around it | Measured in degrees and then converted to radians
ENT.HullType = HULL_LARGE
ENT.VJ_IsHugeMonster = true -- Is this a huge monster?
ENT.MovementType = VJ_MOVETYPE_STATIONARY -- How does the SNPC move?
ENT.CanTurnWhileStationary = false -- If set to true, the SNPC will be able to turn while it's a stationary SNPC
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.CustomBlood_Particle = {"vj_hl_blood_yellow_large"}
ENT.CustomBlood_Decal = {"VJ_HLR_Blood_Yellow"} -- Decals to spawn when it's damaged
ENT.HasBloodPool = false -- Does it have a blood pool?
ENT.VJ_NPC_Class = {"CLASS_RACE_X"} -- NPCs with the same class with be allied to each other

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDamage = 60
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1} -- Melee Attack Animations
ENT.MeleeAttackAnimationFaceEnemy = true -- Should it face the enemy while playing the melee attack animation?
ENT.MeleeAttackDistance = 250 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 500 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something
ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy
ENT.MeleeAttackKnockBack_Forward1 = 400 -- How far it will push you forward | First in math.random
ENT.MeleeAttackKnockBack_Forward2 = 500 -- How far it will push you forward | Second in math.random

ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.RangeAttackEntityToSpawn = "obj_vj_hlrof_gw_biotoxin" -- The entity that is spawned when range attacking
ENT.AnimTbl_RangeAttack = {ACT_RANGE_ATTACK1} -- Range Attack Animations
ENT.RangeDistance = 6000 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 500 -- How close does it have to be until it uses melee?
ENT.TimeUntilRangeAttackProjectileRelease = 2.1 -- How much time until the projectile code is ran?
ENT.RangeAttackExtraTimers = {2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 4, 4.1, 4.2, 4.3} -- Extra range attack timers | it will run the projectile code after the given amount of seconds
ENT.NextRangeAttackTime = 2 -- How much time until it can use a range attack?
ENT.NextRangeAttackTime_DoRand = 4 -- False = Don't use random time | Number = Picks a random number between the regular timer and this timer
ENT.RangeUseAttachmentForPos = true -- Should the projectile spawn on a attachment?
ENT.RangeUseAttachmentForPosID = "mouth" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true

ENT.HasDeathAnimation = true -- Does it play an animation when it dies?
ENT.AnimTbl_Death = {"death"} -- Death Animations
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Breath = {}
ENT.SoundTbl_Idle = {"vj_hlr/hl1_npc/geneworm/geneworm_idle1.wav","vj_hlr/hl1_npc/geneworm/geneworm_idle2.wav","vj_hlr/hl1_npc/geneworm/geneworm_idle3.wav","vj_hlr/hl1_npc/geneworm/geneworm_idle4.wav"}
ENT.SoundTbl_MeleeAttack = {}
ENT.SoundTbl_MeleeAttackMiss = {}
ENT.SoundTbl_Death = {"vj_hlr/hl1_npc/geneworm/geneworm_death.wav"}

ENT.IdleSoundLevel = 90
ENT.BeforeMeleeAttackSoundLevel = 90
ENT.BeforeRangeAttackSoundLevel = 90
ENT.PainSoundLevel = 90
ENT.DeathSoundLevel = 90

-- Custom
ENT.GW_Fade = 0 -- 0 = No fade | 1 = Fade in | 2 = Fade out
ENT.GW_EyeHealth = {}
ENT.GW_OrbOpen = false
ENT.GW_OrbHealth = 1 // 100

/* TODO:
	- Add lights to the eyes
	- Shock trooper spawn on pain_4
	- Add sounds
	- Death animation
	- Death particles
	- Set eye and orb health back to 100!
*/
 local defEyeHealth = 1 // 100
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(400, 400, 350), Vector(-400, -400, -240))
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.GW_EyeHealth = {r=defEyeHealth, l=defEyeHealth}
	
	self.Portal = ents.Create("prop_vj_animatable")
	self.Portal:SetModel("models/vj_hlr/opfor/effects/geneportal.mdl")
	self.Portal:SetPos(self:GetPos() + self:GetForward()*-507)
	self.Portal:SetAngles(self:GetAngles())
	self.Portal:SetParent(self)
	self.Portal:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self.Portal:Spawn()
	self.Portal:Activate()
	self:DeleteOnRemove(self.Portal)
	-- Fade in on spawn, if AI is disabled, then don't do it
	/*if GetConVarNumber("ai_disabled") == 0 then
		self.Portal:ResetSequence("open")
		timer.Simple(12, function()
			if IsValid(self) && IsValid(self.Portal) && self.Portal:GetSequenceName(self.Portal:GetSequence()) == "open" then
				self.Portal:ResetSequence("idle")
			end
		end)
		self:SetColor(Color(255, 255, 255, 0))
		self.GW_Fade = 1
		timer.Simple(0.01, function()
			if IsValid(self) then
				VJ_EmitSound(self, "vj_hlr/hl1_npc/geneworm/geneworm_entry.wav", 90)
				self:VJ_ACT_PLAYACTIVITY(ACT_ARM, true, false)
			end
		end)
	else
		self.Portal:ResetSequence("idle")
	end*/
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key, activator, caller, data)
	print(key)
	if key == "melee" or key == "shakeworld" then
		self:MeleeAttackCode()
	//elseif key == "spit_start" then
		//self:RangeAttackCode()
	elseif key == "spawn_portal" then
		-- Spawn shock trooper
		local at = self:GetAttachment(self:LookupAttachment("orb"))
		sprite = ents.Create("obj_vj_hlrof_gw_spawner")
		sprite:SetPos(at.Pos)
		sprite:SetAngles(at.Ang)
		sprite:Spawn()
		sprite:Activate()
		local phys = sprite:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:EnableGravity(false)
			phys:EnableDrag(false)
			phys:SetVelocity(self:CalculateProjectile("Line", sprite:GetPos(), at.Pos + at.Ang:Forward()*500, 500))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	-- Fade in animation (On Spawn)
	local a = self:GetColor().a
	if self.GW_Fade == 1 && a < 255 then
		self:SetColor(Color(255, 255, 255, a + 2))
		if self:GetColor().a >= 255 then
			self.GW_Fade = 0
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetNearestPointToEntityPosition()
	return self:GetPos() + self:GetForward()*200 -- Override this to use a different position
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetMeleeAttackDamagePosition()
	return self:GetPos() + self:GetForward()*200 -- Override this to use a different position
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_BeforeStartTimer()
	local ene = self:GetEnemy()
	if !IsValid(ene) then return end
	local posR = self:GetPos() + self:GetForward()*200 + self:GetRight()*300
	local posL = self:GetPos() + self:GetForward()*200 + self:GetRight()*-300
	if math.random(1, 2) == 1 then
		self.AnimTbl_MeleeAttack = {ACT_SPECIAL_ATTACK1}
		self.MeleeAttackKnockBack_Up1 = 1000
		self.MeleeAttackKnockBack_Up2 = 1200
		self.SoundTbl_BeforeMeleeAttack = {"vj_hlr/hl1_npc/geneworm/geneworm_big_attack_forward.wav"}
	else
		self.MeleeAttackKnockBack_Up1 = -100
		self.MeleeAttackKnockBack_Up2 = -150
		self.SoundTbl_BeforeMeleeAttack = {"vj_hlr/hl1_npc/geneworm/geneworm_attack_mounted_gun.wav", "vj_hlr/hl1_npc/geneworm/geneworm_attack_mounted_rocket.wav"}
		if self:GetForward():Dot((ene:GetPos() - self:GetPos()):GetNormalized()) > math.cos(math.rad(40)) then
			//print("center")
			self.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1}
		else
			if posR:Distance(ene:GetPos()) > posL:Distance(ene:GetPos()) then
				//print("left")
				self.AnimTbl_MeleeAttack = {"melee1"}
			else
				//print("right")
				self.AnimTbl_MeleeAttack = {"melee2"}
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRangeAttack_BeforeStartTimer()
	self:PlaySoundSystem("BeforeMeleeAttack", "vj_hlr/hl1_npc/geneworm/geneworm_beam_attack.wav", VJ_EmitSound)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(TheProjectile)
	local enePos = self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter()
	local attachPos = self:GetAttachment(1).Pos
	local vel = self:CalculateProjectile("Line", self:GetAttachment(1).Pos, enePos, 2000)
	TheProjectile.EO_Enemy = self:GetEnemy()
	TheProjectile.EO_OrgPosition = enePos
	TheProjectile.EO_TrackTime = CurTime() + (enePos:Distance(attachPos) / vel:Length()) -- Stops chasing the enemy after this time
	return vel
end
/*
	pain_1 = Start animation when both eyes break
	pain_2 = Idle animation when orb is open
	pain_3 = When orb is destroyed -- Play this then pain_4
	pain_4 = Spawns shocktrooper -- Can be triggered if it runs out of time or orb is destroyed
*/
---------------------------------------------------------------------------------------------------------------------------------------------
-- Resets everything, including the eye & stomach health, idle animation and NPC state
function ENT:GW_OrbOpenReset()
	print("ORB RESET")
	self:PlaySoundSystem("Pain", "vj_hlr/hl1_npc/geneworm/geneworm_final_pain4.wav")
	timer.Remove("gw_closestomach"..self:EntIndex())
	self.GW_OrbOpen = false
	self.GW_EyeHealth = {r=defEyeHealth, l=defEyeHealth}
	self.GW_OrbHealth = 100
	self:SetSkin(0)
	self.AnimTbl_IdleStand = {ACT_IDLE}
	self:VJ_ACT_PLAYACTIVITY("pain_4", true, false)
	self:SetState()
end
---------------------------------------------------------------------------------------------------------------------------------------------
-- Checks to the health of each eye and sets the skin
	-- If both are broken, then it will open its stomach
function ENT:GW_EyeHealthCheck()
	local r = self.GW_EyeHealth.r
	local l = self.GW_EyeHealth.l
	if r <= 0 && l <= 0 then -- If both eyes have health below 1 then open stomach!
		self:SetSkin(3)
		if self.GW_OrbOpen == false then
			print("ORB OPEN")
			self.GW_OrbOpen = true
			self:SetState(VJ_STATE_ONLY_ANIMATION_NOATTACK)
			self.AnimTbl_IdleStand = {ACT_IDLE_STIMULATED}
			self:VJ_ACT_PLAYACTIVITY("pain_1", true, false)
			self:PlaySoundSystem("Pain", "vj_hlr/hl1_npc/geneworm/geneworm_final_pain1.wav")
			timer.Create("gw_closestomach"..self:EntIndex(), 18, 1, function()
				if IsValid(self) && self.GW_OrbOpen == true then
					self:GW_OrbOpenReset()
				end
			end)
		end
	elseif r <= 0 then
		self:PlaySoundSystem("Pain", "vj_hlr/hl1_npc/geneworm/geneworm_shot_in_eye.wav")
		self:SetSkin(2)
	elseif l <= 0 then
		self:PlaySoundSystem("Pain", "vj_hlr/hl1_npc/geneworm/geneworm_shot_in_eye.wav")
		self:SetSkin(1)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo,hitgroup)
	if self.GW_Fade == 1 then dmginfo:SetDamage(0) end -- If it's fading inthen don't take damage!
	-- Left eye
	if hitgroup == 14 && self.GW_EyeHealth.l > 0 then
		self:SpawnBloodParticles(dmginfo,hitgroup)
		self.GW_EyeHealth.l = self.GW_EyeHealth.l - dmginfo:GetDamage()
		//print("Left hit!", self.GW_EyeHealth.l)
		if self.GW_EyeHealth.l <= 0 then
			self:VJ_ACT_PLAYACTIVITY(ACT_SMALL_FLINCH, true, false)
			self:GW_EyeHealthCheck()
		end
		dmginfo:SetDamage(0)
	 -- Right eye
	elseif hitgroup == 15 && self.GW_EyeHealth.r > 0 then
		self:SpawnBloodParticles(dmginfo,hitgroup)
		self.GW_EyeHealth.r = self.GW_EyeHealth.r - dmginfo:GetDamage()
		//print("Right hit!", self.GW_EyeHealth.r)
		if self.GW_EyeHealth.r <= 0 then
			self:VJ_ACT_PLAYACTIVITY(ACT_BIG_FLINCH, true, false)
			self:GW_EyeHealthCheck()
		end
		dmginfo:SetDamage(0)
	-- Stomach Orb
	elseif hitgroup == 69 && self.GW_OrbOpen == true && self.GW_OrbHealth > 0 then
		self.GW_OrbHealth = self.GW_OrbHealth - dmginfo:GetDamage()
		if self.GW_OrbHealth <= 0 then
			timer.Remove("gw_closestomach"..self:EntIndex())
			self:PlaySoundSystem("Pain", "vj_hlr/hl1_npc/geneworm/geneworm_final_pain3.wav")
			self:VJ_ACT_PLAYACTIVITY("pain_3", true, false, false, 0, {}, function(vsched)
				vsched.RunCode_OnFinish = function()
					self:GW_OrbOpenReset()
				end
			end)
		end
	else
		dmginfo:SetDamage(0)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	timer.Remove("gw_closestomach"..self:EntIndex())
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2020 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/