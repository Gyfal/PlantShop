
-- Вермя созревания
local waitPlant = 900;


local tPlant = {};
local PlayerData = {};
local tDataBase = {};
local tAuthUser = {};
local standart = {[1] = false; [2] = false; [3] = false;}
local jsStandart = toJSON(standart)
local warningInterval = 5000; -- 5 sec

local number = tonumber

local tPrice = {
    1000,
    2000,
    3000,
}

local tAntiFlood = {};



local function sync_with_players()
    return triggerClientEvent("plantShop:refreshPlant", root, tPlant );
 end 

 local function sync_client(client, about)
    return triggerClientEvent(client, "plantShop:refreshPlant", client, tPlant, about);
 end


-- Cоздаем Растение которое будет расти
local function createSubPlant(id, semena, client)
    tPlant[id]['plant'] = nil;


    tPlant[id]['main']['status'] = 3;
    tPlant[id]['subPlant'] = {};
    tPlant[id]['subPlant']['semena'] = semena;
    tPlant[id]['subPlant']['obj'] = createObject(tPlantObject[semena], tPlant[id]['main']['pos'].x, tPlant[id]['main']['pos'].y, tPlant[id]['main']['pos'].z);

    setElementCollisionsEnabled(tPlant[id]['subPlant']['obj'], false)
    setObjectScale(tPlant[id]['subPlant']['obj'], 0.1)
end 


-- Рост растения
local function startRender(id, start, finishh)

    local data = tPlant[id];
    local scale = 0.1;
    local realUnix = start;
    local second = (getRealTime())['timestamp']

    data['subPlant']['timer'] = realUnix;
    
    -- Получаем время сколько нужноe для роста!
    local difference = finishh - start;
    
    

     
    -- Растение ранее созрело? 
    if finishh - second < 1 and data['main']['status'] == 3 then
        data['main']['status'] = 4;
        setObjectScale(data['subPlant']['obj'], 1);
        return
        -- return sync_with_players()
    end 
    
    -- Создаем таймер, который будет обновляться раз в 1 секунду
    setTimer(function()
        local currectUnix = (getRealTime())['timestamp']
        
        -- Получаем scale путем деления разницы
        local scale = (currectUnix - start) / difference
        if scale < 0.1 then return end
        if scale > 1 then scale = 1 end
        
        if scale >= 1  then
            killTimer(sourceTimer);
            data['main']['status'] = 4;
            return sync_with_players()
        end

        setObjectScale(data['subPlant']['obj'], scale)
        
    end, 1000, 0)
end 

local function sendDataBase(user)
    if getPlayerAccount(user) and getAccountID(getPlayerAccount(user)) then
        
       local seach = true; 
       for k, v in pairs(tDataBase) do
            if v['accID'] == getAccountID(getPlayerAccount(user)) then
                v['crov'] = toJSON(PlayerData[user])
                seach = true
            end 
       end
       if not seach then table.insert(tDataBase, {accID = getAccountID(getPlayerAccount(user)), crov = toJSON(PlayerData[user])}) end
       executeSQLQuery("UPDATE plant SET crov = ? WHERE accID=?", toJSON(PlayerData[user]), getAccountID(getPlayerAccount(user)))
   end 
end

local function searchByDataBase(accID)
    if #tDataBase > 1 then
        for k, v in pairs(tDataBase) do
            if v['accID'] == accID then
                return v['crov']
            end 
        end 
        return false
    end 
end 


local function initClubm(id, pos, plant)
    local tData = {
        -- Клумба!
        main = {
            pos = pos;
            obj = createObject(2203, pos.x, pos.y, pos.z);
            status = 1;
            id = id;
        };
        --[[
        Информация о закладчике
        ['plant'] = {

        };
        -- Информация о созреваемом растении
        ['subPlant'] = {

        }
        ]]
    }

    if plant['startUnix']
    and plant['plant']
    and plant['endUnix']
    and number(plant['plant'])
    and number(plant['endUnix'])  
    and number(plant['startUnix'])
    then
        tData['main']['old'] = {start = plant['startUnix'];  finish = plant['endUnix']; semena =  number(plant['plant'])}
    end 
    setmetatable(tData, {})
    return tData 
end 



-- Загрузка клумб, init ResourceStart
function displayLoadedRes ( res )  
    
	
    -- Надеюсь я правильно понял насчет бд ^_^
    executeSQLQuery([[
        CREATE TABLE IF NOT EXISTS plant ("accID" INTEGER NOT NULL UNIQUE,
	    "crov"	TEXT NOT NULL)
    ]])

    -- Бд семян
    tDataBase = executeSQLQuery("SELECT accID,crov FROM plant")
    
    local rootNode = xmlLoadFile ( "plant.xml" )

    -- open xml-s.lua
    if not rootNode then print("Нет xml растений, создаем") return createFileHandler() end
    
    local optionsNode = xmlFindChild (rootNode, "spawnpoint", 0 )
    
    local messageNodes = xmlNodeGetChildren(rootNode)       
    for i,node in ipairs(messageNodes) do             
        local ser = xmlNodeGetAttributes(node)
        tPlant[#tPlant + 1] = initClubm(ser['id'], ser, {startUnix = ser['startUnix'], endUnix = ser['endUnix'], plant = ser['plant']});
        if tPlant[#tPlant]['main']['old'] then 
            createSubPlant(#tPlant, tPlant[#tPlant]['main']['old']['semena'])
            startRender(#tPlant, tPlant[#tPlant]['main']['old']['start'], tPlant[#tPlant]['main']['old']['finish']);
        end
    end
    print("Успешно загружено", #tPlant)
end
addEventHandler ( "onResourceStart", resourceRoot, displayLoadedRes )


local function playerData(text,account, client)
    local player = searchByDataBase(getAccountID(account))
    if player then
        PlayerData[client or source] = fromJSON(player)
    else
        PlayerData[client or source] = fromJSON(jsStandart)
    end 
    triggerClientEvent(client or source, "plantShop:refreshPlant", client or source, tPlant, PlayerData[client or source] );
end 

addEventHandler("onPlayerLogin", root, playerData)


-- Если игрок разлогинился
addEventHandler("onPlayerLogout",getRootElement(),function(thePreviousAccount) 
     -- Очистка клумб у игрока
     triggerClientEvent(source, "plantShop:refreshPlant", source, {} );
      if PlayerData[source] then PlayerData[source] = nil end 
end )



-- Новый клиент, отправляем актуальный список плантаций
addEvent("plantShop:newClient", true)
addEventHandler("plantShop:newClient", resourceRoot, function() 
    if client and not isGuestAccount(getPlayerAccount ( client )) then
        triggerClientEvent ( client, "plantShop:refreshPlant", client, tPlant )
        playerData(_, getPlayerAccount ( client ), client)
	end
 end)









addEvent("plantShop:createSubPlant", true)
addEventHandler("plantShop:createSubPlant", resourceRoot, 
    function (data)
        if client and type(data) == "table" and PlayerData[client] then

            -- Если игрок в машине
            if getPedOccupiedVehicle(client) then return outputChatBox("[Server] Вы должны быть не в машине!", client) end
            
            -- Если неправильные данные
            if not data['semena'] or not data['id'] then outputChatBox("[Server] Ошибка посадки!", client) end 
            
            -- Если косячный номер плантации
            if data['id'] == 0 or data['semena'] > #tPlant then return outputChatBox("[Server] Недопустимый номер плантации", client) end
            
            
            local id = data['id'];
            local semenaID = data['semena'];

            -- Проверяем дистанцию до клумбы с которой взаимодействует игрок, вдруг врет? =)
            if getDistance(client,  tPlant[id]['main']['obj']) > 3 then  return outputChatBox (" Вы отошли от клумбы", client) end;


            -- Проверка на взаимодействия с клумбой
            if tPlant[id]['plant'] then
                if tPlant[id]['plant']["user"] == client then return outputChatBox("Вы уже сажаете", client) end
                if tPlant[id]['plant']["user"] ~= client then return outputChatBox("Данная клумба занята другим игроком", client) end
                -- если тот кто  посадил - пропал
                if not isElement(tPlant[id]['plant']["user"]) then print("Не человек!"); tPlant[id]['main']['status'] = 1; tPlant[id]['plant'] = {}; return sync_with_players(); end
            end

            
        
            local info = tPlant[id];
            local semena = PlayerData[client][data['semena']];
            
            -- Попытка начать посадку растения
            if tPlant[id]['main']['status'] == 1 and not tPlant[id]['plant'] then

                -- Если невалид номер семян
                if data['semena'] == 0  or data['semena'] > 3 then return outputChatBox("[Server] У вас нет семян", client) end
                
                -- Если у игрока нет такого семечка
                if not PlayerData[client][semenaID] then return outputChatBox("[Server] У вас нема такого семечка!", client) end;


                -- Cоздаем информацию о закладчике
                tPlant[id]['plant'] = {};
                tPlant[id]['plant']["user"] = client;
                tPlant[id]['plant']["time"] = getTickCount();
                tPlant[id]['plant']["semena"] = data["semena"];


                -- Устанавливаем статус растения на 2 (Начат сбор)
                tPlant[id]['main']['status'] = 2;

                -- Cинхра с игроками
                sync_with_players();

                -- Хуки на действия игрока
                addEventList(client);

                -- Устанавливаем анимку игроку
                setPedAnimation(client,'bomber','bom_plant', 15000  , true, true) -- Проигрываем анимацию поднятия мешка
                return triggerClientEvent(client, "plantShop:startPlant", client, {tPlant[id], getTickCount()}); 

                -- Растение все еще растет
            elseif tPlant[id]['main']['status'] == 3 then
                outputChatBox("Не мешайте растению вырасти! =)", client)

            elseif tPlant[data['id']]['main']['status'] == 4 then
                
                -- Игрок начал сбор урожая                
                tPlant[data['id']]['main']['status'] = 5;
                
                -- Cоздаем информацию о закладчике
                tPlant[data['id']]['plant'] = {};
                tPlant[data['id']]['plant']["user"] = client;
                tPlant[data['id']]['plant']["time"] = getTickCount();
                
                -- Синхра, анимка
                sync_with_players();
                addEventList(client);
                setPedAnimation(client,'bomber','bom_plant', 2000  , true, true) -- Проигрываем анимацию поднятия мешка
                
                setPedAnimationSpeed(client, "bomber", 0.1)
                return triggerClientEvent(client, "plantShop:harvesCrop", client, tPlant[data['id']])
            elseif tPlant[data['id']]['main']['status'] == 5 then
                outputChatBox("Растение уже собирают! =)", client)
                return 
            end 
        end
    end)


-- Игрок собрал куст
addEvent("plantShop:endHorv", true)
addEventHandler("plantShop:endHorv", resourceRoot, function (data)
    if client then 
        local planter = false; 
        for k, data in pairs(tPlant) do
            if data['plant'] and data['plant']["user"] == client and data['plant']["time"] > 5000 then --antiVAC(client, data['plant']["time"])
                planter = true;       
                
                -- Разрешаем снова что-то посадить.
                data['main']['status'] = 1


                -- Удаляем прошлое растение, удаляем инфу
                destroyElement(data['subPlant']['obj'])
                data['plant'] = nil;
                data['subPlant'] = nil; 
                
                -- Удалим информацию о плантации
                writeXML(data['main']['id'], {'plant', nil}); -- Семя
                writeXML(data['main']['id'], {'endUnix', nil}); -- unix
                writeXML(data['main']['id'], {'startUnix', nil}); -- unix
                
                -- Удаляем хуки на игрока 
                removEventList(client)
                return sync_with_players()
            end 
        end
    end
end)


-- Отмена все действий игрока
function cancel()
    for k, v in pairs(tPlant) do
        if v['plant'] and v['plant']["user"] == source or v['plant'] and v['plant']["user"] == client then
            outputChatBox("Вы прервали посадку растения", client or source)
            v['main']['status'] = v['main']['status'] - 1;
            v['plant'] = nil;
            sync_with_players()
            setPedAnimation(client or source,'CARRY','crry_prtial',0,false,false, false, false)
            return removEventList(client or source)
        end 
    end 
end 
addEvent("plantShop:cancelPlant", true)
addEventHandler('plantShop:cancelPlant', resourceRoot, cancel)


-- Хуки на игрока
function addEventList(client)
    removEventList(client)
    addEventHandler("onPlayerWasted", client,  cancel, false)
    addEventHandler("onPlayerQuit",   client,  cancel, false)
    addEventHandler("onPlayerLogout", client,  cancel, false)
    addEventHandler("onPlayerVehicleEnter", client, cancel , false)
    addEventHandler("onElementInteriorChange", client, cancel, false)
    addEventHandler("onElementDimensionChange", client, cancel, false)
    return true
end 


function removEventList(client)
    removeEventHandler("onPlayerWasted", client,  cancel) 
    removeEventHandler("onPlayerQuit",   client,  cancel)
    removeEventHandler("onPlayerLogout", client,  cancel)
    removeEventHandler("onPlayerVehicleEnter", client,  cancel)
    removeEventHandler("onElementInteriorChange", client, cancel)
    removeEventHandler("onElementDimensionChange", client, cancel)
    return true
end 


-- Если успешно отыгралась 5 секунд, попытка создать растение!
addEvent("plantShop:endPlant", true)
addEventHandler("plantShop:endPlant", resourceRoot, 
    function(userData)
        if client then
            local planter = false; 
            removEventList(client)
            for id, data in pairs(tPlant) do
                
                if data['main']['status'] == 2 and data['plant'] and data['plant']['user'] == client and getTickCount() - data['plant']["time"] > 5000 then
                    if getDistance(client,  data['main']['obj']) > 3 then  return outputChatBox (" Вы отошли от клумбы", client) end;
                    if getPedOccupiedVehicle(client) then return outputChatBox("[Server] Вы должны быть не в машине!", client) end

                    -- Если у игрока нет такого семечка
                    if not PlayerData[client][data['plant']["semena"]] then
                        data['main']['status'] = 1;
                        sync_with_players();
                        return outputChatBox("[Server] У вас нема такого семечка!", client)
                    else
                        PlayerData[client][data['plant']["semena"]] = false;
                        sendDataBase(client);
                        sync_client(client, PlayerData[client])
                    end;


                     -- Cоздаем плантацию
                    local unix = (getRealTime())['timestamp']
                    local timeOut = unix + waitPlant
                    
                    local semena = data['plant']['semena'];
                    
                    createSubPlant(id, semena, client)
                    startRender(id, unix, timeOut);

                    data['main']['status'] = 3
                    sync_with_players();

                    -- -- Запишем новое время в xml
                    writeXML(data['main']['id'], {'startUnix', unix}); -- unix
                    writeXML(data['main']['id'], {'endUnix', timeOut}); -- unix
                    writeXML(data['main']['id'], {'plant', semena}); -- Семя

                    return
                end 
            end
            if not planter then outputChatBox("Вы ничего не делали", client) end;
        end
    end
)




addEvent("plantShop:buySemena", true)
addEventHandler("plantShop:buySemena", resourceRoot, 
function (idSemya)
    local semena = number(idSemya)
    if client and semena and getPlayerMoney(client) >= tPrice[semena] then
        for k, v in pairs(PlayerData[client]) do
            if semena == k and v ~= true then
                local newMoney = getPlayerMoney(client) - tPrice[semena];
                setPlayerMoney(client, newMoney)

                

                PlayerData[client][k] = true; 
                sendDataBase(client)
                return triggerClientEvent(client, "plantShop:successfulBuy", client, PlayerData[client])
            elseif semena == k and v == true then
                return outputChatBox("У вас уже есть данное семечко", client)
            end 
        end 
    else
       triggerClientEvent(client, "plantShop:refresh", client)
    end 
end)




local playerMarker = createMarker(-2408.54296875, -599.29406738281, 132.6484375 - 0.9, "cylinder", 2, 10, 244, 23, 200, root)

local function handlePlayerMarker(hitElement)
    if getElementType(hitElement) == 'player' then
        triggerClientEvent(hitElement, "plantShop:showGUI",hitElement)
    end 
end
addEventHandler("onMarkerHit", playerMarker, handlePlayerMarker, false)
