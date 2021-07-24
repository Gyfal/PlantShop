plantObject = {
    650, -- Кактус
    655, -- Ель 
    669, -- Береза
}


plantName = {
	[0] = "Нет семян для посадки";
	[1] = "Кактус";
	[2] = "Ель";
	[3] = "Береза";
}


function secondsToTimeDesc( seconds )
	if seconds then
		local results = {}
		local sec = ( seconds %60 )
		local min = math.floor ( ( seconds % 3600 ) /60 )
		local hou = math.floor ( ( seconds % 86400 ) /3600 )
		local day = math.floor ( seconds /86400 )
		print(min, sec)
		if day > 0 then table.insert( results, day .. ( day == 1 and " day" or " days" ) ) end
		if hou > 0 then table.insert( results, hou .. ( hou == 1 and " hour" or " hours" ) ) end
		if min > 0 then table.insert( results, min .. ( min == 1 and " minute" or " minutes" ) ) end
		if sec > 0 then table.insert( results, sec .. ( sec == 1 and " second" or " seconds" ) ) end
		
		return string.reverse ( table.concat ( results, ", " ):reverse():gsub(" ,", " dna ", 1 ) )
	end
	return ""
end

function getDist(x1,y1,z1,x2,y2,z3)
    return getDistanceBetweenPoints3D(x1,y1,z1,x2,y2,z3)    
end 


function getDistance(element, other)
	local x, y, z = getElementPosition(element)
	if isElement(element) and isElement(other) then
		return getDistanceBetweenPoints3D(x, y, z, getElementPosition(other))
	end
end