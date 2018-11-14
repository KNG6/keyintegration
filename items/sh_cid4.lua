ITEM.name = "Carte d'identification de niveau 4"
ITEM.desc = "Une petite carte en plastique vous donnant des accès de niveau 4."
ITEM.model = "models/dorado/tarjetazero.mdl"
ITEM.uniqueID = "cid4"
ITEM.factions = {FACTION_CP, FACTION_ADMIN}
ITEM.functions.Assign = {
	onRun = function(item)
		local data = {}
			data.start = item.player:EyePos()
			data.endpos = data.start + item.player:GetAimVector()*96
			data.filter = item.player
		local entity = util.TraceLine(data).Entity

		if (IsValid(entity) and entity:IsPlayer() and entity:Team() == FACTION_CITIZEN) then
			local status, result = item:transfer(entity:getChar():getInv():getID())

			if (status) then
				item:setData("name", entity:Name())
				item:setData("id", math.random(10000, 99999))
				
				return true
			else
				item.player:notify(result)
			end
		end

		return false
	end,
	onCanRun = function(item)
		return item.player:isCombine()
	end
}

function ITEM:getDesc()
	local description = self.desc.."\nCette carte est assigné a "..self:getData("name", "personne")..", #"..self:getData("id", "00000").."."

	return description
end