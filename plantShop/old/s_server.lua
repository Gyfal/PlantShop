
-- Вермя созревания
local waitPlant = 3;
local tPlant = {};
local PlayerData = {};
local tAuthUser = {};
local tElement = false;
local standart = {[1] = true; [2] = true; [3] = true;}
local jsStandart = toJSON(standart)
local warningInterval = 5000; -- 5 sec

local number = tonumber

local rassada = {
    {time = -1, pos =  {x = -2430.58203125, y =  -605.66528320312, z= 131.8}};
    {time = -1, pos =  {x = -2430.58203125, y = -612.66528320312, z= 131.8}};
    {time = -1, pos =  {x = 1, y = 1, z= 4}};
    {time = -1, pos =  {x = -707.61968994141, y = 963.61639404297, z= 12.472094535828}};
}


local antiFlood = {};




function getNotGuestPlayers ()
    for _ , players_ in ipairs ( getElementsByType ( "player" ) ) do
        local playerAcc = getPlayerAccount ( players_ )
        if not isGuestAccount ( playerAcc ) then
            table.insert(tAuthUser, players_)
        end
    end 
end


function displayLoadedRes ( res )  
    local rootNode = xmlLoadFile ( "plant.xml" )
    print("start server", getRealTime())

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


function playerData(text,account, client)
    if not getAccountData(account, "plantJopa") then
       print("О вас нет информации, выдаем изначально")
       setAccountData(account, "plantJopa", jsStandart)
       triggerClientEvent(client or source , "tz:aboutMe", client or source)
    else
        print("О вас ЕСТЬ информация, выдаем")
        local info = standart --fromJSON(getAccountData(account, "plantJopa"));
        triggerClientEvent(client or source, "tz:aboutMe", client or source, info)
        PlayerData[client and client or source] = info;
    end 
end 

addEventHandler("onPlayerLogin", root, playerData)

function loggedOut(thePreviousAccount)
    if antiFlood[source] then antiFlood[source] = nil end
    if PlayerData[source] then PlayerData[source] = nil end 


	if not getAccountData(thePreviousAccount, "plantJopa") then
        setAccountData(thePreviousAccount, "plantJopa", jsStandart)
     else
        setAccountData(thePreviousAccount, "plantJopa", jsStandart)
     end
end
addEventHandler("onPlayerLogout",getRootElement(),loggedOut)


addEventHandler ( 'onPlayerLogin', getRootElement ( ),
    function ( _, theCurrentAccount )
        triggerClientEvent(source, "tz:refreshPlant", source, tPlant );
    end
)


-- Новый клиент, отправляем актуальный список плантаций
addEvent("tz:newClient", true)
addEventHandler("tz:newClient", resourceRoot, function() 
    if client and not isGuestAccount(getPlayerAccount ( client )) then
        triggerClientEvent ( client, "tz:refreshPlant", client, tPlant )
        playerData(_, getPlayerAccount ( client ), client)
	end
 end)


 function sync_with_players()
    return triggerClientEvent("tz:refreshPlant", root, tPlant );
 end 

 function sync_client(client)
    return triggerClientEvent(client, "tz:refreshPlant", client, tPlant );
 end



function initClubm(id, pos, plant)
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

    -- function tData:resetPlant()
        
    --     --local newTime = 
    -- end 

    -- function tData:setStatus(id)
    --     self['main']['status'] = id;
    --     return self['main']['status'];
    -- end 

    -- function tData:getStatus()
    --     return self['main']['status']
    -- end


    -- function tData:createSubPlant(semena, client)
    --     if (semena < 1 or semena > 3 ) and client then return outputChatBox("У вас нет семян!", client) end
    --     self['main']['status'] = 3;
    --     self['plant'] = nil;

    --     self['subPlant'] = {};
    --     self['subPlant']['semena'] = semena;
    --     self['subPlant']['obj'] = createObject(plantObject[semena], self['main']['pos'].x, self['main']['pos'].y, self['main']['pos'].z);
    --     setElementCollisionsEnabled(self['subPlant']['obj'], false)
    --     setObjectScale(self['subPlant']['obj'], 0.1)
    -- end 

    -- function tData:startRender(start, finishh)
    --     local scale = 0.1;
    --     local realUnix = start;

    --     self['subPlant']['timer'] = realUnix;
        
    --     -- Получаем время сколько нужно для роста!
    --     local difference = finishh - start;
         
        
    --     if difference < 1 and self:getStatus() == 3 then
    --         self:setStatus(4);
    --         setObjectScale(self['subPlant']['obj'], 1);
    --         return sync_with_players()
    --     end 
        

    --     -- difference = 69

    --     setTimer(function()
    --         local currectUnix = (getRealTime())['timestamp']
            
    --         -- Получаем scale путем деления разницы
    --         local scale = (currectUnix - start) / difference
    --         if scale < 0.1 then return end
    --         if scale > 1 then scale = 1 end

    --         setObjectScale(self['subPlant']['obj'], scale)    

    --         if scale >= 1  then
    --             killTimer(sourceTimer);
    --             self:setStatus(4)
    --             return sync_with_players()
    --         end
            
    --     end, 1000, 0)
    -- end 

    if plant['startUnix'] and number(plant['startUnix']) and plant['plant'] and number(plant['plant']) and plant['endUnix'] and number(plant['endUnix'])  then
        -- local endUnix = plant['endUnix']
        -- local startUnix = plant['startUnix'];
        -- local semena = number(plant['plant']);
        tData['main']['old'] = {start = plant['startUnix']; finish = plant['endUnix']; semena =  number(plant['plant'])}
    end 

    setmetatable(tData, {})
    return tData 
end 





addEvent("tz:createSubPlant", true)
addEventHandler("tz:createSubPlant", resourceRoot, 
    function (data)
        if client and type(data) == "table" and PlayerData[client] then

            if getPedOccupiedVehicle(client) then return outputChatBox("[Server] Ошибка посадки!", client) end
            if not data['semena'] or not data['id'] then outputChatBox("[Server] Ошибка посадки!", client) end 
            
            if data['id'] == 0 or data['semena'] > #tPlant then return outputChatBox("[Server] Недопустимый номер плантации", client) end
            
            
            local id = data['id'];
            local semenaID = data['semena'];
            if getDistance(client,  tPlant[id]['main']['obj']) > 3 then  return outputChatBox (" Вы отошли от клумбы", client) end;

            if tPlant[id]['plant'] then
                if tPlant[id]['plant']["user"] == client then return outputChatBox("Вы уже сажаете", client) end
                if tPlant[id]['plant']["user"] ~= client then return outputChatBox("Данная клумба занята другим игроком", client) end
                if not isElement(tPlant[id]['plant']["user"]) then print("Не человек!"); tPlant[id]['main']['status'] = 1; tPlant[id]['plant'] = {}; return sync_with_players(); end
            end

            
        
            local info = tPlant[id];
            local semena = PlayerData[client][data['semena']];
            
            if tPlant[id]['main']['status'] == 1 and not tPlant[id]['plant'] then
                if data['semena'] == 0  or data['semena'] > 3 then return outputChatBox("[Server] У вас нет семян", client) end
                if not PlayerData[client][semenaID] then return outputChatBox("[Server] У вас нема такого семечка!", client) end;


                tPlant[id]['plant'] = {};
                tPlant[id]['plant']["user"] = client;
                tPlant[id]['plant']["time"] = getTickCount();
                tPlant[id]['plant']["semena"] = data["semena"];


                
                tPlant[id]['main']['status'] = 2;
                sync_with_players();

                addEventList(client);

                setPedAnimation(client,'bomber','bom_plant', 15000  , true, true) -- Проигрываем анимацию поднятия мешка
                return triggerClientEvent(client, "tz:startPlant", client, {tPlant[id], getTickCount()}); 
            elseif tPlant[id]['main']['status'] == 3 then
                outputChatBox("Не мешайте растению вырасти! =)", client)

            elseif tPlant[data['id']]['main']['status'] == 4 then
                
                tPlant[data['id']]['main']['status'] = 5;
                
                tPlant[data['id']]['plant'] = {};
                tPlant[data['id']]['plant']["user"] = client;
                tPlant[data['id']]['plant']["time"] = getTickCount();
                
                sync_with_players();
                addEventList(client);
                setPedAnimation(client,'bomber','bom_plant', 2000  , true, true) -- Проигрываем анимацию поднятия мешка
                print(setPedAnimationSpeed(client, "bomber", 0.1))
                return triggerClientEvent(client, "tz:harvesCrop", client, tPlant[data['id']])
            elseif tPlant[data['id']]['main']['status'] == 5 then
                outputChatBox("Растение уже собирают! =)", client)
                return 
            end 
        end
    end)



addEvent("tz:endHorv", true)
addEventHandler("tz:endHorv", resourceRoot, function (data)
    if client then 
        local planter = false; 
        for k, data in pairs(tPlant) do
            if data['plant'] and data['plant']["user"] == client and data['plant']["time"] > 5000 then --antiVAC(client, data['plant']["time"])
                planter = true;       
                
                data['main']['status'] = 1

                destroyElement(data['subPlant']['obj'])
                data['plant'] = nil;
                data['subPlant'] = nil; 
                
                -- -- Запишем новое время в xml
                writeXML(data['main']['id'], {'plant', nil}); -- Семя
                writeXML(data['main']['id'], {'endUnix', nil}); -- unix
                writeXML(data['main']['id'], {'startUnix', nil}); -- unix
                removEventList(client)
              --  outputChatBox("Вы успешно собрали "..plantName[data['subPlant']['semena']], client)
                return sync_with_players()
            end 
        end
    end
end)



function antiVAC(client, time)
    if getTickCount() - time < (warningInterval) then
        if not antiFlood[client] then 
            antiFlood[client] = getTickCount();
        elseif antiFlood[client] and getTickCount() - time < 2000 then
            print ('maybe kick?') 
            -- kick.....
            antiFlood[client] = nil;
        end 
        print( ("Игрок %s посадил растение меньше чем за 5 секунд (%s)"):format(getPlayerName(client), (getTickCount() - time)/1000 )  )      
    end 
end 

function cancel()
    for k, v in pairs(tPlant) do
        if v['plant'] and v['plant']["user"] == source or v['plant'] and v['plant']["user"] == client then
            outputChatBox("Вы прервали посадку растения", client or source)
            print("Салам всем вораам")
            v['main']['status'] = v['main']['status'] - 1;
            v['plant'] = nil;
            sync_with_players()
            setPedAnimation(client or source,'CARRY','crry_prtial',0,false,false, false, false)
            return removEventList(client or source)
        end 
    end 
end 
addEvent("tz:cancelPlant", true)
addEventHandler('tz:cancelPlant', resourceRoot, cancel)


function addEventList(client)
    removEventList(client)
    addEventHandler("onPlayerWasted", client,  cancel) 
    addEventHandler("onPlayerQuit",   client,  cancel)
    addEventHandler("onPlayerLogout", client,  cancel)
    addEventHandler("onPlayerVehicleEnter", client, cancel ) 
    addEventHandler ( "onElementDimensionChange", client, cancel)
    --[[
        
addEventHandler ( "onElementDimensionChange", root,
	function ( oldDimension, newDimension )
		outputChatBox ( inspect ( source ) .. "'s dimension changed from " .. oldDimension .. " to " .. newDimension )
	end
)
    ]]
    return true
end 


function removEventList(client)
    removeEventHandler("onPlayerWasted", client,  cancel) 
    removeEventHandler("onPlayerQuit",   client,  cancel)
    removeEventHandler("onPlayerLogout", client,  cancel)
    removeEventHandler("onPlayerVehicleEnter", client,  cancel)
    removeEventHandler ( "onElementDimensionChange", client, cancel)
    return true
end 


-- Если успешно отыгралась 5 секунд
addEvent("tz:endPlant", true)
addEventHandler("tz:endPlant", resourceRoot, 
    function(userData)
        if client then
            local planter = false; 
            removEventList(client)
            for id, data in pairs(tPlant) do
                
                if data['main']['status'] == 2 and data['plant'] and data['plant']['user'] == client and getTickCount() - data['plant']["time"] > 5000 then
                    if getDistance(client,  data['main']['obj']) > 3 then  return outputChatBox (" Вы отошли от клумбы", client) end;
                    
                    if not PlayerData[client][data['plant']["semena"]] then
                        data['main']['status'] = 1;
                        sync_with_players();
                        return outputChatBox("[Server] У вас нема такого семечка!", client)
                     end;

                     print("Батя в здании")
                    -- VAC
                   -- antiVAC(client, data['plant']["time"])

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


function createSubPlant(id, semena, client)
   -- print(tPlant[id], tPlant[id]['main'], tPlant[id]['main']['status'])
    --tPlant[id]['main']['status'] = 3;
    tPlant[id]['plant'] = nil;

    tPlant[id]['subPlant'] = {};
    tPlant[id]['subPlant']['semena'] = semena;
    tPlant[id]['subPlant']['obj'] = createObject(plantObject[semena], tPlant[id]['main']['pos'].x, tPlant[id]['main']['pos'].y, tPlant[id]['main']['pos'].z);
    setElementCollisionsEnabled(tPlant[id]['subPlant']['obj'], false)
    setObjectScale(tPlant[id]['subPlant']['obj'], 0.1)
end 


function startRender(id, start, finishh)
    print(tPlant[id]['subPlant'])
    local data = tPlant[id];
    local scale = 0.1;
    local realUnix = start;

    data['subPlant']['timer'] = realUnix;
    
    -- Получаем время сколько нужно для роста!
    local difference = finishh - start;
     
    
    if difference < 1 and data['main']['status'] == 3 then
        data['main']['status'] = 4;
        setObjectScale(data['subPlant']['obj'], 1);
        return sync_with_players()
    end 
    

    setTimer(function()
        local currectUnix = (getRealTime())['timestamp']
        
        -- Получаем scale путем деления разницы
        local scale = (currectUnix - start) / difference
        if scale < 0.1 then return end
        if scale > 1 then scale = 1 end

        setObjectScale(data['subPlant']['obj'], scale)    

        if scale >= 1  then
            killTimer(sourceTimer);
            data['main']['status'] = 4;
            return sync_with_players()
        end
        
    end, 1000, 0)
end 


