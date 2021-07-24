tPlant = {};
keyPlant = "e";
PlayerData = {
    ['semena'] = {};
    ['select'] = 0;
    ['planting'] = false;
    ['time'] = getTickCount();
}

local tPlantInStream = {}


addEvent( "plantShop:startPlant", true )
addEventHandler( "plantShop:startPlant", localPlayer, function(data)
    PlayerData['time'] = getTickCount();
    PlayerData['planting'] = true;
    local planting = true;
    

    local function checkAnim() 
        local bool, b,c,d = getPedTask ( localPlayer, "primary", 3 )
        if not bool then
             triggerServerEvent("plantShop:cancelPlant", resourceRoot);
             removeEventHandler("onClientPreRender", root, checkAnim);
             PlayerData['planting'] = false;
             planting = false;
         end
        if getTickCount() - PlayerData['time'] > 5000 and planting then
             removeEventHandler("onClientPreRender", root, checkAnim);

             setPedAnimation(localPlayer,'CARRY','crry_prtial',0,false,false, false, false)
             triggerServerEvent("plantShop:endPlant", resourceRoot, data)
        end

    end 
    removeEventHandler("onClientPreRender", root, checkAnim);
    addEventHandler("onClientPreRender", root, checkAnim)

end)

addEvent( "plantShop:harvesCrop", true )
addEventHandler( "plantShop:harvesCrop", localPlayer, function(data)
    local startTime = getTickCount()
    PlayerData['time'] = getTickCount()
    PlayerData['planting'] = true;


    local function checkAnim()
        local bool, b,c,d = getPedTask ( localPlayer, "primary", 3 )
        if not bool then
             triggerServerEvent("plantShop:cancelPlant", resourceRoot);
             removeEventHandler("onClientPreRender", root, checkAnim);
             PlayerData['planting'] = false;
             planting = false;
         end
        if getTickCount() - PlayerData['time'] > 2000 and PlayerData['planting'] then
            playSFX("script", 151, 1, false)
             removeEventHandler("onClientPreRender", root, checkAnim);
             setPedAnimation(localPlayer,'CARRY','crry_prtial',0,false,false, false, false)
             triggerServerEvent("plantShop:endHorv", resourceRoot, data)
        end
    end 
    addEventHandler("onClientPreRender", root, checkAnim)
end)



addEvent( "plantShop:refreshPlant", true )
addEventHandler( "plantShop:refreshPlant", localPlayer,
     function(tbl, about)
        tPlant = tbl
        if about then
            refreshSelector(about)
        end 
    end
);

function refreshSelector(info)
    PlayerData['select'] = 0;
    PlayerData['semena'] = info;
    for k, v in pairs(PlayerData['semena']) do
        if v == true then
            PlayerData['select'] = k;
            return 
        end 
    end
end 

addEventHandler( "onClientElementStreamIn", resourceRoot,
    function ( )
        if getElementType( source ) == "object"  then
            
        end 
    end
);

-- Посадка растения
local function escapeMe (  key, keyState  )
    local tBetween = {minDist = -1; id = -1;}
    for k, v in pairs(tPlant) do
        local dist = getDistance(localPlayer, v['main']['obj'])
        if dist < 1.5 then
            if tBetween.minDist == -1 then tBetween.minDist = dist; tBetween.id = k; end 
            if tBetween.minDist > dist then tBetween.minDist = dist; tBetween.id = k; end
        end
    end 
    if PlayerData['select'] < 1 and PlayerData['select'] > 3 then return  end
    if tBetween.minDist == -1 then return end
    return triggerServerEvent("plantShop:createSubPlant", resourceRoot, {id = tBetween.id, semena = PlayerData['select'];})
end    


addEventHandler( "onClientResourceStart", resourceRoot,
    function ( startedRes )
       triggerServerEvent("plantShop:newClient", resourceRoot)
       bindKey( keyPlant, "down", escapeMe )   -- bind the player's F1 down key
    end
);

