/datum/game_mode/colonialmarines/ai
	name = "Distress Signal: Lowpop"
	config_tag = "Distress Signal: Lowpop"
	required_players = 1 //Need at least one player, but really we need 2.

	var/list/squad_limit = list(
		SQUAD_NAME_1,
		SQUAD_NAME_2
	)

/datum/game_mode/colonialmarines/ai/pre_setup()
	RegisterSignal(SSdcs, COMSIG_GLOB_XENO_SPAWN, .proc/handle_xeno_spawn)
	for(var/i in RoleAuthority.squads.Copy())
		var/datum/squad/S = i
		if(!(S.name in squad_limit))
			RoleAuthority.squads -= i

	var/datum/techtree/marine/M = GET_TREE(TREE_MARINE)
	M.zlevel_check = FALSE

	. = ..()

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

	while(total_amount < length(GLOB.alive_client_human_list)*MAX_XENOMORPHS_PER_PLAYER)
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
			var/type_to_spawn = pick(xenos_to_spawn)
			xenos_to_spawn -= type_to_spawn
			new type_to_spawn(pick(XA.spawnable_turfs))


/datum/game_mode/colonialmarines/ai/proc/handle_xeno_spawn(var/datum/source, var/mob/living/carbon/Xenomorph/X)
	SIGNAL_HANDLER
	X.make_ai()

// Temporary fix for now, proper win conditions can be set later.
/datum/game_mode/colonialmarines/ai/check_win()
	return FALSE
