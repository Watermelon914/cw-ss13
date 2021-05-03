/datum/pointshop_product/supply_drop/reinforcement
	name = "Reinforcements"
	desc = "Sends down a droppod containing a reinforcement marine. Refunds you if no reinforcements are available."
	icon_state = "marine"
	cost = 30
	var/active = FALSE
	var/list/players = list()
	var/timer = 15 SECONDS
	var/turf/target

	var/loadout = "USCM Cryo Private (Equipped)"

/datum/pointshop_product/supply_drop/reinforcement/ui_data(mob/user)
	. = ..()
	for(var/i in GLOB.observer_list)
		var/mob/M = i
		if(M.client && !(M.client.prefs.be_special & DONT_BE_MARINE_AFTER_DEATH))
			return

	.["name"] += " (Unavailable)"

/datum/pointshop_product/supply_drop/reinforcement/can_purchase_product(mob/user)
	. = ..()
	if(!.)
		return

	if(active)
		return FALSE

	for(var/i in GLOB.observer_list)
		var/mob/M = i
		if(M.client && !(M.client.prefs.be_special & DONT_BE_MARINE_AFTER_DEATH))
			return TRUE
	to_chat(user, SPAN_WARNING("No reinforcements available! Please try again later."))
	return FALSE

/datum/pointshop_product/supply_drop/reinforcement/launch(turf/T)
	active = TRUE
	for(var/i in GLOB.observer_list)
		var/mob/M = i
		if(M.client && !(M.client.prefs.be_special & DONT_BE_MARINE_AFTER_DEATH))
			sound_to(M.client, 'sound/misc/notice3.ogg')
			tgui_alert_async(M, "Would you like to re-enter the game as a marine reinforcement?", "Reinforcements", list("Yes", "No"), CALLBACK(src, .proc/add_player, M), timer)

	target = T
	addtimer(CALLBACK(src, .proc/finish_launch), timer)

/datum/pointshop_product/supply_drop/reinforcement/proc/finish_launch()
	active = FALSE
	var/mob/M
	while((!M || !M.client) && length(players))
		M = pick(players)
		players -= M
	players.Cut()
	if(!M)
		parent.points += cost
		return

	var/obj/structure/droppod/container/toLaunch = new()
	var/mob/living/carbon/human/H = new(toLaunch)
	H.create_hud()
	M.mind.transfer_to(H)
	H.client.prefs.copy_all_to(H)
	arm_equipment(H, loadout)
	toLaunch.launch(target)

/datum/pointshop_product/supply_drop/reinforcement/proc/add_player(var/mob/M, var/choice)
	if(!active || choice != "Yes")
		return

	players += M

/datum/pointshop_product/supply_drop/reinforcement/Destroy(force, ...)
	players = null
	target = null
	return ..()
