tPlant = {};
keyPlant = "e";
local standart = {[1] = false; [2] = true; [3] = false;}
PlayerData = {
    ['semena'] = standart;
    ['select'] = 0;
    ['planting'] = false;
    ['time'] = getTickCount();
}

local tPlantInStream = {}


function checkAnim()
    
end 


addEvent( "tz:startPlant", true )
addEventHandler( "tz:startPlant", localPlayer, function(data)
    PlayerData['time'] = getTickCount();
    PlayerData['time'] = getTickCount();
    PlayerData['planting'] = true;
    local planting = true;
    print("Начал посадку семян")

    local function checkAnim() 
        local bool, b,c,d = getPedTask ( localPlayer, "primary", 3 )
        if not bool then
             triggerServerEvent("tz:cancelPlant", resourceRoot);
             removeEventHandler("onClientPreRender", root, checkAnim);
             PlayerData['planting'] = false;
             planting = false;
         end
        if getTickCount() - PlayerData['time'] > 5000 and planting then
             removeEventHandler("onClientPreRender", root, checkAnim);
             setPedAnimation(localPlayer,'CARRY','crry_prtial',0,false,false, false, false)
             triggerServerEvent("tz:endPlant", resourceRoot, data)
        end

    end 
    removeEventHandler("onClientPreRender", root, checkAnim);
    addEventHandler("onClientPreRender", root, checkAnim)
   
   
   
    -- local function checkAnim()
    --     -- if getTickCount() - PlayerData['time'] > 5000 and PlayerData['planting'] then 
    --     --     triggerServerEvent("tz:endHorv", resourceRoot, data)
    --     --     print("Я все!")
    --     --     removeEventHandler("onClientPreRender", root, checkAnim)
    --     --     setPedAnimation(localPlayer,'CARRY','crry_prtial',0,false,false, false, false)
    --     --     PlayerData['planting'] = false; 
    --     -- end 
    -- end 
    -- addEventHandler("onClientPreRender", root, checkAnim)
    -- -- planting(data, function()
    -- --     if getTickCount() - PlayerData['time'] > 5000 and PlayerData['planting'] then 
    -- --        -- triggerServerEvent("tz:endPlant", resourceRoot, data)
    -- --         setPedAnimation(localPlayer,'CARRY','crry_prtial',0,false,false, false, false)
    -- --         PlayerData['planting'] = false; 
    -- --     end
    -- -- end)
end)

addEvent( "tz:harvesCrop", true )
addEventHandler( "tz:harvesCrop", localPlayer, function(data)
    local startTime = getTickCount()
    PlayerData['time'] = getTickCount()
    PlayerData['planting'] = true;
    print("Начал сбор семян")

    local function checkAnim()
        local bool, b,c,d = getPedTask ( localPlayer, "primary", 3 )
        if not bool then
             triggerServerEvent("tz:cancelPlant", resourceRoot);
             removeEventHandler("onClientPreRender", root, checkAnim);
             PlayerData['planting'] = false;
             planting = false;
         end
        if getTickCount() - PlayerData['time'] > 2000 and PlayerData['planting'] then
             removeEventHandler("onClientPreRender", root, checkAnim);
             setPedAnimation(localPlayer,'CARRY','crry_prtial',0,false,false, false, false)
             triggerServerEvent("tz:endHorv", resourceRoot, data)
        end
    end 
    addEventHandler("onClientPreRender", root, checkAnim)
end)

-- local function startRender()
--     local bool, b,c,d = getPedTask ( localPlayer, "primary", 3 )
--     if not bool then triggerServerEvent("tz:cancelPlant", resourceRoot); removeEventHandler("onClientPreRender", root, startRender);  PlayerData['planting'] = false; end
    
-- end

-- function ANALKARNAVAL(...)


-- end

-- function startRender(data, callback)
--     local bool, b,c,d = getPedTask ( localPlayer, "primary", 3 )
--     if not bool then triggerServerEvent("tz:cancelPlant", resourceRoot); removeEventHandler("onClientPreRender", root, displayMyTask);  PlayerData['planting'] = false; end
--     if getTickCount() - startTimer > 5 and PlayerData['planting'] then callback(data, client) end
-- end
    -- function displayMyTask ()
   
-- end     

-- function qwe(...)
--     print(...)
-- end 

-- function planting(data, callback)
--     local info = 123;
--     startTimer = getTickCount()
--     local functi = function(datasalo) print(data, callback) end 
--     addEventHandler("onClientPreRender", root, functi)
--     -- addEventHandler("onClientPreRender", root, qwe(data, callback)
--         -- print(...)
--         -- local bool, b,c,d = getPedTask ( localPlayer, "primary", 3 )
--         -- if not bool then
--         --      triggerServerEvent("tz:cancelPlant", resourceRoot);
--         --      print("here");
--         --      PlayerData['planting'] = false;
--         --      cancelEvent();
--         --  end
--         -- if getTickCount() - startTimer > 5 and PlayerData['planting'] then callback(data, client) cancelEvent();  end
--         -- print(getTickCount())
--     -- end)
--     setPedAnimation(localPlayer,'bomber','bom_plant', 15000  , true, true) -- Проигрываем анимацию поднятия мешка

--     local anal = {}
--     table.insert(anal, setTimer(function(arg)
--         removeEventHandler("onClientPreRender", root, functi);
--         for k, v in pairs(anal) do
--             if PlayerData['planting'] and v == sourceTimer then
--                 print(PlayerData['planting'], v == sourceTimer)
--                 print("Отправили инфу!")
--                 return callback(data, client);
--             end 
--         end 
--     end,5001,1, anal ))
-- end 





addEvent( "tz:aboutMe", true )
addEventHandler( "tz:aboutMe", localPlayer,
    function(tbl)
        PlayerData['semena'] = tbl;
        local standart = {[1] = true; [2] = false; [3] = true;}
        PlayerData['semena'] = standart
        for k, v in pairs(PlayerData['semena']) do
            if v == true then
                PlayerData['select'] = k;
            return end 
        end 
        PlayerData['select'] = 0;
        return 
end );


addEvent( "tz:refreshPlant", true )
addEventHandler( "tz:refreshPlant", localPlayer,
     function(tbl)
        tPlant = tbl
    end
);


addEventHandler( "onClientElementStreamIn", resourceRoot,
    function ( )
        if getElementType( source ) == "object"  then
            
        end 
    end
);

-- local function togggle(bool,this)
--     setPedWeaponSlot( localPlayer, 0 ) -- Переключаем на фист(ган: Кулак)
--     -- toggleControl("jump", bool ) -- Блокируем/Разрешаем прыгать
--     -- toggleControl("fire", bool )  -- Блокируем/Разрешаем стрелять
--     -- toggleControl("sprint", bool ) -- Блокируем/Разрешаем бегать
--     -- toggleControl("enter_exit", bool ) -- Блокируем/Разрешаем Cесть в кар F
--     -- toggleControl("aim_weapon", bool ) -- Блокируем/Разрешаем ПКМ
--     -- toggleControl("next_weapon", bool ) -- Блокируем/Разрешаем менять оружие
--     -- toggleControl("previous_weapon", bool ) -- Блокируем/Разрешаем менять оружие
--     -- toggleControl("enter_passenger", bool ) -- Блокируем/Разрешаем Сесть на пассажирку    
-- end

-- addEventHandler( "onClientElementStreamOut", resourceRoot, 
-- function ( )
--     if getElementType( source ) == "object"  then
        
--     end 
-- end
-- );




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
    return triggerServerEvent("tz:createSubPlant", resourceRoot, {id = tBetween.id, semena = PlayerData['select'];})
end    


addEventHandler( "onClientResourceStart", resourceRoot,
    function ( startedRes )
       triggerServerEvent("tz:newClient", resourceRoot)
       bindKey( keyPlant, "down", escapeMe )   -- bind the player's F1 down key
    end
);

