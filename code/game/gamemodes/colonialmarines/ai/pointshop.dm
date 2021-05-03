/datum/pointshop
	var/points = 0
	var/mob/handler

	var/list/products = list()

/datum/pointshop/ui_status(mob/user, datum/ui_state/state)
	if(handler == user)
		return UI_INTERACTIVE
	return UI_UPDATE


/datum/pointshop/ui_data(mob/user)
	. = list()
	.["points"] = points

/datum/pointshop/ui_static_data(mob/user)
	. = list()
	.["products"] = list()
	var/index = 1
	for(var/i in products)
		var/datum/pointshop_product/PSP
		.["products"] += list(list(
			"name" = PSP.name,
			"desc" = PSP.desc,
			"cost" = PSP.cost,
			"index" = index
		))

/datum/pointshop/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("purchase")
			var/index = text2num(params["index_to_purchase"])
			if(!index || index < 1 || index > length(products))
				return

			var/datum/pointshop_product/PSP = products[index]
			PSP.purchase_product(src, usr)
			. = TRUE


/datum/pointshop_product
	var/name = ""
	var/desc = ""
	var/cost = 0
	var/abstract_type = /datum/pointshop_product
	var/datum/pointshop/parent

/datum/pointshop_product/proc/can_purchase_product(var/mob/user)
	if(parent.points < cost)
		return
	return TRUE

/// Sanitizing proc to make sure they can actually purchase the product. Deducts points if they can
/datum/pointshop_product/proc/try_purchase_product(var/mob/user)
	if(can_purchase_product(user))
		return
	parent.points -= cost
	return TRUE

/datum/pointshop_product/proc/purchase_product(var/mob/user)
	if(!try_purchase_product(user))
		return
	return TRUE

/datum/pointshop_product/supply_drop
	abstract_type = /datum/pointshop_product/supply_drop

	var/mob/targetter

/datum/pointshop_product/supply_drop/purchase_product(var/mob/user)
	if(!can_purchase_product(user))
		return

	if(targetter == user)
		unregister_user(user)
	else
		register_user(user)

/datum/pointshop_product/supply_drop/proc/register_user(var/mob/M)
	if(targetter)
		unregister_user(targetter)
	RegisterSignal(M, COMSIG_MOB_POST_RESET_VIEW, .proc/mouse_launch)
	RegisterSignal(M, COMSIG_MOB_PRE_CLICK, .proc/select_launch_target)
	RegisterSignal(M, COMSIG_PARENT_QDELETING, .proc/unregister_user)
	targetter = M

/datum/pointshop_product/supply_drop/proc/unregister_user(var/mob/M)
	UnregisterSignal(M, list(
		COMSIG_MOB_POST_RESET_VIEW,
		COMSIG_MOB_PRE_CLICK
	))
	if(M == targetter)
		targetter = null

/datum/pointshop_product/supply_drop/proc/mouse_launch(var/mob/M)
	SIGNAL_HANDLER
	if(M.client)
		M.client.mouse_pointer_icon = 'icons/effects/mouse_pointer/supplypod_target.dmi' //Icon for when mouse is released

/datum/pointshop_product/supply_drop/proc/select_launch_target(var/mob/M, var/atom/target, var/list/mods)
	SIGNAL_HANDLER
	var/left_click = mods["left"]

	if(!left_click || istype(target,/obj/screen))
		return
	unregister_user(M)

	var/turf/T = get_turf(target)
	if(T.density)
		return

	if(!try_purchase_product(M))
		to_chat(M, SPAN_WARNING("Failed to purchase [name]!"))
		return

	launch(T)

	message_staff("[key_name_admin(M)] launched a droppod", target.x, target.y, target.z)
	return COMPONENT_INTERRUPT_CLICK

/datum/pointshop_product/supply_drop/proc/launch(var/turf/T)
	if (isnull(T))
		return
	var/obj/structure/droppod/container/toLaunch = new() //Duplicate the temp_pod (which we have been varediting or configuring with the UI) and store the result
	load_droppod(toLaunch)
	toLaunch.launch(T)

/datum/pointshop_product/supply_drop/proc/load_droppod(var/obj/structure/droppod/container/C)
	return
