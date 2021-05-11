#define XENO_TIER_WORTH 1

/datum/pointshop
	var/points = 0
	var/atom/attached_object
	var/currency = "points"
	var/theme = "default"

	var/list/products = list()

/datum/pointshop/New(var/atom/A)
	. = ..()
	attached_object = A

/datum/pointshop/Destroy(force, ...)
	SStgui.close_uis(src)
	QDEL_NULL(products)
	return ..()

/datum/pointshop/ui_host(mob/user)
	if(attached_object)
		return attached_object
	return ..()

/datum/pointshop/ui_state(mob/user)
	return GLOB.inventory_state


/datum/pointshop/ui_data(mob/user)
	. = list()
	.["points"] = points

/datum/pointshop/ui_static_data(mob/user)
	. = list()
	.["products"] = list()
	var/index = 1
	for(var/i in products)
		var/datum/pointshop_product/PSP = i
		var/list/L = PSP.ui_data()
		L["index"] = index
		.["products"] += list(L)
		index++
	.["currency"] = currency
	.["theme"] = theme

/datum/pointshop/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/pointshop),
	)


/datum/pointshop/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Pointshop", attached_object.name)
		ui.open()


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
			PSP.purchase_product(usr)
			. = TRUE


/datum/pointshop_product
	var/name = ""
	var/desc = ""
	var/category = "Other"
	var/icon = 'icons/effects/pointshop.dmi'
	var/icon_state = ""
	var/cost = 0
	var/abstract_type = /datum/pointshop_product
	var/datum/pointshop/parent

/datum/pointshop_product/ui_data(mob/user)
	return list(
		"name" = name,
		"desc" = desc,
		"cost" = cost,
		"category" = category,
		"image" = replacetext(name, " ", "-")
	)

/datum/pointshop_product/New(datum/pointshop/P)
	. = ..()
	parent = P

/datum/pointshop_product/Destroy(force, ...)
	parent = null
	return ..()

/datum/pointshop_product/proc/can_purchase_product(var/mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(parent.points < cost)
		return
	return TRUE

/// Sanitizing proc to make sure they can actually purchase the product. Deducts points if they can
/datum/pointshop_product/proc/try_purchase_product(var/mob/user)
	if(!can_purchase_product(user))
		return
	parent.points -= cost
	return TRUE

/datum/pointshop_product/proc/purchase_product(var/mob/user)
	if(!try_purchase_product(user))
		return
	return TRUE

/datum/pointshop_product/supply_drop
	abstract_type = /datum/pointshop_product/supply_drop
	category = "Supply pack"

	var/mob/targetter

/datum/pointshop_product/supply_drop/New(datum/pointshop/P)
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/unregister_current_user)

/datum/pointshop_product/supply_drop/proc/unregister_current_user()
	SIGNAL_HANDLER
	if(targetter)
		unregister_user(targetter)

/datum/pointshop_product/supply_drop/Destroy(force, ...)
	targetter = null
	return ..()


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
	M.reset_view()
	targetter = M

/datum/pointshop_product/supply_drop/proc/unregister_user(var/mob/M)
	UnregisterSignal(M, list(
		COMSIG_MOB_POST_RESET_VIEW,
		COMSIG_MOB_PRE_CLICK,
		COMSIG_PARENT_QDELETING
	))
	M.reset_view()
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
		to_chat(M, SPAN_WARNING("Launched failed! Target location blocked!"))
		return

	for(var/i in T)
		var/atom/A = i
		if(A.density)
			to_chat(M, SPAN_WARNING("Launched failed! Target location blocked!"))
			return

	var/area/A = T.loc
	if(A.flags_area & AREA_INACCESSIBLE)
		to_chat(M< SPAN_WARNING("Launched failed! Invalid target location!"))
		return

	if(!try_purchase_product(M))
		to_chat(M, SPAN_WARNING("Launched failed! Failed to purchase [name]!"))
		return

	launch(T)

	message_staff("[key_name_admin(M)] launched a droppod", target.x, target.y, target.z)
	return COMPONENT_INTERRUPT_CLICK

/datum/pointshop_product/supply_drop/proc/launch(var/turf/T)
	if (isnull(T))
		return
	var/obj/structure/droppod/container/toLaunch = new()
	load_droppod(toLaunch)
	toLaunch.max_hold_items = 0
	toLaunch.should_recall = TRUE
	toLaunch.can_be_opened = FALSE
	toLaunch.launch(T)

/datum/pointshop_product/supply_drop/proc/load_droppod(var/obj/structure/droppod/container/C)
	return

/datum/pointshop_product/marine
	abstract_type = /datum/pointshop_product/marine

/obj/item/device/pointshop
	name = "abstract pointshop"
	indestructible = TRUE
	var/datum/pointshop/attached_shop
	var/list/products = list()
	var/list/subtype_products = list()
	var/theme = "default"
	var/currency = "points"
	w_class = SIZE_TINY

/obj/item/device/pointshop/Initialize()
	. = ..()
	attached_shop = new(src)
	attached_shop.currency = currency
	attached_shop.theme = theme
	populate_products()

/obj/item/device/pointshop/proc/populate_products()
	for(var/i in products)
		attached_shop.products += new i(attached_shop)

	for(var/i in subtype_products)
		for(var/l in subtypesof(i))
			var/datum/pointshop_product/P = l
			if(initial(P.abstract_type) == P)
				continue
			attached_shop.products += new P(attached_shop)

/obj/item/device/pointshop/attack_self(mob/user)
	. = ..()
	if(attached_shop)
		attached_shop.tgui_interact(user)
	else
		to_chat(user, "[SPAN_BOLD(src)] beeps: No connection.")

/obj/item/device/pointshop/Destroy()
	QDEL_NULL(attached_shop)
	return ..()

GLOBAL_DATUM(marine_pointshop, /datum/pointshop)

/obj/item/device/pointshop/marine
	name = "marine supply uplink"
	desc = "An uplink to purchase supplies"
	icon_state = "tracker"
	products = list(
		/datum/pointshop_product/supply_drop/weapon_crate,
		/datum/pointshop_product/supply_drop/ammo_crate,
		/datum/pointshop_product/supply_drop/medical_crate,
		/datum/pointshop_product/supply_drop/reinforcement
	)
	subtype_products = list(
		/datum/pointshop_product/marine
	)

/obj/item/device/pointshop/marine/Initialize()
	. = ..()
	if(GLOB.marine_pointshop)
		attached_shop.points += GLOB.marine_pointshop.points
		var/obj/item/device/pointshop/A = GLOB.marine_pointshop.attached_object
		QDEL_NULL(A.attached_shop)
	GLOB.marine_pointshop = attached_shop

	RegisterSignal(SSdcs, COMSIG_GLOB_XENO_DEATH, .proc/xeno_death)

/obj/item/device/pointshop/marine/proc/xeno_death(var/datum/source, var/mob/living/carbon/Xenomorph/X)
	SIGNAL_HANDLER
	if(attached_shop)
		attached_shop.points += X.tier * XENO_TIER_WORTH

/obj/item/device/pointshop/marine/Destroy()
	if(attached_shop == GLOB.marine_pointshop)
		GLOB.marine_pointshop = null
	return ..()
