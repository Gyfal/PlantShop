tPlantObject = {
    650, -- Кактус
    655, -- Ель 
    669, -- Береза
}


-- plantName = {
-- 	[0] = "Нет семян для посадки";
-- 	[1] = "Кактус";
-- 	[2] = "Ель";
-- 	[3] = "Береза";
-- }


function getDist(x1,y1,z1,x2,y2,z3)
    return getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z3)    
end 


function getDistance(element, other)
	local x, y, z = getElementPosition(element)
	if isElement(element) and isElement(other) then
		return getDistanceBetweenPoints3D(x, y, z, getElementPosition(other))
	end
end