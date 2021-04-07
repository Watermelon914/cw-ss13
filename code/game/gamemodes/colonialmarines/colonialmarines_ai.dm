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

	for(var/i in GLOB.spawns_by_job)
		for(var/l in GLOB.spawns_by_job[i])
			var/atom/A = l
			if(!is_ground_level(A.z))
				qdel(A)

	for(var/i in GLOB.latejoin)
		var/atom/A = i
		if(!is_ground_level(A.z))
			qdel(A)

	var/datum/techtree/marine/M = GET_TREE(TREE_MARINE)
	M.zlevel_check = FALSE

	. = ..()

/datum/game_mode/colonialmarines/ai/proc/handle_xeno_spawn(var/datum/source, var/mob/living/carbon/Xenomorph/X)
	SIGNAL_HANDLER
	X.make_ai()

// Temporary fix for now, proper win conditions can be set later.
/datum/game_mode/colonialmarines/ai/check_win()
	return FALSE
