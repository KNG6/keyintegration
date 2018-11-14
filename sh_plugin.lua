PLUGIN.name = "Key Cart intergration"
PLUGIN.author = "K.N.G."
PLUGIN.desc = "Adds Combine locks to doors."

if (SERVER) then
	function PLUGIN:SaveData()
		local data = {}

		for k, v in ipairs(ents.FindByClass("nut_cmblock1")) do
			if (IsValid(v.door)) then
				data[#data + 1] = {v.door:MapCreationID(), v.door:WorldToLocal(v:GetPos()), v.door:WorldToLocalAngles(v:GetAngles()), "nut_cmblock1",v:GetLocked() == true and true or nil}
			end
		end
		for k, v in ipairs(ents.FindByClass("nut_cmblock2")) do
			if (IsValid(v.door)) then
				data[#data + 1] = {v.door:MapCreationID(), v.door:WorldToLocal(v:GetPos()), v.door:WorldToLocalAngles(v:GetAngles()), "nut_cmblock2",v:GetLocked() == true and true or nil}
			end
		end
		for k, v in ipairs(ents.FindByClass("nut_cmblock3")) do
			if (IsValid(v.door)) then
				data[#data + 1] = {v.door:MapCreationID(), v.door:WorldToLocal(v:GetPos()), v.door:WorldToLocalAngles(v:GetAngles()), "nut_cmblock3", v:GetLocked() == true and true or nil}
			end
		end
		for k, v in ipairs(ents.FindByClass("nut_cmblock4")) do
			if (IsValid(v.door)) then
				data[#data + 1] = {v.door:MapCreationID(), v.door:WorldToLocal(v:GetPos()), v.door:WorldToLocalAngles(v:GetAngles()), "nut_cmblock4", v:GetLocked() == true and true or nil}
			end
		end
		self:setData(data)
	end

	function PLUGIN:saveForceFields()
		local buffer = {}
		for k, v in pairs(ents.FindByClass("nut_forcefield")) do
			buffer[#buffer + 1] = {pos = v:GetPos(), ang = v:GetAngles(), mode = v.mode or 1,"nut_forcefield"}
		end
		self:setData(buffer)
	end

	function PLUGIN:LoadData()
		local data = self:getData() or {}
		local buffer = self:getData() or {}

		for k, v in ipairs(data) do

			if (v[4]=="nut_forcefield")then
				local entity = ents.Create("nut_forcefield")
				entity:SetPos(v.pos)
				entity:SetAngles(v.ang)
				entity:Spawn()
				entity.mode = v.mode or 1
			else
				local door = ents.GetMapCreatedEntity(v[1])

				if (IsValid(door) and door:isDoor()) then
					if (v[4]=="nut_cmblock1") then
						local entity = ents.Create("nut_cmblock1")
						entity:SetPos(door:GetPos())
						entity:Spawn()
						entity:setDoor(door, door:LocalToWorld(v[2]), door:LocalToWorldAngles(v[3]))
						entity:SetLocked(v[5])

						if (v[5]) then
							entity:toggle(true)
						end
					elseif (v[4]=="nut_cmblock2") then
						local entity = ents.Create("nut_cmblock2")
						entity:SetPos(door:GetPos())
						entity:Spawn()
						entity:setDoor(door, door:LocalToWorld(v[2]), door:LocalToWorldAngles(v[3]))
						entity:SetLocked(v[4])

						if (v[5]) then
							entity:toggle(true)
						end
					elseif (v[4]=="nut_cmblock3") then
						local entity = ents.Create("nut_cmblock3")
						entity:SetPos(door:GetPos())
						entity:Spawn()
						entity:setDoor(door, door:LocalToWorld(v[2]), door:LocalToWorldAngles(v[3]))
						entity:SetLocked(v[5])

						if (v[5]) then
							entity:toggle(true)
						end
					elseif (v[4]=="nut_cmblock4") then
						local entity = ents.Create("nut_cmblock4")
						entity:SetPos(door:GetPos())
						entity:Spawn()
						entity:setDoor(door, door:LocalToWorld(v[2]), door:LocalToWorldAngles(v[3]))
						entity:SetLocked(v[5])

						if (v[5]) then
							entity:toggle(true)
						end
					end
				end
			end
		end
	end
end