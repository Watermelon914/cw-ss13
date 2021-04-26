/mob/living/carbon/Xenomorph
	// AI stuff
	var/mob/current_target

	var/next_path_generation = 0
	var/list/current_path
	var/turf/current_target_turf

	var/ai_move_delay = 0
	var/path_update_per_second = 0.5 SECONDS
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

/mob/living/carbon/Xenomorph/proc/handle_ai_shot(obj/item/projectile/P)
	if(!current_target && P.firer)
		var/distance = get_dist(src, P.firer)
		if(distance > max_travel_distance)
			return

		SSxeno_pathfinding.calculate_path(src, P.firer, distance, src, CALLBACK(src, .proc/set_path), list(src, P.firer))
		//calculate_path(get_turf(P.firer), distance, CALLBACK(src, .proc/set_path))


/mob/living/carbon/Xenomorph/proc/process_ai(delta_time, game_evaluation)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(!hive)
		return TRUE

	if(is_mob_incapacitated(TRUE))
		current_path = null
		return TRUE

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

	if(QDELETED(current_target) || current_target.stat == DEAD || get_dist(current_target, src) > ai_range)
		current_target = get_target(ai_range)
		if(QDELETED(src))
			return TRUE

		if(current_target)
			resting = FALSE
			return TRUE

	if(!current_target)
		if(!current_path)
			return TRUE

		if(move_to_next_turf(home_turf, home_locate_range))
			if(get_dist(home_turf, src) <= 0 && !resting)
				lay_down()
		else
			home_turf = null

		return TRUE

/atom/proc/xeno_ai_obstacle(var/mob/living/carbon/Xenomorph/X, direction)
	return INFINITY

// Called whenever an obstacle is encountered but xeno_ai_obstacle returned something else than infinite
// and now it is considered a valid path.
/atom/proc/xeno_ai_act(var/mob/living/carbon/Xenomorph/X)
	return

/*
/mob/living/carbon/Xenomorph/proc/calculate_path(var/turf/target, range, var/datum/callback/CB)
	// This proc can sleep if a callback is passed. Not recommended in process procs.
	set waitfor = FALSE

	if(!target)
		return

	calculating_path = TRUE

	newest_path_time = world.time
	var/current_path_time = newest_path_time

	// A* Pathfinding. Uses priority queue
	var/turf/current_node = get_turf(src)
	var/list/visited_nodes = list()
	var/list/distances = list()
	var/list/f_distances = list()
	var/list/prev = list()

	distances[current_node] = 0
	f_distances[current_node] = ASTAR_COST_FUNCTION(current_node)

	for(var/i in RANGE_TURFS(range, src))
		if(i != current_node)
			distances[i] = INFINITY
			f_distances[i] = INFINITY
			prev[i] = null

	visited_nodes += current_node

	while(length(visited_nodes))
		current_node = visited_nodes[visited_nodes.len]
		visited_nodes.len--
		if(current_node == target)
			break

		for(var/direction in cardinal)
			var/turf/neighbor = get_step(current_node, direction)
			var/distance_between = distances[current_node] * DISTANCE_PENALTY

			if(direction != get_dir(prev[neighbor], neighbor))
				distance_between += DIRECTION_CHANGE_PENALTY

			if(!neighbor.weeds)
				distance_between += NO_WEED_PENALTY

			for(var/i in neighbor)
				var/atom/A = i
				distance_between += A.object_weight

			var/list/L = LinkBlocked(src, current_node, neighbor, list(current_target, src), TRUE)
			if(length(L))
				for(var/i in L)
					var/atom/A = i
					distance_between += A.xeno_ai_obstacle(src, direction)

			if(distance_between < distances[neighbor])
				distances[neighbor] = distance_between
				var/f_distance = distance_between + ASTAR_COST_FUNCTION(neighbor)
				f_distances[neighbor] = f_distance
				prev[neighbor] = current_node
				if(neighbor in visited_nodes)
					visited_nodes -= neighbor

				for(var/i in 0 to length(visited_nodes))
					var/index_to_check = length(visited_nodes) - i
					if(index_to_check == 0)
						visited_nodes.Insert(1, neighbor)
						break

					if(f_distance < f_distances[visited_nodes[index_to_check]])
						visited_nodes.Insert(index_to_check, neighbor)
						break

		if(newest_path_time != current_path_time)
			return

		CHECK_TICK

	if(!prev[target])
		calculating_path = FALSE
		return

	var/list/path = list()
	current_node = target
	while(current_node)
		if(current_node == loc)
			break
		path += current_node
		current_node = prev[current_node]

	calculating_path = FALSE
	CB.Invoke(path)

/mob/living/carbon/Xenomorph/proc/stop_calculating_path()
	newest_path_time = 0
*/

/mob/living/carbon/Xenomorph/proc/can_move_and_apply_move_delay()
	// Unable to move, try next time.
	if(ai_move_delay > world.time || !canmove || is_mob_incapacitated(TRUE) || !on_movement())
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
		/*
		if(!calculating_path || current_target_turf != T)
			calculate_path(T, max_range, CALLBACK(src, .proc/set_path))
			current_target_turf = T
		*/

		if(!XENO_CALCULATING_PATH(src) || current_target_turf != T)
			SSxeno_pathfinding.calculate_path(src, T, max_range, src, CALLBACK(src, .proc/set_path), list(src, current_target))
			current_target_turf = T
		next_path_generation = world.time + path_update_per_second

	if(XENO_CALCULATING_PATH(src))
		return TRUE

	// No possible path to target.
	if(!current_path && get_dist(T, src) > 0)
		return FALSE

	// We've reached our destination
	if(!length(current_path) || get_dist(T, src) <= 0)
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
	var/mob/living/carbon/human/closest_human
	var/smallest_distance = INFINITY
	for(var/l in GLOB.alive_client_human_list)
		var/mob/living/carbon/human/H = l
		if(z != H.z)
			continue
		var/distance = get_dist(src, H)
		if(distance < smallest_distance)
			smallest_distance = distance
			closest_human = H

	if(smallest_distance > RANGE_TO_DESPAWN_XENO)
		remove_ai()
		qdel(src)
		return

	if(smallest_distance > ai_range)
		return
	return closest_human

/mob/living/carbon/Xenomorph/proc/make_ai()
	if(!client)
		SSxeno_ai.add_ai(src)

/mob/living/carbon/Xenomorph/proc/remove_ai()
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
