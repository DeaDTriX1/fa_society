ESX = nil
RegisteredSocieties = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function GetSociety(name)
  for i=1, #RegisteredSocieties, 1 do
    if RegisteredSocieties[i].name == name then
      return RegisteredSocieties[i]
    end
  end
end

AddEventHandler('esx_society:getSociety', function(name, cb)
  cb(GetSociety(name))
end)

AddEventHandler('esx_society:registerSociety', function(name, label, account, datastore, inventory, data)
  local found = false
  local society = {
    name      = name,
    label     = label,
    account   = account,
    datastore = datastore,
    inventory = inventory,
    data      = data,
  }
  for i=1, #RegisteredSocieties, 1 do
    if RegisteredSocieties[i].name == name then
      found                  = true
      RegisteredSocieties[i] = society
      break
    end
  end
  if not found then
    table.insert(RegisteredSocieties, society)
  end
end)

RegisterServerEvent('five_society:updateargentsale')
AddEventHandler('five_society:updateargentsale', function(entreprise, montant, depot, retoudep)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if retoudep == 1 then
	xPlayer.removeAccountMoney('black_money', depot)
	TriggerClientEvent('esx:showNotification', source, "Le coffre a maintenant "..montant.."$ d'argent sale et tu a déposé "..depot.."$")
end
if retoudep == 0 then
	xPlayer.addAccountMoney('black_money', depot)
	TriggerClientEvent('esx:showNotification', source, "Le coffre a maintenant "..montant.."$ d'argent sale et tu a retiré "..depot.."$")
end
	MySQL.Async.execute(
		'UPDATE addon_account SET argentsale = @montantzebi WHERE name = @name',
		{
			['@montantzebi'] = montant,
			['@name'] = entreprise
		}
	)
end)

ESX.RegisterServerCallback('five_society:recargentsalecoffre', function(source, cb, entreprise)
    local xPlayer = ESX.GetPlayerFromId(source)
    local argentsale = {}
    MySQL.Async.fetchAll('SELECT * FROM addon_account WHERE name = @name', {
        ['@name'] = entreprise
    }, function(result)
      for i = 1, #result, 1 do
      table.insert(argentsale, {
      	montantsale = result[i].argentsale
      })
    end
    cb(argentsale)
    end)
end)

RegisterServerEvent("five_banque:retraitentreprise")
AddEventHandler("five_banque:retraitentreprise", function(money, job)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local total = money
    local xMoney = xPlayer.getBank()
    
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..job, function (account)
        if account.money >= total then
            account.removeMoney(total)
            xPlayer.addtMoney(total)
            TriggerClientEvent('esx:showAdvancedNotification', source, 'Banque', 'Banque', "~g~Vous avez retiré "..total.." $ de votre entreprise", 'CHAR_BANK_FLEECA', 10)
        else
            TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas assez d\'argent dans votre entreprise!")
        end
    end)

   
end) 

RegisterServerEvent("five_banque:depotentreprise")
AddEventHandler("five_banque:depotentreprise", function(money, job)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local total = money
    local xMoney = xPlayer.getMoney()
    
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..job, function (account)
        if xMoney >= total then
            account.addMoney(total)
            xPlayer.removeMoney(total)
            TriggerClientEvent('esx:showAdvancedNotification', source, 'Banque', 'Banque', "~g~Vous avez déposé "..total.." $ dans votre entreprise", 'CHAR_BANK_FLEECA', 10)
        else
            TriggerClientEvent('esx:showNotification', source, "Vous n'avez pas assez d\'argent !")
        end
    end)   
end)

RegisterServerEvent('five_patron:blanchir')
AddEventHandler('five_patron:blanchir', function(society, amount)

  local xPlayer = ESX.GetPlayerFromId(source)
  local account = xPlayer.getAccount('black_money')

  if xPlayer.job.grade_name == 'boss' or xPlayer.job2.grade_name == 'boss' then
  if amount > 0 and account.money >= amount then
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Blanchiment en cours, 1 minute à patienter...")
  	Wait(60000)
    TriggerClientEvent('esx:showNotification', xPlayer.source, "tu as reçu $"..amount.."argent propre")
    xPlayer.removeAccountMoney('black_money', amount)
    xPlayer.addMoney(amount)

  else
    TriggerClientEvent('esx:showNotification', xPlayer.source, 'montant invalide')
  end
else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "t'es pas patron...")
end
end)

RegisterServerEvent('five_patron:recruter')
AddEventHandler('five_patron:recruter', function(societe, job2, target)

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(target)

  
  if job2 == false then
  	if xPlayer.job.grade_name == 'boss' then
  	xTarget.setJob(societe, 0)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été recruté")
  	TriggerClientEvent('esx:showNotification', target, "Bienvenue chez "..societe.."!")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "t'es pas patron...")
end
  else
  	if xPlayer.job2.grade_name == 'boss' then
  	xTarget.setJob2(societe, 0)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été recruté")
  	TriggerClientEvent('esx:showNotification', target, "Bienvenue chez "..societe.."!")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "t'es pas patron...")
end
  end
end)

RegisterServerEvent('five_patron:promouvoir')
AddEventHandler('five_patron:promouvoir', function(societe, job2, target)

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(target)

  
  if job2 == false then
  	if xPlayer.job.grade_name == 'boss' and xPlayer.job.name == xTarget.job.name then
  	xTarget.setJob(societe, tonumber(xTarget.job.grade) + 1)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été promu")
  	TriggerClientEvent('esx:showNotification', target, "Vous avez été promu chez "..societe.."!")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "t'es pas patron ou alors le joueur ne peut pas être promu")
end
  else
  	if xPlayer.job2.grade_name == 'boss' and xPlayer.job2.name == xTarget.job2.name then
  	xTarget.setJob2(societe, tonumber(xTarget.job2.grade) + 1)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été promu")
  	TriggerClientEvent('esx:showNotification', target, "Vous avez été promu "..societe.."!")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "t'es pas patron ou alors le joueur ne peut pas être promu")
end
  end
end)

RegisterServerEvent('five_patron:descendre')
AddEventHandler('five_patron:descendre', function(societe, job2, target)

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(target)

  
  if job2 == false then
  	if xPlayer.job.grade_name == 'boss' and xPlayer.job.name == xTarget.job.name then
  	xTarget.setJob(societe, tonumber(xTarget.job.grade) - 1)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été rétrogradé")
  	TriggerClientEvent('esx:showNotification', target, "Vous avez été rétrogradé de "..societe.."!")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "t'es pas patron ou alors le joueur ne peut pas être promu")
end
  else
  	if xPlayer.job2.grade_name == 'boss' and xPlayer.job2.name == xTarget.job2.name then
  	xTarget.setJob2(societe, tonumber(xTarget.job2.grade) - 1)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été rétrogradé")
  	TriggerClientEvent('esx:showNotification', target, "Vous avez été rétrogradé de "..societe.."!")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "t'es pas patron ou alors le joueur ne peut pas être promu")
end
  end
end)

RegisterServerEvent('five_patron:virer')
AddEventHandler('five_patron:virer', function(societe, job2, target)

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(target)

  
  if job2 == false then
  	if xPlayer.job.grade_name == 'boss' and xPlayer.job.name == xTarget.job.name then
  	xTarget.setJob("unemployed", 0)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été viré")
  	TriggerClientEvent('esx:showNotification', target, "Vous avez été viré de "..societe.."!")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "t'es pas patron ou alors le joueur ne peut pas être viré")
end
  else
  	if xPlayer.job2.grade_name == 'boss' and xPlayer.job2.name == xTarget.job2.name then
  	xTarget.setJob2("unemployed2", 0)
  	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le joueur a été viré")
  	TriggerClientEvent('esx:showNotification', target, "Vous avez été viré de "..societe.."!")
  	else
	TriggerClientEvent('esx:showNotification', xPlayer.source, "t'es pas patron ou alors le joueur ne peut pas être viré")
end
  end
end)

ESX.RegisterServerCallback('five_patron:listesalaire', function(source, cb, job)
  local xPlayer = ESX.GetPlayerFromId(source)
  local listegens = {}

  MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = @job', {
    ['@job'] = job
  }, function(result)
    for i = 1, #result, 1 do
      table.insert(listegens, {
        salaire = result[i].salary,
        nom = result[i].label,
        id = result[i].id
      })
    end

    cb(listegens)
  end)
end)

RegisterServerEvent('five_society:changersalaire')
AddEventHandler('five_society:changersalaire', function (id, salaire)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)


  MySQL.Async.execute(
    'UPDATE job_grades SET salary = @salaire WHERE id = @id',
    {
      ['@salaire'] = salaire,
      ['@id'] = id
    }
  )
end)

ESX.RegisterServerCallback('five_patron:listegensjob1', function(source, cb, job)
  local xPlayer = ESX.GetPlayerFromId(source)
  local listegens = {}

  MySQL.Async.fetchAll('SELECT * FROM users WHERE job = @job', {
    ['@job'] = job
  }, function(result)
    for i = 1, #result, 1 do
      if result[i].identifier ~= xPlayer.identifier then
      table.insert(listegens, {
        prenom = result[i].firstname,
        nom = result[i].lastname,
        steam = result[i].identifier
      })
    end
    end
    cb(listegens)
  end)
end)

ESX.RegisterServerCallback('five_patron:listegensjob2', function(source, cb, job2)
  local xPlayer = ESX.GetPlayerFromId(source)
  local listegens = {}

  MySQL.Async.fetchAll('SELECT * FROM users WHERE job2 = @job', {
    ['@job'] = job2
  }, function(result)
    for i = 1, #result, 1 do
      if result[i].identifier ~= xPlayer.identifier then
      table.insert(listegens, {
        prenom = result[i].firstname,
        nom = result[i].lastname,
        steam = result[i].identifier
      })
    end
    end
    cb(listegens)
  end)
end)

RegisterServerEvent('five_society:virersql')
AddEventHandler('five_society:virersql', function (identifier)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)


  MySQL.Async.execute(
    'UPDATE users SET job = @job WHERE identifier = @identifier',
    {
      ['@identifier'] = identifier,
      ['@job'] = "unemployed"
    }
  )
end)

RegisterServerEvent('five_society:virersql2')
AddEventHandler('five_society:virersql2', function (identifier)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)


  MySQL.Async.execute(
    'UPDATE users SET job2 = @job WHERE identifier = @identifier',
    {
      ['@identifier'] = identifier,
      ['@job'] = "unemployed"
    }
  )
end)


ESX.RegisterServerCallback('five_society:getSocietyMoney', function(source, cb, societyName)
  if societyName ~= nil then
    local society = "society_"..societyName
    TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
      cb(account.money)
    end)
  else
    cb(0)
  end
end)
