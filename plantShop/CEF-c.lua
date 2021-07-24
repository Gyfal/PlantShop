tWeb = {
  browser;
  gui;
  load = false;
  CEF = false;
}


local function execute(eval)
  executeBrowserJavascript(tWeb["gui"], eval)
end



-- Загрузка страницы
local function load()
  showCursor(true)
  loadBrowserURL(tWeb["gui"], "http://mta/local/cef/index.html")
  
end

function destroyGUI()
  tWeb["CEF"] = false;
  tWeb["load"] = false;
  if isElement(tWeb["gui"]) then  destroyElement(tWeb["gui"]) end
  if isElement(tWeb["browser"]) then  destroyElement(tWeb["browser"]) end
  showCursor(false)
end 

-- Закрытие GUI
addEvent('plantShop:closedGUI', true)
addEventHandler('plantShop:closedGUI', resourceRoot, destroyGUI)

-- Создание GUI
local function startLoadGUI()
  --setDevelopmentMode(true, true) -- Enable client dev mode -- DEBUG
  tWeb["browser"] = guiCreateBrowser(0.2, 0.2, 0.6, 0.6, true, true, true)
  tWeb["gui"]     = guiGetBrowser(tWeb["browser"]) 
  tWeb["load"]    = true;
  addEventHandler("onClientBrowserCreated", tWeb["gui"], load, false)
end 
addEvent("plantShop:showGUI", true)
addEventHandler("plantShop:showGUI", localPlayer, startLoadGUI)






-- Игрок хочет что-то купить?
addEvent("plantShop:guiBuy", true)
addEventHandler("plantShop:guiBuy", resourceRoot, function(id)
 triggerServerEvent("plantShop:buySemena", resourceRoot, id)
end)

-- Ответ от сервера что покупка прошла успешно!
addEvent("plantShop:successfulBuy", true)
addEventHandler("plantShop:successfulBuy", localPlayer, function(newInfo)
  refreshSelector(newInfo);
  execute("vue.$data.showModal = true")
  triggerEvent("plantShop:refresh", resourceRoot)
end)


-- Если CEF Загрузился
addEvent("plantShop:guiLoad", true)
addEventHandler("plantShop:guiLoad", resourceRoot, function()
  tWeb["CEF"] = true;
  triggerEvent("plantShop:refresh", resourceRoot)
end)


-- Обновление инфорации Player
addEvent("plantShop:refresh", true)
addEventHandler("plantShop:refresh", resourceRoot, function()
  local json = {}
  for k, v in pairs(PlayerData['semena']) do
    json[tostring(k)] = v
  end 

  local qwe = toJSON(json)
  
  execute(("%s(`%s`,%d)"):format("updateInfo",qwe,getPlayerMoney(localPlayer) ))
end)



