#define NON_BYOND_URL			"https://bay.proxima.fun/"
//#define ROUNDWAITERROLEID		""
#define RUNWAITERROLEID			"1287084776473493636"

/datum/tgs_chat_embed/provider/author/glob
	name = "Буквально Гунпещеры"
	url = NON_BYOND_URL
	icon_url = "https://cdn.discordapp.com/attachments/1287095900103250030/1290784480247808010/1287805995275391029.png"

/datum/tgs_chat_command/ircstatus
	name = "status"
	help_text = "Показывает админов, кол-во игроков, игровой режим и настоящий игровой режим на сервере"
	admin_only = TRUE
	var/last_irc_status = 0

/datum/tgs_chat_command/ircstatus/Run(datum/tgs_chat_user/sender, params)
	var/rtod = Uptime()
	if(rtod - last_irc_status < IRC_STATUS_THROTTLE)
		return
	last_irc_status = rtod
	var/list/adm = get_admin_counts()
	var/list/allmins = adm["total"]

	var/datum/tgs_message_content/message = new ("")
	var/datum/tgs_chat_embed/structure/embed = new()
	message.embed = embed
	var/datum/tgs_chat_embed/field/adminCount	= new ("Админы", "[allmins.len]")
	var/datum/tgs_chat_embed/field/afk			= new ("АФК", "[english_list(adm["afk"])]")
	var/datum/tgs_chat_embed/field/activeAdmins	= new ("Активные админы", "[english_list(adm["present"])]")
	var/datum/tgs_chat_embed/field/stealth		= new ("Скрыты", "[english_list(adm["stealth"])]")
	var/datum/tgs_chat_embed/field/useless		= new ("Сотрудники без флага +BAN", "[english_list(adm["noflags"])]")
	var/datum/tgs_chat_embed/field/players		= new ("Игроки", "[GLOB.clients.len]")
	var/datum/tgs_chat_embed/field/activePlayers= new ("Активные игроки", "[get_active_player_count(0,1,0)]")
	var/datum/tgs_chat_embed/field/modePublic	= new ("Публичный режим", "||[PUBLIC_GAME_MODE]||")
	var/datum/tgs_chat_embed/field/modeReal		= new ("Реальный режим", "||[SSticker.mode ? SSticker.mode.name : "Не начался"]||")
	adminCount.is_inline = TRUE
	afk.is_inline = TRUE
	stealth.is_inline = TRUE
	players.is_inline = TRUE
	activePlayers.is_inline = TRUE
	//modePublic.is_inline = TRUE
	modeReal.is_inline = TRUE
	embed.fields = list(adminCount, activeAdmins, afk, stealth, useless, players, activePlayers, modePublic, modeReal)
	embed.colour = "#00ff8c"

	embed.title = "Статус Гунпещер"
	embed.author = new /datum/tgs_chat_embed/provider/author/glob("Сервер 'PRX'")
	//embed.footer = new /datum/tgs_chat_embed/footer("Сервер 'PRX'")
	//embed.url = NON_BYOND_URL

	return message

/datum/tgs_chat_command/irccheck
	name = "check"
	help_text = "Показывает онлайн, текущий режим и адрес сервера"
	var/last_irc_check = 0

/datum/tgs_chat_command/irccheck/Run(datum/tgs_chat_user/sender, params)
	var/rtod = Uptime()
	if(rtod - last_irc_check < IRC_STATUS_THROTTLE)
		return
	last_irc_check = rtod

	var/datum/tgs_message_content/message = new ("")
	var/datum/tgs_chat_embed/structure/embed = new()
	message.embed = embed
	var/datum/tgs_chat_embed/field/round		= new ("Раунд №", "[game_id ? "[game_id]" : "НЕТ АЙДИ"]")
	var/datum/tgs_chat_embed/field/players		= new ("Игроки", "[GLOB.clients.len]")
	var/datum/tgs_chat_embed/field/map			= new ("Карта", "[GLOB.using_map.full_name]")
	var/datum/tgs_chat_embed/field/modePublic	= new ("Режим", "||[PUBLIC_GAME_MODE]||")
	var/datum/tgs_chat_embed/field/gameStatus	= new ("Статус игры", "[GAME_STATE != RUNLEVEL_LOBBY ? (GAME_STATE != RUNLEVEL_POSTGAME ? "Активен" : "Заканчивается") : "Подготавливается"]")

	round.is_inline = TRUE
	players.is_inline = TRUE
	//map.is_inline = TRUE
	modePublic.is_inline = TRUE
	gameStatus.is_inline = TRUE
	embed.fields = list(round, players, map, modePublic, gameStatus)
	embed.colour = "#ffae00"


	embed.title = "Статус гунпещер"
	embed.author = new /datum/tgs_chat_embed/provider/author/glob("Сервер 'Goonworld'")
	//embed.footer = new /datum/tgs_chat_embed/footer("Сервер 'PRX'")
	//embed.url = NON_BYOND_URL

	return message

/*
/datum/tgs_chat_command/ircmanifest
	name = "manifest"
	help_text = "Показывает список членов экипажа с их должностями"
	var/last_irc_check = 0

/datum/tgs_chat_command/ircmanifest/Run(datum/tgs_chat_user/sender, params)
	var/rtod = Uptime()
	if(rtod - last_irc_check < IRC_STATUS_THROTTLE)
		return
	last_irc_check = rtod

	if(GAME_STATE == RUNLEVEL_LOBBY)
		return new /datum/tgs_message_content("Раунд еще подготавливается...")

	var/datum/tgs_message_content/message = new ("")
	var/datum/tgs_chat_embed/structure/embed = new()
	message.embed = embed

	embed.colour = "#ff003c"
	embed.fields = list()

	embed.title = "Манифест экипажа на сервере Proxima"
	embed.author = new /datum/tgs_chat_embed/provider/author/glob("Сервер 'PRX'")
	//embed.footer = new /datum/tgs_chat_embed/footer("Сервер 'PRX'")
	//embed.url = NON_BYOND_URL

	var/list/msg = list()
	var/list/positions = list()
	var/list/nano_crew_manifest = nano_crew_manifest()
	// We rebuild the list in the format external tools expect
	for(var/dept in nano_crew_manifest)
		var/list/dept_list = nano_crew_manifest[dept]
		if(dept_list.len > 0)
			positions[dept] = list()
			var/depString
			switch(dept)
				if ("heads") depString = "Командование"
				if ("spt") depString = "Поддержка командования"
				if ("sci") depString = "Научный отдел"
				if ("sec") depString = "Отдел безопасности"
				if ("eng") depString = "Инженерный отдел"
				if ("med") depString = "Медицинский отдел"
				if ("sup") depString = "Отдел снабжения"
				if ("exp") depString = "Экспедиционный отдел"
				if ("srv") depString = "Отдел обслуживания"
				if ("bot") depString = "Синтетики"
				if ("civ") depString = "Гражданские"
				else depString = dept
			for(var/list/person in dept_list)
				var/datum/mil_branch/branch_obj = GLOB.mil_branches.get_branch(person["branch"])
				var/datum/mil_rank/rank_obj = GLOB.mil_branches.get_rank(person["branch"], person["milrank"])
				msg += "*[person["rank"]]* - `[((branch_obj != null) && (branch_obj.name_short) && (branch_obj.name_short != "")) ? "[branch_obj.name_short] " : ""][((rank_obj != null) && (rank_obj.name_short) && (rank_obj.name_short != "")) ? "[rank_obj.name_short] " : ""][replacetext_char(person["name"], "&#39;", "'")]`"

			var/datum/tgs_chat_embed/field/depEntry	= new ("[depString]", jointext(msg, "\n"))
			embed.fields += depEntry

			msg = list()
	return message
*/

/datum/tgs_chat_command/adminwho
	name = "adminwho"
	help_text = "Перечисляет администраторов, находящихся на сервере"

/datum/tgs_chat_command/adminwho/Run(datum/tgs_chat_user/sender, params)
	var/list/msg = list()
	var/active_staff = 0
	var/total_staff = 0
	var/can_investigate = sender.channel.is_admin_channel

	for(var/client/C in GLOB.admins)
		var/line = list()
		if(!can_investigate && C.is_stealthed())
			continue
		total_staff++
		if(check_rights(R_ADMIN,0,C))
			line += "*[C]* в ранге ***["\improper[C.holder.rank]"]***"
		else
			line += "*[C]* в ранге *["\improper[C.holder.rank]"]*"
		if(!C.is_afk())
			active_staff++
		if(can_investigate)
			if(C.is_afk())
				line += " *(АФК - [C.inactivity2text()])*"
			if(isghost(C.mob))
				line += " - *Наблюдает*"
			else if(istype(C.mob,/mob/new_player))
				line += " - *В Лобби*"
			else
				line += " - *Играет*"
			if(C.is_stealthed())
				line += " *(Скрыт)*"
		line = jointext(line, null)
		if(check_rights(R_ADMIN,0,C))
			msg.Insert(1, line)
		else
			msg += line

	var/datum/tgs_message_content/message = new ("")
	var/datum/tgs_chat_embed/structure/embed = new()
	message.embed = embed

	embed.colour = "#ff0000"

	embed.title = "Список администрации на сервере Proxima"
	embed.author = new /datum/tgs_chat_embed/provider/author/glob("Сервер 'PRX'")
	//embed.footer = new /datum/tgs_chat_embed/footer("Сервер 'PRX'")
	//embed.url = NON_BYOND_URL

	var/datum/tgs_chat_embed/field/adminCount	= new ("Админы онлайн", "[can_investigate?"[active_staff]/[total_staff]":"[active_staff]"]")
	var/datum/tgs_chat_embed/field/adminList	= new ("Список администрации", jointext(msg, "\n"))
	embed.fields = list(adminCount, adminList)

	return message

GLOBAL_LIST(round_end_notifiees)

/datum/tgs_chat_command/notify
	name = "notify"
	help_text = "Уведомляет вызвавшего по окончанию раунда"
	//admin_only = TRUE

/datum/tgs_chat_command/notify/Run(datum/tgs_chat_user/sender, params)
	if(GAME_STATE == RUNLEVEL_POSTGAME)
		return new /datum/tgs_message_content("[sender.mention], раунд уже закончился!")
	LAZYINITLIST(GLOB.round_end_notifiees)
	GLOB.round_end_notifiees[sender.mention] = TRUE
	return new /datum/tgs_message_content("Я уведомлю [sender.mention] когда раунд закончится.")
