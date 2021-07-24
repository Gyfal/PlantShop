local tMarkers = {}
local anims = {}



-- Создание текста на элемете с возможность обходить обьект(Чтоб сквозь стены не смотреть)
local function dxDrawTextOnElement(TheElement,text,height,distance,R,G,B,alpha,size,font,...)
	local x, y, z = getElementPosition(TheElement)
	local x2, y2, z2 = getCameraMatrix()
	local distance = distance or 20
	local height = height or 1

	if (isLineOfSightClear(x, y, z+2, x2, y2, z2, ...)) then
		local sx, sy = getScreenFromWorldPosition(x, y, z+height)
		if(sx) and (sy) then
			local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			if (distanceBetweenPoints < distance) then
				dxDrawText(text, sx+2, sy+2, sx, sy, tocolor(R or 255, G or 255, B or 255, alpha or 255), (size or 1)-(distanceBetweenPoints / distance), font or "arial", "center", "center")
			end
		end
	end
end


-- Получаем название растения по иду
function getRastenie(xz)
    local tPlants = {
        [0] = "Нет семян для посадки";
        [1] = "Кактус";
        [2] = "Ель";
        [3] = "Береза";
    }
    if not tPlants[xz] then return "Error", outputConsole("Неверно указан номер растения");  end
    return tPlants[xz]
end 



-- Получаем статус растения
function getStatus(data, idSemya)
    local status = data['main']['status']
    local rastenie = getRastenie(idSemya)
    local tStatus = {
        [1] = '[{key}] – посадить «{name}»\n[Колесико] – сменить растение"';
        [2] = "Идет посадка «{name}»";
        [3] = "Cозревает растение «{name}» \n";
		[4] = '[{key}] – собрать «{name}»'; --"Растение «{name}» созрело \n Нажмите "..keyPlant.." чтобы собрать урожай";
		[5] = "Собираем урожай...";
    }
    if getPedOccupiedVehicle(localPlayer) then
        tStatus = {
            [1] = 'Чтобы посадить растение \nнеобходимо выйти из машины';
            [2] = "Идет посадка «{name}»";
            [3] = "Cозревает растение «{name}» \n";
            [4] = 'Чтобы собрать «{name}» \nнеобходимо выйти из машины'; --"Растение «{name}» созрело \n Нажмите "..keyPlant.." чтобы собрать урожай";
            [5] = "Собираем урожай...";
        }
    end 
    
    if not tStatus[status] then return error("Ошибочка") end
    if idSemya == 0 then return getRastenie(idSemya) end

    -- Замена текста с помощью тэгов
    local newText = tStatus[status];
    newText = newText:gsub("{name}", getRastenie(idSemya))
    newText = newText:gsub("{key}", string.upper(keyPlant)) 
    
    return newText
end 

local lastSelect = 0;



-- Selector по колесику мышки
addEventHandler( "onClientKey", getRootElement(), function(button,press) 
    if button == "mouse_wheel_up" or button == "mouse_wheel_down" then
        local selector = (button == "mouse_wheel_up") and PlayerData['select'] + 1 or (button == "mouse_wheel_down") and PlayerData['select'] - 1
        if selector > 3 then selector = 1 end;
        if selector < 1 then selector = 3 end
        
        if PlayerData['semena'][selector] then
            PlayerData['select'] = selector
        end 
        if PlayerData['semena'][selector + 1] then
            PlayerData['select'] = selector
            return 
        end 
        if PlayerData['semena'][selector - 1] then
            PlayerData['select'] = selector
            return
        end 
        -- for k, v in pairs(PlayerData['semena']) do
        --     if k == selector and v == true then
        --         PlayerData['select'] = k
        --     end
        -- end 

        return true
    end
end )


local function togggle(bool,this)
    setPedWeaponSlot( localPlayer, 0 ) -- Переключаем на фист(ган: Кулак)
    -- toggleControl("jump", bool ) -- Блокируем/Разрешаем прыгать
    -- toggleControl("fire", bool )  -- Блокируем/Разрешаем стрелять
    -- toggleControl("sprint", bool ) -- Блокируем/Разрешаем бегать
    -- toggleControl("enter_exit", bool ) -- Блокируем/Разрешаем Cесть в кар F
    -- toggleControl("aim_weapon", bool ) -- Блокируем/Разрешаем ПКМ
    toggleControl("next_weapon", bool ) -- Блокируем/Разрешаем менять оружие
    toggleControl("previous_weapon", bool ) -- Блокируем/Разрешаем менять оружие
    -- toggleControl("enter_passenger", bool ) -- Блокируем/Разрешаем Сесть на пассажирку    
end
    



function dxDrawLoading (x, y, width, height, x2, y2, size, color, color2, second)
    print(second)
    local now = getTickCount()
    local seconds = second or 5000
	local color = color or tocolor(0,0,0,170)
	local color2 = color2 or tocolor(255,255,0,170)
	local size = size or 1.00
    local with = interpolateBetween(0,0,0,width,0,0, (now - PlayerData['time']) / ((PlayerData['time'] + seconds) - PlayerData['time']), "Linear")
    local text = interpolateBetween(0,0,0,100,0,0,(now - PlayerData['time']) / ((PlayerData['time'] + seconds) - PlayerData['time']),"Linear")

    dxDrawRectangle(x  - height, y - 35 ,width ,height -10, color)
    dxDrawRectangle(x  - height, y - 35, with ,height -10, color2)
 end 


function render()
    if not tPlant then return end

    for i, data in pairs(tPlant) do
        local element = data['main']['obj'];
        local x, y, z = getElementPosition(data['main']['obj'])
        local x1, y1, z1 = getElementPosition(localPlayer)

        
        if isElementOnScreen(element) then

            -- Если игрок подошел к клумбе = убираем оружие
            if getDist(x, y, z, x1, y1, z1) < 15 then
                togggle(false)
            else
                toggleControl("next_weapon", true ) -- Блокируем/Разрешаем менять оружие
                toggleControl("previous_weapon", true ) -- Блокируем/Разрешаем менять оружие
            end 

            local idStatus = data['main']['status'];
			local semena = PlayerData['select'];

            if data['subPlant'] and data['subPlant']['semena'] then semena = data['subPlant']['semena'] end
            if data['plant'] and data['plant']['semena'] then semena = data['plant']['semena'] end
            

            local text = getStatus(data, semena)
            dxDrawTextOnElement(element,text,1,15,236,147,106,255,2,"default")
            
            
            if idStatus == 2 or idStatus == 5 and (data['plant'] and data['plant']['user'] == localPlayer) then 
                local sx, sy = getScreenFromWorldPosition(x, y, z + 0.7)
                if sx then 
                    -- progress bar
                    dxDrawLoading(sx, sy, 100, 50, _, _, 1, _, _, idStatus == 2 and 5000 or idStatus == 5 and 2000)
                end
            end  
        end 
    end
end 
addEventHandler("onClientRender", root, render)



