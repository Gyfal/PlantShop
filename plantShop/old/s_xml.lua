function writeXML(id, data)
    local rootNode = xmlLoadFile ( "plant.xml" )
    local children = xmlFindChild(rootNode, "spawnpoint", id - 1)
    xmlNodeSetAttribute(children, data[1], data[2])
    xmlSaveFile(rootNode)
    xmlUnloadFile(rootNode)
end 


function createFileHandler()
    local rootNode = xmlCreateFile("plant.xml","plantgroup")
    for k, v in pairs(rassada) do
        local childNode = xmlCreateChild(rootNode, "spawnpoint")
        xmlNodeSetAttribute(childNode, "z", v.pos.z) -- remove 'foo' attribute
        xmlNodeSetAttribute(childNode, "y", v.pos.y) -- remove 'foo' attribute
        xmlNodeSetAttribute(childNode, "x", v.pos.x) -- remove 'foo' attribute
        xmlNodeSetAttribute(childNode, "id", k)
    end 
    xmlSaveFile(rootNode)
    xmlUnloadFile(rootNode)
    displayLoadedRes()
 end