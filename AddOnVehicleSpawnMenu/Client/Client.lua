
XD = nil
local openedFromNCN = false
local isIsland = false
local isLogged = true

Citizen.CreateThread(function()
    while XD == nil do
        Citizen.Wait(50)
        TriggerEvent("XD:GetObject", function(obj) XD = obj end)
    end
end)

local Pool = MenuPool.New()
local MainMenu = UIMenu.New('Vehicles', '~H~~b~NO ~p~WAYS ~b~SRL', 1300, 25)
local SettingsMenu = UIMenu.New('Settings', 'Settings for the "Add-On Vehicles" menu')
local Feedbackmenu = UIMenu.New('∑NCN Settings Menu', 'Coming soon!', true, false, "Ω~p~→")
local SubMenus = {}
local Items = {}

local spawnedCars = {}

Pool:Add(MainMenu)
Pool:Add(SettingsMenu)
Pool:Add(Feedbackmenu)

Pool:MouseControlsEnabled(false)
Pool:MouseEdgeEnabled(false)
Pool:ControlDisablingEnabled(false)

local IsAdmin

RegisterNetEvent('AOVSM:AdminStatusChecked')
AddEventHandler('AOVSM:AdminStatusChecked', function(State)
    IsAdmin = State
end)

RegisterNetEvent("addon:vehspawner:setPrisonIsland")
AddEventHandler("addon:vehspawner:setPrisonIsland", function(isOnIsland)
    isIsland = isOnIsland
end)

RegisterNetEvent("XD:Client:OnPlayerLoaded")
AddEventHandler("XD:Client:OnPlayerLoaded", function()
    isLogged = true
end)

print("In need of any scripts? Get in contact with us projects@noways.xyz")

Citizen.CreateThread(function()
    AOVSM.CheckStuff()

    local Time
    while true do
        Citizen.Wait(0)
        if not isIsland then
            if isLogged then
                Pool:ProcessMenus()
                if GetIsControlPressed(AOVSM.SettingsKey) and GetIsControlJustPressed(AOVSM.KBKey) and IsInputDisabled(2) and AOVSM.SettingsAllowed then
                    MainMenu:Visible(false)
                    for _, SubMenu in pairs(SubMenus) do
                        SubMenu:Visible(false)
                    end
                    SettingsMenu:Visible(not SettingsMenu:Visible())
                elseif ((GetIsControlJustPressed(AOVSM.KBKey) and IsInputDisabled(2)) or ((GetIsControlPressed(AOVSM.GPKey1) and GetIsControlJustPressed(AOVSM.GPKey2)) and not IsInputDisabled(2))) then
                    SettingsMenu:Visible(false)
                    if MainMenu:Visible() then
                        MainMenu:Visible(false)
                        MainMenu.OnMenuClosed()
                    else
                        local SubMenuClosed = false

                        for _, SubMenu in pairs(SubMenus) do
                            if SubMenu:Visible() then
                                SubMenu:Visible(false)
                                SubMenuClosed = true
                            end
                        end
                        if not SubMenuClosed then
                            MainMenu:Visible(true)
                        end
                        SubMenuClosed = false
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("addon:client:openVehicleMenu")
AddEventHandler("addon:client:openVehicleMenu", function()
    if MainMenu:Visible() then
        MainMenu:Visible(false)
    else
        local SubMenuClosed = false
        for _, SubMenu in pairs(SubMenus) do
            if SubMenu:Visible() then
                SubMenu:Visible(false)
                SubMenuClosed = true
            end
        end
        if not SubMenuClosed then
            MainMenu:Visible(true)
        end
        SubMenuClosed = false
    end
end)

local inputVehicle = UIMenuItem.New("∑~b~ Spawn ~s~Vehicle", "NCN | Spawn vehicle by model.")
MainMenu:AddItem(inputVehicle)

MainMenu.OnMenuClosed = function()
    TriggerEvent("csrp_menu:setIsVehMenuOpened", false)
end

MainMenu.OnItemSelect = function(Sender, Item, Index)
    if Item == inputVehicle then
        local modelName = KeyboardInput("Enter vehicle model: ", '', 25, true)
        if modelName ~= nil then
            AOVSM.SpawnVehicle(modelName)
        else
            TriggerEvent('okokNotify:Alert', "INVALID", "This is not a valid vehicle spawncode", 5000, 'error')
        end
    end
end

RegisterNetEvent('AOVSM:GotVehicles')
AddEventHandler('AOVSM:GotVehicles', function(AddOnVehicles)
    for k,v in pairs(Categories) do
        local categoryName = v.name
        local subCategories = v.subCategories
        if not SubMenus[categoryName] then
            SubMenus[categoryName] = Pool:AddSubMenu(MainMenu, categoryName, '', true)
        end

        for _, Value in pairs(AddOnVehicles) do
            if Value.Class == 'N/A' then
                Value.Class = GetVehicleClassFromName(GetHashKey(Value.SpawnName))
            end

            local Vehicle = UIMenuItem.New(Value.DisplayName, 'Model: ' .. Value.SpawnName)
            if subCategories[Value.Class] ~= nil then
                
                if not SubMenus[categoryName][Value.Class] then
                    SubMenus[categoryName][Value.Class] = Pool:AddSubMenu(SubMenus[categoryName], subCategories[Value.Class] or GetLabelText('VEH_CLASS_' .. tostring(GetVehicleClassFromName(GetHashKey(Value.SpawnName)))), '', true)

                    SubMenus[categoryName][Value.Class].OnItemSelect = function(Sender, Item, Index)
                        AOVSM.SpawnVehicle(string.sub(Item:Description(), 8))
                    end
                end
                
                SubMenus[categoryName][Value.Class]:AddItem(Vehicle)
            end

            table.insert(Items, {Vehicle, Value.SpawnName, Value.Class})
        end

        Pool:MouseControlsEnabled(false)
        Pool:MouseEdgeEnabled(false)
        Pool:ControlDisablingEnabled(false)

        local Despawnable = UIMenuCheckboxItem.New('Despawnable', AOVSM.despawnable)
        SettingsMenu:AddItem(Despawnable)
        local Replace = UIMenuCheckboxItem.New('Replace', AOVSM.autodelete)
        SettingsMenu:AddItem(Replace)
        local MarkOnMap = UIMenuCheckboxItem.New('Mark On Map', AOVSM.mapblip)
        SettingsMenu:AddItem(MarkOnMap)

        SettingsMenu.OnCheckboxChange = function(Sender, Item, Checked)
            if Item == Despawnable then
                AOVSM.despawnable = Checked
            elseif Item == Replace then
                AOVSM.autodelete = Checked
            elseif Item == MarkOnMap then
                AOVSM.mapblip = Checked
            end
        end

        Pool:RefreshIndex()
    end
end)

-- Functions [

AddEventHandler('onClientResourceStop', function(resourceName)
    if(GetCurrentResourceName() ~= resourceName) then
        return
    end
    if spawnedCars ~= nil then
        for i = 1, #spawnedCars do
            if DoesEntityExist(spawnedCars[i]) then
                XD.Functions.DeleteVehicle(spawnedCars[i])
            end
        end
    end
    print('The resource ' .. resourceName .. ' has been stopped on the client.')
end)

Citizen.CreateThread(function()
   

 while true do
        Citizen.Wait(60 * 1000 * 10) -- Wait 10 minutes
        if spawnedCars ~= nil then
            for i = 1, #spawnedCars do
                if DoesEntityExist(spawnedCars[i]) then
                    if IsVehicleSeatFree(spawnedCars[i], -1) then
                        XD.Functions.DeleteVehicle(spawnedCars[i])
                    end
                end
            end
        end
    end	
end)

function AOVSM.SpawnVehicle(Model)
    Model = GetHashKey(Model)
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
    if IsModelValid(Model) then
        if AOVSM.autodelete then
            if IsPedInAnyVehicle(PlayerPedId(), true) then
                SetEntityAsMissionEntity(Object, 1, 1)
                SetEntityAsMissionEntity(GetVehiclePedIsIn(PlayerPedId(), false), 1, 1)
                DeleteEntity(Object)
                DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
            end
        end
        RequestModel(Model)
        while not HasModelLoaded(Model) do
            Citizen.Wait(0)
        end
        local veh = CreateVehicle(Model, x, y, z + 1, GetEntityHeading(PlayerPedId()), true, true)
        if spawnedCars == nil then
            spawnedCars[1] = veh
        else
            if DoesEntityExist(spawnedCars[1]) then
                local vehicleHealth = GetVehicleEngineHealth(spawnedCars[1])
                local vehicleBodyHealth = GetVehicleBodyHealth(spawnedCars[1])
                SetVehicleBodyHealth(veh, vehicleBodyHealth)
                SetVehicleEngineHealth(veh, vehicleHealth)
            end
        end
        SetPedIntoVehicle(PlayerPedId(), veh, -1)
        if AOVSM.despawnable then
            --SetEntityAsNoLongerNeeded(veh)
        else
            SetVehicleHasBeenOwnedByPlayer(veh, true)
        end

        if AOVSM.mapblip then
            local vehBlip = AddBlipForEntity(veh)
            SetBlipColour(vehBlip, 3)
        end
        TriggerEvent("xd_keys:client:setPlateOwned", GetVehicleNumberPlateText(veh))
        SetVehicleModKit(veh, 0)
        SetModelAsNoLongerNeeded(Model)
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentString('~r~Invalid Model!')
        DrawNotification(false, false)
    end
end

function AOVSM.CheckStuff()
    IsAdmin = nil
    if AOVSM.OnlyForAdmins then
        TriggerServerEvent('AOVSM:CheckAdminStatus')
        while (IsAdmin == nil) do
            Citizen.Wait(0)
        end
        if IsAdmin then
            TriggerServerEvent('AOVSM:GetVehicles')
        end
    else
        TriggerServerEvent('AOVSM:GetVehicles')
    end
end

function GetIsControlPressed(Control)
    if IsControlPressed(1, Control) or IsDisabledControlPressed(1, Control) then
        return true
    end
    return false
end

function GetIsControlJustPressed(Control)
    if IsControlJustPressed(1, Control) or IsDisabledControlJustPressed(1, Control) then
        return true
    end
    return false
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght, NoSpaces)
    AddTextEntry(GetCurrentResourceName() .. '_KeyboardHead', TextEntry)
    DisplayOnscreenKeyboard(1, GetCurrentResourceName() .. '_KeyboardHead', '', ExampleText, '', '', '', MaxStringLenght)

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        if NoSpaces == true then
            --
        end
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        return result
    else
        Citizen.Wait(500)
        return nil
    end
end

print("Made by NOWAYS SRL")

