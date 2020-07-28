AddCSLuaFile()

ENT.Type = "nextbot"
ENT.Base = "base_nextbot"

ENT.AutomaticFrameAdvance = true
ENT.RenderGroup = RENDERGROUP_OPAQUE

local MOVE_HEIGHT_EPSILON = 0.0625
local StepHeight = 18

AccessorFunc(ENT, "m_Target", "Target") -- This should be an entity
AccessorFunc(ENT, "m_MaxSpeed", "MaxSpeed") -- max velocity in m/s
AccessorFunc(ENT, "m_Attacking", "Attacking") -- Boolean if Target isn't null
AccessorFunc(ENT, "m_Controller", "Controller") -- Controller object, set with ENT:InitController
AccessorFunc(ENT, "m_AimDistance", "AimDistance") -- maximum detection range for entities
AccessorFunc(ENT, "m_Acceleration", "Acceleration") -- Acceleration measure in m/s
AccessorFunc(ENT, "m_HULLTYPE", "HULLType") -- Max steering force in m/s

-- Modifiles the speed
function ENT:SetSpeedMult( mul )
	self.speedMul = mul or 1
	self.loco:SetDesiredSpeed( self:GetMoveSpeed() )
end
-- Returns the movespeed
function ENT:GetMoveSpeed()
	return (self:GetMaxSpeed() or 25) * (self.speedMul or 1)
end
-- Makes the nextbot become a ragdoll
function ENT:MakeRagdoll( duration )
	if self:Health() <= 0 then return end
	if self.e_Ragdoll then SafeRemoveEntity( self.e_Ragdoll) end
	local rag = ents.Create("prop_ragdoll")
	if not IsValid(rag) then return false end
	rag.NPC_OWNER = self
	rag:SetPos( self:GetPos() )
	rag:SetModel( self:GetModel() )
	rag:SetSkin( self:GetSkin() )
	for key, value in pairs(self:GetBodyGroups()) do
		rag:SetBodygroup(value.id, self:GetBodygroup(value.id))	
	end
	rag:SetAngles(self:GetAngles())
	rag:SetColor(self:GetColor())
	rag:Spawn()
	rag:Activate()
	rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	function rag:OnTakeDamage( dmginfo )
		if not IsValid(self.NPC_OWNER) then return end
		self.NPC_OWNER:TakeDamageInfo( dmginfo )
	end
	if self.Weapon then
		self.Weapon:SetNoDraw(true)
	end
	self:SetRagdolled( true )
	self.e_Ragdoll = rag
	self.i_RagdollTime = CurTime() + (duration or 2)
	return rag
end
-- Makes the nextbot unragdoll
function ENT:UnRagdoll()
	if self.e_Ragdoll then
		self:SetPos(self.e_Ragdoll:GetPos() + Vector(0,0,4))
		SafeRemoveEntity( self.e_Ragdoll )
	end
	if self.Weapon then
		self.Weapon:SetNoDraw(false)
	end
	self.e_Ragdoll = nil
	self:SetRagdolled( false )
	local controller = self:GetController()
	if not controller then return end
	controller:MakeInvalid()
	if self.NPC_DATA.ANIM_LAND then
		self:ResetSequence(self.NPC_DATA.ANIM_LAND)
		self:SetCycle( 0.01 )
		self:SetPlaybackRate( 0.01 )
	end
end
-- Makes the nextbot become a ragdoll and fly in a direction
function ENT:Fling( vel )
	if self:Health() <= 0 then return end
	local rag = self:MakeRagdoll()
	local num = rag:GetPhysicsObjectCount()-1
	for i=0, num do
		local bone = rag:GetPhysicsObjectNum(i)
		if IsValid(bone) then
			local bp, ba = self:GetBonePosition(rag:TranslatePhysBoneToBone(i))
			if bp and ba then
				bone:SetPos(bp)
				bone:SetAngles(ba)
			end
			bone:SetVelocity(vel)
		end
	end
end
-- Gives the nextbot a weapon
hook.Add("PlayerCanPickupWeapon", "yawd_bot", function( ply, wep)
	if wep.m_YawdBlockPick then return false end
end)
function ENT:GiveWeapon(wep)
	local wep = ents.Create(wep)
	local pos = self:GetAttachment(self:LookupAttachment("anim_attachment_RH")).Pos
	wep:SetOwner(self)
	wep:SetPos(pos)
	wep:Spawn()
	wep:SetSolid(SOLID_NONE)
	wep:SetParent(self)

	wep:Fire("setparentattachment", "anim_attachment_RH")
	wep:AddEffects(EF_BONEMERGE)
	wep.m_YawdBlockPick = true
	self.Weapon = wep
end
function ENT:ShootWeapon( target, bullet_data )
	if not self.Weapon then return end
	aimcone = aimcone or 0.1
	local att = self.Weapon:LookupAttachment("muzzle")
	local shootPos
	if att > 0 then
		local t = self.Weapon:GetAttachment(att)
		shootPos = t.Pos
	else
		shootPos = self:GetPos()
	end
	local dir = (target:GetPos() - shootPos + target:OBBCenter()):GetNormalized()
	bullet_data = bullet_data or {}
		bullet_data.Num = Num or 1
		bullet_data.Src = shootPos
		bullet_data.Dir = dir
		bullet_data.Spread = Vector(aimcone , aimcone, 0) 
		bullet_data.Tracer = tracer or 1
		bullet_data.Damage = dmg or 3
	self:FireBullets(bullet_data)
end

function ENT:OnRemove()
	if self.e_Ragdoll then SafeRemoveEntity( self.e_Ragdoll) end
end
function ENT:OnKilled( dmginfo )
	hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
	self:BecomeRagdoll( dmginfo )
	if self.e_Ragdoll then SafeRemoveEntity( self.e_Ragdoll) end
	if self.Weapon then SafeRemoveEntity( self.Weapon) end
	NPC.RewardCurrency( self.NPC_DATA.Currency or 3 )
end

-- Returns a trace
function ENT:TraceHull(From, To)
	return util.TraceHull({
		start = From,
		endpos = To,
		mins = self:OBBMins(),
		maxs = self:OBBMaxs(),
		mask = MASK_NPCSOLID_BRUSHONLY,
	})
end

function ENT:Initialize()
	self:SetAimDistance(50) -- How far away the ent can detect players, measured in meters

	-- leave these ones alone
	self:SetTarget(NULL) -- target should always be an entity even if it is NULL
	self:SetAttacking(false) -- set internally, use to check if the ent has a target
	self:SetAcceleration(Vector()) -- acceleration vector for movement
	self:AddSolidFlags( FSOLID_NOT_STANDABLE )
	
	if CLIENT then
		hook.Add("PreDrawHalos", self, self.DrawHalo) -- shitcode alert
		NPC.ApplyFunctions(self, self:GetNPCType())
	end

	if SERVER then
		self:SetMaxHealth(self.NPC_DATA.Health or 25)
		self:SetHealth(self.NPC_DATA.Health or 25)
	--	self:SetModel("models/combine_soldier.mdl")
	--	self:PhysicsInit(SOLID_BBOX)
	--	self:SetSolid(SOLID_BBOX)
	--	self:SetMoveType(MOVETYPE_STEP )
		self:SetCollisionGroup( COLLISION_GROUP_PUSHAWAY )

	--	self:PhysWake()
		local physobj = self:GetPhysicsObject()
	--	physobj:SetDragCoefficient( 0.1 )
	--	physobj:EnableGravity(true)
	--	physobj:SetMaterial("gmod_ice")
		self.loco:SetStepHeight(50)
	end
	self:SetHULLType(self.NPC_DATA.HullType or PathFinder.FindEntityHULL( self ))
	self:InitController(Building.GetCore():GetPos(), 0, 0)
end

-- How far can we go in this direction
function ENT:InitController(target, jump_down, jump_up)
	local controller = Controller.New(target, jump_down, jump_up)
	if controller then
		local path = Controller.RequestEntityPath(self, target, jump_down, jump_up)
		if path then
			DebugMessage(string.format("Generated initial path for %s.", self))
			controller:SetPath(path)
		end
		self:SetController(controller)
	end
end

function ENT:CalculateGoal( stepUp )
	local controller = self:GetController()
	if not controller then return false end

	local goal = controller:GetGoal()
	if not goal then
		local new_path = Controller.RequestEntityPath(self, target, jump_down, jump_up)

		if new_path then
			DebugMessage(string.format("Generated new path for %s.", self))
			controller:SetPath(new_path)

			goal = controller:GetGoal()

			if not goal then
				DebugMessage("Failed to set new goal.")
				return false
			end
		else
			DebugMessage(string.format("Failed to generate new path for %s.", self))
			if SERVER then
				self:Remove()
			end
			return false
		end
	end
	local desired = goal - self:GetPos()
	if IsValid(self:GetTarget()) then
		desired = self:GetTarget():GetPos() - self:GetPos()
	end
	if SERVER then
		local cur = self:GetAngles()
		local ang = desired:Angle()
		local a = math.Clamp(math.AngleDifference(ang.y, cur.y), -5, 5)
		self:SetAngles(Angle(0,cur.y + a,0))
	end
end

function ENT:HandleAnimation(  )
	if self.b_WasRagdolled and self.NPC_DATA.ANIM_LAND then
		self:ResetSequence(self.NPC_DATA.ANIM_LAND)
		coroutine.wait( self:SequenceDuration(self.NPC_DATA.ANIM_LAND) )
		self.b_WasRagdolled = false
	end
	local speed = self.loco:GetVelocity():Length()
	if speed < 1 then
		self:ResetSequence(self.NPC_DATA.ANIM_IDLE)
	elseif speed < self:GetMaxSpeed() * 0.75 then
		--self:StartActivity( ACT_WALK )
		self:ResetSequence(self.NPC_DATA.ANIM_WALK or self.NPC_DATA.ANIM_WALK_AIM or self.NPC_DATA.ANIM_RUN)
	else
		--self:StartActivity( ACT_RUN )
		self:ResetSequence(self.NPC_DATA.ANIM_RUN or self.NPC_DATA.ANIM_RUN_AIM or self.NPC_DATA.ANIM_WALK)
	end
end

local function ET(self, from, to, target)
	local t = util.TraceLine( {
		start = from,
		endpos = to,
		filter = self,
		mask = MASK_BLOCKLOS_AND_NPCS
	} )
	return not t.Hit or (t.Entity and t.Entity == target)
end

local function SearchPlayers(self, distance, vPos)
	local c,e
	vPos = vPos or self:GetPos() + self:OBBCenter()
	for k,v in ipairs(player.GetAll()) do
		local dis = vPos:Distance( v:GetPos() )
		if (not c or c > dis) and dis < distance then
			if self.NPC_DATA.TargetIgnoreWalls or ET(self, vPos, v:GetPos() + v:OBBCenter(), v) then
				e = v
				c = dis
			end
		end
	end
	return e
end

function ENT:MoveTowards( pos )
	local mov_speed = self:GetMoveSpeed()
	local delta = (pos - self:GetPos())
	local l = delta:Length()
	local vel = delta:GetNormalized() * mov_speed
	self:HandleAnimation(mov_speed)
	if l < 50 then return true end
	self:SetGoalPos(pos)
	self.loco:SetVelocity(vel)
	self.loco:Approach(pos, 1)
	return false
end

function ENT:RunBehaviour()
	local controller = self:GetController()
	if not controller then return false end
	while ( true ) do
		if self:GetRagdolled() then
			self.b_WasRagdolled = true
			if IsValid( self.e_Ragdoll ) then
				self:SetPos( self.e_Ragdoll:GetPos() )
			end
			coroutine.wait( 0.5 )
		elseif self:GetTarget() then
			if not IsValid( self:GetTarget() ) or not self.NPC_DATA.OnAttack then
				self:SetTarget( nil )
			else
				self.NPC_DATA.OnAttack(self, self:GetTarget())
				self.m_TargetCooldown = CurTime() + ( self.NPC_DATA.TargetCooldown or 15 )
				self:SetTarget( nil )
				coroutine.wait(0.3)
			end
		else
			local goal = controller:GetGoal()
			if self.NPC_DATA.CanTargetPlayers and (self.i_search or 0) < CurTime() then
				self.i_search = CurTime() + 5
				self:SetTarget( SearchPlayers(self, self.NPC_DATA.TargetPlayersRange or 200) )
			end
			if goal then
				if self:MoveTowards(goal) then
					local finished = controller:NextGoal()
					if finished then
						DebugMessage(string.format("%s reached the end of the path, removing.", self))
						if SERVER then self:Remove() end
						return false
					end
				end
			end
		end
		coroutine.yield()
	end
end

function ENT:Draw()
	if self:GetRagdolled() then return end
	if self:Health() <= 0 and self:GetMaxHealth() > 0 then return end
	self:DrawModel()
	local v = self:GetGoalPos()
	if not v then return end
	render.DrawLine(self:GetPos(), v, Color(255,255,0), true)
end

function ENT:Think()
	if self:GetRagdolled() then
		if SERVER and (self.i_RagdollTime or 0) < CurTime() and (self.e_Ragdoll or self):GetVelocity():Length() < 10 then
			self:UnRagdoll()
		else
			self.b_WasRagdolled = true
		end
		self:NextThink(CurTime() + 1)
		return true
	else
		if self.b_WasRagdolled then
			self.b_WasRagdolled = false
		end
		self:CalculateGoal( )
		--self:SetVelocity(velocity)
		self:NextThink(CurTime())
		self.BaseClass.Think(self)
		return true
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Vector", 0, "GoalPos" )
	self:NetworkVar( "Bool", 0, "Ragdolled" )
	self:NetworkVar( "String", 0, "NPCType" )
	self:NetworkVar("Int", 0, "Buffs")
	self:NetworkVar("Int", 1, "Debuffs")
end

--[[
	Problems:
		- Using physics can get stuck on small elevations
		- Using SetPos makes the model glitch out if we got physics.
		- Some Models are 4 units above the ground.
		- If we don't use have physics, the NPC can't be tossed around.

	Solutions:
		- Have a switch between SetPos and Physics. A simple "toss" function might work.
		- SetPos + HullTrace might be a better move function, as it won't roll downhull
		- Update the client with the goal position, to make it more seamless.
		- "Noclip" the NPC and make it move towards points on the path, using HULL_Trace
]]


if CLIENT then
	ENT.HaloColour = Color(234, 60, 83) -- team.GetColor(TEAM_ATTACKER) -- not defined yet smh, manual include master race
	function ENT:DrawHalo()
		halo.Add({self}, self.HaloColour)
	end
end