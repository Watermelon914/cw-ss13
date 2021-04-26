// marine dropships
/obj/docking_port/stationary/marine_dropship
	name = "dropship landing zone"
	id = "dropship"
	dir = SOUTH
	dwidth = 5
	dheight = 10
	width = 11
	height = 21

/obj/docking_port/stationary/marine_dropship/lz1
	name = "Landing Zone One"
	id = "lz1"

/obj/docking_port/stationary/marine_dropship/lz1/prison
	name = "Main Hangar"

/obj/docking_port/stationary/marine_dropship/lz2
	name = "Landing Zone Two"
	id = "lz2"

/obj/docking_port/stationary/marine_dropship/lz2/prison
	name = "Civ Residence Hangar"

/obj/docking_port/stationary/marine_dropship/hangar/one
	name = "Theseus Hangar Pad One"
	id = "alamo"
	roundstart_template = /datum/map_template/shuttle/dropship_one

/obj/docking_port/stationary/marine_dropship/hangar/two
	name = "Theseus Hangar Pad Two"
	id = "normandy"
	roundstart_template = /datum/map_template/shuttle/dropship_two

/obj/docking_port/stationary/marine_dropship/hive
	name = "Hive"
	id = "hive"

/obj/docking_port/mobile/marine_dropship
	name = "marine dropship"
	dir = SOUTH
	dwidth = 5
	dheight = 10
	width = 11
	height = 21

	ignitionTime = 10 SECONDS
	callTime = 38 SECONDS // same as old transit time with flight optimisation
	rechargeTime = 2 MINUTES
	prearrivalTime = 12 SECONDS

	var/list/left_airlocks = list()
	var/list/right_airlocks = list()
	var/list/rear_airlocks = list()

	var/obj/docking_port/stationary/hijack_request

	var/list/equipments = list()

	var/hijack_state = HIJACK_STATE_NORMAL
	var/enabled = TRUE

/obj/docking_port/mobile/marine_dropship/register()
	. = ..()
	SSshuttle.dropships += src

/obj/docking_port/mobile/marine_dropship/enterTransit()
	. = ..()
	if(!.) // it failed in parent
		return
	// pull the shuttle from datum/source, and state info from the shuttle itself
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_DROPSHIP_TRANSIT)

/obj/docking_port/mobile/marine_dropship/proc/lockdown_all()
	lockdown_airlocks("rear")
	lockdown_airlocks("left")
	lockdown_airlocks("right")

/obj/docking_port/mobile/marine_dropship/proc/lockdown_airlocks(side)
	if(hijack_state != HIJACK_STATE_NORMAL)
		return
	switch(side)
		if("left")
			for(var/i in left_airlocks)
				var/obj/structure/machinery/door/airlock/dropship_hatch/D = i
				D.lockdown()
		if("right")
			for(var/i in right_airlocks)
				var/obj/structure/machinery/door/airlock/dropship_hatch/D = i
				D.lockdown()
		if("rear")
			for(var/i in rear_airlocks)
				var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/D = i
				D.lockdown()

/obj/docking_port/mobile/marine_dropship/proc/unlock_all()
	unlock_airlocks("rear")
	unlock_airlocks("left")
	unlock_airlocks("right")

/obj/docking_port/mobile/marine_dropship/proc/unlock_airlocks(side)
	switch(side)
		if("left")
			for(var/i in left_airlocks)
				var/obj/structure/machinery/door/airlock/dropship_hatch/D = i
				D.release()
		if("right")
			for(var/i in right_airlocks)
				var/obj/structure/machinery/door/airlock/dropship_hatch/D = i
				D.release()
		if("rear")
			for(var/i in rear_airlocks)
				var/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/D = i
				D.release()

/obj/docking_port/mobile/marine_dropship/Destroy(force)
	. = ..()
	if(force)
		SSshuttle.dropships -= src

/obj/docking_port/mobile/marine_dropship/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force=FALSE)
	if(crashing)
		force = TRUE

	return ..()

/obj/docking_port/mobile/marine_dropship/one
	id = "alamo"

/obj/docking_port/mobile/marine_dropship/two
	id = "normandy"

// queen calldown

/obj/docking_port/mobile/marine_dropship/afterShuttleMove(turf/oldT, rotation)
	. = ..()
	if(hijack_state != HIJACK_STATE_CALLED_DOWN)
		return
	unlock_all()

/obj/docking_port/mobile/marine_dropship/proc/reset_hijack()
	if(hijack_state == HIJACK_STATE_CALLED_DOWN || hijack_state == HIJACK_STATE_UNLOCKED)
		set_hijack_state(HIJACK_STATE_NORMAL)

/obj/docking_port/mobile/marine_dropship/proc/summon_dropship_to(obj/docking_port/stationary/S)
	if(hijack_state != HIJACK_STATE_NORMAL)
		return
	unlock_all()
	do_start_hijack_timer()
	switch(mode)
		if(SHUTTLE_IDLE)
			set_hijack_state(HIJACK_STATE_CALLED_DOWN)
			request_to(S)
		if(SHUTTLE_RECHARGING)
			set_hijack_state(HIJACK_STATE_CALLED_DOWN)
			playsound(loc,'sound/effects/alert.ogg', 50)
			addtimer(CALLBACK(src, .proc/request_to, S), 15 SECONDS)


/obj/docking_port/mobile/marine_dropship/proc/do_start_hijack_timer(hijack_time = LOCKDOWN_TIME)
	addtimer(CALLBACK(src, .proc/reset_hijack), hijack_time)


/obj/docking_port/mobile/marine_dropship/proc/request_to(obj/docking_port/stationary/S)
	set_idle()
	request(S)

/obj/docking_port/mobile/marine_dropship/proc/set_hijack_state(new_state)
	hijack_state = new_state

/obj/docking_port/mobile/marine_dropship/on_prearrival()
	. = ..()
	if(hijack_state == HIJACK_STATE_CRASHING)
		marine_announcement("DROPSHIP ON COLLISION COURSE. CRASH IMMINENT." , "EMERGENCY", 'sound/AI/dropship_emergency.ogg')


/obj/docking_port/mobile/marine_dropship/getStatusText()
	if(hijack_state == HIJACK_STATE_CALLED_DOWN)
		return "Control integrity compromised"
	else if(hijack_state == HIJACK_STATE_UNLOCKED)
		return "Remote control compromised"
	return ..()


/obj/docking_port/mobile/marine_dropship/can_move_topic(mob/user)
	if(hijack_state != HIJACK_STATE_NORMAL)
		to_chat(user, "<span class='warning'>Control integrity compromised!</span>")
		return FALSE
	return ..()

// summon dropship to closest lz to A
/datum/game_mode/proc/summon_dropship(atom/A)
	var/list/lzs = list()
	for(var/i in SSshuttle.stationary)
		var/obj/docking_port/stationary/S = i
		if(S.z != A.z)
			continue
		if(S.id == "lz1" || S.id == "lz2")
			lzs[S] = get_dist(S, A)
	if(!length(lzs))
		stack_trace("couldn't find any lzs to call down the dropship to")
		return FALSE
	var/obj/docking_port/stationary/closest = lzs[1]
	for(var/j in lzs)
		if(lzs[j] < lzs[closest])
			closest = j
	var/obj/docking_port/mobile/marine_dropship/D
	for(var/k in SSshuttle.dropships)
		var/obj/docking_port/mobile/M = k
		if(M.id == "alamo")
			D = M
	D.summon_dropship_to(closest)
	return closest

// ************************************************	//
//													//
// 			dropship specific objs and turfs		//
//													//
// ************************************************	//

// control computer
/obj/structure/machinery/computer/shuttle/marine_dropship
	icon_state = "console"
	icon = 'icons/obj/structures/machinery/shuttle-parts.dmi'
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER) // TLs can only operate the remote console
	possible_destinations = "lz1;lz2;alamo;normandy"

/obj/structure/machinery/computer/shuttle/marine_dropship/Initialize()
	. = ..()
	GLOB.shuttle_controls_list += src

/obj/structure/machinery/computer/shuttle/marine_dropship/Destroy()
	GLOB.shuttle_controls_list -= src
	return ..()


/obj/structure/machinery/computer/shuttle/marine_dropship/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "MarineDropship", name)
		ui.open()

/obj/structure/machinery/computer/shuttle/marine_dropship/ui_data(mob/user)
	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttleId)
	if(!shuttle)
		WARNING("[src] could not find shuttle [shuttleId] from SSshuttle")
		return

	. = list()
	.["on_flyby"] = shuttle.mode == SHUTTLE_CALL
	.["dest_select"] = !(shuttle.mode == SHUTTLE_CALL || shuttle.mode == SHUTTLE_IDLE)
	.["hijack_state"] = shuttle.hijack_state != HIJACK_STATE_CALLED_DOWN
	.["ship_status"] = shuttle.getStatusText()

	var/locked = 0
	var/reardoor = 0
	for(var/i in shuttle.rear_airlocks)
		var/obj/structure/machinery/door/airlock/A = i
		if(A.locked && A.density)
			reardoor++
	if(!reardoor)
		.["rear"] = 0
	else if(reardoor==length(shuttle.rear_airlocks))
		.["rear"] = 2
		locked++
	else
		.["rear"] = 1

	var/leftdoor = 0
	for(var/i in shuttle.left_airlocks)
		var/obj/structure/machinery/door/airlock/A = i
		if(A.locked && A.density)
			leftdoor++
	if(!leftdoor)
		.["left"] = 0
	else if(leftdoor==length(shuttle.left_airlocks))
		.["left"] = 2
		locked++
	else
		.["left"] = 1

	var/rightdoor = 0
	for(var/i in shuttle.right_airlocks)
		var/obj/structure/machinery/door/airlock/A = i
		if(A.locked && A.density)
			rightdoor++
	if(!rightdoor)
		.["right"] = 0
	else if(rightdoor==length(shuttle.right_airlocks))
		.["right"] = 2
		locked++
	else
		.["right"] = 1

	if(locked == 3)
		.["lockdown"] = 2
	else if(!locked)
		.["lockdown"] = 0
	else
		.["lockdown"] = 1

	var/list/options = valid_destinations()
	var/list/valid_destinations = list()
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(!options.Find(S.id))
			continue
		if(!shuttle.check_dock(S, silent=TRUE))
			continue
		valid_destinations += list(list("name" = S.name, "id" = S.id))
	.["destinations"] = valid_destinations

/obj/structure/machinery/computer/shuttle/marine_dropship/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/obj/docking_port/mobile/marine_dropship/M = SSshuttle.getShuttle(shuttleId)
	if(!M)
		return
	if(M.hijack_state == HIJACK_STATE_CALLED_DOWN)
		return
	if(!M.enabled)
		return

	switch(action)
		if("move")
			Topic(null, list("move" = params["move"]))
			return
		if("lockdown")
			M.lockdown_all()
			. = TRUE
		if("release")
			M.unlock_all()
			. = TRUE
		if("lock")
			M.lockdown_airlocks(params["lock"])
			. = TRUE
		if("unlock")
			M.unlock_airlocks(params["unlock"])
			. = TRUE

/obj/structure/machinery/computer/shuttle/marine_dropship/Topic(href, href_list)
	var/obj/docking_port/mobile/marine_dropship/M = SSshuttle.getShuttle(shuttleId)
	if(!M)
		return
	. = ..()
	if(.)
		return
	if(M.hijack_state == HIJACK_STATE_CRASHING)
		return

	if(ishuman(usr) || isAI(usr))
		if(!allowed(usr))
			return
		if(href_list["lockdown"])

		else if(href_list["release"])

		else if(href_list["lock"])
			M.lockdown_airlocks(href_list["lock"])
		else if(href_list["unlock"])
			M.unlock_airlocks(href_list["unlock"])
		return

/obj/structure/machinery/computer/shuttle/marine_dropship/one
	name = "\improper 'Alamo' flight controls"
	desc = "The flight controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texians to rally to the flag."

/obj/structure/machinery/computer/shuttle/marine_dropship/two
	name = "\improper 'Normandy' flight controls"
	desc = "The flight controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."


/obj/structure/machinery/door/poddoor/shutters/transit/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	if(SSmapping.level_has_any_trait(z, list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND)))
		open()
	else
		close()

/turf/open/shuttle/dropship/floor
	icon_state = "rasputin15"

/obj/structure/machinery/door/airlock/multi_tile/almayer/dropshiprear/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	. = ..()
	if(!istype(port, /obj/docking_port/mobile/marine_dropship))
		return
	var/obj/docking_port/mobile/marine_dropship/D = port
	D.rear_airlocks += src

/obj/structure/machinery/door/airlock/dropship_hatch/left/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	. = ..()
	if(!istype(port, /obj/docking_port/mobile/marine_dropship))
		return
	var/obj/docking_port/mobile/marine_dropship/D = port
	D.left_airlocks += src

/obj/structure/machinery/door/airlock/dropship_hatch/right/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	. = ..()
	if(!istype(port, /obj/docking_port/mobile/marine_dropship))
		return
	var/obj/docking_port/mobile/marine_dropship/D = port
	D.right_airlocks += src

/obj/structure/machinery/door_control/dropship
	var/obj/docking_port/mobile/marine_dropship/D
	req_one_access = list(ACCESS_MARINE_BRIG, ACCESS_MARINE_DROPSHIP)
	pixel_y = -19
	name = "Dropship Lockdown"

/obj/structure/machinery/door_control/dropship/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	. = ..()
	D = port

/obj/structure/machinery/door_control/dropship/attack_hand(mob/living/user)
	. = ..()
	if(isXeno(user))
		return

	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied</span>")
		flick("doorctrl-denied",src)
		return

	D.lockdown_all()

// half-tile structure pieces
/obj/structure/dropship_piece
	icon = 'icons/obj/structures/dropship_structures.dmi'
	density = TRUE
	opacity = TRUE

/obj/structure/dropship_piece/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	if(. & MOVE_AREA)
		ENABLE_BITFIELD(., MOVE_CONTENTS)
		DISABLE_BITFIELD(., MOVE_TURF)

/obj/structure/dropship_piece/ex_act(severity)
	return

/obj/structure/dropship_piece/one
	name = "\improper Alamo"

/obj/structure/dropship_piece/one/front
	icon_state = "brown_front"
	opacity = FALSE

/obj/structure/dropship_piece/one/front/right
	icon_state = "brown_fr"

/obj/structure/dropship_piece/one/front/left
	icon_state = "brown_fl"


/obj/structure/dropship_piece/one/cockpit/left
	icon_state = "brown_cockpit_fl"

/obj/structure/dropship_piece/one/cockpit/right
	icon_state = "brown_cockpit_fr"


/obj/structure/dropship_piece/one/weapon
	opacity = FALSE

/obj/structure/dropship_piece/one/weapon/leftleft
	icon_state = "brown_weapon_ll"

/obj/structure/dropship_piece/one/weapon/leftright
	icon_state = "brown_weapon_lr"

/obj/structure/dropship_piece/one/weapon/rightleft
	icon_state = "brown_weapon_rl"

/obj/structure/dropship_piece/one/weapon/rightright
	icon_state = "brown_weapon_rr"


/obj/structure/dropship_piece/one/wing
	opacity = FALSE

/obj/structure/dropship_piece/one/wing/left/top
	icon_state = "brown_wing_lt"

/obj/structure/dropship_piece/one/wing/left/bottom
	icon_state = "brown_wing_lb"

/obj/structure/dropship_piece/one/wing/right/top
	icon_state = "brown_wing_rt"

/obj/structure/dropship_piece/one/wing/right/bottom
	icon_state = "brown_wing_rb"


/obj/structure/dropship_piece/one/corner/middleleft
	icon_state = "brown_middle_lc"

/obj/structure/dropship_piece/one/corner/middleright
	icon_state = "brown_middle_rc"

/obj/structure/dropship_piece/one/corner/rearleft
	icon_state = "brown_rear_lc"

/obj/structure/dropship_piece/one/corner/rearright
	icon_state = "brown_rear_rc"


/obj/structure/dropship_piece/one/engine
	opacity = FALSE

/obj/structure/dropship_piece/one/engine/lefttop
	icon_state = "brown_engine_lt"

/obj/structure/dropship_piece/one/engine/righttop
	icon_state = "brown_engine_rt"

/obj/structure/dropship_piece/one/engine/leftbottom
	icon_state = "brown_engine_lb"

/obj/structure/dropship_piece/one/engine/rightbottom
	icon_state = "brown_engine_rb"


/obj/structure/dropship_piece/one/rearwing/lefttop
	icon_state = "brown_rearwing_lt"

/obj/structure/dropship_piece/one/rearwing/righttop
	icon_state = "brown_rearwing_rt"

/obj/structure/dropship_piece/one/rearwing/leftbottom
	icon_state = "brown_rearwing_lb"

/obj/structure/dropship_piece/one/rearwing/rightbottom
	icon_state = "brown_rearwing_rb"

/obj/structure/dropship_piece/one/rearwing/leftlbottom
	icon_state = "brown_rearwing_llb"
	opacity = FALSE

/obj/structure/dropship_piece/one/rearwing/rightrbottom
	icon_state = "brown_rearwing_rrb"
	opacity = FALSE

/obj/structure/dropship_piece/one/rearwing/leftllbottom
	icon_state = "brown_rearwing_lllb"
	opacity = FALSE

/obj/structure/dropship_piece/one/rearwing/rightrrbottom
	icon_state = "brown_rearwing_rrrb"
	opacity = FALSE



/obj/structure/dropship_piece/two
	name = "\improper Normandy"

/obj/structure/dropship_piece/two/front
	icon_state = "blue_front"
	opacity = FALSE

/obj/structure/dropship_piece/two/front/right
	icon_state = "blue_fr"

/obj/structure/dropship_piece/two/front/left
	icon_state = "blue_fl"


/obj/structure/dropship_piece/two/cockpit/left
	icon_state = "blue_cockpit_fl"

/obj/structure/dropship_piece/two/cockpit/right
	icon_state = "blue_cockpit_fr"


/obj/structure/dropship_piece/two/weapon
	opacity = FALSE

/obj/structure/dropship_piece/two/weapon/leftleft
	icon_state = "blue_weapon_ll"

/obj/structure/dropship_piece/two/weapon/leftright
	icon_state = "blue_weapon_lr"

/obj/structure/dropship_piece/two/weapon/rightleft
	icon_state = "blue_weapon_rl"

/obj/structure/dropship_piece/two/weapon/rightright
	icon_state = "blue_weapon_rr"


/obj/structure/dropship_piece/two/wing
	opacity = FALSE

/obj/structure/dropship_piece/two/wing/left/top
	icon_state = "blue_wing_lt"

/obj/structure/dropship_piece/two/wing/left/bottom
	icon_state = "blue_wing_lb"

/obj/structure/dropship_piece/two/wing/right/top
	icon_state = "blue_wing_rt"

/obj/structure/dropship_piece/two/wing/right/bottom
	icon_state = "blue_wing_rb"


/obj/structure/dropship_piece/two/corner/middleleft
	icon_state = "blue_middle_lc"

/obj/structure/dropship_piece/two/corner/middleright
	icon_state = "blue_middle_rc"

/obj/structure/dropship_piece/two/corner/rearleft
	icon_state = "blue_rear_lc"

/obj/structure/dropship_piece/two/corner/rearright
	icon_state = "blue_rear_rc"


/obj/structure/dropship_piece/two/engine
	opacity = FALSE

/obj/structure/dropship_piece/two/engine/lefttop
	icon_state = "blue_engine_lt"

/obj/structure/dropship_piece/two/engine/righttop
	icon_state = "blue_engine_rt"

/obj/structure/dropship_piece/two/engine/leftbottom
	icon_state = "blue_engine_lb"

/obj/structure/dropship_piece/two/engine/rightbottom
	icon_state = "blue_engine_rb"


/obj/structure/dropship_piece/two/rearwing/lefttop
	icon_state = "blue_rearwing_lt"

/obj/structure/dropship_piece/two/rearwing/righttop
	icon_state = "blue_rearwing_rt"

/obj/structure/dropship_piece/two/rearwing/leftbottom
	icon_state = "blue_rearwing_lb"

/obj/structure/dropship_piece/two/rearwing/rightbottom
	icon_state = "blue_rearwing_rb"

/obj/structure/dropship_piece/two/rearwing/leftlbottom
	icon_state = "blue_rearwing_llb"
	opacity = FALSE

/obj/structure/dropship_piece/two/rearwing/rightrbottom
	icon_state = "blue_rearwing_rrb"
	opacity = FALSE

/obj/structure/dropship_piece/two/rearwing/leftllbottom
	icon_state = "blue_rearwing_lllb"
	opacity = FALSE

/obj/structure/dropship_piece/two/rearwing/rightrrbottom
	icon_state = "blue_rearwing_rrrb"
	opacity = FALSE

//Dropship control console

/obj/structure/machinery/computer/shuttle/shuttle_control
	name = "shuttle control console"
	icon = 'icons/obj/structures/machinery/computer.dmi'
	icon_state = "shuttle"

/obj/structure/machinery/computer/shuttle/shuttle_control/ui_interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied!</span>")
		return
	var/list/options = valid_destinations()
	var/obj/docking_port/mobile/marine_dropship/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if (M?.hijack_state == HIJACK_STATE_NORMAL)
		var/destination_found
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S, silent=TRUE))
				continue
			destination_found = TRUE
			dat += "<A href='?src=[REF(src)];move=[S.id]'>Send to [S.name]</A><br>"
		if(!destination_found)
			dat += "<B>Shuttle Locked</B><br>"

	var/datum/browser/popup = new(user, "computer", M ? M.name : "shuttle", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.open()


/obj/structure/machinery/computer/shuttle/shuttle_control/dropship1
	name = "\improper 'Alamo' dropship console"
	desc = "The remote controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texans to rally to the flag."
	icon = 'icons/obj/structures/machinery/computer.dmi'
	icon_state = "shuttle"
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER) // TLs can only operate the remote console
	shuttleId = "alamo"
	possible_destinations = "lz1;lz2;alamo;normandy"


/obj/structure/machinery/computer/shuttle/shuttle_control/dropship2
	name = "\improper 'Normandy' dropship console"
	desc = "The remote controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decisive victory in World War II and the campaign for the Liberation of France."
	icon = 'icons/obj/structures/machinery/computer.dmi'
	icon_state = "shuttle"
	req_one_access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LEADER)
