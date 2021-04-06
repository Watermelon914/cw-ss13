/mob/living/carbon/Xenomorph
	// AI stuff
	var/mob/current_target

	var/next_path_generation = 0
	var/list/current_path
	var/turf/current_target_turf

	var/ai_move_delay = 0
	var/path_update_per_second = 0.5 SECONDS
	var/ai_range = 8
	var/max_travel_distance = 24
	var/turf/path_override

	var/ai_timeout_time = 0
	var/ai_timeout_period = 5 SECONDS

	// Home turf
	var/next_home_search = 0
	var/home_search_delay = 5 SECONDS
	var/max_distance_from_home = 15
	var/home_locate_range = 15
	var/turf/home_turf

/mob/living/carbon/Xenomorph/proc/handle_ai_shot(obj/item/projectile/P)
	if(P.firer && P.firer != current_target)
		var/distance = get_dist(src, P.firer)
		if(distance > max_travel_distance)
			return

		SSxeno_pathfinding.calculate_path(src, P.firer, distance, src, CALLBACK(src, .proc/set_override_path))

		//calculate_path(get_turf(P.firer), distance, CALLBACK(src, .proc/set_override_path))

/mob/living/carbon/Xenomorph/proc/set_override_path(var/list/path)
	path_override = path

/mob/living/carbon/Xenomorph/proc/process_ai(delta_time, game_evaluation)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(!hive)
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
		if(current_target)
			resting = FALSE
			return TRUE

	if(!current_target)
		if(move_to_next_turf(home_turf, home_locate_range))
			if(get_dist(home_turf, src) <= 0 && !resting)
				lay_down()
			return TRUE
		else
			home_turf = null

		return TRUE

/atom/proc/xeno_ai_obstacle(var/mob/living/carbon/Xenomorph/X, direction)
	return INFINITY

// Called whenever an obstacle is encountered but xeno_ai_obstacle returned something else than infinite
// and now it is considered a valid path.
/atom/proc/xeno_ai_act(var/mob/living/carbon/Xenomorph/X)
	return

// Old way of calculating the path (Doesn't use a subsystem)
/*
/mob/living/carbon/Xenomorph/proc/calculate_path(var/turf/target, range, var/datum/callback/CB)
	// This proc can sleep if a callback is passed. Not recommended in process procs.
	set waitfor = FALSE

	if(!target)
		return null

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
						visited_nodes.Insert(index_to_check+1, neighbor)
						break

		if(CB)
			CHECK_TICK

	if(!prev[target])
		return null

	var/list/path = list()
	current_node = target
	while(current_node)
		if(current_node == loc)
			break
		path += current_node
		current_node = prev[current_node]

	if(!CB)
		return path
	else
		CB.Invoke(path)
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

/mob/living/carbon/Xenomorph/proc/move_to_next_turf(var/turf/T, var/max_range = ai_range)
	if(!T)
		return FALSE

	if(path_override)
		current_path = path_override
	else if(!current_path || (next_path_generation < world.time && current_target_turf != T))
		//current_path = calculate_path(T, max_range)
		if(!XENO_CALCULATING_PATH(src) || current_target_turf != T)
			SSxeno_pathfinding.calculate_path(src, T, ai_range, src, CALLBACK(src, .proc/set_path))
			current_target_turf = T
		next_path_generation = world.time + path_update_per_second



	// No possible path to target.
	if(!current_path && get_dist(T, src) > 0)
		return FALSE

	// We've reached our destination
	if(!length(current_path) || get_dist(T, src) <= 0)
		if(current_path == path_override)
			path_override = null
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
		var/distance = get_dist(src, H)
		if(distance > ai_range)
			continue

		if(distance < smallest_distance)
			smallest_distance = distance
			closest_human = H

	return closest_human

/mob/living/carbon/Xenomorph/proc/make_ai()
	if(!client)
		SSxeno_ai.add_ai(src)

/mob/living/carbon/Xenomorph/proc/remove_ai()
	SSxeno_ai.remove_ai(src)
