local spawnedProps = {} -- Ensure this is initialized as an empty table

CreateThread(function()
    for k, v in pairs(Config.Props) do
        RequestModel(v.model)
        local iter_for_request = 1
        while not HasModelLoaded(v.model) and iter_for_request < 5 do
            Wait(500)
            iter_for_request = iter_for_request + 1
        end
        if not HasModelLoaded(v.model) then
            SetModelAsNoLongerNeeded(v.model)
        else
            local created_object = CreateObjectNoOffset(v.model, v.coords.x, v.coords.y, v.coords.z - 1, 1, 0, 1)
            PlaceObjectOnGroundProperly(created_object)
            SetEntityHeading(created_object, v.coords.w)
            FreezeEntityPosition(created_object, true)
            SetModelAsNoLongerNeeded(v.model)

            spawnedProps[#spawnedProps + 1] = created_object -- Add the created object to the table
        end
    end
end)

-- Cleanup spawned props when the resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, prop in ipairs(spawnedProps) do
            if DoesEntityExist(prop) then
                DeleteObject(prop)
            end
        end
        spawnedProps = {} -- Reset the table
    end
end)
