ITEM.name = "Ration CWU"
ITEM.desc = "Un sachet contenant des produit de l'union."
ITEM.model = "models/weapons/w_packatp.mdl"
ITEM.uniqueID = "ration_cwu"
ITEM.width = 1
ITEM.height = 1
ITEM.factions = {}
ITEM.iconCam = {
	pos = Vector(-4, 5.9, 200),
	ang = Angle(90, 0, 0),
	fov = 5.5
}
ITEM.functions.Open = {
	icon = "icon16/briefcase.png",
	sound = "physics/body/body_medium_impact_soft1.wav",
	onRun = function(item)
		local position = item.player:getItemDropPos()
		local client = item.player

		timer.Simple(0, function()
			for k, v in pairs(item.items) do
				if (IsValid(client) and client:getChar() and !client:getChar():getInv():add(v)) then
					nut.item.spawn(v, position)
				end
			end
		end)
	end
}
local rand1=math.random(3)
if rand1==1 then
	itemgive1="biscuit"
elseif rand1==2 then
	itemgive1="brownies_chocolat"
else
	itemgive1="brownies_vanille"
end
local rand2=math.random(3)
if rand2==1 then
	itemgive2="biscuit"
elseif rand2==2 then
	itemgive2="brownies_chocolat"
else
	itemgive2="brownies_vanille"
end
 
ITEM.money = {30, 50}
ITEM.items = {"sachet_alim_cwu","sachet_alim_cwu","eau",itemgive1,itemgive2}