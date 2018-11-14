AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Ration Dispenser"
ENT.Author = "Chessnut"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.PhysgunAllowAdmin = true

local COLOR_RED = 1
local COLOR_ORANGE = 2
local COLOR_BLUE = 3
local COLOR_GREEN = 4

local colors = {
	[COLOR_RED] = Color(255, 50, 50),
	[COLOR_ORANGE] = Color(255, 80, 20),
	[COLOR_BLUE] = Color(50, 80, 230),
	[COLOR_GREEN] = Color(50, 240, 50)
}

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "DispColor")
	self:NetworkVar("String", 1, "Text")
	self:NetworkVar("Bool", 0, "Disabled")
end

function ENT:SpawnFunction(client, trace)
	local entity = ents.Create("nut_dispenser")
	entity:SetPos(trace.HitPos)
	entity:SetAngles(trace.HitNormal:Angle())
	entity:Spawn()
	entity:Activate()

	SCHEMA:saveDispensers()

	return entity
end

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/props_junk/gascan001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetText("INSERT ID")
		self:DrawShadow(false)
		self:SetDispColor(COLOR_GREEN)
		self.canUse = true

		-- Use prop_dynamic so we can use entity:Fire("SetAnimation")
		self.dummy = ents.Create("prop_dynamic")
		self.dummy:SetModel("models/props_combine/combine_dispenser.mdl")
		self.dummy:SetPos(self:GetPos())
		self.dummy:SetAngles(self:GetAngles())
		self.dummy:SetParent(self)
		self.dummy:Spawn()
		self.dummy:Activate()

		self:DeleteOnRemove(self.dummy)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end
	end
end

if (CLIENT) then
	function ENT:Draw()
		local position, angles = self:GetPos(), self:GetAngles()

		angles:RotateAroundAxis(angles:Forward(), 90)
		angles:RotateAroundAxis(angles:Right(), 270)

		cam.Start3D2D(position + self:GetForward()*7.6 + self:GetRight()*8.5 + self:GetUp()*3, angles, 0.1)
			render.PushFilterMin(TEXFILTER.NONE)
			render.PushFilterMag(TEXFILTER.NONE)

			surface.SetDrawColor(40, 40, 40)
			surface.DrawRect(0, 0, 66, 60)

			draw.SimpleText((self:GetDisabled() and "OFFLINE" or (self:GetText() or "")), "Default", 33, 0, Color(255, 255, 255, math.abs(math.cos(RealTime() * 1.5) * 255)), 1, 0)

			surface.SetDrawColor(colors[self:GetDisabled() and COLOR_RED or self:GetDispColor()] or color_white)
			surface.DrawRect(4, 14, 58, 42)

			surface.SetDrawColor(60, 60, 60)
			surface.DrawOutlinedRect(4, 14, 58, 42)

			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
	end
else
	function ENT:setUseAllowed(state)
		self.canUse = state
	end

	function ENT:error(text)
		self:EmitSound("buttons/combine_button_locked.wav")
		self:SetText(text)
		self:SetDispColor(COLOR_RED)

		timer.Create("nut_DispenserError"..self:EntIndex(), 1.5, 1, function()
			if (IsValid(self)) then
				self:SetText("INSERT ID")
				self:SetDispColor(COLOR_GREEN)

				timer.Simple(0.5, function()
					if (!IsValid(self)) then return end

					self:setUseAllowed(true)
				end)
			end
		end)
	end

	function ENT:createRation()
		local entity = ents.Create("prop_physics")
		entity:SetAngles(self:GetAngles())
		entity:SetModel("models/weapons/w_package.mdl")
		entity:SetPos(self:GetPos())
		entity:Spawn()
		entity:SetNotSolid(true)
		entity:SetParent(self.dummy)
		entity:Fire("SetParentAttachment", "package_attachment")

		timer.Simple(1.2, function()
			if (IsValid(self) and IsValid(entity)) then
				entity:Remove()
				if (levl==1) then
					nut.item.spawn("ration_civil", entity:GetPos(), nil, entity:GetAngles())
				elseif (levl==2) then
					nut.item.spawn("ration_loyal", entity:GetPos(), nil, entity:GetAngles())
				elseif (levl==3) then
					nut.item.spawn("ration_cwu", entity:GetPos(), nil, entity:GetAngles())
				elseif (levl==4) then
					nut.item.spawn("ration_pc", entity:GetPos(), nil, entity:GetAngles())
				end
			end
		end)
	end

	function ENT:dispense(amount)
		if (amount < 1) then
			return
		end

		self:setUseAllowed(false)
		self:SetText("DISPENSING")
		self:EmitSound("ambient/machines/combine_terminal_idle4.wav")
		self:createRation()
		self.dummy:Fire("SetAnimation", "dispense_package", 0)

		timer.Simple(3.5, function()
			if (IsValid(self)) then
				if (amount > 1) then
					self:dispense(amount - 1)
				else
					self:SetText("ARMING")
					self:SetDispColor(COLOR_ORANGE)
					self:EmitSound("buttons/combine_button7.wav")

					timer.Simple(7, function()
						if (!IsValid(self)) then return end

						self:SetText("INSERT ID")
						self:SetDispColor(COLOR_GREEN)
						self:EmitSound("buttons/combine_button1.wav")

						timer.Simple(0.75, function()
							if (!IsValid(self)) then return end

							self:setUseAllowed(true)
						end)
					end)
				end
			end
		end)
	end

	function ENT:Use(activator)
		if ((self.nextUse or 0) >= CurTime()) then
			return
		end

		if (activator:Team() == activator:Team()) then
			if (!self.canUse or self:GetDisabled()) then
				return
			end

			self:setUseAllowed(false)
			self:SetText("CHECKING")
			self:SetDispColor(COLOR_BLUE)
			self:EmitSound("ambient/machines/combine_terminal_idle2.wav")

			timer.Simple(1, function()
				if (!IsValid(self) or !IsValid(activator)) then return self:setUseAllowed(true) end

				levl = 0
				local amount = 0

				for k, v in pairs(activator:getChar():getInv():getItems()) do
					if (v.uniqueID == "cid") then
						if (v:getData("nextTime", 0) < os.time()) then
							levl = 1
							amount = 1
							itemz = activator:getChar():getInv():hasItem("cid")
						else
							levl=-1
						end
					elseif (v.uniqueID == "cid2") then
						if (v:getData("nextTime", 0) < os.time()) then
							levl = 2
							amount = 1
							itemz = activator:getChar():getInv():hasItem("cid2")
						else
							levl=-1
						end
					elseif (v.uniqueID == "cid3") then
						if (v:getData("nextTime", 0) < os.time()) then
							levl = 3
							amount = 1
							itemz = activator:getChar():getInv():hasItem("cid3")
						else
							levl=-1
						end
					elseif (v.uniqueID == "cid4") then
						if (v:getData("nextTime", 0) < os.time()) then
							levl = 4
							amount = 1
							itemz = activator:getChar():getInv():hasItem("cid4")
						else
							levl=-1
						end
					end
				end

				
				if (levl==0) then
					return self:error("INVALID ID")
				elseif (levl==-1) then
					return self:error("TRY LATER")
				else
					itemz:setData("nextTime", os.time() + 300)

					self:SetText("ID OKAY")
					self:EmitSound("buttons/button14.wav", 100, 50)

					timer.Simple(1, function()
						if (IsValid(self)) then
							self:dispense(amount)
						end
					end)
				end
			end)
		end
	end

	function ENT:OnRemove()
		if (!nut.shuttingDown) then
			SCHEMA:saveDispensers()
		end
	end
end