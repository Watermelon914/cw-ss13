/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/

/obj/screen
	name = ""
	icon = 'icons/mob/hud/screen1.dmi'
	icon_state = "x"
	layer = ABOVE_HUD_LAYER
	unacidable = TRUE
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/obj/screen/cinematic
	layer = CINEMATIC_LAYER
	mouse_opacity = 0
	screen_loc = "1,0"

/obj/screen/cinematic/explosion
	icon = 'icons/effects/station_explosion.dmi'
	icon_state = "intro_ship"

/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.


/obj/screen/close
	name = "close"
	icon_state = "x"


/obj/screen/close/clicked(var/mob/user)
	if(master)
		if(isstorage(master))
			var/obj/item/storage/S = master
			S.storage_close(user)
	return TRUE


/obj/screen/action_button
	icon = 'icons/mob/hud/actions.dmi'
	icon_state = "template"
	var/datum/action/source_action

/obj/screen/action_button/clicked(var/mob/user)
	if(!user || !source_action)
		return TRUE

	if(source_action.can_use_action())
		source_action.action_activate()
	return TRUE

/obj/screen/action_button/Destroy()
	source_action = null
	. = ..()

/obj/screen/action_button/proc/get_button_screen_loc(button_number)
	var/row = round((button_number-1)/13) //13 is max amount of buttons per row
	var/col = ((button_number - 1)%(13)) + 1
	var/coord_col = "+[col-1]"
	var/coord_col_offset = 4+2*col
	var/coord_row = "[-1 - row]"
	var/coord_row_offset = 26
	return "WEST[coord_col]:[coord_col_offset],NORTH[coord_row]:[coord_row_offset]"



/obj/screen/action_button/hide_toggle
	name = "Hide Buttons"
	icon = 'icons/mob/hud/actions.dmi'
	icon_state = "hide"
	var/hidden = 0

/obj/screen/action_button/hide_toggle/clicked(var/mob/user, mods)
	user.hud_used.action_buttons_hidden = !user.hud_used.action_buttons_hidden
	hidden = user.hud_used.action_buttons_hidden
	if(hidden)
		name = "Show Buttons"
		icon_state = "show"
	else
		name = "Hide Buttons"
		icon_state = "hide"
	user.update_action_buttons()
	return 1


/obj/screen/storage
	name = "storage"
	layer = HUD_LAYER

/obj/screen/storage/proc/update_fullness(obj/item/storage/S)
	if(!S.contents.len)
		color = null
	else
		var/total_w = 0
		for(var/obj/item/I in S)
			total_w += I.w_class

		//Calculate fullness for etiher max storage, or for storage slots if the container has them
		var/fullness = 0
		if (S.storage_slots == null)
			fullness = round(10*total_w/S.max_storage_space)
		else
			fullness = round(10*S.contents.len/S.storage_slots)
		switch(fullness)
			if(10) color = "#ff0000"
			if(7 to 9) color = "#ffa500"
			else color = null



/obj/screen/gun
	name = "gun"
	dir = SOUTH
	var/gun_click_time = -100

/obj/screen/gun/move
	name = "Allow Walking"
	icon_state = "no_walk0"

	update_icon(mob/user)
		if(user.gun_mode)
			if(user.target_can_move)
				icon_state = "no_walk1"
				name = "Disallow Walking"
			else
				icon_state = "no_walk0"
				name = "Allow Walking"
			screen_loc = initial(screen_loc)
			return
		screen_loc = null

/obj/screen/gun/move/clicked(var/mob/user)
	if (..())
		return 1

	if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
		return 1
	if(!istype(user.get_held_item(),/obj/item/weapon/gun))
		to_chat(user, "You need your gun in your active hand to do that!")
		return 1
	user.AllowTargetMove()
	gun_click_time = world.time
	return 1


/obj/screen/gun/run
	name = "Allow Running"
	icon_state = "no_run0"

	update_icon(mob/user)
		if(user.gun_mode)
			if(user.target_can_move)
				if(user.target_can_run)
					icon_state = "no_run1"
					name = "Disallow Running"
				else
					icon_state = "no_run0"
					name = "Allow Running"
				screen_loc = initial(screen_loc)
				return
		screen_loc = null

/obj/screen/gun/run/clicked(var/mob/user)
	if (..())
		return 1

	if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
		return 1
	if(!istype(user.get_held_item(),/obj/item/weapon/gun))
		to_chat(user, "You need your gun in your active hand to do that!")
		return 1
	user.AllowTargetRun()
	gun_click_time = world.time
	return 1


/obj/screen/gun/item
	name = "Allow Item Use"
	icon_state = "no_item0"

	update_icon(mob/user)
		if(user.gun_mode)
			if(user.target_can_click)
				icon_state = "no_item1"
				name = "Allow Item Use"
			else
				icon_state = "no_item0"
				name = "Disallow Item Use"
			screen_loc = initial(screen_loc)
			return
		screen_loc = null

/obj/screen/gun/item/clicked(var/mob/user)
	if (..())
		return 1

	if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
		return 1
	if(!istype(user.get_held_item(),/obj/item/weapon/gun))
		to_chat(user, "You need your gun in your active hand to do that!")
		return 1
	user.AllowTargetClick()
	gun_click_time = world.time
	return 1


/obj/screen/gun/mode
	name = "Toggle Gun Mode"
	icon_state = "gun0"

	update_icon(mob/user)
		if(user.gun_mode) icon_state = "gun1"
		else icon_state = "gun0"

/obj/screen/gun/mode/clicked(var/mob/user)
	if (..())
		return 1
	user.ToggleGunMode()
	return 1


/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	var/selecting = "chest"

/obj/screen/zone_sel/update_icon(mob/living/user)
	overlays.Cut()
	overlays += image('icons/mob/hud/zone_sel.dmi', "[selecting]")
	user.zone_selected = selecting

/obj/screen/zone_sel/clicked(var/mob/user, var/list/mods)
	if (..())
		return 1

	var/icon_x = text2num(mods["icon-x"])
	var/icon_y = text2num(mods["icon-y"])
	var/old_selecting = selecting //We're only going to update_icon() if there's been a change

	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					selecting = "r_foot"
				if(17 to 22)
					selecting = "l_foot"
				else
					return 1
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					selecting = "r_leg"
				if(17 to 22)
					selecting = "l_leg"
				else
					return 1
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					selecting = "r_hand"
				if(12 to 20)
					selecting = "groin"
				if(21 to 24)
					selecting = "l_hand"
				else
					return 1
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					selecting = "r_arm"
				if(12 to 20)
					selecting = "chest"
				if(21 to 24)
					selecting = "l_arm"
				else
					return 1
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				selecting = "head"
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							selecting = "mouth"
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							selecting = "eyes"
					if(25 to 27)
						if(icon_x in 15 to 17)
							selecting = "eyes"

	if(old_selecting != selecting)
		update_icon(user)
	return 1

/obj/screen/zone_sel/robot
	icon = 'icons/mob/hud/screen1_robot.dmi'

/obj/screen/clicked(var/mob/user)
	if(!user)	return 1

	switch(name)
		if("equip")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.quick_equip()
			return 1

		if("Reset Machine")
			user.unset_interaction()
			return 1

		if("module")
			if(isSilicon(user))
				if(usr:module)
					return 1
				user:pick_module()
			return 1

		if("radio")
			if(isSilicon(user))
				user:radio_menu()
			return 1
		if("panel")
			if(isSilicon(user))
				user:installed_modules()
			return 1

		if("store")
			if(isSilicon(user))
				user:uneq_active()
			return 1

		if("module1")
			if(isrobot(user))
				user:toggle_module(1)
			return 1

		if("module2")
			if(isrobot(user))
				user:toggle_module(2)
			return 1

		if("module3")
			if(isrobot(user))
				user:toggle_module(3)
			return 1

		if("Activate weapon attachment")
			var/obj/item/weapon/gun/G = user.get_held_item()
			if(istype(G))
				G.activate_attachment_verb()
			return 1

		if("Toggle Rail Flashlight")
			var/obj/item/weapon/gun/G = user.get_held_item()
			if(istype(G))
				G.activate_rail_attachment_verb()
			return 1

		if("Eject magazine")
			var/obj/item/weapon/gun/G = user.get_held_item()
			if(istype(G)) G.empty_mag()
			return 1

		if("Toggle burst fire")
			var/obj/item/weapon/gun/G = user.get_held_item()
			if(istype(G)) G.toggle_burst()
			return 1

		if("Use unique action")
			var/obj/item/weapon/gun/G = user.get_held_item()
			if(istype(G)) G.use_unique_action()
			return 1
	return 0


/obj/screen/inventory/clicked(var/mob/user)
	if (..())
		return 1
	if(user.is_mob_incapacitated(TRUE))
		return 1
	switch(name)
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = user
				C.activate_hand("r")
			return 1
		if("l_hand")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.activate_hand("l")
			return 1
		if("swap")
			user.swap_hand()
			return 1
		if("hand")
			user.swap_hand()
			return 1
		else
			if(user.attack_ui(slot_id))
				user.update_inv_l_hand(0)
				user.update_inv_r_hand(0)
				return 1
	return 0

/obj/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/mob/hud/human_midnight.dmi'
	icon_state = "act_throw_off"

/obj/screen/throw_catch/clicked(var/mob/user, var/list/mods)
	var/mob/living/carbon/C = user

	if (!istype(C))
		return

	if(user.is_mob_incapacitated())
		return TRUE

	if (mods["ctrl"])
		C.toggle_throw_mode(THROW_MODE_HIGH)
	else
		C.toggle_throw_mode(THROW_MODE_NORMAL)
	return TRUE

/obj/screen/drop
	name = "drop"
	icon = 'icons/mob/hud/human_midnight.dmi'
	icon_state = "act_drop"
	layer = HUD_LAYER

/obj/screen/drop/clicked(var/mob/user)
	user.drop_item_v()
	return 1


/obj/screen/resist
	name = "resist"
	icon = 'icons/mob/hud/human_midnight.dmi'
	icon_state = "act_resist"
	layer = HUD_LAYER

/obj/screen/resist/clicked(var/mob/user)
	if(isliving(user))
		var/mob/living/L = user
		L.resist()
		return 1

/obj/screen/act_intent
	name = "intent"
	icon_state = "intent_help"

/obj/screen/act_intent/clicked(var/mob/user)
	user.a_intent_change()
	return 1

/obj/screen/act_intent/corner/clicked(var/mob/user, var/list/mods)
	var/_x = text2num(mods["icon-x"])
	var/_y = text2num(mods["icon-y"])

	if(_x<=16 && _y<=16)
		user.a_intent_change(INTENT_HARM)

	else if(_x<=16 && _y>=17)
		user.a_intent_change(INTENT_HELP)

	else if(_x>=17 && _y<=16)
		user.a_intent_change(INTENT_GRAB)

	else if(_x>=17 && _y>=17)
		user.a_intent_change(INTENT_DISARM)

	return 1


/obj/screen/healths
	name = "health"
	icon_state = "health0"
	icon = 'icons/mob/hud/human_midnight.dmi'
	mouse_opacity = 0

/obj/screen/pull
	name = "stop pulling"
	icon = 'icons/mob/hud/human_midnight.dmi'
	icon_state = "pull0"

/obj/screen/pull/clicked(var/mob/user)
	if (..())
		return 1
	user.stop_pulling()
	return 1

/obj/screen/pull/update_icon(mob/user)
	if(!user) return
	if(user.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"



/obj/screen/squad_leader_locator
	icon = 'icons/mob/hud/human_midnight.dmi'
	icon_state = "trackoff"
	name = "squad leader locator"
	alpha = 0 //invisible
	mouse_opacity = 0

/obj/screen/squad_leader_locator/clicked(var/mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(H.get_active_hand())
		return
	var/obj/item/device/radio/headset/almayer/marine/earpiece = H.wear_ear
	if(!H.assigned_squad || !istype(earpiece) || H.assigned_squad.radio_freq != earpiece.frequency)
		to_chat(H, SPAN_WARNING("Unauthorized access detected."))
		return
	H.assigned_squad.ui_interact(H)

/obj/screen/queen_locator
	icon = 'icons/mob/hud/alien_standard.dmi'
	icon_state = "trackoff"
	name = "queen locator"

/obj/screen/queen_locator/clicked(var/mob/living/carbon/Xenomorph/X)
	if(!istype(X))
		return FALSE
	if(!X.hive)
		return FALSE
	if(!X.hive.living_xeno_queen)
		return FALSE
	X.overwatch(X.hive.living_xeno_queen)

/obj/screen/xenonightvision
	icon = 'icons/mob/hud/alien_standard.dmi'
	name = "toggle night vision"
	icon_state = "nightvision1"

/obj/screen/xenonightvision/clicked(var/mob/user)
	if (..())
		return 1
	var/mob/living/carbon/Xenomorph/X = user
	X.toggle_nightvision()
	if(icon_state == "nightvision1")
		icon_state = "nightvision0"
	else
		icon_state = "nightvision1"
	return 1

/obj/screen/bodytemp
	name = "body temperature"
	icon_state = "temp0"

/obj/screen/oxygen
	name = "oxygen"
	icon_state = "oxy0"

/obj/screen/toggle_inv
	name = "toggle"
	icon_state = "other"

/obj/screen/toggle_inv/clicked(var/mob/user)
	if (..())
		return 1

	if(user && user.hud_used)
		if(user.hud_used.inventory_shown)
			user.hud_used.inventory_shown = 0
			user.client.screen -= user.hud_used.toggleable_inventory
		else
			user.hud_used.inventory_shown = 1
			user.client.screen += user.hud_used.toggleable_inventory

		user.hud_used.hidden_inventory_update()
	return 1


/obj/screen/ammo
	name = "ammo"
	icon = 'icons/mob/hud/ammoHUD.dmi'
	icon_state = "ammo"
	var/warned = FALSE


/obj/screen/ammo/proc/add_hud(mob/living/user)
	if(!user?.client)
		return

	var/obj/item/weapon/gun/G = user.get_held_item()

	if(!G?.hud_enabled || !(G.flags_gun_features & GUN_AMMO_COUNTER))
		return

	user.client.screen += src


/obj/screen/ammo/proc/remove_hud(mob/living/user)
	user?.client?.screen -= src


/obj/screen/ammo/proc/update_hud(mob/living/user)
	if(!user?.client?.screen.Find(src))
		return

	var/obj/item/weapon/gun/G = user.get_held_item()

	if(!istype(G) || !(G.flags_gun_features & GUN_AMMO_COUNTER) || !G.hud_enabled || !G.get_ammo_type() || isnull(G.get_ammo_count()))
		remove_hud(user)
		return

	var/list/ammo_type = G.get_ammo_type()
	var/rounds = G.get_ammo_count()

	var/hud_state = ammo_type[1]
	var/hud_state_empty = ammo_type[2]

	overlays.Cut()

	var/empty = image('icons/mob/hud/ammoHUD.dmi', src, "[hud_state_empty]")

	if(rounds == 0)
		if(warned)
			overlays += empty
		else
			warned = TRUE
			var/obj/screen/ammo/F = new /obj/screen/ammo(src)
			F.icon_state = "frame"
			user.client.screen += F
			flick("[hud_state_empty]_flash", F)
			spawn(20)
				user.client.screen -= F
				qdel(F)
				overlays += empty
	else
		warned = FALSE
		overlays += image('icons/mob/hud/ammoHUD.dmi', src, "[hud_state]")

	rounds = num2text(rounds)

	//Handle the amount of rounds
	switch(length(rounds))
		if(1)
			overlays += image('icons/mob/hud/ammoHUD.dmi', src, "o[rounds[1]]")
		if(2)
			overlays += image('icons/mob/hud/ammoHUD.dmi', src, "o[rounds[2]]")
			overlays += image('icons/mob/hud/ammoHUD.dmi', src, "t[rounds[1]]")
		if(3)
			overlays += image('icons/mob/hud/ammoHUD.dmi', src, "o[rounds[3]]")
			overlays += image('icons/mob/hud/ammoHUD.dmi', src, "t[rounds[2]]")
			overlays += image('icons/mob/hud/ammoHUD.dmi', src, "h[rounds[1]]")
		else //"0" is still length 1 so this means it's over 999
			overlays += image('icons/mob/hud/ammoHUD.dmi', src, "o9")
			overlays += image('icons/mob/hud/ammoHUD.dmi', src, "t9")
			overlays += image('icons/mob/hud/ammoHUD.dmi', src, "h9")
