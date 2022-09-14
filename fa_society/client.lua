ESX = nil
local PlayerData = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
     PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	PlayerData.job = job  
	Citizen.Wait(5000) 
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
    end
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
    end
    if ESX.IsPlayerLoaded() then

		ESX.PlayerData = ESX.GetPlayerData()

    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
    ESX.PlayerData.job2 = job2
end)

local entreprisesolde = nil

local entreprisesolde2 = nil
menupatronzebi = false

RMenu.Add('menupatronbb', 'main', RageUI.CreateMenu("Gestion job", "Pour gérer votre entreprise/gang."))
RMenu.Add('menupatronbb', 'listegens', RageUI.CreateSubMenu(RMenu:Get('menupatronbb', 'main'), "Liste employés", "Pour voir la liste des employés."))
RMenu.Add('menupatronbb', 'gestsalaire', RageUI.CreateSubMenu(RMenu:Get('menupatronbb', 'main'), "Gestion salaire", "Pour gérer les salaires."))

RMenu:Get('menupatronbb', 'main').Closed = function()
    menupatronzebi = false
end

listegens1 = {}
listegens2 = {}
salairezebi = {}

RegisterNetEvent('five_society')
AddEventHandler('five_society', function(societetrafikante, blanchir, job2)
    entreprisemoney()
    if job2 == false then
        ESX.TriggerServerCallback('five_patron:listegensjob1', function(liste)
        listegens1 = liste
        end, societetrafikante)
        else
        ESX.TriggerServerCallback('five_patron:listegensjob2', function(liste)
        listegens2 = liste
        end, societetrafikante)
        end
        ESX.TriggerServerCallback('five_patron:listesalaire', function(liste)
        salairezebi = liste
        end, societetrafikante)

    if not menupatronzebi then
        menupatronzebi = true
        
        RageUI.Visible(RMenu:Get('menupatronbb', 'main'), true)
    while menupatronzebi do
        RageUI.IsVisible(RMenu:Get('menupatronbb', 'main'), true, true, true, function()
            if job2 == false then
                RageUI.Separator('Gestion entreprise') 
                if entreprisesolde ~= nil then
                    RageUI.Separator('Argent : $'..entreprisesolde)
                end              
            else
                RageUI.Separator('Gestion gang')
                if entreprisesolde2 ~= nil then
                    RageUI.Separator('Argent : $'..entreprisesolde2)
                end
            end
            
            if blanchir == true then
            RageUI.ButtonWithStyle("Blanchir de l'argent", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
            if (Selected) then   
                 local montant = KeyboardInput('Veuillez choisir le montant que vous voulez retirer de cet objet', '', 2)
                 montant = tonumber(montant)
                if not montant then
                ESX.ShowNotification('quantité invalide')
                else
                TriggerServerEvent('five_patron:blanchir', societetrafikante, montant)
                TriggerEvent('Ise_Logs3', "https://discord.com/api/webhooks/930540000137846804/XcVIoVoO_64k_O8a1EyjTBlf1WavRemdT9yXNYakGlN3CnYpCyPAY0QwpFxf9DuyCpE8", 3447003, societetrafikante, "Nom : "..GetPlayerName(PlayerId())..".\nA blanchi de l'argent sale : $"..montant.."")
                RageUI.CloseAll()
                menupatronzebi = false
            end
            end
            end)
        end
            RageUI.ButtonWithStyle("Recruter", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
            if (Selected) then   
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    TriggerServerEvent('five_patron:recruter', societetrafikante, job2, GetPlayerServerId(closestPlayer))
                    TriggerEvent('Ise_Logs3', "https://discord.com/api/webhooks/930540000137846804/XcVIoVoO_64k_O8a1EyjTBlf1WavRemdT9yXNYakGlN3CnYpCyPAY0QwpFxf9DuyCpE8", 3447003, societetrafikante, "Nom : "..GetPlayerName(PlayerId())..".\nA recruté : "..GetPlayerName(closestPlayer).."")
                 else
                    ESX.ShowNotification('Aucun joueur à proximité')
                end 
                
            end
            end)
            RageUI.ButtonWithStyle("Promouvoir", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
            if (Selected) then   
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    TriggerServerEvent('five_patron:promouvoir', societetrafikante, job2, GetPlayerServerId(closestPlayer))
                    TriggerEvent('Ise_Logs3', "https://discord.com/api/webhooks/930540000137846804/XcVIoVoO_64k_O8a1EyjTBlf1WavRemdT9yXNYakGlN3CnYpCyPAY0QwpFxf9DuyCpE8", 3447003, societetrafikante, "Nom : "..GetPlayerName(PlayerId())..".\nA promu : "..GetPlayerName(closestPlayer).."")
                 else
                    ESX.ShowNotification('Aucun joueur à proximité')
                end 
                
            end
            end)
            RageUI.ButtonWithStyle("Rétrograder", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
            if (Selected) then   
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    TriggerServerEvent('five_patron:descendre', societetrafikante, job2, GetPlayerServerId(closestPlayer))
                    TriggerEvent('Ise_Logs3', "https://discord.com/api/webhooks/930540000137846804/XcVIoVoO_64k_O8a1EyjTBlf1WavRemdT9yXNYakGlN3CnYpCyPAY0QwpFxf9DuyCpE8", 3447003, societetrafikante, "Nom : "..GetPlayerName(PlayerId())..".\nA rétrogradé : "..GetPlayerName(closestPlayer).."")
                 else
                    ESX.ShowNotification('Aucun joueur à proximité')
                end 
                
            end
            end)
            RageUI.ButtonWithStyle("Virer", nil, {RightLabel = "→"},true, function(Hovered, Active, Selected)
            if (Selected) then   
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    TriggerServerEvent('five_patron:virer', societetrafikante, job2, GetPlayerServerId(closestPlayer))
                    TriggerEvent('Ise_Logs3', "https://discord.com/api/webhooks/930540000137846804/XcVIoVoO_64k_O8a1EyjTBlf1WavRemdT9yXNYakGlN3CnYpCyPAY0QwpFxf9DuyCpE8", 3447003, societetrafikante, "Nom : "..GetPlayerName(PlayerId())..".\nA viré : "..GetPlayerName(closestPlayer).."")
                 else
                    ESX.ShowNotification('Aucun joueur à proximité')
                end 
                
            end
            end)
    		RageUI.ButtonWithStyle("Liste employés", "Pour voir la liste des employés.", {RightLabel = "→"},true, function()
                if (Selected) then
                    
                end
            end, RMenu:Get('menupatronbb', 'listegens'))

            RageUI.ButtonWithStyle("Gestion salaire", "Pour voir la liste des employés.", {RightLabel = "→"},true, function()
                if (Selected) then
                    
                end
            end, RMenu:Get('menupatronbb', 'gestsalaire'))
           
    		end, function()
			end)
        RageUI.IsVisible(RMenu:Get('menupatronbb', 'listegens'), true, true, true, function()
            if job2 == false then
                for i = 1, #listegens1, 1 do
            RageUI.ButtonWithStyle(listegens1[i].prenom.." "..listegens1[i].nom, nil, {RightLabel = 'Virer'}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    TriggerServerEvent('five_society:virersql', listegens1[i].steam)
                    ESX.ShowNotification("La personne a été viré")
                    TriggerEvent('Ise_Logs3', "https://discord.com/api/webhooks/930540000137846804/XcVIoVoO_64k_O8a1EyjTBlf1WavRemdT9yXNYakGlN3CnYpCyPAY0QwpFxf9DuyCpE8", 3447003, societetrafikante, "Nom : "..GetPlayerName(PlayerId())..".\nA viré : "..listegens1[i].prenom.." "..listegens1[i].nom.." de son entreprise")
                    RageUI.CloseAll()
                menupatronzebi = false
                end
            end)
            end
            else
                for i = 1, #listegens2, 1 do
            RageUI.ButtonWithStyle(listegens2[i].prenom.." "..listegens2[i].nom, nil, {RightLabel = 'Virer'}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    TriggerServerEvent('five_society:virersql2', listegens2[i].steam)
                    ESX.ShowNotification("La personne a été viré")
                    TriggerEvent('Ise_Logs3', "https://discord.com/api/webhooks/930540000137846804/XcVIoVoO_64k_O8a1EyjTBlf1WavRemdT9yXNYakGlN3CnYpCyPAY0QwpFxf9DuyCpE8", 3447003, societetrafikante, "Nom : "..GetPlayerName(PlayerId())..".\nA viré : "..listegens2[i].prenom.." "..listegens2[i].nom.." de son gang")
                    RageUI.CloseAll()
                menupatronzebi = false
                end
            end)
            end
            end
            
        end, function()
        end)
        RageUI.IsVisible(RMenu:Get('menupatronbb', 'gestsalaire'), true, true, true, function()
            for i = 1, #salairezebi, 1 do
            RageUI.ButtonWithStyle(salairezebi[i].nom.." - $"..salairezebi[i].salaire, nil, {RightLabel = 'Changer'}, true, function(Hovered, Active, Selected)
                if (Selected) then
                    local montant = KeyboardInput('Veuillez choisir le montant', '', 8)
                 montant = tonumber(montant)
                if not montant then
                ESX.ShowNotification('quantité invalide')
                else
                if montant > 10000 then
                ESX.ShowNotification("Le salaire ne peut pas être supérieur à 10000$")
                else         
                TriggerServerEvent('five_society:changersalaire', salairezebi[i].id, montant)
                TriggerEvent('Ise_Logs3', "https://discord.com/api/webhooks/930540000137846804/XcVIoVoO_64k_O8a1EyjTBlf1WavRemdT9yXNYakGlN3CnYpCyPAY0QwpFxf9DuyCpE8", 3447003, societetrafikante, "Nom : "..GetPlayerName(PlayerId())..".\nA changer le salaire du grade "..salairezebi[i].nom.." pour $"..montant)
                ESX.ShowNotification("Changement du salaire ok")
                RageUI.CloseAll()
                menupatronzebi = false
            end
            end

                end
            end)
        end
            
        end, function()
        end)
        

            Citizen.Wait(0)
        end
    else
        menupatronzebi = false
    end
end)

function entreprisemoney()
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
        ESX.TriggerServerCallback('five_society:getSocietyMoney', function(money)
            majsocietyargent(money)
        end, ESX.PlayerData.job.name)
    end
    if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
        ESX.TriggerServerCallback('five_society:getSocietyMoney', function(money)
            majsocietyargent2(money)
        end, ESX.PlayerData.job2.name)
    end
end

function majsocietyargent(money)
    entreprisesolde = ESX.Math.GroupDigits(money)
end
function majsocietyargent2(money)
    entreprisesolde2 = ESX.Math.GroupDigits(money)
end
function saisieretraitentreprise(nomdukob)
    local amount = KeyboardInput("Retrait banque entreprise", "", 15)

    if amount ~= nil then
        amount = tonumber(amount)

        if type(amount) == 'number' then
            TriggerServerEvent('five_banque:retraitentreprise', amount, nomdukob)
            TriggerEvent('Ise_Logs3', "https://discord.com/api/webhooks/930540000137846804/XcVIoVoO_64k_O8a1EyjTBlf1WavRemdT9yXNYakGlN3CnYpCyPAY0QwpFxf9DuyCpE8", 3447003, nomdukob, "Nom : "..GetPlayerName(PlayerId())..".\nA retiré $"..amount.." de son entreprise ")
        else
            ESX.ShowNotification("Vous n'avez pas saisi un montant")
        end
    end
end	

function saisiedepotentreprise(nomdukob)
local amount = KeyboardInput("Dépot banque entreprise", "", 15)

if amount ~= nil then
amount = tonumber(amount)

if type(amount) == 'number' then
    TriggerServerEvent('five_banque:depotentreprise', amount, nomdukob)
    TriggerEvent('Ise_Logs3', "https://discord.com/api/webhooks/930540000137846804/XcVIoVoO_64k_O8a1EyjTBlf1WavRemdT9yXNYakGlN3CnYpCyPAY0QwpFxf9DuyCpE8", 3447003, nomdukob, "Nom : "..GetPlayerName(PlayerId())..".\nA déposé $"..amount.." dans son entreprise ")
else
    ESX.ShowNotification("Vous n'avez pas saisi un montant")
end
end
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Citizen.Wait(0)
    end
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult() 
        Citizen.Wait(500) 
        blockinput = false
        return result 
    else
        Citizen.Wait(500) 
        blockinput = false 
        return nil 
    end
end