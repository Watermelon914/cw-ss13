
/obj/machinery/part_fabricator
	name = "part fabricator"
	desc = "A large automated 3D printer for producing runtime errors."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	var/busy = FALSE
	var/generate_points = TRUE
	var/valid_parts = null
	var/valid_ammo = null

/obj/machinery/part_fabricator/New()
	..()
	start_processing()

/obj/machinery/part_fabricator/proc/get_point_store()
    return 0
    
/obj/machinery/part_fabricator/proc/add_to_point_store(var/number = 1)
    return
    
/obj/machinery/part_fabricator/proc/spend_point_store(var/number = 1)
    return

/obj/machinery/part_fabricator/power_change()
	..()
	if (stat & NOPOWER)
		icon_state = "drone_fab_nopower"

/obj/machinery/part_fabricator/process()
	if(ticker.current_state < GAME_STATE_PLAYING)
		return
	if(stat & NOPOWER)
		icon_state = "drone_fab_nopower"
		return
	if(busy)
		icon_state = "drone_fab_active"
		return
	else
		icon_state = "drone_fab_idle"
	if(generate_points)
		add_to_point_store()

/obj/machinery/part_fabricator/proc/build_part(part_type, cost, mob/user)
	set waitfor = 0
	if(stat & NOPOWER) return
	if(get_point_store() < text2num(cost))
		to_chat(user, SPAN_WARNING("You don't have enough points to build that."))
		return
	visible_message(SPAN_NOTICE("[src] starts printing something."))
	spend_point_store(text2num(cost))
	icon_state = "drone_fab_active"
	busy = TRUE
	sleep(100)
	busy = FALSE
	var/turf/T = locate(x+1,y-1,z)
	playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
	new part_type(T)
	icon_state = "drone_fab_idle"

/obj/machinery/part_fabricator/Topic(href, href_list)
	if(..())
		return

	usr.set_interaction(src)
	add_fingerprint(usr)

	if(busy)
		to_chat(usr, SPAN_WARNING("The autolathe is busy. Please wait for completion of previous operation."))
		return

	if(href_list["produce"]&&href_list["cost"])
		var/produce = text2path(href_list["produce"])
		var/cost = href_list["cost"]
		var/exploiting = TRUE
		
		if (valid_parts || valid_ammo) 
			if (valid_parts && ispath(produce, valid_parts))
				exploiting = FALSE
				
			else if (valid_ammo && ispath(produce, valid_ammo))
				exploiting = FALSE

		if (text2num(cost) < 0)
			exploiting = TRUE

		if (exploiting)
			log_admin("Bad topic: [usr] may be trying to HREF exploit [src] with [produce], [cost]")
			return

		build_part(produce, cost, usr)
		return
	else 
		log_admin("Bad topic: [usr] may be trying to HREF exploit [src]")
		return

/obj/machinery/part_fabricator/attack_hand(mob/user)
	if(!allowed(user))
		to_chat(user, SPAN_WARNING("Access denied."))
		return 1
	return . = ..()

/obj/machinery/part_fabricator/dropship
	name = "dropship part fabricator"
	desc = "A large automated 3D printer for producing dropship parts."
	req_access = list(ACCESS_MARINE_DROPSHIP)
	valid_parts = /obj/structure/dropship_equipment
	valid_ammo = /obj/structure/ship_ammo

/obj/machinery/part_fabricator/dropship/get_point_store()
    return supply_controller.dropship_points
    
/obj/machinery/part_fabricator/dropship/add_to_point_store(var/number = 1)
    supply_controller.dropship_points += number

/obj/machinery/part_fabricator/dropship/spend_point_store(var/number = 1)
    supply_controller.dropship_points -= number

/obj/machinery/part_fabricator/dropship/attack_hand(mob/user)
	if(..())
		return
	user.set_interaction(src)
	var/dat = "<center><h2>Dropship Part Fabricator</h2></center><hr/>"
	dat += "<h4>Points Available: [get_point_store()]</h4>"
	dat += "<h3>Dropship Equipment:</h3>"
	for(var/build_type in typesof(/obj/structure/dropship_equipment))
		var/obj/structure/dropship_equipment/DE = build_type
		var/build_name = initial(DE.name)
		var/build_cost = initial(DE.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Dropship Ammo:</h3>"
	for(var/build_type in typesof(/obj/structure/ship_ammo))
		var/obj/structure/ship_ammo/SA = build_type
		var/build_name = initial(SA.name)
		var/build_cost = initial(SA.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"


	user << browse(dat, "window=dropship_part_fab")
	onclose(user, "dropship_part_fab")
	return

/obj/machinery/part_fabricator/tank
	name = "tank part fabricator"
	desc = "A large automated 3D printer for producing tank parts."
	req_access = list(ACCESS_MARINE_TANK)
	generate_points = FALSE
	valid_parts = /obj/item/hardpoint
	valid_ammo = /obj/item/ammo_magazine/tank

/obj/machinery/part_fabricator/tank/get_point_store()
    return supply_controller.tank_points
    
/obj/machinery/part_fabricator/tank/add_to_point_store(var/number = 1)
    supply_controller.tank_points += number

/obj/machinery/part_fabricator/tank/spend_point_store(var/number = 1)
    supply_controller.tank_points -= number

/obj/machinery/part_fabricator/tank/attack_hand(mob/user)
	if(..())
		return
	user.set_interaction(src)
	var/dat = "<center><h2>Tank Part Fabricator</h2></center><hr/>"
	dat += "<h4>Points Available: [get_point_store()]</h4>"
	dat += "<h3>Tank Equipment:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint))
		var/obj/item/hardpoint/TE = build_type
		var/build_name = initial(TE.name)
		var/build_cost = initial(TE.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Tank Ammo:</h3>"
	for(var/build_type in typesof(/obj/item/ammo_magazine/tank))
		var/obj/item/ammo_magazine/tank/TA = build_type
		var/build_name = initial(TA.name)
		var/build_cost = initial(TA.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"
	user << browse(dat, "window=tank_part_fab")
	onclose(user, "tank_part_fab")
	return