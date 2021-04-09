/datum/game_mode/colonialmarines/ai
	name = "Distress Signal: Lowpop"
	config_tag = "Distress Signal: Lowpop"
	required_players = 1 //Need at least one player, but really we need 2.

	flags_round_type = MODE_DISABLE_ACID_BLOOD|MODE_INFESTATION|MODE_NEW_SPAWN

	var/list/squad_limit = list(
		SQUAD_NAME_1,
		SQUAD_NAME_2
	)

	var/outpost_name = "USCM Outpost Alpha"

	var/spawn_flags = XENO_SPAWN_T1

	var/list/objectives = list()

	var/endgame_launch_time = 5 MINUTES
	var/endgame_spawn_amount = 4
	var/endgame_shuttle = "alamo"

/datum/game_mode/colonialmarines/ai/pre_setup()
	RegisterSignal(SSdcs, COMSIG_GLOB_XENO_SPAWN, .proc/handle_xeno_spawn)
	for(var/i in RoleAuthority.squads.Copy())
		var/datum/squad/S = i
		if(!(S.name in squad_limit))
			RoleAuthority.squads -= i

	var/datum/techtree/marine/M = GET_TREE(TREE_MARINE)
	M.zlevel_check = FALSE

	for(var/i in GLOB.objective_landmarks)
		var/turf/T = get_turf(i)
		var/obj/structure/resource_node/RN = new(T)

		RN.make_active()
		RegisterSignal(RN, list(
			COMSIG_RESOURCE_NODE_SET_TREE,
			COMSIG_PARENT_QDELETING
		), .proc/finish_objective)
		objectives += RN

	. = ..()

/datum/game_mode/colonialmarines/ai/map_announcement()
	if(SSmapping.configs[GROUND_MAP].announce_text)
		var/announce_text = SSmapping.configs[GROUND_MAP].announce_text
		announce_text = replacetext(announce_text, "####OUTPOSTNAME####", outpost_name)
		marine_announcement(SSmapping.configs[GROUND_MAP].announce_text, outpost_name)

/datum/game_mode/colonialmarines/ai/announce_bioscans()
	return

/datum/game_mode/colonialmarines/ai/proc/finish_objective(var/obj/structure/resource_node/RN)
	objectives -= RN

	for(var/i in GLOB.xeno_ai_spawns)
		var/obj/effect/landmark/xeno_ai/XA = i
		XA.remaining_spawns = initial(XA.remaining_spawns)

	if(!length(objectives))
		enter_endgame()

/datum/game_mode/colonialmarines/ai/proc/enter_endgame()
	marine_announcement("Dropship landing shortly arriving to LZ2. You have [] to board before it launches. You may launch earlier. The xeno horde has been unleashed.", "Marine Broadcast", 'sound/misc/queen_alarm.ogg')
	for(var/i in GLOB.xeno_ai_spawns)
		var/obj/effect/landmark/xeno_ai/XA = i
		XA.remaining_spawns = INFINITY

	CONFIG_SET(number/ai_director/max_xeno_per_player, endgame_spawn_amount)
	var/obj/docking_port/mobile/marine_dropship/ship = SSshuttle.getShuttle(endgame_shuttle)
	addtimer(CALLBACK(src, .proc/launch_and_end, ship), endgame_launch_time)

/datum/game_mode/colonialmarines/ai/proc/launch_and_end(var/obj/docking_port/mobile/marine_dropship/ship)
	if(QDELETED(ship))
		return

	ship.jumpToNullSpace()
	round_finished = MODE_PVE_WIN

/datum/game_mode/colonialmarines/ai/end_round_message()
	switch(round_finished)
		if(MODE_PVE_WIN)
			return "Marine Win"
		if(MODE_PVE_LOSE)
			return "Marine Loss"
	return ..()

GLOBAL_LIST_INIT(t1_ais, list(
	/mob/living/carbon/Xenomorph/Drone,
	/mob/living/carbon/Xenomorph/Runner,
	/mob/living/carbon/Xenomorph/Defender,
	/mob/living/carbon/Xenomorph/Sentinel
))

GLOBAL_LIST_INIT(t2_ais, list(
	/mob/living/carbon/Xenomorph/Warrior,
	/mob/living/carbon/Xenomorph/Spitter,
	/mob/living/carbon/Xenomorph/Lurker
))

GLOBAL_LIST_INIT(t3_ais, list(
	/mob/living/carbon/Xenomorph/Ravager,
	/mob/living/carbon/Xenomorph/Crusher
))

/datum/game_mode/colonialmarines/ai/process(delta_time)
	. = ..()
	var/t2_amount = 0
	var/t3_amount = 0
	var/total_amount = length(GLOB.living_xeno_list)

	for(var/i in GLOB.living_xeno_list)
		var/mob/living/carbon/Xenomorph/X = i
		switch(X.tier)
			if(2)
				t2_amount++
			if(3)
				t3_amount++

	var/list/xenos_to_spawn = list()

	while(total_amount < length(GLOB.alive_client_human_list)*CONFIG_GET(number/ai_director/max_xeno_per_player))
		var/current_amount = total_amount
		total_amount++
		if(!current_amount || (t3_amount/current_amount) < IDEAL_T3_PERCENT)
			xenos_to_spawn += pick(GLOB.t3_ais)
			t3_amount++
			continue

		if((t2_amount/current_amount) < IDEAL_T2_PERCENT)
			xenos_to_spawn += pick(GLOB.t2_ais)
			t2_amount++
			continue

		xenos_to_spawn += pick(GLOB.t1_ais)

	for(var/i in GLOB.xeno_ai_spawns)
		var/obj/effect/landmark/xeno_ai/XA = i
		var/within_range = 0
		if(XA.remaining_spawns <= 0 || length(XA.spawned_xenos) > XA.remaining_spawns)
			continue

		for(var/h in GLOB.alive_client_human_list)
			var/distance = get_dist(h, XA)
			if(distance < MIN_RANGE_TO_SPAWN_XENO)
				within_range = 0
				break

			if(distance > MAX_RANGE_TO_SPAWN_XENO)
				continue

			within_range++

		if(!within_range)
			continue

		for(var/iteration in 1 to round(within_range/length(GLOB.alive_client_human_list), 1)*length(xenos_to_spawn))
			if(length(XA.spawned_xenos) > XA.remaining_spawns)
				break

			var/type_to_spawn = pick(xenos_to_spawn)
			xenos_to_spawn -= type_to_spawn
			var/datum/D = new type_to_spawn(pick(XA.spawnable_turfs))
			XA.RegisterSignal(D, COMSIG_MOB_DEATH, /obj/effect/landmark/xeno_ai.proc/reduce_remaining_spawns)
			XA.RegisterSignal(D, COMSIG_PARENT_QDELETING, /obj/effect/landmark/xeno_ai.proc/handle_xeno_delete)
			XA.spawned_xenos += D


/datum/game_mode/colonialmarines/ai/proc/handle_xeno_spawn(var/datum/source, var/mob/living/carbon/Xenomorph/X)
	SIGNAL_HANDLER
	X.make_ai()

// Temporary fix for now, proper win conditions can be set later.
/datum/game_mode/colonialmarines/ai/check_win()
	return FALSE

GLOBAL_LIST_EMPTY_TYPED(objective_landmarks, /obj/effect/landmark/objective_landmark)

/obj/effect/landmark/objective_landmark
	name = "Objective Landmark"

/obj/effect/landmark/objective_landmark/Initialize(mapload, ...)
	. = ..()
	GLOB.objective_landmarks += src

/obj/effect/landmark/objective_landmark/Destroy()
	GLOB.objective_landmarks -= src
	return ..()
