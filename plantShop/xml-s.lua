local tDefaultRassada = {
    {time = -1, pos =  {x = -2422.9228515625, y =  -606.18365478516, z= 131.8}};
    {time = -1, pos =  {x = -2419.9177246094, y = -608.61712646484, z= 131.8}};
    {time = -1, pos =  {x = -2423.3093261719, y = -613.48614501953, z= 131.8}};
    {time = -1, pos =  {x = -2426.3034667969, y = -609.30780029297, z= 131.8}};
}


-- Запись в XML по ID плантации
function writeXML(id, data)
    local rootNode = xmlLoadFile ( "plant.xml" )
    local children = xmlFindChild(rootNode, "spawnpoint", id - 1)
    xmlNodeSetAttribute(children, data[1], data[2])
    xmlSaveFile(rootNode)
    xmlUnloadFile(rootNode)
end 


function createFileHandler()
    local rootNode = xmlCreateFile("plant.xml","plantgroup")
    for k, v in pairs(tDefaultRassada) do
        local childNode = xmlCreateChild(rootNode, "spawnpoint")
        xmlNodeSetAttribute(childNode, "z", v.pos.z) -- remove 'foo' attribute
        xmlNodeSetAttribute(childNode, "y", v.pos.y) -- remove 'foo' attribute
        xmlNodeSetAttribute(childNode, "x", v.pos.x) -- remove 'foo' attribute
        xmlNodeSetAttribute(childNode, "id", k)
    end 
    xmlSaveFile(rootNode)
    xmlUnloadFile(rootNode)

    -- restart
    return displayLoadedRes()
 end