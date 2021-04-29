/mob/living/carbon/Xenomorph
	// AI stuff
	var/flags_ai = NO_FLAGS
	var/mob/current_target

	var/next_path_generation = 0
	var/list/current_path
	var/turf/current_target_turf

	var/ai_move_delay = 0
	var/path_update_period = 0.5 SECONDS
	var/no_path_found = FALSE
	var/ai_range = 8
	var/max_travel_distance = 24

	var/ai_timeout_time = 0
	var/ai_timeout_period = 2 SECONDS

	// Home turf
	var/next_home_search = 0
	var/home_search_delay = 5 SECONDS
	var/max_distance_from_home = 15
	var/home_locate_range = 15
	var/turf/home_turf

	var/list/datum/action/xeno_action/registered_ai_abilities = list()

GLOBAL_LIST_INIT(ai_target_limbs, list(
	"head",
	"chest",
	"l_leg",
	"r_leg",
	"l_arm",
	"r_arm"
))

/mob/living/carbon/Xenomorph/proc/handle_ai_shot(obj/item/projectile/P)
	if(!current_target && P.firer)
		var/distance = get_dist(src, P.firer)
		if(distance > max_travel_distance)
			return

		SSxeno_pathfinding.calculate_path(src, P.firer, distance, src, CALLBACK(src, .proc/set_path), list(src, P.firer))

/mob/living/carbon/Xenomorph/proc/register_ai_action(var/datum/action/xeno_action/XA)
	if(XA.owner != src)
		XA.give_to(src)
	registered_ai_abilities |= XA
	XA.ai_registered(src)

/mob/living/carbon/Xenomorph/proc/unregister_ai_action(var/datum/action/xeno_action/XA)
	registered_ai_abilities -= XA
	XA.ai_unregistered(src)

/mob/living/carbon/Xenomorph/proc/process_ai(delta_time, game_evaluation)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(!hive || !get_turf(src))
		return TRUE

	if(is_mob_incapacitated(TRUE))
		current_path = null
		return TRUE

	if(QDELETED(current_target) || current_target.stat == DEAD || get_dist(current_target, src) > ai_range)
		current_target = get_target(ai_range)
		if(QDELETED(src))
			return TRUE

		if(current_target)
			resting = FALSE
			return TRUE

	if(!current_target)
		ai_move_idle(delta_time, game_evaluation)
		return TRUE

	a_intent = INTENT_HARM

	if(ai_move_target(delta_time, game_evaluation))
		return TRUE

	for(var/x in registered_ai_abilities)
		var/datum/action/xeno_action/XA = x
		if(QDELETED(XA) || XA.owner != src)
			unregister_ai_action(XA)
			continue

		if(XA.hidden)
			continue

		if(XA.process_ai(src, delta_time, game_evaluation) == PROCESS_KILL)
			unregister_ai_action(XA)

	if(get_dist(src, current_target) <= 1 && DT_PROB(XENO_SLASH, delta_time))
		INVOKE_ASYNC(src, /mob.proc/do_click, current_target, "", list())

/** Controls movement when idle. Called by process_ai */
/mob/living/carbon/Xenomorph/proc/ai_move_idle(delta_time, game_evaluation)
	if(throwing)
		return

	if(next_home_search < world.time && (!home_turf || !home_turf.weeds || get_dist(home_turf, src) > max_distance_from_home))
		var/turf/T = get_turf(loc)
		next_home_search = world.time + home_search_delay
		if(T.weeds)
			home_turf = T
		else
			var/shortest_distance = INFINITY
			for(var/i in RANGE_TURFS(home_locate_range, T))
				var/turf/potential_home = i
				if(potential_home.weeds && !potential_home.density && get_dist(src, potential_home) < shortest_distance)
					home_turf = potential_home

	if(!home_turf)
		return

	if(move_to_next_turf(home_turf, home_locate_range))
		if(get_dist(home_turf, src) <= 0 && !resting)
			lay_down()
	else
		home_turf = null

/** Controls movement towards target. Called by process_ai */
/mob/living/carbon/Xenomorph/proc/ai_move_target(delta_time, game_evaluation)
	if(throwing)
		return

	var/turf/T = get_turf(current_target)
	if(get_dist(src, current_target) <= 1)
		var/list/turfs = RANGE_TURFS(1, T)
		while(length(turfs))
			T = pick(turfs)
			turfs -= T
			if(!T.density)
				break

			if(T == get_turf(current_target))
				break


	if(!move_to_next_turf(T))
		current_target = null
		return TRUE

/atom/proc/xeno_ai_obstacle(var/mob/living/carbon/Xenomorph/X, direction)
	return INFINITY

// Called whenever an obstacle is encountered but xeno_ai_obstacle returned something else than infinite
// and now it is considered a valid path.
/atom/proc/xeno_ai_act(var/mob/living/carbon/Xenomorph/X)
	return

/mob/living/carbon/Xenomorph/proc/can_move_and_apply_move_delay()
	// Unable to move, try next time.
	if(ai_move_delay > world.time || !canmove || is_mob_incapacitated(TRUE) || !on_movement() || anchored)
		return FALSE

	ai_move_delay = world.time + move_delay
	if(recalculate_move_delay)
		ai_move_delay = world.time + movement_delay()
	if(next_move_slowdown)
		ai_move_delay += next_move_slowdown
		next_move_slowdown = 0
	return TRUE


/mob/living/carbon/Xenomorph/proc/set_path(var/list/path)
	current_path = path
	if(!path)
		no_path_found = TRUE

/mob/living/carbon/Xenomorph/proc/move_to_next_turf(var/turf/T, var/max_range = ai_range)
	if(!T)
		return FALSE

	if(no_path_found)
		no_path_found = FALSE
		return FALSE

	if(!current_path || (next_path_generation < world.time && current_target_turf != T))
		if(!XENO_CALCULATING_PATH(src) || current_target_turf != T)
			SSxeno_pathfinding.calculate_path(src, T, max_range, src, CALLBACK(src, .proc/set_path), list(src, current_target))
			current_target_turf = T
		next_path_generation = world.time + path_update_period

	if(XENO_CALCULATING_PATH(src))
		return TRUE

	// No possible path to target.
	if(!current_path && get_dist(T, src) > 0)
		return FALSE

	// We've reached our destination
	if(!length(current_path) || get_dist(T, src) <= 0)
		current_path = null
		return TRUE

	// We've somehow deviated from our current path. Generate next path whenever possible.
	if(get_dist(current_path[current_path.len], src) > 1)
		current_path = null
		return TRUE

	// Unable to move, try next time.
	if(!can_move_and_apply_move_delay())
		return TRUE


	var/turf/next_turf = current_path[current_path.len]
	var/list/L = LinkBlocked(src, loc, next_turf, list(src, current_target), TRUE)
	for(var/a in L)
		var/atom/A = a
		if(A.xeno_ai_obstacle(src, get_dir(loc, next_turf)) == INFINITY)
			return FALSE
		INVOKE_ASYNC(A, /atom.proc/xeno_ai_act, src)
	var/successful_move = Move(next_turf, get_dir(src, next_turf))
	if(successful_move)
		ai_timeout_time = world.time
		current_path.len--

	if(ai_timeout_time < world.time - ai_timeout_period)
		return FALSE

	return TRUE

/mob/living/carbon/Xenomorph/proc/get_target(var/range)
	var/list/viable_humans = list()
	var/smallest_distance = INFINITY
	for(var/l in GLOB.alive_client_human_list)
		var/mob/living/carbon/human/H = l
		if(z != H.z)
			continue
		var/distance = get_dist(src, H)

		if(distance < ai_range)
			viable_humans += H
		smallest_distance = min(distance, smallest_distance)


	if(smallest_distance > RANGE_TO_DESPAWN_XENO && !(XENO_AI_NO_DESPAWN & flags_ai))
		remove_ai()
		qdel(src)
		return

	if(length(viable_humans))
		return pick(viable_humans)

/mob/living/carbon/Xenomorph/proc/make_ai()
	SHOULD_CALL_PARENT(TRUE)
	create_hud()
	if(!client)
		SSxeno_ai.add_ai(src)

/mob/living/carbon/Xenomorph/proc/remove_ai()
	SHOULD_CALL_PARENT(TRUE)
	SSxeno_ai.remove_ai(src)

GLOBAL_LIST_EMPTY_TYPED(xeno_ai_spawns, /obj/effect/landmark/xeno_ai)
/obj/effect/landmark/xeno_ai
	name = "Xeno AI Spawn"
	var/list/spawned_xenos
	var/remaining_spawns = 5

	var/spawn_radius = 5
	var/list/spawnable_turfs

/obj/effect/landmark/xeno_ai/Initialize(mapload, ...)
	. = ..()
	spawned_xenos = list()

	GLOB.xeno_ai_spawns += src
	spawnable_turfs = list()
	for(var/i in RANGE_TURFS(spawn_radius, src))
		var/turf/T = i
		if(T == get_turf(src))
			spawnable_turfs += T
			continue

		if(T.density)
			continue

		var/failed = FALSE
		for(var/a in T)
			var/atom/A = a
			if(A.density)
				failed = TRUE
				break

		if(failed)
			continue

		for(var/t in getline(T, src))
			var/turf/line = t
			if(line.density)
				failed = TRUE
				break

		if(failed)
			continue

		spawnable_turfs += T

/obj/effect/landmark/xeno_ai/proc/reduce_remaining_spawns(var/mob/living/carbon/Xenomorph/X)
	SIGNAL_HANDLER
	remaining_spawns--

/obj/effect/landmark/xeno_ai/proc/handle_xeno_delete(var/mob/living/carbon/Xenomorph/X)
	SIGNAL_HANDLER
	spawned_xenos -= X

/obj/effect/landmark/xeno_ai/Destroy()
	spawnable_turfs = null
	GLOB.xeno_ai_spawns -= src
	return ..()
